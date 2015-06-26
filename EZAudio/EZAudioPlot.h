//
//  EZAudioPlot.h
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

#import <QuartzCore/QuartzCore.h>
#import "TargetConditionals.h"
#import "EZAudioUtilities.h"
#import "EZPlot.h"

@class EZAudio;

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

/**
 The default value used for the maximum rolling history buffer length of any EZAudioPlot.
 @deprecated This constant is deprecated starting in version 0.2.0.
 @note Please use EZAudioPlotDefaultMaxHistoryBufferLength instead.
 */
FOUNDATION_EXPORT UInt32 const kEZAudioPlotMaxHistoryBufferLength __attribute__((deprecated));

/**
 The default value used for the default rolling history buffer length of any EZAudioPlot.
 @deprecated This constant is deprecated starting in version 0.2.0.
 @note Please use EZAudioPlotDefaultHistoryBufferLength instead.
 */
FOUNDATION_EXPORT UInt32 const kEZAudioPlotDefaultHistoryBufferLength __attribute__((deprecated));

/**
 The default value used for the default rolling history buffer length of any EZAudioPlot.
 */
FOUNDATION_EXPORT UInt32 const EZAudioPlotDefaultHistoryBufferLength;

/**
 The default value used for the maximum rolling history buffer length of any EZAudioPlot.
 */
FOUNDATION_EXPORT UInt32 const EZAudioPlotDefaultMaxHistoryBufferLength;

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlotWaveformLayer
//------------------------------------------------------------------------------

@interface EZAudioPlotWaveformLayer : CAShapeLayer
@end

/**
 `EZAudioPlot`, a subclass of `EZPlot`, is a cross-platform (iOS and OSX) class that plots an audio waveform using Core Graphics. 
 
 The caller provides updates a constant stream of updated audio data in the `updateBuffer:withBufferSize:` function, which in turn will be plotted in one of the plot types:
    
 * Buffer (`EZPlotTypeBuffer`) - A plot that only consists of the current buffer and buffer size from the last call to `updateBuffer:withBufferSize:`. This looks similar to the default openFrameworks input audio example.
 * Rolling (`EZPlotTypeRolling`) - A plot that consists of a rolling history of values averaged from each buffer. This is the traditional waveform look.
 
 #Parent Methods and Properties#
 
 See EZPlot for full API methods and properties (colors, plot type, update function)
 
 */
@interface EZAudioPlot : EZPlot

/**
 A BOOL that allows optimizing the audio plot's drawing for real-time displays. Since the update function may be updating the plot's data very quickly (over 60 frames per second) this property will throttle the drawing calls to be 60 frames per second (or whatever the screen rate is). Specifically, it disables implicit path change animations on the `waveformLayer` and sets up a display link to render 60 fps (audio updating the plot at 44.1 kHz causes it to re-render 86 fps - far greater than what is needed for a visual display).
 */
@property (nonatomic, assign) BOOL shouldOptimizeForRealtimePlot;

//------------------------------------------------------------------------------

/**
 A BOOL indicating whether the plot should center itself vertically.
 */
@property (nonatomic, assign) BOOL shouldCenterYAxis;

//------------------------------------------------------------------------------

/**
 An `EZAudioPlotWaveformLayer` that is used to render the actual waveform. By switching the drawing code to Core Animation layers in version 0.2.0 most work, specifically the compositing step, is now done on the GPU. Hence, multiple EZAudioPlot instances can be used simultaneously with very low CPU overhead so these are now practical for table and collection views.
 */
@property (nonatomic, strong) EZAudioPlotWaveformLayer *waveformLayer;

//------------------------------------------------------------------------------
#pragma mark - Adjust Resolution
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Adjusting The Resolution
///-----------------------------------------------------------

/**
 The length of the rolling history display. Can grow or shrink the display up to the maximum size specified by the kEZAudioPlotMaxHistoryBufferLength macro. Will return the actual set value, which will be either the given value if smaller than the kEZAudioPlotMaxHistoryBufferLength or kEZAudioPlotMaxHistoryBufferLength if a larger value is attempted to be set.
 @param  historyLength The new length of the rolling history buffer.
 @return The new value equal to the historyLength or the kEZAudioPlotMaxHistoryBufferLength.
 */
-(int)setRollingHistoryLength:(int)historyLength;

//------------------------------------------------------------------------------

/**
 Provides the length of the rolling history buffer
 *  @return An int representing the length of the rolling history buffer
 */
-(int)rollingHistoryLength;

//------------------------------------------------------------------------------
#pragma mark - Subclass Methods
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Subclass Methods
///-----------------------------------------------------------

/**
 <#Description#>
 @param points     <#points description#>
 @param pointCount <#pointCount description#>
 @param rect       <#rect description#>
 @return <#return value description#>
 */
- (CGPathRef)createPathWithPoints:(CGPoint *)points
                       pointCount:(UInt32)pointCount
                           inRect:(EZRect)rect;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @return <#return value description#>
 */
- (int)defaultRollingHistoryLength;

//------------------------------------------------------------------------------

/**
 <#Description#>
 @return <#return value description#>
 */
- (int)initialPointCount;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @return <#return value description#>
 */
- (int)maximumRollingHistoryLength;

//------------------------------------------------------------------------------

/**
 <#Description#>
 */
- (void)redraw;

//------------------------------------------------------------------------------

/**
 Main method used to copy the sample data from the source buffer and update the 
 plot. Subclasses can overwrite this method for custom behavior.
 @param data   A float array of the sample data. Subclasses should copy this data to a separate array to avoid threading issues.
 @param length The length of the float array as an int.
 */
-(void)setSampleData:(float *)data
              length:(int)length;

//------------------------------------------------------------------------------

@end