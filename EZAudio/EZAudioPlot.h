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

#import "TargetConditionals.h"
#import "EZPlot.h"

@class EZAudio;

#define kEZAudioPlotMaxHistoryBufferLength (8192)

#define kEZAudioPlotDefaultHistoryBufferLength (1024)

/**
 `EZAudioPlot`, a subclass of `EZPlot`, is a cross-platform (iOS and OSX) class that plots an audio waveform using Core Graphics. 
 
 The caller provides updates a constant stream of updated audio data in the `updateBuffer:withBufferSize:` function, which in turn will be plotted in one of the plot types:
    
 * Buffer (`EZPlotTypeBuffer`) - A plot that only consists of the current buffer and buffer size from the last call to `updateBuffer:withBufferSize:`. This looks similar to the default openFrameworks input audio example.
 * Rolling (`EZPlotTypeRolling`) - A plot that consists of a rolling history of values averaged from each buffer. This is the traditional waveform look.
 
 #Parent Methods and Properties#
 
 See EZPlot for full API methods and properties (colors, plot type, update function)
 
 */
@interface EZAudioPlot : EZPlot
{
    CGPoint *plotData;
    UInt32   plotLength;
}

#pragma mark - Adjust Resolution
///-----------------------------------------------------------
/// @name Adjusting The Resolution
///-----------------------------------------------------------

/**
 Sets the length of the rolling history display. Can grow or shrink the display up to the maximum size specified by the kEZAudioPlotMaxHistoryBufferLength macro. Will return the actual set value, which will be either the given value if smaller than the kEZAudioPlotMaxHistoryBufferLength or kEZAudioPlotMaxHistoryBufferLength if a larger value is attempted to be set. 
 @param  historyLength The new length of the rolling history buffer.
 @return The new value equal to the historyLength or the kEZAudioPlotMaxHistoryBufferLength.
 */
-(int)setRollingHistoryLength:(int)historyLength;

/**
 Provides the length of the rolling history buffer
 *  @return An int representing the length of the rolling history buffer
 */
-(int)rollingHistoryLength;

#pragma mark - Subclass Methods

/**
 <#Description#>
 @param data   <#theplotData description#>
 @param length <#length description#>
 */
-(void)setSampleData:(float *)data
              length:(int)length;

@end
