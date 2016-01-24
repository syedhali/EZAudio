//
//  AppDelegate.h
//  WaveformFromFile
//
//  Created by Syed Haris Ali on 12/1/13.
//  Updated by Syed Haris Ali on 1/23/16.
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

//
// Here's the default audio file included with the example
//
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

//------------------------------------------------------------------------------
#pragma mark - AppDelegate
//------------------------------------------------------------------------------

@interface AppDelegate : NSObject <NSApplicationDelegate, NSOpenSavePanelDelegate>

//------------------------------------------------------------------------------
#pragma mark - Components
//------------------------------------------------------------------------------

//
// The EZAudioFile representing of the currently selected audio file
//
@property (nonatomic,strong) EZAudioFile *audioFile;

//------------------------------------------------------------------------------

//
// The CoreGraphics based audio plot
//
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlot;

//
// A label to display the current file path with the waveform shown
//
@property (nonatomic,weak) IBOutlet NSTextField *filePathLabel;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

//
// Prompts the file manager and loads in a new audio file into the
// EZAudioFile representation.
//
-(IBAction)openFile:(id)sender;

//------------------------------------------------------------------------------

//
// Shows how to take a snapshot of the Core Graphics based waveform and save
// it to the file path: ~/Documents/waveform.png
//
-(IBAction)snapshot:(id)sender;

//------------------------------------------------------------------------------

@end

