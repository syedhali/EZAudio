//
//  OpenGLWaveformViewController.m
//  EZAudioOpenGLWaveformExample
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

#import "OpenGLWaveformViewController.h"

//------------------------------------------------------------------------------
#pragma mark - OpenGLWaveformViewController
//------------------------------------------------------------------------------

@implementation OpenGLWaveformViewController

//------------------------------------------------------------------------------
#pragma mark - Customize the Audio Plot
//------------------------------------------------------------------------------

- (void)awakeFromNib
{
    //
    // Customizing the audio plot's look
    //
    // Background color
    self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];

    // Waveform color
    self.audioPlot.color = [NSColor colorWithCalibratedRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];

    // Plot type
    self.audioPlot.plotType = EZPlotTypeBuffer;

    //
    // Create the microphone
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    //
    // Start the microphone
    //
    [self.microphone startFetchingAudio];
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void) reloadMicrophoneInputPopUpButtonMenu
{
    NSArray *inputDevices = [EZAudioDevice inputDevices];
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *defaultInputMenuItem;
    for (EZAudioDevice *device in inputDevices)
    {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:device.name
                                                      action:@selector(changedInput:)
                                               keyEquivalent:@""];
        item.representedObject = device;
        item.target = self;
        [menu addItem:item];

        // If this device is the same one the microphone is using then
        // we will use this menu item as the currently selected item
        // in the microphone input popup button's list of items. For instance,
        // if you are connected to an external display by default the external
        // display's microphone might be used instead of the mac's built in
        // mic.
        if ([device isEqual:self.microphone.device])
        {
            defaultInputMenuItem = item;
        }
    }
    self.microphoneInputPopUpButton.menu = menu;

    //
    // Set the selected device to the current selection on the
    // microphone input popup button
    //
    [self.microphoneInputPopUpButton selectItem:defaultInputMenuItem];
}

//------------------------------------------------------------------------------

- (void) reloadMicrophoneInputChannelPopUpButtonMenu
{
    NSMenu *menu = [[NSMenu alloc] init];
    for (int i = 0; i < self.microphone.device.inputChannelCount; i++)
    {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@(i).stringValue
                                                      action:nil
                                               keyEquivalent:@""];
        [menu addItem:item];
    }
    self.microphoneInputChannelPopUpButton.menu = menu;
    [self.microphoneInputChannelPopUpButton selectItemAtIndex:0];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)changedInput:(id)sender
{
    EZAudioDevice *device = [sender representedObject];
    [self.microphone setDevice:device];
}

//------------------------------------------------------------------------------

- (void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegment];
    switch(selectedSegment)
    {
        case 0:
            [self drawBufferPlot];
            break;
        case 1:
            [self drawRollingPlot];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------

- (void)toggleMicrophone:(id)sender
{
    switch([sender state])
    {
        case NSOffState:
            [self.microphone stopFetchingAudio];
            break;
        case NSOnState:
            [self.microphone startFetchingAudio];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Action Extensions
//------------------------------------------------------------------------------

//
// Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
//
- (void)drawBufferPlot
{
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldMirror = NO;
    self.audioPlot.shouldFill = NO;
}

//------------------------------------------------------------------------------

//
// Give the classic mirrored, rolling waveform look
//
- (void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
- (void)microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^{
    // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        NSInteger channel = [weakSelf.microphoneInputChannelPopUpButton indexOfSelectedItem];
        [weakSelf.audioPlot updateBuffer:buffer[channel] withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    // The AudioStreamBasicDescription of the microphone stream. This is useful when configuring the EZRecorder or telling another component what audio format type to expect.
    // Here's a print function to allow you to inspect it a little easier
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone
     hasBufferList:(AudioBufferList *)bufferList
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder or EZOutput. Say whattt...
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone
     changedDevice:(EZAudioDevice *)device
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // Set up the microphone input popup button's items to select
        // between different microphone inputs
        //
        [self reloadMicrophoneInputPopUpButtonMenu];

        //
        // Set up the microphone input popup button's items to select
        // between different microphone input channels
        //
        [self reloadMicrophoneInputChannelPopUpButtonMenu];
    });
}

//------------------------------------------------------------------------------

@end
