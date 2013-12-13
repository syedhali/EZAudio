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
 `EZAudioPlot`, a subclass of `EZPlot`, is a cross-platform (iOS and OSX) class that plots an audio waveform using Core Graphics. The caller provides updates a constant stream of updated audio data in the `updateBuffer:withBufferSize:` function, which in turn will be plotted in one of the plot types:
    - Buffer
    - Rolling
 */
@interface EZAudioPlot : EZPlot

/**
 *  <#Description#>
 */
#define kEZAudioPlotHistoryBufferSize 1024

@end
