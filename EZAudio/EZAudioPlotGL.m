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

typedef struct
{
    BOOL                interpolated;
    EZPlotHistoryInfo  *historyInfo;
    EZAudioPlotGLPoint *points;
    UInt32              pointCount;
    GLuint              vbo;
#if !TARGET_OS_IPHONE
    GLuint              vab;
#endif
} EZAudioPlotGLInfo;

@interface EZAudioPlotGL () <EZAudioDisplayLinkDelegate>

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) EZAudioDisplayLink *displayLink;
@property (nonatomic, assign) EZAudioPlotGLInfo *info;
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
    [EZAudioUtilities freeHistoryInfo:self.info->historyInfo];
#if !TARGET_OS_IPHONE
    glDeleteVertexArrays(1, &self.info->vab);
#endif
    glDeleteBuffers(1, &self.info->vbo);
    free(self.info->points);
    self.baseEffect = nil;
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

- (instancetype)initWithFrame:(EZRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------

#if TARGET_OS_IPHONE
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
#elif TARGET_OS_MAC
- (instancetype)initWithFrame:(NSRect)frameRect
                  pixelFormat:(NSOpenGLPixelFormat *)format
{
    self = [super initWithFrame:frameRect pixelFormat:format];
    if (self)
    {
        [self setup];
    }
    return self;
}
#endif

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    //
    // Setup info data structure
    //
    self.info = (EZAudioPlotGLInfo *)malloc(sizeof(EZAudioPlotGLInfo));
    memset(self.info, 0, sizeof(EZAudioPlotGLInfo));
    
    //
    // Create points array
    //
    UInt32 pointCount = [self maximumRollingHistoryLength];
    self.info->points = (EZAudioPlotGLPoint *)calloc(sizeof(EZAudioPlotGLPoint), pointCount);
    self.info->pointCount = pointCount;
    
    //
    // Create the history data structure to hold the rolling data
    //
    self.info->historyInfo = [EZAudioUtilities historyInfoWithDefaultLength:[self defaultRollingHistoryLength]
                                                              maximumLength:[self maximumRollingHistoryLength]];
    
    //
    // Setup OpenGL properties
    //
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = YES;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.gain = 1.0f;
    
    //
    // Setup OpenGL specific stuff
    //
    [self setupOpenGL];
    
    //
    // Create the display link
    //
    self.displayLink = [EZAudioDisplayLink displayLinkWithDelegate:self];
    [self.displayLink start];
}

//------------------------------------------------------------------------------

- (void)setupOpenGL
{
#if TARGET_OS_IPHONE
    if (!self.context)
    {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    [EAGLContext setCurrentContext:self.context];
    self.drawableColorFormat   = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat   = GLKViewDrawableDepthFormat24;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    self.drawableMultisample   = GLKViewDrawableMultisample4X;
    self.opaque                = NO;
    self.enableSetNeedsDisplay = NO;
#elif TARGET_OS_MAC
    self.wantsLayer = YES;
    if (!self.pixelFormat)
    {
        NSOpenGLPixelFormatAttribute attrs[] =
        {
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAMultisample,
            NSOpenGLPFASampleBuffers,      1,
            NSOpenGLPFASamples,            4,
            NSOpenGLPFADepthSize,          24,
            NSOpenGLPFAOpenGLProfile,
            NSOpenGLProfileVersion3_2Core, 0
        };
        self.pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    }
#if DEBUG
    NSAssert(self.pixelFormat, @"Could not create OpenGL pixel format so context is not valid");
#endif
    self.openGLContext = [[NSOpenGLContext alloc] initWithFormat:self.pixelFormat
                                                    shareContext:nil];
    self.wantsBestResolutionOpenGLSurface = YES;
    [self.openGLContext lock];
    GLint swapInt = 1;
    [self.openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    glEnable(GL_MULTISAMPLE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glGenVertexArrays(1, &self.info->vab);
    glBindVertexArray(self.info->vab);
#endif
    glGenBuffers(1, &self.info->vbo);
    glBindBuffer(GL_ARRAY_BUFFER, self.info->vbo);
    glBufferData(GL_ARRAY_BUFFER,
                 self.info->pointCount * sizeof(EZAudioPlotGLPoint),
                 self.info->points,
                 GL_STREAM_DRAW);
    glClearColor(0.686f, 0.51f, 0.663f, 1.0f);
#if !TARGET_OS_IPHONE
    [self.openGLContext unlock];
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Updating The Plot
//------------------------------------------------------------------------------

- (void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize
{
    //
    // Update history
    //
    [EZAudioUtilities appendBuffer:buffer
                    withBufferSize:bufferSize
                     toHistoryInfo:self.info->historyInfo];

    //
    // Convert this data to point data
    //
    switch (self.plotType)
    {
        case EZPlotTypeBuffer:
            [self setSampleData:buffer
                         length:bufferSize];
            break;
        case EZPlotTypeRolling:
            [self setSampleData:self.info->historyInfo->buffer
                         length:self.info->historyInfo->bufferSize];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------

- (void)setSampleData:(float *)data length:(int)length
{
    int pointCount = self.shouldFill ? length * 2 : length;
    EZAudioPlotGLPoint *points = self.info->points;
    for (int i = 0; i < length; i++)
    {
        if (self.shouldFill)
        {
            points[i * 2].x = points[i * 2 + 1].x = i;
            points[i * 2].y = data[i];
            points[i * 2 + 1].y = 0.0f;
        }
        else
        {
            points[i].x = i;
            points[i].y = data[i];
        }
    }
    points[0].y = points[pointCount - 1].y = 0.0f;
    self.info->pointCount = pointCount;
    self.info->interpolated = self.shouldFill;
#if !TARGET_OS_IPHONE
    [self.openGLContext lock];
    glBindVertexArray(self.info->vab);
#endif
    glBindBuffer(GL_ARRAY_BUFFER, self.info->vbo);
    glBufferSubData(GL_ARRAY_BUFFER,
                    0,
                    pointCount * sizeof(EZAudioPlotGLPoint),
                    self.info->points);
#if !TARGET_OS_IPHONE
    [self.openGLContext unlock];
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Adjusting History Resolution
//------------------------------------------------------------------------------

- (int)rollingHistoryLength
{
    return self.info->historyInfo->bufferSize;
}

//------------------------------------------------------------------------------

- (int)setRollingHistoryLength:(int)historyLength
{
    self.info->historyInfo->bufferSize = MIN(EZAudioPlotDefaultMaxHistoryBufferLength, historyLength);
    return self.info->historyInfo->bufferSize;
}

//------------------------------------------------------------------------------
#pragma mark - Clearing The Plot
//------------------------------------------------------------------------------

- (void)clear
{
    //
    // TODO: clear plot!
    //
}

//------------------------------------------------------------------------------
#pragma mark - Drawing
//------------------------------------------------------------------------------

- (void)drawRect:(EZRect)rect
{
    [self redraw];
}

//------------------------------------------------------------------------------

- (void)redraw
{
#if !TARGET_OS_IPHONE
    [self.openGLContext makeCurrentContext];
    [self.openGLContext lock];
#endif
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    GLenum mode = self.info->interpolated ? GL_TRIANGLE_STRIP : GL_LINE_STRIP;
    float interpolatedFactor = self.info->interpolated ? 2.0f : 1.0f;
    float xscale = 2.0f / ((float)self.info->pointCount / interpolatedFactor);
    GLKMatrix4 transform = GLKMatrix4MakeTranslation(-1.0f, 0.0f, 0.0f);
    transform = GLKMatrix4Scale(transform, xscale, self.gain, 1.0f);
    self.baseEffect.transform.modelviewMatrix = transform;
#if !TARGET_OS_IPHONE
    glBindVertexArray(self.info->vab);
#endif
    glBindBuffer(GL_ARRAY_BUFFER, self.info->vbo);
    [self.baseEffect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(EZAudioPlotGLPoint),
                          NULL);
    glDrawArrays(mode, 0, self.info->pointCount);
    if (self.shouldMirror)
    {
        self.baseEffect.transform.modelviewMatrix = GLKMatrix4Rotate(transform, M_PI, 1.0f, 0.0f, 0.0f);
        [self.baseEffect prepareToDraw];
        glDrawArrays(mode, 0, self.info->pointCount);
    }
#if !TARGET_OS_IPHONE
    [self.openGLContext flushBuffer];
    [self.openGLContext unlock];
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

- (int)defaultRollingHistoryLength
{
    return EZAudioPlotDefaultHistoryBufferLength;
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
#if TARGET_OS_IPHONE
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        [self display];
    }
#elif TARGET_OS_MAC
    [self redraw];
#endif
}

//------------------------------------------------------------------------------

@end