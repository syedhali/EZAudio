//
//  ViewController.h
//  PassThrough
//
//  Created by Syed Haris Ali on 1/23/16.
//  Copyright © 2016 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// First import the EZAudio header
//
#include <EZAudio/EZAudio.h>

//------------------------------------------------------------------------------
#pragma mark - ViewController
//------------------------------------------------------------------------------

@interface ViewController : UIViewController <EZMicrophoneDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

//
// The OpenGL based audio plot
//
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

//------------------------------------------------------------------------------

//
// The UILabel used to display whether the microphone is on or off
//
@property (nonatomic, weak) IBOutlet UILabel *microphoneTextLabel;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

//
// Switches the plot drawing type between a buffer plot (visualizes the current
// stream of audio data from the update function) or a rolling plot (visualizes
// the audio data over time, this is the classic waveform look)
//
- (IBAction)changePlotType:(id)sender;

//------------------------------------------------------------------------------

//
// Toggles the microphone on and off. When the microphone is on it will send its
// delegate (aka this view controller) the audio data in various ways (check out
// the EZMicrophoneDelegate documentation for more details);
//
- (IBAction)toggleMicrophone:(id)sender;

@end

