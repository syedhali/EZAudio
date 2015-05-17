//
//  EZAudioPlot.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "EZAudioPlot.h"
#import "EZAudioUtilities.h"
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#include <pthread.h>

#if TARGET_OS_IPHONE
typedef CGRect EZRect;
#elif TARGET_OS_MAC
typedef NSRect EZRect;
#endif

typedef struct EZAudioPlotInfo
{
    CGPoint *points;
    UInt32  numberOfPoints;
} EZAudioPlotInfo;

@interface EZAudioPlot ()
@property (nonatomic, assign) EZAudioPlotInfo info;
@property (nonatomic) pthread_mutex_t lock;
@property (nonatomic, strong) CAShapeLayer *waveformLayer;
@end

@implementation EZAudioPlot

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    free(_info.points);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if(self)
    {
        [self initPlot];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initPlot];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (id)initWithFrame:(CGRect)frameRect
#elif TARGET_OS_MAC
- (id)initWithFrame:(NSRect)frameRect
#endif
{
    self = [super initWithFrame:frameRect];
    if(self)
    {
        [self initPlot];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (void)layoutSubviews
{
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.waveformLayer.frame = self.bounds;
    [CATransaction commit];
}
#elif TARGET_OS_MAC
- (void)layout
{
    [super layout];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.waveformLayer.frame = self.bounds;
    [CATransaction commit];
}
#endif

- (void)initPlot
{
    self.gain = 1.0;
    self.plotType = EZPlotTypeRolling;
    self.shouldMirror = NO;
    self.shouldFill = NO;
    self.waveformLayer = [CAShapeLayer layer];
    self.waveformLayer.frame = self.bounds; // TODO: account for resizing view
    self.waveformLayer.lineWidth = 1.0f;
    _info.points = calloc(kEZAudioPlotMaxHistoryBufferLength, sizeof(CGPoint));
    _info.numberOfPoints = 0;
#if TARGET_OS_IPHONE
    self.backgroundColor = [UIColor blackColor];
    self.color = [UIColor colorWithHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
#elif TARGET_OS_MAC
    self.backgroundColor = [NSColor blackColor];
    self.color = [NSColor colorWithCalibratedHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
    self.wantsLayer = YES;
#endif
    [self.layer addSublayer:self.waveformLayer];
    self.waveformLayer.fillColor = nil;
}

- (void)setBackgroundColor:(id)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.waveformLayer.backgroundColor = [backgroundColor CGColor];
}

- (void)setColor:(id)color
{
    [super setColor:color];
    self.waveformLayer.strokeColor = [color CGColor];
}

- (void)redraw
{
    EZRect frame = [self.waveformLayer frame];
    if(_info.numberOfPoints > 0)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        double xscale = (frame.size.width) / (float)_info.numberOfPoints;
        double halfHeight = floor(frame.size.height / 2.0);
        int deviceOriginFlipped = 1;
        CGAffineTransform xf = CGAffineTransformIdentity;
        xf = CGAffineTransformTranslate(xf, frame.origin.x , halfHeight + frame.origin.y);
        xf = CGAffineTransformScale(xf, xscale, deviceOriginFlipped * halfHeight);
        CGPathAddLines(path, &xf, _info.points, _info.numberOfPoints);
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.waveformLayer.path = path;
        [CATransaction commit];
        CGPathRelease(path);
    }
}

- (void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize
{
    // copy samples
    [self setSampleData:buffer length:bufferSize];
}

- (void)setSampleData:(float *)data length:(int)length
{
    CGPoint *points = _info.points;
    for (int i = 0; i < length; i++)
    {
        points[i].x = i;
        points[i].y = data[i] * self.gain;
    }
    _info.numberOfPoints = length;

    // redraw the plot if it's not yet optimized
    if (!self.optimizeForRealtimePlot)
    {
        [self redraw];
    }
}

//------------------------------------------------------------------------------

@end