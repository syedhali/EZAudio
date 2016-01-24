//
//  AppDelegate.h
//  PassThrough
//
//  Created by Syed Haris Ali on 1/23/16.
//  Copyright © 2016 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//
// First import the EZAudio header
//
#include <EZAudio/EZAudio.h>

//------------------------------------------------------------------------------
#pragma mark - AppDelegate
//------------------------------------------------------------------------------

@interface AppDelegate : NSObject <EZMicrophoneDelegate, NSApplicationDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

@property (weak) IBOutlet NSWindow *window;

//
// The OpenGL based audio plot
//
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

//------------------------------------------------------------------------------

//
// The label used to display the microphone state
//
@property (nonatomic, weak) IBOutlet NSButton *microphoneSwitch;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

//
// Switches the plot drawing type between a buffer plot (visualizes the current
// stream of audio data from the update function) or a rolling plot (visualizes
// the audio data over time, this is the classic waveform look)
//
-(IBAction)changePlotType:(id)sender;

//------------------------------------------------------------------------------

//
// Toggles the microphone on and off. When the microphone is on it will send
// its delegate (aka this view controller) the audio data in various ways
// (check out the EZMicrophoneDelegate documentation for more details)
//
-(IBAction)toggleMicrophone:(id)sender;

@end

