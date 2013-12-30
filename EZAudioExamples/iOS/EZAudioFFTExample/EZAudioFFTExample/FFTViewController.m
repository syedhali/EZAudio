//
//  FFTViewController.m
//  EZAudioFFTExample
//
//  Created by Syed Haris Ali on 12/30/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "FFTViewController.h"

@interface FFTViewController (){
  COMPLEX_SPLIT _A;
  FFTSetup      _FFTSetup;
  BOOL          _isFFTSetup;
  vDSP_Length   _log2n;
}
@end

@implementation FFTViewController
@synthesize audioPlotFreq;
@synthesize audioPlotTime;
@synthesize microphone;

#pragma mark - Customize the Audio Plot
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  /*
   Customizing the audio plot's look
   */
  // Setup time domain audio plot
  self.audioPlotTime.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];
  self.audioPlotTime.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
  self.audioPlotTime.shouldFill      = YES;
  self.audioPlotTime.shouldMirror    = YES;
  self.audioPlotTime.plotType        = EZPlotTypeRolling;
  
  // Setup frequency domain audio plot
  self.audioPlotFreq.backgroundColor = [UIColor colorWithRed: 0.984 green: 0.471 blue: 0.525 alpha: 1];
  self.audioPlotFreq.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
  self.audioPlotFreq.shouldFill      = YES;
  self.audioPlotFreq.plotType        = EZPlotTypeBuffer;
  
  /*
   Start the microphone
   */
  self.microphone = [EZMicrophone microphoneWithDelegate:self
                                       startsImmediately:YES];
  
}

#pragma mark - FFT
/**
 Adapted from http://batmobile.blogs.ilrt.org/fourier-transforms-on-an-iphone/
 */
-(void)createFFTWithBufferSize:(float)bufferSize withAudioData:(float*)data {
  
  // Setup the length
  _log2n = log2f(bufferSize);
  
  // Calculate the weights array. This is a one-off operation.
  _FFTSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
  
  // For an FFT, numSamples must be a power of 2, i.e. is always even
  int nOver2 = bufferSize/2;
  
  // Populate *window with the values for a hamming window function
  float *window = (float *)malloc(sizeof(float)*bufferSize);
  vDSP_hamm_window(window, bufferSize, 0);
  // Window the samples
  vDSP_vmul(data, 1, window, 1, data, 1, bufferSize);
  
  // Define complex buffer
  _A.realp = (float *) malloc(nOver2*sizeof(float));
  _A.imagp = (float *) malloc(nOver2*sizeof(float));
  
}

-(void)updateFFTWithBufferSize:(float)bufferSize withAudioData:(float*)data {
  
  // For an FFT, numSamples must be a power of 2, i.e. is always even
  int nOver2 = bufferSize/2;
  
  // Pack samples:
  // C(re) -> A[n], C(im) -> A[n+1]
  vDSP_ctoz((COMPLEX*)data, 2, &_A, 1, nOver2);
  
  // Perform a forward FFT using fftSetup and A
  // Results are returned in A
  vDSP_fft_zrip(_FFTSetup, &_A, 1, _log2n, FFT_FORWARD);
  
  // Convert COMPLEX_SPLIT A result to magnitudes
  float amp[nOver2];
  float maxMag = 0;
  
  for(int i=0; i<nOver2; i++) {
    // Calculate the magnitude
    float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
    maxMag = mag > maxMag ? mag : maxMag;
  }
  for(int i=0; i<nOver2; i++) {
    // Calculate the magnitude
    float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
    // Bind the value to be less than 1.0 to fit in the graph
    amp[i] = [EZAudio MAP:mag leftMin:0.0 leftMax:maxMag rightMin:0.0 rightMax:1.0];
  }
  
  // Update the frequency domain plot
  [self.audioPlotFreq updateBuffer:amp
                    withBufferSize:nOver2];
  
}

#pragma mark - EZMicrophoneDelegate
-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
  dispatch_async(dispatch_get_main_queue(), ^{
    
    // Update time domain plot
    [self.audioPlotTime updateBuffer:buffer[0]
                      withBufferSize:bufferSize];
    
    // Setup the FFT if it's not already setup
    if( !_isFFTSetup ){
      [self createFFTWithBufferSize:bufferSize withAudioData:buffer[0]];
      _isFFTSetup = YES;
    }
    
    // Get the FFT data
    [self updateFFTWithBufferSize:bufferSize withAudioData:buffer[0]];
    
  });
}

@end
