//
//  AppDelegate.h
//  EZAudioCoreGraphicsWaveformExample
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

@property (assign) IBOutlet NSWindow *window;

//------------------------------------------------------------------------------
#pragma mark - Components
//------------------------------------------------------------------------------

//
// The CoreGraphics based audio plot
//
@property (nonatomic, weak) IBOutlet EZAudioPlot *audioPlot;

//
// The microphone
//
@property (nonatomic, strong) EZMicrophone *microphone;

//
// The microphone pop up button (contains the menu for choosing a microphone
// input)
//
@property (nonatomic, weak) IBOutlet NSPopUpButton *microphoneInputPopUpButton;

//
// The microphone input channel pop up button (contains the menu for choosing a
// microphone input channel)
//
@property (nonatomic, weak) IBOutlet NSPopUpButton *microphoneInputChannelPopUpButton;

//
// The checkbox button used to turn the microphone off/on
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

//
// Toggles the microphone on and off. When the microphone is on it will send its
// delegate (aka this view controller) the audio data in various ways (check out
// the EZMicrophoneDelegate documentation for more details)
//
-(IBAction)toggleMicrophone:(id)sender;

@end
