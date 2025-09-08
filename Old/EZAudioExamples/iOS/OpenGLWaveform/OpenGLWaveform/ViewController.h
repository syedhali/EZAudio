//
//  ViewController.h
//  OpenGLWaveform
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

@interface ViewController : UIViewController <EZMicrophoneDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

//
// The CoreGraphics based audio plot
//
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

//
// The microphone component
//
@property (nonatomic, strong) EZMicrophone *microphone;

//
// The button at the bottom displaying the currently selected microphone input
//
@property (nonatomic, weak) IBOutlet UIButton *microphoneInputToggleButton;

//
// The microphone input picker view to display the different microphone input sources
//
@property (nonatomic, weak) IBOutlet UIPickerView *microphoneInputPickerView;

//
// The microphone input picker view's top layout constraint (we use this to hide the control)
//
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *microphoneInputPickerViewTopConstraint;

//
// The text label displaying "Microphone On" or "Microphone Off"
//
@property (nonatomic, weak) IBOutlet UILabel *microphoneTextLabel;


//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

//
// Switches the plot drawing type between a buffer plot (visualizes the current
// stream of audio data from the update function) or a rolling plot (visualizes
// the audio data over time, this is the classic waveform look)
//
- (IBAction)changePlotType:(id)sender;

//
// Toggles the microphone inputs picker view in and out of display.
//
- (IBAction)toggleMicrophonePickerView:(id)sender;

//
// Toggles the microphone on and off. When the microphone is on it will send its
// delegate (aka this view controller) the audio data in various ways (check out
// the EZMicrophoneDelegate documentation for more details);
//
- (IBAction)toggleMicrophone:(id)sender;

@end

