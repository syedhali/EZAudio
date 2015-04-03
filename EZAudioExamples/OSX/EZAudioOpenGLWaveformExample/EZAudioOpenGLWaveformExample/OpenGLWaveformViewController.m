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

-(void)awakeFromNib
{
    /*
    Customizing the audio plot's look
    */
    // Background color
    self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed:0.569f
                                                               green:0.820f
                                                                blue:0.478f
                                                               alpha:1.0f];
    
    // Waveform color
    self.audioPlot.color = [NSColor colorWithCalibratedRed:1.0f
                                                     green:1.0f
                                                      blue:1.0f
                                                     alpha:1.0f];
    
    // Plot type
    self.audioPlot.plotType = EZPlotTypeBuffer;
    
    // Set length
    self.audioPlot.rollingHistoryLength = 1024;
  
    /*
    Start the microphone
    */
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    [self.microphone startFetchingAudio];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

-(void)changePlotType:(id)sender
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

-(void)toggleMicrophone:(id)sender
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

/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input eample)
 */
-(void)drawBufferPlot
{
    // change the plot type to the buffer plot
    self.audioPlot.plotType = EZPlotTypeBuffer;
    
    // don't mirror over the x-axis
    self.audioPlot.shouldMirror = NO;
    
    // don't fill
    self.audioPlot.shouldFill = NO;
}

//------------------------------------------------------------------------------

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot
{
    // change the plot type to the rolling plot
    self.audioPlot.plotType = EZPlotTypeRolling;
    
    // fill
    self.audioPlot.shouldFill = YES;
    
    // mirror about the x-axis
    self.audioPlot.shouldMirror = YES;
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
  
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    __weak OpenGLWaveformViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),^{
    // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

-(void)microphone:(EZMicrophone *)microphone
hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    // The AudioStreamBasicDescription of the microphone stream. This is useful when configuring the EZRecorder or telling another component what audio format type to expect.
    // Here's a print function to allow you to inspect it a little easier
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder or EZOutput. Say whattt...
}

//------------------------------------------------------------------------------

@end
