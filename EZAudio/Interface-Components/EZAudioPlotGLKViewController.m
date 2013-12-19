//
//  EZAudioPlotGLKViewController.m
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

#if TARGET_OS_IPHONE

#import "EZAudioPlotGLKViewController.h"
#import "EZAudio.h"

@interface EZAudioPlotGLKViewController () {
  
  // Flags indicating whether the plots have been instantiated
  BOOL _hasBufferPlotData;
  BOOL _hasRollingPlotData;
  
  // The buffers
  GLuint _bufferPlotVBO;
  GLuint _rollingPlotVBO;
  
  // Buffers size
  UInt32 _bufferPlotGraphSize;
  UInt32 _rollingPlotGraphSize;
  
  // History buffer
  UInt32 _historyIndex;
  float  _historyBuffer[kEZAudioPlotHistoryBufferSize];
  
}
@end

@implementation EZAudioPlotGLKViewController
@synthesize baseEffect   = _baseEffect;
@synthesize context      = _context;
@synthesize drawingType  = _drawingType;
@synthesize plotType     = _plotType;
@synthesize shouldMirror = _shouldMirror;

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

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self){
    [self initializeView];
  }
  return self;
  
}
#pragma mark - Initialize Properties Here
-(void)initializeView {
  // Setup the base effect
  self.baseEffect = [[GLKBaseEffect alloc] init];
  self.baseEffect.useConstantColor = GL_TRUE;
  self.preferredFramesPerSecond = 60;
}

#pragma mark - View Did Load
-(void)viewDidLoad {
  [super viewDidLoad];
  
  // Setup the context
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  if (!self.context) {
    NSLog(@"Failed to create ES context");
  }
  else {
    EAGLContext.currentContext = self.context;
  }
  
  // Set the view's context
  GLKView *view            = (GLKView *)self.view;
  view.context             = self.context;
  view.drawableMultisample = GLKViewDrawableMultisample4X;
  
  // Generate both the buffer id references
  glGenBuffers(1, &_bufferPlotVBO);
  glGenBuffers(1, &_rollingPlotVBO);
  
  // Refresh color values
  [self _refreshWithBackgroundColor: self.backgroundColor];
  [self _refreshWithColor:           self.color];
  
  // Set the line width for the context
  glLineWidth(2.0);
  
}

#pragma mark - Get Samples
-(void)updateBuffer:(float *)buffer
     withBufferSize:(UInt32)bufferSize {
  
  // Make sure the update render loop is active
  if( self.paused ) self.paused = NO;
  
  // Draw based on plot type
  switch(_plotType) {
    case EZPlotTypeBuffer:
      [self _updateBufferPlotBufferWithAudioReceived:buffer
                                      withBufferSize:bufferSize];
      break;
    case EZPlotTypeRolling:
      [self _updateRollingPlotBufferWithAudioReceived:buffer
                                       withBufferSize:bufferSize];
      break;
    default:
      break;
  }
  
}

#pragma mark - Buffer Updating By Type
-(void)_updateBufferPlotBufferWithAudioReceived:(float*)buffer
                                 withBufferSize:(UInt32)bufferSize {
  
  glBindBuffer(GL_ARRAY_BUFFER, _bufferPlotVBO);
  
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
  
  if( !_hasBufferPlotData ){
    glBufferData( GL_ARRAY_BUFFER, sizeof(graph), graph, GL_STREAM_DRAW );
    _hasBufferPlotData = YES;
  }
  else {
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(graph), graph);
  }
  
}

-(void)_updateRollingPlotBufferWithAudioReceived:(float*)buffer
                                  withBufferSize:(UInt32)bufferSize {
  
  glBindBuffer(GL_ARRAY_BUFFER, _rollingPlotVBO);
  
  // If starting with a VBO of half of our max size make sure we initialize it to anticipate
  // a filled graph (which needs 2 * bufferSize) to allocate its resources properly
  if( !_hasRollingPlotData && _drawingType == EZAudioPlotGLDrawTypeLineStrip ){
    EZAudioPlotGLPoint maxGraph[2*kEZAudioPlotHistoryBufferSize];
    glBufferData(GL_ARRAY_BUFFER, sizeof(maxGraph), maxGraph, GL_STREAM_DRAW );
    _hasRollingPlotData = YES;
  }
  
  // Setup the plot
  _rollingPlotGraphSize = [EZAudioPlotGL graphSizeForDrawingType:_drawingType
                                                   withBufferSize:kEZAudioPlotHistoryBufferSize];
  
  // Fill the graph with data
  EZAudioPlotGLPoint graph[_rollingPlotGraphSize];
  
  // Update the history buffer
  _historyBuffer[_historyIndex] = [EZAudio RMS:buffer length:bufferSize];
  if( _historyIndex == kEZAudioPlotHistoryBufferSize - 1 ){
    _historyIndex = 0;
    for(int i = 0; i < kEZAudioPlotHistoryBufferSize; i++) _historyBuffer[i] = 0.0f;
  }
  else {
    _historyIndex++;
  }
  
  // Fill in graph data
  [EZAudioPlotGL fillGraph:graph
     withGraphSize:_rollingPlotGraphSize
    forDrawingType:_drawingType
        withBuffer:_historyBuffer
    withBufferSize:kEZAudioPlotHistoryBufferSize
                   withGain:self.gain];
  
  // Update the drawing
  if( !_hasRollingPlotData ){
    glBufferData( GL_ARRAY_BUFFER, sizeof(graph) , graph, GL_STREAM_DRAW );
    _hasRollingPlotData = YES;
  }
  else {
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(graph), graph);
  }
  
}

#pragma mark - Drawing
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  if( _hasBufferPlotData || _hasRollingPlotData ){
    // Prepare the effect for drawing
    [self.baseEffect prepareToDraw];
    
    // Clear the context
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Plot either a buffer plot or a rolling plot
    switch(_plotType) {
      case EZPlotTypeBuffer:
        [self _drawBufferPlotWithView:view
                           drawInRect:rect];
        break;
      case EZPlotTypeRolling:
        [self _drawRollingPlotWithView:view
                            drawInRect:rect];
        break;
      default:
        break;
        
    }
  }
}

#pragma mark - Private Drawing
-(void)_drawBufferPlotWithView:(GLKView*)view drawInRect:(CGRect)rect {
  if( _hasBufferPlotData ){
    
    glBindBuffer(GL_ARRAY_BUFFER, _bufferPlotVBO);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(EZAudioPlotGLPoint), NULL);
    
    // Normal plot
    glPushMatrix();
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(0);
    glDrawArrays(_drawingType, 0, _bufferPlotGraphSize);
    glPopMatrix();
    
    if( self.shouldMirror ){
      // Mirrored plot
      [self.baseEffect prepareToDraw];
      glPushMatrix();
      self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(M_PI);
      glDrawArrays(_drawingType, 0, _bufferPlotGraphSize);
      glPopMatrix();
    }
    
  }
}

-(void)_drawRollingPlotWithView:(GLKView*)view drawInRect:(CGRect)rect {
  if( _hasRollingPlotData ){
    
    // Normal plot
    glBindBuffer(GL_ARRAY_BUFFER, _rollingPlotVBO);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(EZAudioPlotGLPoint), NULL);
    
    // Normal plot
    glPushMatrix();
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(0);
    glDrawArrays(_drawingType, 0, _rollingPlotGraphSize);
    glPopMatrix();
    
    if( self.shouldMirror ){
      // Mirrored plot
      [self.baseEffect prepareToDraw];
      glPushMatrix();
      self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeXRotation(3.14159265359);
      glDrawArrays(_drawingType, 0, _rollingPlotGraphSize);
      glPopMatrix();
    }
    
  }
}

#pragma mark - Setters
-(void)setBackgroundColor:(UIColor *)backgroundColor {
  // Set the background color
  _backgroundColor = backgroundColor;
  // Refresh background color (map to GL vector)
  [self _refreshWithBackgroundColor:backgroundColor];
}

-(void)setColor:(UIColor *)color {
  // Set the color
  _color = color;
  // Refresh the color (map to GL vector)
  [self _refreshWithColor:color];
}

#pragma mark - Private Setters
-(void)_refreshWithBackgroundColor:(UIColor*)backgroundColor {
  // Extract colors
  CGFloat red; CGFloat green; CGFloat blue; CGFloat alpha;
  [backgroundColor getRed:&red
                    green:&green
                     blue:&blue
                    alpha:&alpha];
  // Set them on the context
  glClearColor((GLclampf)red,(GLclampf)green,(GLclampf)blue,(GLclampf)alpha);
}

-(void)_refreshWithColor:(UIColor*)color {
  // Extract colors
  CGFloat red; CGFloat green; CGFloat blue; CGFloat alpha;
  [color getRed:&red
          green:&green
           blue:&blue
          alpha:&alpha];
  // Set them on the base shader
  self.baseEffect.constantColor = GLKVector4Make((GLclampf)red,(GLclampf)green,(GLclampf)blue,(GLclampf)alpha);
}

@end

#elif TARGET_OS_MAC

#endif
