//
//  ViewController.h
//  FFT
//
//  Created by Syed Haris Ali on 1/23/16.
//  Copyright © 2016 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// First import the EZAudio header
//
#include <EZAudio/EZAudio.h>

//------------------------------------------------------------------------------
#pragma mark - ViewController
//------------------------------------------------------------------------------

@interface ViewController : UIViewController <EZMicrophoneDelegate, EZAudioFFTDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

//
// EZAudioPlot for frequency plot
//
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlotFreq;

//
// EZAudioPlot for time plot
//
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlotTime;

//
// A label used to display the maximum frequency (i.e. the frequency with the
// highest energy) calculated from the FFT.
//
@property (nonatomic, weak) IBOutlet UILabel *maxFrequencyLabel;

//
// The microphone used to get input.
//
@property (nonatomic,strong) EZMicrophone *microphone;

//
// Used to calculate a rolling FFT of the incoming audio data.
//
@property (nonatomic, strong) EZAudioFFTRolling *fft;


@end

