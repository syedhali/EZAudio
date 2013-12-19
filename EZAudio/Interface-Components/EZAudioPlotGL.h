//
//  EZAudioPlotGL.h
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

#import "TargetConditionals.h"
#import "EZPlot.h"

#if TARGET_OS_IPHONE
#import <GLKit/GLKit.h>
@class EZAudioPlotGLKViewController;
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#import <GLKit/GLKit.h>
#import <OpenGL/gl3.h>
#import <QuartzCore/CVDisplayLink.h>
#endif

#pragma mark - Enumerations
/**
 Constant drawing types wrapping around the OpenGL equivalents. In the audio drawings the line strip will be the stroked graph while the triangle will provide the filled equivalent.
 */
typedef NS_ENUM(NSUInteger,EZAudioPlotGLDrawType){
  /**
   *  Maps to the OpenGL constant for a line strip, which for the audio graph will correspond to a stroked drawing (no fill).
   */
  EZAudioPlotGLDrawTypeLineStrip     = GL_LINE_STRIP,
  /**
   *  Maps to the OpenGL constant for a triangle strip, which for the audio graph will correspond to a filled drawing.
   */
  EZAudioPlotGLDrawTypeTriangleStrip = GL_TRIANGLE_STRIP
};

#pragma mark - Structures
/**
 A structure describing a 2D point (x,y) in space for an audio plot.
 */
typedef struct {
  GLfloat x;
  GLfloat y;
} EZAudioPlotGLPoint;

/**
 EZAudioPlotGL is a subclass of either the EZPlot on iOS or an NSOpenGLView on OSX. I apologize ahead of time for the weirdness in the docs for this class, but I had to do a bit of hackery to get a universal namespace for something works on both iOS and OSX without any additional components. The EZAudioPlotGL provides an the same utilities and interface as the EZAudioPlot with the added benefit of being GPU-accelerated. This is the recommended plot to use on iOS devices to get super fast real-time drawings of audio streams. For the methods and properties below I've included notes on the bottom just indicating which OS they correspond to. In most (if not all) use cases you can just refer to the EZPlot documentation to see which custom properties can be setup. There update function is the same as the EZPlot as well: `updateBuffer:withBufferSize:`
 */
#if TARGET_OS_IPHONE
@interface EZAudioPlotGL : EZPlot
#elif TARGET_OS_MAC
@interface EZAudioPlotGL : NSOpenGLView
#endif

#if TARGET_OS_IPHONE

// Inherited from EZPlot

#elif TARGET_OS_MAC

#pragma mark - Properties
///-----------------------------------------------------------
/// @name Customizing The Plot's Appearance
///-----------------------------------------------------------
/**
 The default background color of the plot. For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is black.
 */
@property (nonatomic,strong) id backgroundColor;

/**
 The default color of the plot's data (i.e. waveform, y-axis values). For iOS the color is specified as a UIColor while for OSX the color is an NSColor. The default value on both platforms is red.
 */
@property (nonatomic,strong) id color;

/**
 The plot's gain value, which controls the scale of the y-axis values. The default value of the gain is 1.0f and should always be greater than 0.0f.
 */
@property (nonatomic,assign,setter=setGain:) float gain;

/**
 The type of plot as specified by the `EZPlotType` enumeration (i.e. a buffer or rolling plot type).
 */
@property (nonatomic,assign,setter=setPlotType:) EZPlotType plotType;

/**
 A BOOL indicating whether or not to fill in the graph. A value of YES will make a filled graph (filling in the space between the x-axis and the y-value), while a value of NO will create a stroked graph (connecting the points along the y-axis).
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
///-----------------------------------------------------------
/// @name Shared OpenGL Methods
///-----------------------------------------------------------
/**
 Converts a float array to an array of EZAudioPlotGLPoint structures that hold the (x,y) values the OpenGL buffer needs to properly plot its points.
 @param graph       A pointer to the array that should hold the EZAudioPlotGLPoint structures.
 @param graphSize   The size (or length) of the array with the EZAudioPlotGLPoint structures.
 @param drawingType The EZAudioPlotGLDrawType constant defining whether the plot should interpolate between points for a triangle strip (filled waveform) or not for a line strip (stroked waveform)
 @param buffer      The float array holding the audio data
 @param bufferSize  The size of the float array holding the audio data
 @param gain        The gain (always greater than 0.0) to apply to the amplitudes (y-values) of the graph. Y-values can only range from -1.0 to 1.0 so any value that's greater will be rounded to -1.0 or 1.0.
 */
+(void)fillGraph:(EZAudioPlotGLPoint*)graph
   withGraphSize:(UInt32)graphSize
  forDrawingType:(EZAudioPlotGLDrawType)drawingType
      withBuffer:(float*)buffer
  withBufferSize:(UInt32)bufferSize
        withGain:(float)gain;

/**
 Determines the proper size of a graph given a EZAudioPlotGLDrawType (line strip or triangle strip) and the size of the incoming buffer. Triangle strips require interpolating between points so the buffer becomes 2*bufferSize
 @param drawingType The EZAudioPlotGLDraw type (line strip or triangle strip)
 @param bufferSize  The size of the float array holding the audio data coming in.
 @return A Int32 representing the proper graph size that should be used to account for any necessary interpolating between points.
 */
+(UInt32)graphSizeForDrawingType:(EZAudioPlotGLDrawType)drawingType
                  withBufferSize:(UInt32)bufferSize;

@end
