//
//  PlayFileViewController.m
//  EZAudioPlayFileExample
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

#import "PlayFileViewController.h"

@interface PlayFileViewController ()
@property (nonatomic, strong) EZOutput *output;
@end

@implementation PlayFileViewController

#pragma mark - Customize the Audio Plot
- (void)awakeFromNib
{
    /*
     Customizing the audio plot's look
     */
    self.audioPlot.backgroundColor = [NSColor clearColor];
    self.audioPlot.color = [NSColor colorWithCalibratedRed: 0.255 green: 0.608 blue: 0.976 alpha: 1];
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.wantsLayer = YES;
    
    /**
     Setup an output
     */
    self.output = [EZOutput outputWithDataSource:self];
  
    /*
     Try opening the sample file
     */
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
}

#pragma mark - Actions
-(void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegment];
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

-(void)changeOutputSamplingFrequency:(id)sender
{
    AudioStreamBasicDescription asbd = self.output.audioStreamBasicDescription;
    float samplingFrequency = [sender floatValue];
    asbd.mSampleRate = samplingFrequency;
    self.output.audioStreamBasicDescription = asbd;
}

-(void)openFile:(id)sender
{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.delegate = self;
    if( [openDlg runModal] == NSOKButton )
    {
        NSArray *selectedFiles = [openDlg URLs];
        [self openFileWithFilePathURL:selectedFiles.firstObject];
        NSLog(@"selected files: %@", selectedFiles);
    }
}

-(void)play:(id)sender
{
    if( ![self.output isPlaying] )
    {
        if( self.eof )
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

- (void)seekToFrame:(id)sender
{
    SInt64 frame = [sender integerValue];
    [self.audioFile seekToFrame:frame];
}

#pragma mark - Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
 */
- (void)drawBufferPlot
{
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = NO;
    self.audioPlot.shouldMirror = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
- (void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    // stop playback
    [self.output stopPlayback];

    // create a new audio file
    AudioStreamBasicDescription asbd;
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL
                                          delegate:self
                                        permission:EZAudioFilePermissionRead
                                        fileFormat:asbd];
    
    //
    self.filePathLabel.stringValue = filePathURL.lastPathComponent;
    self.framePositionSlider.minValue = 0.0;
    self.framePositionSlider.maxValue = (double)self.audioFile.totalFrames;
    self.output.audioStreamBasicDescription = self.audioFile.clientFormat;
    self.playButton.state = NSOffState;
    self.plotSegmentControl.selectedSegment = 1;
    self.sampleRateSlider.floatValue = self.audioFile.clientFormat.mSampleRate;
  
    // plot the whole waveform
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    [self.progressIndicator startAnimation:nil];
    
    //
    __weak PlayFileViewController *weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(EZAudioFloatData *waveformData)
    {
        [weakSelf.progressIndicator stopAnimation:nil];
        [weakSelf.audioPlot updateBuffer:[waveformData bufferForChannel:0]
                          withBufferSize:waveformData.bufferSize];
    }];
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFileDelegate
//------------------------------------------------------------------------------
- (void)audioFile:(EZAudioFile *)audioFile
        readAudio:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    if( self.output.isPlaying )
    {
        __weak PlayFileViewController *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.audioPlot updateBuffer:buffer[0]
                              withBufferSize:bufferSize];
        });
    }
}

//------------------------------------------------------------------------------

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( ![self.framePositionSlider.cell isHighlighted] )
        {
            self.framePositionSlider.floatValue = (float)framePosition;
        }
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZOutputDataSource
//------------------------------------------------------------------------------
-(void)             output:(EZOutput*)output
 shouldFillAudioBufferList:(AudioBufferList*)audioBufferList
        withNumberOfFrames:(UInt32)frames
{
    if( self.audioFile )
    {
        UInt32 bufferSize;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&_eof];
        if( _eof )
        {
            [self seekToFrame:0];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - NSOpenSavePanelDelegate
//------------------------------------------------------------------------------
/**
 Here's an example how to filter the open panel to only show the supported file types by the EZAudioFile (which are just the audio file types supported by Core Audio).
 */
- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    NSArray *fileTypes = [EZAudioFile supportedAudioFileTypes];
    BOOL isDirectory = [ext isEqualToString:@""];
    return [fileTypes containsObject:ext] || isDirectory;
}

//------------------------------------------------------------------------------

@end
