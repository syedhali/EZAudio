//
//  EZAudioPlotGL.h
//  EZAudioExampleiOS
//
//  Created by Syed Haris Ali on 11/22/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "TargetConditionals.h"
#import "EZPlot.h"

#if TARGET_OS_IPHONE

#import <GLKit/GLKit.h>
@class EZAudioPlotGLKViewController;

/**

 */
@interface EZAudioPlotGL : EZPlot

#pragma mark - Properties
/**
 An embedded OpenGL ES View Controller to perform the GL drawing. There's currently a bug that won't just allow GLKView subclasses so this is a work around.
 */
@property (nonatomic,strong,readonly) EZAudioPlotGLKViewController *glViewController;

#elif TARGET_OS_MAC

#import <Cocoa/Cocoa.h>
#import <GLKit/GLKit.h>
#import <OpenGL/gl3.h>
#import <QuartzCore/CVDisplayLink.h>

/**

 */
@interface EZAudioPlotGL : NSOpenGLView

#endif

#pragma mark - Enumerations
/**
 *  <#Description#>
 */
typedef NS_ENUM(NSUInteger,EZAudioPlotGLDrawType){
  /**
   *  <#Description#>
   */
  EZAudioPlotGLDrawTypeLineStrip     = GL_LINE_STRIP,
  /**
   *  <#Description#>
   */
  EZAudioPlotGLDrawTypeTriangleStrip = GL_TRIANGLE_STRIP
};

#pragma mark - Structures
/**
 *  <#Description#>
 */
typedef struct {
  GLfloat x;
  GLfloat y;
} EZAudioPlotGLPoint;

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC

#pragma mark - Properties
///-----------------------------------------------------------
/// @name Customizing The Plot's Appearance
///-----------------------------------------------------------
/**
 The default background color of the plot. For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is black.
 */
@property (nonatomic,strong) NSColor *backgroundColor;

/**
 *  <#Description#>
 */
@property (nonatomic,strong) GLKBaseEffect *baseEffect;

/**
 The default color of the plot's data (i.e. waveform, y-axis values). For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is red.
 */
@property (nonatomic,strong) NSColor *color;

/**
 *  <#Description#>
 */
@property (nonatomic,assign,readonly) EZAudioPlotGLDrawType drawingType;

/**
 The plot's gain value, which controls the scale of the y-axis values. The default value of the gain is 1.0f and should always be greater than 0.0f.
 */
@property (nonatomic,assign,setter=setGain:) float gain;

/**
 The type of plot as specified by the `EZPlotType` enumeration (i.e. a buffer or rolling plot type).
 */
@property (nonatomic,assign,setter=setPlotType:) EZPlotType plotType;

/**
 A boolean indicating whether or not to fill in the graph. A value of YES will make a filled graph (filling in the space between the x-axis and the y-value), while a value of NO will create a stroked graph (connecting the points along the y-axis).
 */
@property (nonatomic,assign,setter=setShouldFill:) BOOL shouldFill;

/**
 A boolean indicating whether the graph should be rotated along the x-axis to give a mirrored reflection. This is typical for audio plots to produce the classic waveform look. A value of YES will produce a mirrored reflection of the y-values about the x-axis, while a value of NO will only plot the y-values.
 */
@property (nonatomic,assign,setter=setShouldMirror:) BOOL shouldMirror;

#pragma mark - Get Samples
///-----------------------------------------------------------
/// @name Updating The Plot
///-----------------------------------------------------------
/**
 Updates the plot with the new buffer data and tells the view to redraw itself. Caller will provide a float array with the values they expect to see on the y-axis. The plot will internally handle mapping the x-axis and y-axis to the current view port, any interpolation for fills effects, and mirroring.
 @param buffer     A float array of values to map to the y-axis.
 @param bufferSize The size of the float array that will be mapped to the y-axis.
 @warning The bufferSize is expected to be the same, constant value once initial triggered. For plots using OpenGL a vertex buffer object will be allocated with a maximum buffersize of (2 * the initial given buffer size) to account for any interpolation necessary for filling in the graph. Updates use the glBufferSubData(...) function, which will crash if the buffersize exceeds the initial maximum allocated size.
 */
-(void)updateBuffer:(float *)buffer
     withBufferSize:(UInt32)bufferSize;

#endif

#pragma mark - Shared Methods
/**
 *  <#Description#>
 *
 *  @param graph       <#graph description#>
 *  @param graphSize   <#graphSize description#>
 *  @param drawingType <#drawingType description#>
 *  @param buffer      <#buffer description#>
 *  @param bufferSize  <#bufferSize description#>
 *  @param gain        <#gain description#>
 */
+(void)fillGraph:(EZAudioPlotGLPoint*)graph
   withGraphSize:(UInt32)graphSize
  forDrawingType:(EZAudioPlotGLDrawType)drawingType
      withBuffer:(float*)buffer
  withBufferSize:(UInt32)bufferSize
        withGain:(float)gain;

/**
 *  <#Description#>
 *
 *  @param drawingType <#drawingType description#>
 *  @param bufferSize  <#bufferSize description#>
 *
 *  @return <#return value description#>
 */
+(UInt32)graphSizeForDrawingType:(EZAudioPlotGLDrawType)drawingType
                  withBufferSize:(UInt32)bufferSize;


@end
