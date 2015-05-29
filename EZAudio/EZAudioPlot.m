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

#if TARGET_OS_IPHONE
typedef CGRect EZRect;
#elif TARGET_OS_MAC
typedef NSRect EZRect;
#endif

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
static CVReturn EZAudioPlotDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                               const CVTimeStamp *now,
                                               const CVTimeStamp *outputTime,
                                               CVOptionFlags flagsIn,
                                               CVOptionFlags *flagsOut,
                                               void   *displayLinkContext)
{
    EZAudioPlot *plot = (__bridge EZAudioPlot*)displayLinkContext;
    [plot redraw];
    return kCVReturnSuccess;
}
#endif

@interface EZAudioPlot ()
#if TARGET_OS_IPHONE
@property (nonatomic, strong) CADisplayLink *displayLink;
#elif TARGET_OS_MAC
@property (nonatomic, assign) CVDisplayLinkRef displayLink;
#endif
@property (nonatomic, assign) CGPoint *points;
@property (nonatomic, assign) UInt32 pointCount;
@end

@implementation EZAudioPlot

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    free(self.history);
    free(self.points);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initPlot];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
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
    if (self)
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
    [self redraw];
    [CATransaction commit];
}
#elif TARGET_OS_MAC
- (void)layout
{
    [super layout];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.waveformLayer.frame = self.bounds;
    [self redraw];
    [CATransaction commit];
}
#endif

- (void)initPlot
{
    self.centerYAxis = YES;
    self.optimizeForRealtimePlot = YES;
    self.gain = 1.0;
    self.plotType = EZPlotTypeRolling;
    self.shouldMirror = NO;
    self.shouldFill = NO;
    
    // Setup history window
    self.history = (EZPlotHistoryInfo *)malloc(sizeof(EZPlotHistoryInfo));
    self.history->buffer = calloc(kEZAudioPlotMaxHistoryBufferLength, sizeof(float));
    self.history->bufferSize = 1024;
    self.history->changingHistorySize = NO;
    self.history->index = 0;
    
    self.waveformLayer = [CAShapeLayer layer];
    self.waveformLayer.frame = self.bounds; // TODO: account for resizing view
    self.waveformLayer.lineWidth = 1.0f;
    self.waveformLayer.fillColor = nil;
    self.waveformLayer.backgroundColor = nil;
    
    self.points = calloc(kEZAudioPlotMaxHistoryBufferLength, sizeof(CGPoint));
    self.pointCount = 0;
#if TARGET_OS_IPHONE
    self.backgroundColor = [UIColor blackColor];
    self.color = [UIColor colorWithHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
#elif TARGET_OS_MAC
    self.backgroundColor = [NSColor blackColor];
    self.color = [NSColor colorWithCalibratedHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
    self.wantsLayer = YES;
#endif
    [self.layer addSublayer:self.waveformLayer];
}

- (void)addDisplayLink
{
#if TARGET_OS_IPHONE
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(redraw)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
#elif TARGET_OS_MAC
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink,
                                   EZAudioPlotDisplayLinkCallback,
                                   (__bridge void *)(self));
    CVDisplayLinkStart(self.displayLink);
#endif
}

- (void)removeDisplayLink
{
#if TARGET_OS_IPHONE
    [self.displayLink invalidate];
    self.displayLink = nil;
#elif TARGET_OS_MAC
    CVDisplayLinkStop(self.displayLink);
    CVDisplayLinkRelease(self.displayLink);
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

//- (CGPoint)waveformLayerCenter
//{
//    CGPoint anchorPoint = self.waveformLayer.anchorPoint;
//    CGFloat x = [EZAudioUtilities MAP:anchorPoint.x
//                              leftMin:0.0f
//                              leftMax:1.0f
//                             rightMin:0.0f
//                             rightMax:self.frame.size.width];
//    CGFloat y = [EZAudioUtilities MAP:anchorPoint.y
//                              leftMin:0.0f
//                              leftMax:1.0f
//                             rightMin:0.0f
//                             rightMax:self.frame.size.height];
//    return CGPointMake(x, y);
//}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setBackgroundColor:(id)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.layer.backgroundColor = [backgroundColor CGColor];
}

- (void)setColor:(id)color
{
    [super setColor:color];
    self.waveformLayer.strokeColor = [color CGColor];
}

- (void)setOptimizeForRealtimePlot:(BOOL)optimizeForRealtimePlot
{
    _optimizeForRealtimePlot = optimizeForRealtimePlot;
    [self removeDisplayLink];
    if (optimizeForRealtimePlot)
    {
        [self addDisplayLink];
    }
}

- (void)setShouldFill:(BOOL)shouldFill
{
    [super setShouldFill:shouldFill];
    self.waveformLayer.fillColor = shouldFill ? [self.color CGColor] : nil;
}

//- (void)setWaveformLayerCenter:(CGPoint)waveformLayerCenter
//{
//    CGFloat x = [EZAudioUtilities MAP:waveformLayerCenter.x
//                              leftMin:0.0f
//                              leftMax:self.frame.size.width
//                             rightMin:0.0f
//                             rightMax:1.0f];
//    CGFloat y = [EZAudioUtilities MAP:waveformLayerCenter.y
//                              leftMin:0.0f
//                              leftMax:self.frame.size.height
//                             rightMin:0.0f
//                             rightMax:1.0f];
//    self.waveformLayer.anchorPoint = CGPointMake(x, y);
//}

#warning RESET THIS TRANSFORM FOR iOS ZOOMING
//- (void)setTransform:(CGAffineTransform)transform
//{
////    [super setTransform:transform];
//    transform.d = 1.0f;
//    CATransform3D transform3D = CATransform3DMakeAffineTransform(transform);
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    self.waveformLayer.transform = transform3D;
//    [CATransaction commit];
//    
//    [super setTransform:transform];
//}

//------------------------------------------------------------------------------
#pragma mark - Drawing
//------------------------------------------------------------------------------

- (void)redraw
{
    EZRect frame = [self.waveformLayer frame];
    if (self.pointCount > 0)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        double xscale = (frame.size.width) / (float)self.pointCount;
        double halfHeight = floor(frame.size.height / 2.0);
        int deviceOriginFlipped = 1;
        CGAffineTransform xf = CGAffineTransformIdentity;
        CGFloat translateY = !self.centerYAxis ?: halfHeight + frame.origin.y;
        xf = CGAffineTransformTranslate(xf, 0.0, translateY);
        xf = CGAffineTransformScale(xf, xscale, deviceOriginFlipped * halfHeight);
        CGPathAddLines(path, &xf, self.points, self.pointCount);
        if (self.shouldMirror)
        {
            xf = CGAffineTransformScale(xf, 1.0, -1.0);
            CGPathAddLines(path, &xf, self.points, self.pointCount);
        }
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.waveformLayer.path = path;
        [CATransaction commit];
        CGPathRelease(path);
    }
}

//------------------------------------------------------------------------------
#pragma mark - Update
//------------------------------------------------------------------------------

- (void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize
{
    // update the scroll history datasource
    float rms = [EZAudioUtilities RMS:buffer length:bufferSize];
    [EZAudioUtilities appendValue:rms
                  toScrollHistory:self.history->buffer
            withScrollHistorySize:self.history->bufferSize];
    
    // copy samples
    switch (self.plotType)
    {
        case EZPlotTypeBuffer:
            [self setSampleData:buffer
                         length:bufferSize];
            break;
        case EZPlotTypeRolling:
            [self setSampleData:self.history->buffer
                         length:self.history->bufferSize];
            break;
        default:
            break;
    }
    
    // update drawing
    if (!self.optimizeForRealtimePlot)
    {
        [self redraw];
    }
}

//------------------------------------------------------------------------------

- (void)setSampleData:(float *)data length:(int)length
{
    // append to buffer type
    CGPoint *points = self.points;
    for (int i = 0; i < length; i++)
    {
        points[i].x = i;
        points[i].y = data[i] * self.gain;
    }
    points[0].y = points[length-1].y = 0.0f;
    self.pointCount = length;
}

//------------------------------------------------------------------------------

@end