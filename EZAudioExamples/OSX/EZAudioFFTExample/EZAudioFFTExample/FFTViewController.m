//
//  FFTViewController.m
//  EZAudioFFTExample
//
//  Created by Syed Haris Ali on 12/30/13.
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

#import "FFTViewController.h"

@interface FFTViewController ()
@property (nonatomic, assign) COMPLEX_SPLIT *A;
@property (nonatomic, assign) FFTSetup      FFTSetup;
@property (nonatomic, assign) vDSP_Length   log2n;
@property (nonatomic, assign) BOOL          isFFTSetup;
@end

@implementation FFTViewController

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    vDSP_destroy_fftsetup(self.FFTSetup);
    free(self.A);
}

//------------------------------------------------------------------------------
#pragma mark - Customize the Audio Plot
//------------------------------------------------------------------------------

- (void)awakeFromNib
{
    //
    // Setup time domain audio plot
    //
    self.audioPlotTime.backgroundColor = [NSColor colorWithCalibratedRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];
    self.audioPlotTime.color           = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlotTime.shouldFill      = YES;
    self.audioPlotTime.shouldMirror    = YES;
    self.audioPlotTime.plotType        = EZPlotTypeRolling;
    
    //
    // Setup frequency domain audio plot
    //
    self.audioPlotFreq.backgroundColor   = [NSColor colorWithCalibratedRed: 0.984 green: 0.471 blue: 0.525 alpha: 1];
    self.audioPlotFreq.color             = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlotFreq.shouldFill        = YES;
    self.audioPlotFreq.plotType          = EZPlotTypeBuffer;
    self.audioPlotFreq.shouldCenterYAxis = NO;
  
    //
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self
                                         startsImmediately:YES];
}

//------------------------------------------------------------------------------
#pragma mark - FFT
//------------------------------------------------------------------------------

/**
 Adapted from http://batmobile.blogs.ilrt.org/fourier-transforms-on-an-iphone/
 */
- (void)createFFTWithBufferSize:(float)bufferSize
                  withAudioData:(float *)data
{
    //
    // Setup the length
    //
    self.log2n = log2f(bufferSize);

    //
    // Calculate the weights array. This is a one-off operation.
    //
    _FFTSetup = vDSP_create_fftsetup(self.log2n, FFT_RADIX2);

    //
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    //
    int nOver2 = bufferSize/2;

    //
    // Populate *window with the values for a hamming window function
    //
    float *window = (float *)malloc(sizeof(float) * bufferSize);
    vDSP_hamm_window(window, bufferSize, 0);

    //
    // Window the samples
    //
    vDSP_vmul(data, 1, window, 1, data, 1, bufferSize);

    //
    // Define complex buffer
    //
    self.A = malloc(sizeof(COMPLEX_SPLIT));
    self.A->realp = (float *) malloc(nOver2 * sizeof(float));
    self.A->imagp = (float *) malloc(nOver2 * sizeof(float));
}

//------------------------------------------------------------------------------

- (void)updateFFTWithBufferSize:(float)bufferSize
                  withAudioData:(float*)data
{
    //
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    //
    int nOver2 = bufferSize / 2;

    //
    // Pack samples:
    // C(re) -> A[n], C(im) -> A[n+1]
    //
    vDSP_ctoz((COMPLEX *)data, 2, self.A, 1, nOver2);

    //
    // Perform a forward FFT using fftSetup and A
    // Results are returned in A
    //
    vDSP_fft_zrip(_FFTSetup, self.A, 1, self.log2n, FFT_FORWARD);

    //
    // Convert COMPLEX_SPLIT A result to magnitudes
    //
    float amp[nOver2];
    float maxMag = 0;
    for(int i = 0; i < nOver2; i++)
    {
        // Calculate the magnitude
        float mag = self.A->realp[i]*self.A->realp[i]+self.A->imagp[i]*self.A->imagp[i];
        maxMag = mag > maxMag ? mag : maxMag;
    }
    for(int i=0; i < nOver2; i++)
    {
        // Calculate the magnitude
        float mag = self.A->realp[i]*self.A->realp[i]+self.A->imagp[i]*self.A->imagp[i];
        // Bind the value to be less than 1.0 to fit in the graph
        amp[i] = [EZAudioUtilities MAP:mag leftMin:0.0 leftMax:maxMag rightMin:0.0 rightMax:1.0];
    }

    //
    // Update the frequency domain plot
    //
    [self.audioPlotFreq updateBuffer:amp withBufferSize:nOver2];
}

//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // Update time domain plot
        //
        [weakSelf.audioPlotTime updateBuffer:buffer[0]
                              withBufferSize:bufferSize];
        
        //
        // Lazily perform the FFT setup
        //
        if (!weakSelf.isFFTSetup)
        {
            [weakSelf createFFTWithBufferSize:bufferSize withAudioData:buffer[0]];
            weakSelf.isFFTSetup = YES;
        }
    
        //
        // Perform FFT and update FFT graph
        //
        [weakSelf updateFFTWithBufferSize:bufferSize
                            withAudioData:buffer[0]];
    });
}

//------------------------------------------------------------------------------

@end