//
//  PlayFileViewController.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 12/16/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "PlayFileViewController.h"

@implementation PlayFileViewController

#pragma mark - Status Bar Style
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Customize the Audio Plot
- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
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
    // Customize the plot's look
    //
    // Background color
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 1];
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;

    //
    // Create an EZOutput instance
    //
    self.output = [EZOutput outputWithDataSource:self];
    
    //
    // Try opening the sample file
    //
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    switch(selectedSegment)
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

- (void)changeRollingHistoryLength:(id)sender
{
    float value = [(UISlider *)sender value];
    [self.audioPlot setRollingHistoryLength:(int)value];
}

//------------------------------------------------------------------------------

- (void)changeVolume:(id)sender
{
    float value = [(UISlider *)sender value];
    [self.output setVolume:value];
}

//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    // Stop playback
    [self.output stopPlayback];
    
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL delegate:self];
    self.eof = NO;
    self.filePathLabel.text = filePathURL.lastPathComponent;
    self.framePositionSlider.maximumValue = (float)self.audioFile.totalFrames;
    
    // Set the input format from the EZAudioFile on the output
    [self.output setInputFormat:[self.audioFile clientFormat]];
    
    // Plot the whole waveform
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
    {
        [weakSelf.audioPlot updateBuffer:waveformData[0]
                          withBufferSize:length];
    }];
}

//------------------------------------------------------------------------------

- (void)play:(id)sender
{
    if (![self.output isPlaying])
    {
        if (self.eof)
        {
            [self.audioFile seekToFrame:0];
        }
        [self.output startPlayback];
    }
    else
    {
        [self.output stopPlayback];
    }
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(id)sender
{
    [self.audioFile seekToFrame:(SInt64)[(UISlider *)sender value]];
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input eample)
 */
- (void)drawBufferPlot
{
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldMirror = NO;
    self.audioPlot.shouldFill = NO;
}

//------------------------------------------------------------------------------

/*
 Give the classic mirrored, rolling waveform look
 */
- (void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFileDelegate
//------------------------------------------------------------------------------

- (void)     audioFile:(EZAudioFile *)audioFile
            readAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.output isPlaying])
        {
            if (weakSelf.audioPlot.plotType == EZPlotTypeBuffer &&
               weakSelf.audioPlot.shouldFill == YES &&
               weakSelf.audioPlot.shouldMirror == YES)
            {
                weakSelf.audioPlot.shouldFill = NO;
                weakSelf.audioPlot.shouldMirror = NO;
            }
            [weakSelf.audioPlot updateBuffer:buffer[0]
                              withBufferSize:bufferSize];
        }
    });
}

//------------------------------------------------------------------------------

- (void)audioFile:(EZAudioFile *)audioFile
  updatedPosition:(SInt64)framePosition
{
     __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.framePositionSlider.touchInside)
        {
            weakSelf.framePositionSlider.value = (float)framePosition;
        }
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    if (self.audioFile)
    {
        UInt32 bufferSize;
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&eof];
        if (eof)
        {
            [self.audioFile seekToFrame:0];
        }
    }
    return noErr;
}

//------------------------------------------------------------------------------

@end
