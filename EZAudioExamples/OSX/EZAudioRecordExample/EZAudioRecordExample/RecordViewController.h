//
//  RecordViewController.h
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/1/13.
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

#import <Cocoa/Cocoa.h>

// Import EZAudio header
#import "EZAudio.h"

// By default this will record a file to /Users/YOUR_USERNAME/Documents/test.caf
#define kAudioFilePath [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/test.m4a"]

//------------------------------------------------------------------------------
#pragma mark - RecordViewController
//------------------------------------------------------------------------------

/**
 We will allow this view controller to act as an EZMicrophoneDelegate. This is how we listen for the microphone callback.
 */
@interface RecordViewController : NSViewController <EZAudioPlayerDelegate,
                                                    EZMicrophoneDelegate,
                                                    EZRecorderDelegate>

/**
 The label used to display the current time for recording/playback in the top left
 */
@property (nonatomic, weak) IBOutlet NSTextField *currentTimeLabel;

//------------------------------------------------------------------------------

/**
 Use a OpenGL based plot to visualize the data coming in
 */
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *recordingAudioPlot;

//------------------------------------------------------------------------------

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic, assign) BOOL isRecording;

//------------------------------------------------------------------------------

/**
 The microphone component
 */
@property (nonatomic, strong) EZMicrophone *microphone;

//------------------------------------------------------------------------------

/**
 The switch used to toggle the microphone on/off
 */
@property (nonatomic, weak) IBOutlet NSButton *microphoneSwitch;

//------------------------------------------------------------------------------

/**
 The audio player that will play the recorded file
 */
@property (nonatomic, strong) EZAudioPlayer *player;

//------------------------------------------------------------------------------

/**
 The recorder component
 */
@property (nonatomic, strong) EZRecorder *recorder;

//------------------------------------------------------------------------------

/**
 The second audio plot used on the top right to display the current playing audio
 */
@property (nonatomic, weak) IBOutlet EZAudioPlot *playingAudioPlot;

//------------------------------------------------------------------------------

/**
 The button the user taps to play the recorded audio file
 */
@property (nonatomic, weak) IBOutlet NSButton *playButton;

//------------------------------------------------------------------------------

/**
 The label used to display the audio player play state
 */
@property (nonatomic, weak) IBOutlet NSTextField *playingStateLabel;

//------------------------------------------------------------------------------

/**
 The switch used to toggle the recording on/off
 */
@property (nonatomic, weak) IBOutlet NSButton *recordSwitch;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 Stops the recorder and starts playing whatever has been recorded.
 */
- (IBAction)playFile:(id)sender;

//------------------------------------------------------------------------------

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
- (IBAction)toggleMicrophone:(id)sender;

//------------------------------------------------------------------------------

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
- (IBAction)toggleRecording:(id)sender;

@end
