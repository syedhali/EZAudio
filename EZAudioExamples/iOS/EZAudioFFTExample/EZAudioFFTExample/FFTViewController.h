//
//  FFTViewController.h
//  EZAudioFFTExample
//
//  Created by Syed Haris Ali on 12/30/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
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

#import <UIKit/UIKit.h>

/**
 EZAudio
 */
#import "EZAudio.h"

/**
 Accelerate
 */
#import <Accelerate/Accelerate.h>

/**
 The FFTViewController demonstrates how to use the Accelerate framework to calculate the real-time FFT of audio data provided by an EZAudioMicrophone.
 */
@interface FFTViewController : UIViewController <EZMicrophoneDelegate>

#pragma mark - Components
/**
 EZAudioPlot for frequency plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlotFreq;

/**
 EZAudioPlot for time plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlotTime;

/**
 Microphone
 */
@property (nonatomic,strong) EZMicrophone *microphone;

@end
