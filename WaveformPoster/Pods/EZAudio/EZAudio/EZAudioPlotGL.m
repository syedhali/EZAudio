//
//  EZAudioPlotGL.m
//  EZAudio
//
//  Created by Syed Haris Ali on 11/22/13.
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

#import "EZAudioPlotGL.h"

#import "EZAudio.h"

#if TARGET_OS_IPHONE
  #import "EZAudioPlotGLKViewController.h"
@interface EZAudioPlotGL ()
@property (nonatomic,strong,readonly) EZAudioPlotGLKViewController *glViewController;
@end
#elif TARGET_OS_MAC
@interface EZAudioPlotGL (){
  
  // Flags indicating whether the plots have been instantiated
  BOOL _hasBufferPlotData;
  BOOL _hasRollingPlotData;
  
  // Vertex Array Buffers
  GLuint _bufferPlotVAB;
  GLuint _rollingPlotVAB;
  
  // Vertex Buffer Objects
  GLuint _bufferPlotVBO;
  GLuint _rollingPlotVBO;
  
  // Display Link
  CVDisplayLinkRef _displayLink;
  
  // Buffers size
  UInt32 _bufferPlotGraphSize;
  UInt32 _rollingPlotGraphSize;
  
  // Rolling History
  BOOL    _setMaxLength;
  float   *_scrollHistory;
  int     _scrollHistoryIndex;
  UInt32  _scrollHistoryLength;
  BOOL    _changingHistorySize;
  
  // Copied buffer data
  float *_copiedBuffer;
  UInt32 _copiedBufferSize;
  
}
@property (nonatomic,assign,readonly) EZAudioPlotGLDrawType drawingType;
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@end
#endif

@implementation EZAudioPlotGL
#if TARGET_OS_IPHONE
@synthesize glViewController = _glViewController;
#elif TARGET_OS_MAC
@synthesize baseEffect = _baseEffect;
#endif
@synthesize backgroundColor  = _backgroundColor;
@synthesize color            = _color;
@synthesize gain             = _gain;
@synthesize plotType         = _plotType;
@synthesize shouldFill       = _shouldFill;
@synthesize shouldMirror     = _shouldMirror;

#pragma mark - Initialization
-(id)init
{
  self = [super init];
  if (self) {
    [self initializeView];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self){
    [self initializeView];
  }
  return self;
}

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initializeView];
  }
  return self;
}

#pragma mark - Initialize Properties Here
-(void)initializeView {
#if TARGET_OS_IPHONE
  // Initialize the subview controller
  _glViewController = [[EZAudioPlotGLKViewController alloc] init];
  _glViewController.view.frame = self.bounds;
  [self insertSubview:self.glViewController.view atIndex:0];
#elif TARGET_OS_MAC
  _copiedBuffer = NULL;
#endif
  // Set the default properties
  self.gain       = 1.0;
  self.plotType   = EZPlotTypeBuffer;
#if TARGET_OS_IPHONE
  self.backgroundColor = [UIColor colorWithRed:0.796 green:0.749 blue:0.663 alpha:1];
  self.color = [UIColor colorWithRed:0.481 green:0.548 blue:0.637 alpha:1];
#elif TARGET_OS_MAC
  _scrollHistory       = NULL;
  _scrollHistoryLength = kEZAudioPlotDefaultHistoryBufferLength;
#endif
  self.shouldFill   = NO;
  self.shouldMirror = NO;
}

#pragma mark - Setters
-(void)setBackgroundColor:(id)backgroundColor {
  _backgroundColor = backgroundColor;
#if TARGET_OS_IPHONE
  self.glViewController.backgroundColor = backgroundColor;
#elif TARGET_OS_MAC
  [self _refreshWithBackgroundColor:backgroundColor];
#endif
}

-(void)setColor:(id)color {
  _color = color;
#if TARGET_OS_IPHONE
  self.glViewController.color = color;
#elif TARGET_OS_MAC
  [self _refreshWithColor:color];
#endif
}

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
-(void)setDrawingType:(EZAudioPlotGLDrawType)drawingType {
  CGLLockContext([[self openGLContext] CGLContextObj]);
  _drawingType = drawingType;
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
}
#endif

#if TARGET_OS_IPHONE
-(void)setGain:(float)gain {
  _gain = gain;
  self.glViewController.gain = gain;
}
#elif TARGET_OS_MAC
// Gain changed mac
#endif

#if TARGET_OS_IPHONE
-(void)setPlotType:(EZPlotType)plotType {
  _plotType = plotType;
  self.glViewController.plotType = plotType;
}
#elif TARGET_OS_MAC
// Plot type changed mac
#endif

-(void)setShouldFill:(BOOL)shouldFill {
  _shouldFill = shouldFill;
#if TARGET_OS_IPHONE
  self.glViewController.drawingType = shouldFill ? EZAudioPlotGLDrawTypeTriangleStrip : EZAudioPlotGLDrawTypeLineStrip;
#elif TARGET_OS_MAC
  // Fill flag changed mac
  self.drawingType = shouldFill ? EZAudioPlotGLDrawTypeTriangleStrip : EZAudioPlotGLDrawTypeLineStrip;
#endif
}

#if TARGET_OS_IPHONE
-(void)setShouldMirror:(BOOL)shouldMirror {
  _shouldMirror = shouldMirror;
  self.glViewController.shouldMirror = shouldMirror;
}
#elif TARGET_OS_MAC
// Mirror flag changed mac
#endif

#pragma mark - Get Samples
-(void)updateBuffer:(float *)buffer
     withBufferSize:(UInt32)bufferSize {
#if TARGET_OS_IPHONE
  [self.glViewController updateBuffer:buffer
                       withBufferSize:bufferSize];
#elif TARGET_OS_MAC
    
    
    
  if( _copiedBuffer == NULL ){
    _copiedBuffer = (float*)malloc(bufferSize*sizeof(float));
  }
  _copiedBufferSize = bufferSize;
  // Copy the buffer
  memcpy(_copiedBuffer,
         buffer,
         bufferSize*sizeof(float));
  // Draw based on plot type
  switch(_plotType) {
    case EZPlotTypeBuffer:
      [self _updateBufferPlotBufferWithAudioReceived:_copiedBuffer
                                      withBufferSize:_copiedBufferSize];
      break;
    case EZPlotTypeRolling:
      [self _updateRollingPlotBufferWithAudioReceived:_copiedBuffer
                                       withBufferSize:_copiedBufferSize];
      break;
    default:
      break;
  }
#endif
}

#pragma mark - OSX Specific GL Implementation
#if TARGET_OS_IPHONE

// Handled by the embedded GLKViewController

#elif TARGET_OS_MAC

#pragma mark - Awake
-(void)awakeFromNib {
  
  // Setup the base effect
  [self _setupBaseEffect];
  
  // Setup the OpenGL Pixel Format and Context
  [self _setupProfile];
  
  // Setup view
  [self _setupView];
  
}

-(void)_setupBaseEffect {
  self.baseEffect                  = [[GLKBaseEffect alloc] init];
  self.baseEffect.useConstantColor = GL_TRUE;
  self.baseEffect.constantColor    = GLKVector4Make(0.489, 0.34, 0.185, 1.0);
}

-(void)_setupProfile {
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
	
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	
	if (!pf)
	{
		NSLog(@"No OpenGL pixel format");
	}
  
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
  
  // Debug only
  CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
	
  self.pixelFormat   = pf;
  self.openGLContext = context;
}

-(void)_setupView {
  self.backgroundColor = [NSColor colorWithCalibratedRed: 0.796 green: 0.749 blue: 0.663 alpha: 1];
  self.color           = [NSColor colorWithCalibratedRed: 0.481 green: 0.548 blue: 0.637 alpha: 1];
}

#pragma mark - Prepare
-(void)prepareOpenGL {
  [super prepareOpenGL];
  
  GLint swapInt = 1;
  [self.openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
  
  ////////////////////////////////////////////////////////////////////////////
  //                          Setup VABs and VBOs                           //
  ////////////////////////////////////////////////////////////////////////////
  // Buffer
  glGenVertexArrays(1,&_bufferPlotVAB);
  glBindVertexArray(_bufferPlotVAB);
  glGenBuffers(1,&_bufferPlotVBO);
  glBindBuffer(GL_ARRAY_BUFFER,_bufferPlotVBO);
  
  // Rolling
  glGenVertexArrays(1,&_rollingPlotVAB);
  glBindVertexArray(_rollingPlotVAB);
  glGenBuffers(1,&_rollingPlotVBO);
  glBindBuffer(GL_ARRAY_BUFFER,_rollingPlotVBO);
  
  if( self.shouldFill ){
    glBindVertexArray(_rollingPlotVAB);
    glBindBuffer(GL_ARRAY_BUFFER,_rollingPlotVBO);
  }
  
    // Enable anti-aliasing
    glEnable(GL_MULTISAMPLE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glClearColor(0, 0, 0, 0);
    self.layer = nil;
    
  // Set the background color
  [self _refreshWithBackgroundColor:self.backgroundColor];
  [self _refreshWithColor:self.color];
  
  // Setup the display link (rendering loop)
  [self _setupDisplayLink];
  
}

-(void)_setupDisplayLink {
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback, (__bridge void *)(self));
	
	// Set the display link for the current renderer
	CGLContextObj     cglContext     = self.openGLContext.CGLContextObj;
	CGLPixelFormatObj cglPixelFormat = self.pixelFormat.CGLPixelFormatObj;
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
  
	// Activate the display link
	CVDisplayLinkStart(_displayLink);
  
  // Register to be notified when the window closes so we can stop the displaylink
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowWillClose:)
                                               name:NSWindowWillCloseNotification
                                             object:[self window]];
  
}

- (void) windowWillClose:(NSNotification*)notification
{
	// Stop the display link when the window is closing because default
	// OpenGL render buffers will be destroyed.  If display link continues to
	// fire without renderbuffers, OpenGL draw calls will set errors.
	
	CVDisplayLinkStop(_displayLink);
}

#pragma mark - Display Link Callback
// This is the renderer output callback function
static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink,
                                    const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime,
                                    CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut,
                                    void* displayLinkContext)
{
  CVReturn result = [(__bridge EZAudioPlotGL*)displayLinkContext getFrameForTime:outputTime];
  return result;
}

- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
  @autoreleasepool {
   	[self drawFrame];
  }
	return kCVReturnSuccess;
}

#pragma mark - Buffer Updating By Type
-(void)_updateBufferPlotBufferWithAudioReceived:(float*)buffer
                                 withBufferSize:(UInt32)bufferSize {
  
  // Lock
  CGLLockContext([[self openGLContext] CGLContextObj]);
  
  // Bind to buffer VBO
  glBindVertexArray(_bufferPlotVAB);
  glBindBuffer(GL_ARRAY_BUFFER,_bufferPlotVBO);
  
  // If starting with a VBO of half of our max size make sure we initialize it to anticipate
  // a filled graph (which needs 2 * bufferSize) to allocate its resources properly
  if( !_hasBufferPlotData && _drawingType == EZAudioPlotGLDrawTypeLineStrip ){
    EZAudioPlotGLPoint maxGraph[2*bufferSize];
    glBufferData(GL_ARRAY_BUFFER, sizeof(maxGraph), maxGraph, GL_STREAM_DRAW );
    _hasBufferPlotData = YES;
  }
  
  // Setup the buffer plot's graph size
  _bufferPlotGraphSize = [EZAudioPlotGL graphSizeForDrawingType:_drawingType
                                                  withBufferSize:bufferSize];
  
  // Setup the graph
  EZAudioPlotGLPoint graph[_bufferPlotGraphSize];
  
  // Fill in graph data
  [EZAudioPlotGL fillGraph:graph
              withGraphSize:_bufferPlotGraphSize
             forDrawingType:_drawingType
                 withBuffer:buffer
             withBufferSize:bufferSize
                   withGain:self.gain];
  
  // Update the drawing
  if( !_hasBufferPlotData ){
    glBufferData(GL_ARRAY_BUFFER, sizeof(graph) , graph, GL_STREAM_DRAW);
    _hasBufferPlotData = YES;
    
  }
  else {
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(graph), graph);
    
  }
  
  // Unlock
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
  
}

-(void)_updateRollingPlotBufferWithAudioReceived:(float*)buffer
                                  withBufferSize:(UInt32)bufferSize {
  
  // Lock
  CGLLockContext([[self openGLContext] CGLContextObj]);
  
  // Bind to rolling VBO
  glBindVertexArray(_rollingPlotVAB);
  glBindBuffer(GL_ARRAY_BUFFER,_rollingPlotVBO);
  
  // If starting with a VBO of half of our max size make sure we initialize it to anticipate
  // a filled graph (which needs 2 * bufferSize) to allocate its resources properly
  if( !_hasRollingPlotData ){
    EZAudioPlotGLPoint maxGraph[2*kEZAudioPlotMaxHistoryBufferLength];
    glBufferData(GL_ARRAY_BUFFER, sizeof(maxGraph), maxGraph, GL_STREAM_DRAW );
    _hasRollingPlotData = YES;
  }
  
  // Setup the plot
  _rollingPlotGraphSize = [EZAudioPlotGL graphSizeForDrawingType:_drawingType
                                                   withBufferSize:_scrollHistoryLength];
  
  // Fill the graph with data
  EZAudioPlotGLPoint graph[_rollingPlotGraphSize];

  
  
  // Update the scroll history datasource
  [EZAudio updateScrollHistory:&_scrollHistory
                    withLength:_scrollHistoryLength
                       atIndex:&_scrollHistoryIndex
                    withBuffer:buffer
                withBufferSize:bufferSize
          isResolutionChanging:&_changingHistorySize];
  
  // Fill in graph data
  [EZAudioPlotGL fillGraph:graph
              withGraphSize:_rollingPlotGraphSize
             forDrawingType:_drawingType
                 withBuffer:_scrollHistory
             withBufferSize:_scrollHistoryLength
                   withGain:self.gain];
  
  // Update the drawing
  if( !_hasRollingPlotData ){
    glBufferData(GL_ARRAY_BUFFER, sizeof(graph), graph, GL_STREAM_DRAW);
    _hasRollingPlotData = YES;
  }
  else {
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(graph), graph);
  }
  
  // Unlock
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
  
}

//#pragma mark - Render
-(void)drawFrame {
  
	// Avoid flickering during resize by drawing
	[[self openGLContext] makeCurrentContext];
  
  // Lock
	CGLLockContext([[self openGLContext] CGLContextObj]);
  
  // Draw frame
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
  
  if( _hasBufferPlotData || _hasRollingPlotData ){  
    // Plot either a buffer plot or a rolling plot
    switch(_plotType) {
      case EZPlotTypeBuffer:
        [self _drawBufferPlot];
        break;
      case EZPlotTypeRolling:
        [self _drawRollingPlot];
        break;
      default:
        break;
    }
  }

  // Flush and unlock
  CGLFlushDrawable([[self openGLContext] CGLContextObj]);
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
  
}

-(void)_drawBufferPlot {
  
  glBindVertexArray(_bufferPlotVAB);
  glBindBuffer(GL_ARRAY_BUFFER,_bufferPlotVBO);
  
  [self.baseEffect prepareToDraw];
  self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(0);
  
  // Enable the vertex data
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	// Define the vertex data size & layout
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(EZAudioPlotGLPoint), NULL);
  // Draw the triangle
  glDrawArrays(_drawingType,0,_bufferPlotGraphSize);
  
  // Mirrored
  if( self.shouldMirror ){
    [self.baseEffect prepareToDraw];
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(M_PI);
    
    // Enable the vertex data
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // Define the vertex data size & layout
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(EZAudioPlotGLPoint), NULL);
    // Draw the triangle
    glDrawArrays(_drawingType, 0, _bufferPlotGraphSize);
  }
  
}

-(void)_drawRollingPlot {
  
  glBindVertexArray(_rollingPlotVAB);
  glBindBuffer(GL_ARRAY_BUFFER,_rollingPlotVBO);
  
  [self.baseEffect prepareToDraw];
  self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(0);
  
  // Enable the vertex data
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  // Define the vertex data size & layout
  glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(EZAudioPlotGLPoint), NULL);
  // Draw the triangle
  glDrawArrays(_drawingType, 0,_rollingPlotGraphSize);
  
  // Mirrored
  if( self.shouldMirror ){
    [self.baseEffect prepareToDraw];
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(M_PI);
    
    // Enable the vertex data
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // Define the vertex data size & layout
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(EZAudioPlotGLPoint), NULL);
    // Draw the triangle
    glDrawArrays(_drawingType, 0,_rollingPlotGraphSize);
  }
  
}

-(void)drawRect:(NSRect)dirtyRect {
	[self drawFrame];
}

#pragma mark - Reshape
-(void)reshape {
	[super reshape];
	
	// We draw on a secondary thread through the display link. However, when
	// resizing the view, -drawRect is called on the main thread.
	// Add a mutex around to avoid the threads accessing the context
	// simultaneously when resizing.
	CGLLockContext([[self openGLContext] CGLContextObj]);
  
	// Get the view size in Points
	NSRect viewRectPoints = [self bounds];
  NSRect viewRectPixels = [self convertRectToBacking:viewRectPoints];
  
	// Set the new dimensions in our renderer
  glViewport(0, 0, viewRectPixels.size.width, viewRectPixels.size.height);
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

#pragma mark - Private Setters
-(void)_refreshWithBackgroundColor:(NSColor*)backgroundColor {
  CGLLockContext([[self openGLContext] CGLContextObj]);
  // Extract colors
  CGFloat red; CGFloat green; CGFloat blue; CGFloat alpha;
  [backgroundColor getRed:&red
                    green:&green
                     blue:&blue
                    alpha:&alpha];
  // Set them on the context
  glClearColor((GLclampf)red,(GLclampf)green,(GLclampf)blue,(GLclampf)alpha);
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

-(void)_refreshWithColor:(NSColor*)color {
  CGLLockContext([[self openGLContext] CGLContextObj]);
  // Extract colors
  CGFloat red; CGFloat green; CGFloat blue; CGFloat alpha;
  [color getRed:&red
          green:&green
           blue:&blue
          alpha:&alpha];
  // Set them on the base shader
  self.baseEffect.constantColor = GLKVector4Make((GLclampf)red,(GLclampf)green,(GLclampf)blue,(GLclampf)alpha);
  CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

#pragma mark - Cleanup
- (void) dealloc
{
	// Stop the display link BEFORE releasing anything in the view
  // otherwise the display link thread may call into the view and crash
  // when it encounters something that has been release
	CVDisplayLinkStop(_displayLink);
	CVDisplayLinkRelease(_displayLink);
  
  if( _copiedBuffer != NULL ){
    free( _copiedBuffer );
  }
}
#endif

#pragma mark - Adjust Resolution
-(int)setRollingHistoryLength:(int)historyLength {
#if TARGET_OS_IPHONE
  int result = [self.glViewController setRollingHistoryLength:historyLength];
  return result;
#elif TARGET_OS_MAC
  historyLength = MIN(historyLength,kEZAudioPlotMaxHistoryBufferLength);
  size_t floatByteSize = sizeof(float);
  _changingHistorySize = YES;
  if( _scrollHistoryLength != historyLength ){
    _scrollHistoryLength = historyLength;
  }
  _scrollHistory = realloc(_scrollHistory,_scrollHistoryLength*floatByteSize);
  if( _scrollHistoryIndex < _scrollHistoryLength ){
    memset(&_scrollHistory[_scrollHistoryIndex],
           0,
           (_scrollHistoryLength-_scrollHistoryIndex)*floatByteSize);
  }
  else {
    _scrollHistoryIndex = _scrollHistoryLength;
  }
  _changingHistorySize = NO;
  return historyLength;
#endif
  return kEZAudioPlotDefaultHistoryBufferLength;
}

-(int)rollingHistoryLength {
#if TARGET_OS_IPHONE
  return self.glViewController.rollingHistoryLength;
#elif TARGET_OS_MAC
  return _scrollHistoryLength;
#endif
}

#pragma mark - Clearing
-(void)clear {
#if TARGET_OS_IPHONE
  [self.glViewController clear];
#elif TARGET_OS_MAC
#endif
}

#pragma mark - Graph Methods
+(void)fillGraph:(EZAudioPlotGLPoint*)graph
   withGraphSize:(UInt32)graphSize
  forDrawingType:(EZAudioPlotGLDrawType)drawingType
      withBuffer:(float*)buffer
  withBufferSize:(UInt32)bufferSize
        withGain:(float)gain {
  if( drawingType == EZAudioPlotGLDrawTypeLineStrip ){
    // graph size = buffer size to stroke waveform
    for(int i = 0; i < graphSize; i++){
      float x = [EZAudio MAP:i
                      leftMin:0
                      leftMax:bufferSize
                     rightMin:-1.0
                     rightMax:1.0];
      graph[i].x = x;
      graph[i].y = gain*buffer[i];
    }
  }
  else if( drawingType == EZAudioPlotGLDrawTypeTriangleStrip ) {
    // graph size = 2 * buffer size to draw triangles and fill regions properly
    for(int i = 0; i < graphSize; i+=2){
      int bufferIndex = (int)[EZAudio MAP:i
                              leftMin:0
                              leftMax:graphSize
                              rightMin:0
                              rightMax:bufferSize];
      float x = [EZAudio MAP:bufferIndex
                      leftMin:0
                      leftMax:bufferSize
                     rightMin:-1.0
                     rightMax:1.0];
      graph[i].x = x;
      graph[i].y = 0.0f;
    }
    for(int i = 0; i < graphSize; i+=2){
      int bufferIndex = (int)[EZAudio
                              MAP:i
                              leftMin:0
                              leftMax:graphSize
                              rightMin:0
                              rightMax:bufferSize];
      float x = [EZAudio MAP:bufferIndex
                      leftMin:0
                      leftMax:bufferSize
                     rightMin:-1.0
                     rightMax:1.0];
      graph[i+1].x = x;
      graph[i+1].y = gain*buffer[bufferIndex];
    }
  }
}

+(UInt32)graphSizeForDrawingType:(EZAudioPlotGLDrawType)drawingType
                  withBufferSize:(UInt32)bufferSize {
  UInt32 graphSize = bufferSize;
  switch(drawingType) {
    case EZAudioPlotGLDrawTypeLineStrip:
      graphSize = bufferSize;
      break;
    case EZAudioPlotGLDrawTypeTriangleStrip:
      graphSize = 2*bufferSize;
      break;
    default:
      break;
  }
  return graphSize;
}

@end
