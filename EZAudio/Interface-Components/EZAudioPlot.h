//
//  SHAAudioPlot.h
//  SHAAudioExampleOSX
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "TargetConditionals.h"
#import "EZPlot.h"

@class EZAudio;

/**
 The default since of the rolling audio plot. TODO: In future release make this real-time adjustable.
 */
#define kEZAudioPlotHistoryBufferSize 1024

/**
 `EZAudioPlot`, a subclass of `EZPlot`, is a cross-platform (iOS and OSX) class that plots an audio waveform using Core Graphics. 
 
 The caller provides updates a constant stream of updated audio data in the `updateBuffer:withBufferSize:` function, which in turn will be plotted in one of the plot types:
    
 * Buffer (`EZPlotTypeBuffer`) - A plot that only consists of the current buffer and buffer size from the last call to `updateBuffer:withBufferSize:`. This looks similar to the default openFrameworks input audio example.
 * Rolling (`EZPlotTypeRolling`) - A plot that consists of a rolling history of values averaged from each buffer. This is the traditional waveform look.
 
 #Parent Methods and Properties#
 
 See EZPlot for full API methods and properties (colors, plot type, update function)
 
 */
@interface EZAudioPlot : EZPlot

@end
