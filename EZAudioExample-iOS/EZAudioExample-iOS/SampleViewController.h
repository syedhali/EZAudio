//
//  SampleViewController.h
//  SHAAudioExample-iOS
//
//  Created by Syed Haris Ali on 11/22/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "EZAudio.h"

@interface SampleViewController : UIViewController <EZMicrophoneDelegate>

#pragma mark - Example Components
/**
 *	@brief	The audio plot to visualize the samples
 */
@property (nonatomic,weak) IBOutlet EZPlot *audioPlot;

/**
 *	@brief	The microphone object used to fetch the audio samples. It's important to
 *          declare this as a strong property!
 */
@property (nonatomic,strong) EZMicrophone *microphone;

#pragma mark - Interface
/**
 *	@brief	Switch to toggle between filling in the waveform
 */
@property (nonatomic,weak) IBOutlet UISwitch *fillSwitch;

/**
 *	@brief	The label that displays the gain value
 */
@property (nonatomic,weak) IBOutlet UILabel *gainLabel;

/**
 *	@brief	Gain control to increase and decrease the waveform's peaks
 */
@property (nonatomic,weak) IBOutlet UISlider *gainSlider;

/**
 *	@brief	Switch to toggle between a mirrored waveform (traditional mirror over axis plot)
 */
@property (nonatomic,weak) IBOutlet UISwitch *mirrorSwitch;

/**
 *	@brief	The view containing the option controls
 */
@property (nonatomic,weak) IBOutlet UIView *optionsView;

/**
 *	@brief	Segmented control to switch between buffer or rolling waveform
 */
@property (nonatomic,weak) IBOutlet UISegmentedControl *waveformSegmentedControl;

#pragma mark - Events
/**
 *	@brief	Fill switch value changed
 */
-(IBAction)changedFillSwitchValue:(id)sender;

/**
 *	@brief	Gain slider value changed
 */
-(IBAction)changedGainSliderValue:(id)sender;

/**
 *	@brief	Mirror switch value changed
 */
-(IBAction)changedMirrorSwitchValue:(id)sender;

/**
 *	@brief	Waveform type segument control's value changed
 */
-(IBAction)changedWaveformSegmentedControl:(id)sender;

/**
 *	@brief	Method to start and stop the microphone
 */
-(IBAction)toggleMicrophone:(id)sender;

/**
 *	@brief	Method to toggle the options in and out of view
 */
-(IBAction)toggleOptions:(id)sender;

@end
