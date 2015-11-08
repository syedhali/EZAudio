//
//  PlayFileViewController.h
//  EZAudioPlayFileExample
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

/**
 Here's the default audio file included with the example
 */
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

/**
 Using the EZOutputDataSource to provide output data to the EZOutput component. 
 */
@interface PlayFileViewController : NSViewController <NSOpenSavePanelDelegate,
                                                      EZAudioPlayerDelegate>

#pragma mark - Components
/**
 The EZAudioFile representing of the currently selected audio file
 */
@property (nonatomic, strong) EZAudioFile *audioFile;

/**
 The EZOutput component used to output the audio file's audio data.
 */
@property (nonatomic, strong) EZAudioPlayer *player;

/**
 The CoreGraphics based audio plot
 */
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

#pragma mark - UI Extras
/**
 A label to display the current file path with the waveform shown
 */
@property (nonatomic, weak) IBOutlet NSTextField *filePathLabel;

/**
 A checkbox button to that allows you to specify if the audio player should loop.
 */
@property (nonatomic, weak) IBOutlet NSButton *loopCheckboxButton;

/**
 A label to display the audio file's current position.
 */
@property (nonatomic, weak) IBOutlet NSTextField *positionLabel;

/**
 A slider to indicate the current frame position in the audio file
 */
@property (nonatomic, weak) IBOutlet NSSlider *positionSlider;

/**
 A label to display the value of the rolling history length of the audio plot.
 */
@property (nonatomic, weak) IBOutlet NSTextField *rollingHistoryLengthLabel;

/**
 A slider to adjust the rolling history length of the audio plot.
 */
@property (nonatomic, weak) IBOutlet NSSlider *rollingHistoryLengthSlider;

/**
 A slider to adjust the volume.
 */
@property (nonatomic, weak) IBOutlet NSSlider *volumeSlider;

/**
 A label to display the volume of the audio plot.
 */
@property (nonatomic, weak) IBOutlet NSTextField *volumeLabel;

/**
 A BOOL indicating whether or not we've reached the end of the file
 */
@property (nonatomic,assign) BOOL eof;

/**
 The microphone pop up button (contains the menu for choosing a microphone input)
 */
@property (nonatomic, weak) IBOutlet NSPopUpButton *outputDevicePopUpButton;

/**
 The microphone pop up button (contains the menu for choosing a microphone input)
 */
@property (nonatomic, weak) IBOutlet NSPopUpButton *outputChannelMappingPopUpButton;

#pragma mark - Actions
/**
 Switches the plot drawing type between a buffer plot (visualizes the current stream of audio data from the update function) or a rolling plot (visualizes the audio data over time, this is the classic waveform look)
 */
-(IBAction)changePlotType:(id)sender;

/**
 Changes the length of the rolling history of the audio plot.
 */
- (IBAction)changeRollingHistoryLength:(id)sender;

/**
 Switches the loop state on the audio player regarding whether the current playing audio file should loop back to the beginning when it finishes.
 */
- (IBAction)changeShouldLoop:(id)sender;

/**
 Changes the volume of the audio coming out of the EZOutput.
 */
- (IBAction)changeVolume:(id)sender;

/**
 Prompts the file manager and loads in a new audio file into the EZAudioFile representation.
 */
-(IBAction)openFile:(id)sender;

/**
 Begins playback if a file is loaded. Pauses if the file is already playing.
 */
-(IBAction)play:(id)sender;

/**
 Seeks to a specific frame in the audio file.
 */
-(IBAction)seekToFrame:(id)sender;

@end
