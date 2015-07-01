//
//  EZAudioPlotGL.m
//  EZAudio
//
//  Created by Syed Haris Ali on 11/22/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
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

#import "EZAudioPlotGL.h"
#import "EZAudioDisplayLink.h"
#import "EZAudioUtilities.h"
#import "EZAudioPlot.h"

@interface EZAudioPlotGL () <EZAudioDisplayLinkDelegate>

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) EZAudioDisplayLink *displayLink;
@property (nonatomic, assign) EZPlotHistoryInfo *historyInfo;
@property (nonatomic, assign) EZAudioPlotGLPoint *points;
@property (nonatomic, assign) UInt32 pointCount;

#if TARGET_OS_IPHONE

#elif TARGET_OS_MAC

#endif

@end

@implementation EZAudioPlotGL

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [self.displayLink stop];
    self.baseEffect = nil;
    [EZAudioUtilities freeHistoryInfo:self.historyInfo];
    free(self.points);
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithFrame:(CGRect)frame
                      context:(EAGLContext *)context
{
    self = [super initWithFrame:frame context:context];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    //
    // Make sure we have a valid OpenGL Context
    //
    if (!self.context)
    {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    [EAGLContext setCurrentContext:self.context];
    
    //
    // Create points array
    //
    
    //
    // Create the history data structure to hold the rolling data
    //
    self.historyInfo = [EZAudioUtilities historyInfoWithDefaultLength:[self defaultRollingHistoryLength]
                                                        maximumLength:[self maximumRollingHistoryLength]];
    
    //
    // Setup OpenGL properties
    //
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = YES;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
#if TARGET_OS_IPHONE
    self.drawableColorFormat   = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat   = GLKViewDrawableDepthFormat24;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    self.drawableMultisample   = GLKViewDrawableMultisample4X;
    self.opaque                = NO;
    self.enableSetNeedsDisplay = NO;
    
#elif TARGET_OS_MAC
    //
    // mac OpenGL setup
    //
#endif
    
    //
    // Create the display link
    //
    self.displayLink = [EZAudioDisplayLink displayLinkWithDelegate:self];
    [self.displayLink start];
}

//------------------------------------------------------------------------------
#pragma mark - Updating The Plot
//------------------------------------------------------------------------------

- (void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize
{
    //    //
    //    // Update history
    //    //
    //    [EZAudioUtilities appendBuffer:buffer
    //                    withBufferSize:bufferSize
    //                     toHistoryInfo:self.historyInfo];
    //
    //    //
    //    // Convert this data to point data
    //    //
    //    switch (self.plotType)
    //    {
    //        case EZPlotTypeBuffer:
    //            [self setSampleData:buffer
    //                         length:bufferSize];
    //            break;
    //        case EZPlotTypeRolling:
    //            [self setSampleData:self.historyInfo->buffer
    //                         length:self.historyInfo->bufferSize];
    //            break;
    //        default:
    //            break;
    //    }
}

//------------------------------------------------------------------------------

- (void)setSampleData:(float *)data length:(int)length
{
    //    //
    //    // Convert buffer to points
    //    //
    //    int pointCount = length * 2;
    //    EZAudioPlotGLPoint *points = self.points;
    //    for (int i = 0; i < length; i++)
    //    {
    //        EZAudioPlotGLPoint point     = points[i * 2];
    //        EZAudioPlotGLPoint nextPoint = points[i * 2 + 1];
    //        point.x = nextPoint.x = i;
    //        point.y = 0.0f;
    //        nextPoint.y = data[i];
    //    }
    //    points[0].y = points[pointCount - 1].y = 0.0f;
    //    self.pointCount = pointCount;
    //    glBindBuffer(GL_ARRAY_BUFFER, *self.vbo);
    //    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(self.points), self.points);
}

//------------------------------------------------------------------------------
#pragma mark - Drawing
//------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect
{
    //
    // Draw the background
    //
    glClearColor(0.686f, 0.51f, 0.663f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

- (int)defaultRollingHistoryLength
{
    return EZAudioPlotDefaultHistoryBufferLength;
}

//------------------------------------------------------------------------------

- (int)initialPointCount
{
    return 100;
}

//------------------------------------------------------------------------------

- (int)maximumRollingHistoryLength
{
    return EZAudioPlotDefaultMaxHistoryBufferLength;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLinkDelegate
//------------------------------------------------------------------------------

- (void)displayLinkNeedsDisplay:(EZAudioDisplayLink *)displayLink
{
    [self display];
}

//------------------------------------------------------------------------------

@end