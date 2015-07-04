//
//  RecordViewController.m
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "RecordViewController.h"

@implementation RecordViewController

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
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
    // Customizing the audio plot that'll show the current microphone input/recording
    //
    self.recordingAudioPlot.backgroundColor = [UIColor colorWithRed: 0.984 green: 0.71 blue: 0.365 alpha: 1];
    self.recordingAudioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.recordingAudioPlot.plotType        = EZPlotTypeRolling;
    self.recordingAudioPlot.shouldFill      = YES;
    self.recordingAudioPlot.shouldMirror    = YES;
    
    //
    // Customizing the audio plot that'll show the playback
    //
    self.playingAudioPlot.color = [UIColor whiteColor];
    self.playingAudioPlot.plotType = EZPlotTypeRolling;
    self.playingAudioPlot.shouldFill = YES;
    self.playingAudioPlot.shouldMirror = YES;
    
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    
    //
    // Initialize UI components
    //
    self.microphoneStateLabel.text = @"Microphone On";
    self.recordingStateLabel.text = @"Not Recording";
    self.playingStateLabel.text = @"Not Playing";
    self.playButton.enabled = NO;

    //
    // Setup notifications
    //
    [self setupNotifications];
    
    //
    // Log out where the file is being written to within the app's documents directory
    //
    NSLog(@"File written to application sandbox's documents directory: %@",[self testFilePathURL]);
    
    //
    // Start the microphone
    //
    [self.microphone startFetchingAudio];
}

//------------------------------------------------------------------------------

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:self.player];
}

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

- (void)playerDidChangeAudioFile:(NSNotification *)notification
{
    
}

//------------------------------------------------------------------------------

- (void)playerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    BOOL isPlaying = [player isPlaying];
    self.playingStateLabel.text = isPlaying ? @"Playing" : @"Not Playing";
    self.playingAudioPlot.hidden = !isPlaying;
}

//------------------------------------------------------------------------------

- (void)playerDidReachEndOfFile:(NSNotification *)notification
{
    [self.playingAudioPlot clear];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)playFile:(id)sender
{
    // Update microphone state
    [self.microphone stopFetchingAudio];
    self.microphoneStateLabel.text = @"Microphone Off";
    self.microphoneSwitch.on = NO;

    // Update recording state
    self.isRecording = NO;
    self.recordingStateLabel.text = @"Not Recording";
    self.recordSwitch.on = NO;

    // Close the audio file
    if ( self.recorder )
    {
        [self.recorder closeAudioFile];
    }

    EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[self testFilePathURL]];
    [self.player playAudioFile:audioFile];
}

//------------------------------------------------------------------------------

- (void)toggleMicrophone:(id)sender
{
    BOOL isOn = [(UISwitch*)sender isOn];
    
    [self.player pause];

    if (!isOn)
    {
        [self.microphone stopFetchingAudio];
        self.microphoneStateLabel.text = @"Microphone Off";
    }
    else
    {
        [self.microphone startFetchingAudio];
        self.microphoneStateLabel.text = @"Microphone On";
    }
}

//------------------------------------------------------------------------------

- (void)toggleRecording:(id)sender
{
    [self.player pause];
    if ([sender isOn])
    {
        //
        // Create the recorder
        //
        [EZAudioUtilities printASBD:self.microphone.audioStreamBasicDescription];
        self.recorder = [EZRecorder recorderWithDestinationURL:[self testFilePathURL]
                                                  sourceFormat:self.microphone.audioStreamBasicDescription
                                           destinationFileType:EZRecorderFileTypeM4A];
        self.playButton.enabled = YES;
    }
    else
    {
        [self.recorder closeAudioFile];
    }
    self.isRecording = (BOOL)[sender isOn];
    self.recordingStateLabel.text = self.isRecording ? @"Recording" : @"Not Recording";
}

//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
  
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [weakSelf.recordingAudioPlot updateBuffer:buffer[0]
                                   withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)   microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if (self.isRecording)
    {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void) audioPlayer:(EZAudioPlayer *)audioPlayer
         playedAudio:(float **)buffer
      withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.playingAudioPlot updateBuffer:buffer[0]
                                 withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.currentTimeLabel.text = [audioPlayer formattedCurrentTime];
    });
}

#pragma mark - Utility
- (NSArray *)applicationDocuments
{
  return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSURL *)testFilePathURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [self applicationDocumentsDirectory],
                                   kAudioFilePath]];
}

@end