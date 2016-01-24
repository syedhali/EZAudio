//
//  AppDelegate.m
//  FFT
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

#import "AppDelegate.h"

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;

//------------------------------------------------------------------------------
#pragma mark - AppDelegate (Implementation)
//------------------------------------------------------------------------------

@implementation AppDelegate

//------------------------------------------------------------------------------
#pragma mark - Customize the Audio Plot
//------------------------------------------------------------------------------

- (void)awakeFromNib
{
    //
    // Setup time domain audio plot
    //
    self.audioPlotTime.plotType = EZPlotTypeBuffer;
    
    //
    // Setup frequency domain audio plot
    //
    self.audioPlotFreq.shouldFill = YES;
    self.audioPlotFreq.plotType = EZPlotTypeBuffer;
    self.audioPlotFreq.shouldCenterYAxis = NO;
    
    //
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    //
    // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
    //
    self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTViewControllerFFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                           delegate:self];
    
    //
    // Start the mic
    //
    [self.microphone startFetchingAudio];
}

//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    //
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlotTime updateBuffer:buffer[0]
                              withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTDelegate
//------------------------------------------------------------------------------

- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    float maxFrequency = [fft maxFrequency];
    NSString *noteName = [EZAudioUtilities noteNameStringForFrequency:maxFrequency
                                                        includeOctave:YES];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.maxFrequencyLabel.stringValue = [NSString stringWithFormat:@"Highest Note: %@,\nFrequency: %.2f", noteName, maxFrequency];
        [weakSelf.audioPlotFreq updateBuffer:fftData withBufferSize:(UInt32)bufferSize];
    });
}

//------------------------------------------------------------------------------

@end
