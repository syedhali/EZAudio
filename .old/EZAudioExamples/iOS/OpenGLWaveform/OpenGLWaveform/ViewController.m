//
//  ViewController.m
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

#import "ViewController.h"

//------------------------------------------------------------------------------
#pragma mark - ViewController (Interface Extension)
//------------------------------------------------------------------------------

@interface ViewController ()
@property (nonatomic, strong) NSArray *inputs;
@end

//------------------------------------------------------------------------------
#pragma mark - ViewController (Implementation)
//------------------------------------------------------------------------------

@implementation ViewController

//------------------------------------------------------------------------------
#pragma mark - View Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    //
    // Customizing the audio plot's look
    //
    
    //
    // Background color
    //
    self.audioPlot.backgroundColor = [UIColor colorWithRed:0.569 green:0.82 blue:0.478 alpha:1.0];

    //
    // Waveform color
    //
    self.audioPlot.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

    //
    // Plot type
    //
    self.audioPlot.plotType = EZPlotTypeBuffer;

    //
    // Create the microphone
    //
    self.microphone = [EZMicrophone microphoneWithDelegate:self];

    //
    // Set up the microphone input UIPickerView items to select
    // between different microphone inputs. Here what we're doing behind the hood
    // is enumerating the available inputs provided by the AVAudioSession.
    //
    self.inputs = [EZAudioDevice inputDevices];
    self.microphoneInputPickerView.dataSource = self;
    self.microphoneInputPickerView.delegate = self;

    //
    // Start the microphone
    //
    [self.microphone startFetchingAudio];
    self.microphoneTextLabel.text = @"Microphone On";
}

//------------------------------------------------------------------------------
#pragma mark - UIPickerViewDataSource
//------------------------------------------------------------------------------

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//------------------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    EZAudioDevice *device = self.inputs[row];
    return device.name;
}

//------------------------------------------------------------------------------

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component
{
    EZAudioDevice *device = self.inputs[row];
    UIColor *textColor = [device isEqual:self.microphone.device] ? self.audioPlot.backgroundColor : [UIColor blackColor];
    return  [[NSAttributedString alloc] initWithString:device.name
                                            attributes:@{ NSForegroundColorAttributeName : textColor }];
}

//------------------------------------------------------------------------------

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.inputs.count;
}

//------------------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    EZAudioDevice *device = self.inputs[row];
    [self.microphone setDevice:device];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    switch (selectedSegment)
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
    BOOL isOn = [sender isOn];
    if (!isOn)
    {
        [self.microphone stopFetchingAudio];
        self.microphoneTextLabel.text = @"Microphone Off";
    }
    else
    {
        [self.microphone startFetchingAudio];
        self.microphoneTextLabel.text = @"Microphone On";
    }
}

//------------------------------------------------------------------------------

- (void)toggleMicrophonePickerView:(id)sender
{
    BOOL isHidden = self.microphoneInputPickerViewTopConstraint.constant != 0.0;
    [self setMicrophonePickerViewHidden:!isHidden];
}

//------------------------------------------------------------------------------

- (void)setMicrophonePickerViewHidden:(BOOL)hidden
{
    CGFloat pickerHeight = CGRectGetHeight(self.microphoneInputPickerView.bounds);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.55
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:(UIViewAnimationOptionBeginFromCurrentState|
                                 UIViewAnimationOptionCurveEaseInOut|
                                 UIViewAnimationOptionLayoutSubviews)
                     animations:^{
                         weakSelf.microphoneInputPickerViewTopConstraint.constant = hidden ? -pickerHeight : 0.0f;
                         [weakSelf.view layoutSubviews];
                     } completion:nil];
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

//
// Give the visualization of the current buffer (this is almost exactly the
// openFrameworks audio input eample)
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
-(void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
//
// Note that any callback that provides streamed audio data (like streaming
// microphone input) happens on a separate audio thread that should not be
// blocked. When we feed audio data into any of the UI components we need to
// explicity create a GCD block on the main thread to properly get the UI
// to work.
//
- (void)microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as an array of float buffer arrays. What does that mean?
    // Because the audio is coming in as a stereo signal the data is split into
    // a left and right channel. So buffer[0] corresponds to the float* data
    // for the left channel while buffer[1] corresponds to the float* data
    // for the right channel.
    //

    //
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    //
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources.
        // Hence, one badass line of code gets you a pretty plot :)
        //
        [weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    //
    // The AudioStreamBasicDescription of the microphone stream. This is useful
    // when configuring the EZRecorder or telling another component what
    // audio format type to expect.
    //
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone
     hasBufferList:(AudioBufferList *)bufferList
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as a buffer list that can be directly fed into the
    // EZRecorder or EZOutput. Say whattt...
    //
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device
{
    NSLog(@"Microphone changed device: %@", device.name);

    //
    // Called anytime the microphone's device changes
    //
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = device.name;
        NSString *tapText = @" (Tap To Change)";
        NSString *microphoneInputToggleButtonText = [NSString stringWithFormat:@"%@%@", device.name, tapText];
        NSRange rangeOfName = [microphoneInputToggleButtonText rangeOfString:name];
        NSMutableAttributedString *microphoneInputToggleButtonAttributedText = [[NSMutableAttributedString alloc] initWithString:microphoneInputToggleButtonText];
        [microphoneInputToggleButtonAttributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0f] range:rangeOfName];
        [weakSelf.microphoneInputToggleButton setAttributedTitle:microphoneInputToggleButtonAttributedText forState:UIControlStateNormal];

        //
        // Reset the device list (a device may have been plugged in/out)
        //
        weakSelf.inputs = [EZAudioDevice inputDevices];
        [weakSelf.microphoneInputPickerView reloadAllComponents];
        [weakSelf setMicrophonePickerViewHidden:YES];
    });
}

@end