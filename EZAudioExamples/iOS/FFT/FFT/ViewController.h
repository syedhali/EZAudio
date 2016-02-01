//
//  ViewController.h
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

