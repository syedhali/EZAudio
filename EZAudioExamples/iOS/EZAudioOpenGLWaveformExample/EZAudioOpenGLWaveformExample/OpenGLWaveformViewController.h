//
//  OpenGLWaveformViewController.h
//  EZAudioOpenGLWaveformExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

// Import EZAudio header
#import "EZAudio.h"

@interface OpenGLWaveformViewController : UIViewController <EZMicrophoneDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate>

//------------------------------------------------------------------------------
#pragma mark - Components
//------------------------------------------------------------------------------

/**
 The OpenGL based audio plot
 */
@property (nonatomic, weak) IBOutlet EZAudioPlot *audioPlot;

/**
 The microphone component
 */
@property (nonatomic, strong) EZMicrophone *microphone;

/**
 The button at the bottom displaying the currently selected microphone input
 */
@property (nonatomic, weak) IBOutlet UIButton *microphoneInputToggleButton;

/**
 The microphone input picker view to display the different microphone input sources
 */
@property (nonatomic, weak) IBOutlet UIPickerView *microphoneInputPickerView;

/**
 The microphone input picker view's top layout constraint (we use this to hide the control)
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *microphoneInputPickerViewTopConstraint;

/**
 The text label displaying "Microphone On" or "Microphone Off"
 */
@property (nonatomic, weak) IBOutlet UILabel *microphoneTextLabel;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 Switches the plot drawing type between a buffer plot (visualizes the current stream of audio data from the update function) or a rolling plot (visualizes the audio data over time, this is the classic waveform look)
 */
- (IBAction)changePlotType:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
- (IBAction)toggleMicrophonePickerView:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
- (IBAction)toggleMicrophone:(id)sender;

@end
