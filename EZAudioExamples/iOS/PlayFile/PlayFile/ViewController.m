//
//  ViewController.m
//  PlayFile
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
#import "PlayFile-Swift.h"
#import "AppDelegate.h"
@implementation ViewController

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
    _myTmpInt = 0;
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
    // Customizing the audio plot's look
    //
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 1];
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    
    NSLog(@"outputs: %@", [EZAudioDevice outputDevices]);
    
    //
    // Create the audio player
    //
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    // 希望通过这样的方式进行波形图的初始化。
    self.player.shouldLoop = NO;
    
    //
    // Override the output to the speaker
    //
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error)
    {
        NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
    }
    
    //
    // Customize UI components
    //
    self.rollingHistorySlider.value = (float)[self.audioPlot rollingHistoryLength];
    
    //
    // Listen for EZAudioPlayer notifications
    //
    [self setupNotifications];
    
    /*
     Try opening the sample file
     #define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]
     
     当前我们的存储位置
     //1.获取沙盒地址
     NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     filePath = [path stringByAppendingString:@"/RRecord.wav"];
     
     //2.获取文件路径
     self.recordFileUrl = [NSURL fileURLWithPath:filePath];
     */
    #define kAudioFileDefault2 [[NSBundle mainBundle] pathForResource:@"la - 1" ofType:@"wav"]
    
    //1.获取沙盒地址
    NSString *path2 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath2 = [path2 stringByAppendingString:@"/RRecord.wav"];
    
    //2.获取文件路径
    NSURL *recordFileUrl2 = [NSURL fileURLWithPath:filePath2];
    [self openFileWithFilePathURL:[NSURL fileURLWithPath: filePath2]];
//    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault2]];
    // 这个位置确定file位置
}

//------------------------------------------------------------------------------
#pragma mark - Notifications
//------------------------------------------------------------------------------

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
    //    _taytay = [player.audioFile totalFrames];
    size_t size = sizeof(float) * [player.audioFile totalFrames];
    size_t small = size/512;
    small++;
    size = small * 512;
    _taytay = (float *)malloc(size);
    _theTailLenth = size;
    _actualLenth = [player.audioFile totalFrames];
}
//------------------------------------------------------------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"goM"]){
//        segue.destinationViewController
        NSLog(@"I was here");
        NSNumber *c0 = [NSNumber numberWithDouble:0];
        NSMutableArray *mArr = [NSMutableArray arrayWithObjects: c0,nil];
        NSNumber *c1 = [NSNumber numberWithDouble:1];
//        [mArr addObject:c1];
        for (int i = 0;i<_actualLenth;i++){
            float tmp = _taytay[i];
            NSNumber *tmpNum = [NSNumber numberWithFloat:tmp];
            [mArr addObject:tmpNum];
        }
        NSArray *myArray = [mArr copy];
//        // NSArray --> NSMutableArray
//        NSMutableArray *myMutableArray = [myArray mutableCopy];
//        // NSMutableArray --> NSArray
//        NSArray *myArray = [myMutableArray copy];
        [((FinallyViewController*) segue.destinationViewController) getTayTayWithMan:( myArray)];
//        AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
//        app.myAppArray = myArray;
    }
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
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
    [self.player setVolume:value];
}

//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    //
    // Create the EZAudioPlayer
    //
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    
    //
    // Update the UI
    //
    self.filePathLabel.text = filePathURL.lastPathComponent;
    self.positionSlider.maximumValue = (float)self.audioFile.totalFrames;
    self.volumeSlider.value = [self.player volume];
    
    //
    // Plot the whole waveform
    //
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    __weak typeof (self) weakSelf = self;
    // getWaveformDataWithNumberOfPoints
    // 超级无敌关键步骤
//    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
//                                                         int length)
//     {
//         [weakSelf.audioPlot updateBuffer:waveformData[0]
//                           withBufferSize:length];
//     }];
    // getWaveformDataWithNumberOfPoints
    // 超级无敌关键步骤
    [self.audioFile getWaveformDataWithNumberOfPoints:1024
                                           completion:^(float **waveformData,
                                                         int length)
     {
         [weakSelf.audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
         NSLog(@"1数组第一维度长度: %u", sizeof(waveformData)/sizeof(waveformData[0]));
         NSLog(@"1数组第二维度长度: %u", sizeof(waveformData[0])/sizeof(waveformData[0][0]));
     }];

    //
    // Play the audio file
    //
    [self.player setAudioFile:self.audioFile];
    
    // myTime 今早实力
    EZAudioFloatData *a = [self.audioFile getWaveformDataWithNumberOfPoints : 8000];
    int count1 = sizeof([a buffers]) / sizeof([a buffers][0]);
    int count2 = sizeof([a buffers][0]) / sizeof([a buffers][0][0]);
    NSLog(@"数组一维长度: %d",count1);
    NSLog(@"数组二维长度: %d",count2);
}

//------------------------------------------------------------------------------

- (void)play:(id)sender
{
    if ([self.player isPlaying])
    {
        [self.player pause];
    }
    else
    {
        if (self.audioPlot.shouldMirror && (self.audioPlot.plotType == EZPlotTypeBuffer))
        {
            self.audioPlot.shouldMirror = NO;
            self.audioPlot.shouldFill = NO;
        }
        [self.player play];
    }
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(id)sender
{
    [self.player seekToFrame:(SInt64)[(UISlider *)sender value]];
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void)  audioPlayer:(EZAudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    // 超级无敌关键步骤
    dispatch_async(dispatch_get_main_queue(), ^{
        _myTmpInt++;
        NSLog(@"counting : %d",_myTmpInt);
//        NSLog(@"2数组一维的长度: %lu",sizeof(buffer)/sizeof(buffer[0]));
//        NSLog(@"2数组二维的长度: %lu",sizeof(buffer[0])/sizeof(buffer[0][0]));
//        for (int i = 0; i < numberOfChannels; i++)
//        {
//            memcpy(buffersCopy[i], buffers[i], size);
//        }
//        memcpy(_taytay[_myTmpInt-1],buffer[0],sizeof(float)*512);
        for (int i = 0;i<512;i++){
//            _taytay[][0]
            long long tmpIndex = (_myTmpInt-1)*512+i;
            if (tmpIndex >= _actualLenth){
                break;
            }
            if (_myTmpInt == 2){
                NSLog(@"my[2][%d]: %f",i,buffer[0][i]);
            }
            _taytay[tmpIndex] = buffer[0][i];
//            memcpy(_taytay[tmpIndex],buffer[0][i],sizeof(float));
        }
        [weakSelf.audioPlot updateBuffer:buffer[0]
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
        if (!weakSelf.positionSlider.touchInside)
        {
            weakSelf.positionSlider.value = (float)framePosition;
        }
    });
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

@end
