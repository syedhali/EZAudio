//
//  WaveformFromFileViewController.m
//  EZAudioWaveformFromFileExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "WaveformFromFileViewController.h"

@implementation WaveformFromFileViewController

//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------
#pragma mark - Customize the Audio Plot
//------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    // Customizing the audio plot's look
    //
    // Background color
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.169 green: 0.643 blue: 0.675 alpha: 1];
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    // No need to optimze for realtime
    self.audioPlot.optimizeForRealtimePlot = NO;
  
    //
    // Load in the sample file
    //
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
}

//------------------------------------------------------------------------------
#pragma mark - Action Extensions
//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    self.audioFile          = [EZAudioFile audioFileWithURL:filePathURL];
    self.eof                = NO;
    self.filePathLabel.text = filePathURL.lastPathComponent;
    
    // Plot the whole waveform
    self.audioPlot.plotType     = EZPlotTypeBuffer;
    self.audioPlot.shouldFill   = YES;
    self.audioPlot.shouldMirror = YES;
    
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData,
                                                         UInt32 length)
    {
        [weakSelf.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];
}

//------------------------------------------------------------------------------

@end