//
//  PlayFileViewController.h
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 12/16/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

// Import EZAudio header
#import "EZAudio.h"

/**
 Here's the default audio file included with the example
 */
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

/**
 Using the EZOutputDataSource to provide output data to the EZOutput component.
 */
@interface PlayFileViewController : UIViewController <EZAudioFileDelegate,EZOutputDataSource>

#pragma mark - Components
/**
 The EZAudioFile representing of the currently selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;

/**
 The CoreGraphics based audio plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;

#pragma mark - UI Extras
/**
 A label to display the current file path with the waveform shown
 */
@property (nonatomic,weak) IBOutlet UILabel *filePathLabel;

/**
 A slider to indicate the current frame position in the audio file
 */
@property (nonatomic,weak) IBOutlet UISlider *framePositionSlider;

/**
 A BOOL indicating whether or not we've reached the end of the file
 */
@property (nonatomic,assign) BOOL eof;

#pragma mark - Actions
/**
 Switches the plot drawing type between a buffer plot (visualizes the current stream of audio data from the update function) or a rolling plot (visualizes the audio data over time, this is the classic waveform look)
 */
-(IBAction)changePlotType:(id)sender;

/**
 Begins playback if a file is loaded. Pauses if the file is already playing.
 */
-(IBAction)play:(id)sender;

/**
 Seeks to a specific frame in the audio file.
 */
-(IBAction)seekToFrame:(id)sender;

@end
