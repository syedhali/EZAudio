//
//  FFTViewController.h
//  EZAudioFFTExample
//
//  Created by Syed Haris Ali on 12/30/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

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
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlotTime;

/**
 Microphone
 */
@property (nonatomic,strong) EZMicrophone *microphone;

@end
