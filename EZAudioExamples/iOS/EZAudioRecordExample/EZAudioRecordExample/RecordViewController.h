//
//  RecordViewController.h
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

// Import EZAudio header
#import "EZAudio.h"

// Import AVFoundation to play the file (will save EZAudioFile and EZOutput for separate example)
#import <AVFoundation/AVFoundation.h>

// By default this will record a file to the application's documents directory (within the application's sandbox)
#define kAudioFilePath @"EZAudioTest.caf"

@interface RecordViewController : UIViewController <AVAudioPlayerDelegate,EZMicrophoneDelegate>

/**
 Use a OpenGL based plot to visualize the data coming in
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic,assign) BOOL isRecording;

/**
 The microphone component
 */
@property (nonatomic,strong) EZMicrophone *microphone;

/**
 The recorder component
 */
@property (nonatomic,strong) EZRecorder *recorder;

#pragma mark - Actions
/**
 Stops the recorder and starts playing whatever has been recorded.
 */
-(IBAction)playFile:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleMicrophone:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleRecording:(id)sender;

@end
