//
//  RecordViewController.h
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Import EZAudio header
#import "EZAudio.h"

// By default this will record a file to /Users/YOUR_USERNAME/Documents/test.caf
#define kAudioFilePath [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/test.caf"]

/**
 We will allow this view controller to act as an EZMicrophoneDelegate. This is how we listen for the microphone callback.
 */
@interface RecordViewController : NSViewController <EZMicrophoneDelegate>

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
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleMicrophone:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleRecording:(id)sender;

@end
