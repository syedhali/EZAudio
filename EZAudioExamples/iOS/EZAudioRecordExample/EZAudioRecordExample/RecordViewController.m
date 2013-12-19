//
//  RecordViewController.m
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "RecordViewController.h"

@interface RecordViewController ()
// Using AVPlayer for example
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,weak) IBOutlet UISwitch *microphoneSwitch;
@property (nonatomic,weak) IBOutlet UILabel *microphoneTextField;
@property (nonatomic,weak) IBOutlet UIButton *playButton;
@property (nonatomic,weak) IBOutlet UILabel *playingTextField;
@property (nonatomic,weak) IBOutlet UISwitch *recordSwitch;
@property (nonatomic,weak) IBOutlet UILabel *recordingTextField;
@end

@implementation RecordViewController
@synthesize audioPlot;
@synthesize microphone;
@synthesize microphoneSwitch;
@synthesize microphoneTextField;
@synthesize playButton;
@synthesize playingTextField;
@synthesize recorder;
@synthesize recordSwitch;
@synthesize recordingTextField;

#pragma mark - Initialization
-(id)init {
  self = [super init];
  if(self){
    [self initializeViewController];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self){
    [self initializeViewController];
  }
  return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
  // Create an instance of the microphone and tell it to use this view controller instance as the delegate
  self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

#pragma mark - Customize the Audio Plot
-(void)viewDidLoad {
  
  [super viewDidLoad];
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.984 green: 0.71 blue: 0.365 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeRolling;
  // Fill
  self.audioPlot.shouldFill      = YES;
  // Mirror
  self.audioPlot.shouldMirror    = YES;
  
  /*
   Start the microphone
   */
  [self.microphone startFetchingAudio];
  self.microphoneTextField.text = @"Microphone On";
  self.recordingTextField.text = @"Not Recording";
  self.playingTextField.text = @"Not Playing";
  
  // Hide the play button
  self.playButton.hidden = YES;
  
  /*
   Log out where the file is being written to within the app's documents directory
   */
  NSLog(@"File written to application sandbox's documents directory: %@",[self testFilePathURL]);
  
}

#pragma mark - Actions
-(void)playFile:(id)sender {
  
  // Update microphone state
  [self.microphone stopFetchingAudio];
  self.microphoneTextField.text = @"Microphone Off";
  self.microphoneSwitch.on = NO;
  
  // Update recording state
  self.isRecording = NO;
  self.recordingTextField.text = @"Not Recording";
  self.recordSwitch.on = NO;
  
  // Create Audio Player
  if( self.audioPlayer ){
    if( self.audioPlayer.playing ) [self.audioPlayer stop];
    self.audioPlayer = nil;
  }
  NSError *err;
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self testFilePathURL]
                                                            error:&err];
  [self.audioPlayer play];
  self.audioPlayer.delegate = self;
  self.playingTextField.text = @"Playing";
  
}

-(void)toggleMicrophone:(id)sender {
  
  self.playingTextField.text = @"Not Playing";
  if( self.audioPlayer ){
    if( self.audioPlayer.playing ) [self.audioPlayer stop];
    self.audioPlayer = nil;
  }
  
  if( ![(UISwitch*)sender isOn] ){
    [self.microphone stopFetchingAudio];
    self.microphoneTextField.text = @"Microphone Off";
  }
  else {
    [self.microphone startFetchingAudio];
    self.microphoneTextField.text = @"Microphone On";
  }
}

-(void)toggleRecording:(id)sender {
  
  self.playingTextField.text = @"Not Playing";
  if( self.audioPlayer ){
    if( self.audioPlayer.playing ) [self.audioPlayer stop];
    self.audioPlayer = nil;
  }
  self.playButton.hidden = NO;
  
  self.isRecording = (BOOL)[sender isOn];
  self.recordingTextField.text = self.isRecording ? @"Recording" : @"Not Recording";
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
  self.recorder = [EZRecorder recorderWithDestinationURL:[self testFilePathURL]
                                         andSourceFormat:audioStreamBasicDescription];
  
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  
  // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
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
  self.audioPlayer = nil;
  self.playingTextField.text = @"Finished Playing";
  
  [self.microphone startFetchingAudio];
  self.microphoneSwitch.on = YES;
  self.microphoneTextField.text = @"Microphone On";
}

#pragma mark - Utility
-(NSArray*)applicationDocuments {
  return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

-(NSString*)applicationDocumentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}

-(NSURL*)testFilePathURL {
  return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory],kAudioFilePath]];
}

@end
