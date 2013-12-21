//
//  RecordViewController.m
//  EZAudioRecordExample
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

#import "RecordViewController.h"

@interface RecordViewController (){
  BOOL _hasSomethingToPlay;
}
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,weak) IBOutlet NSButton *microphoneToggle;
@property (nonatomic,weak) IBOutlet NSButton *playButton;
@property (nonatomic,weak) IBOutlet NSButton *recordingToggle;
@end

@implementation RecordViewController
@synthesize audioPlayer;
@synthesize audioPlot;
@synthesize isRecording;
@synthesize microphone;
@synthesize microphoneToggle;
@synthesize recorder;
@synthesize recordingToggle;

#pragma mark - Initialization
-(id)init {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
    [self initializeViewController];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
    [self initializeViewController];
  }
  return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
    [self initializeViewController];
  }
  return self;
}

#pragma mark - Initialize View Controller
-(void)initializeViewController {
  // Create an instance of the microphone and tell it to use this view controller instance as the delegate
  self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

#pragma mark - Customize the Audio Plot
-(void)awakeFromNib {
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.984 green: 0.71 blue: 0.365 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [NSColor colorWithCalibratedRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeRolling;
  // Fill
  self.audioPlot.shouldFill      = YES;
  // Mirror
  self.audioPlot.shouldMirror    = YES;
  
  // Configure the play button
  [self.playButton setHidden:YES];
  
  /*
   Start the microphone
   */
  [self.microphone startFetchingAudio];
  
}

#pragma mark - Actions
-(void)playFile:(id)sender {
  
  // Update microphone state
  [self.microphone stopFetchingAudio];
  self.microphoneToggle.state = NSOffState;
  [self.microphoneToggle setEnabled:NO];
  
  // Update recording state
  self.isRecording = NO;
  self.recordingToggle.state = NSOffState;
  [self.recordingToggle setEnabled:NO];
  
  // Create Audio Player
  if( self.audioPlayer ){
    if( self.audioPlayer.playing ) [self.audioPlayer stop];
    self.audioPlayer = nil;
  }
  NSError *err;
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:kAudioFilePath]
                                                            error:&err];
  
  [self.audioPlayer play];
  self.audioPlayer.delegate = self;
  
}

-(void)toggleMicrophone:(id)sender {
  switch([sender state]){
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

-(void)toggleRecording:(id)sender {
  [self.playButton setHidden:NO];
  self.isRecording = (BOOL)[sender state];
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
  
  // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
  dispatch_async(dispatch_get_main_queue(),^{
    // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}

-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
  // The AudioStreamBasicDescription of the microphone stream. This is useful when configuring the EZRecorder or telling another component what audio format type to expect.
  
  // Here's a print function to allow you to inspect it a little easier
  [EZAudio printASBD:audioStreamBasicDescription];
  
  // We can initialize the recorder with this ASBD
  self.recorder = [EZRecorder recorderWithDestinationURL:[NSURL fileURLWithPath:kAudioFilePath]
                                         andSourceFormat:audioStreamBasicDescription];
  
}

// Append the microphone data coming as a AudioBufferList with the specified buffer size to the recorder
-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  
  // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block.
  if( self.isRecording ){
    [self.recorder appendDataFromBufferList:bufferList
                             withBufferSize:bufferSize];
  }
  
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
  // Update microphone state
  self.microphoneToggle.state = NSOnState;
  [self.microphoneToggle setEnabled:YES];
  [self.microphone startFetchingAudio];
  
  // Update recording state
  self.isRecording = NO;
  self.recordingToggle.state = NSOffState;
  [self.recordingToggle setEnabled:YES];
}

@end
