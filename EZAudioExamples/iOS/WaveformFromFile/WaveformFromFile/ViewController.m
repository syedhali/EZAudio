//
//  ViewController.m
//  WaveformFromFile
//
//  Created by Syed Haris Ali on 1/23/16.
//  Copyright © 2016 Syed Haris Ali. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

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
    
    //
    // Background color
    //
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.169 green: 0.643 blue: 0.675 alpha: 1];
    
    //
    // Waveform color
    //
    self.audioPlot.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    //
    // Plot type
    //
    self.audioPlot.plotType = EZPlotTypeBuffer;
    
    //
    // Fill
    //
    self.audioPlot.shouldFill = YES;
    
    //
    // Mirror
    //
    self.audioPlot.shouldMirror = YES;
    
    //
    // No need to optimze for realtime
    //
    self.audioPlot.shouldOptimizeForRealtimePlot = NO;
    
    //
    // Customize the layer with a shadow for fun
    //
    self.audioPlot.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.audioPlot.waveformLayer.shadowRadius = 0.0;
    self.audioPlot.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
    self.audioPlot.waveformLayer.shadowOpacity = 1.0;
    
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
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    self.filePathLabel.text = filePathURL.lastPathComponent;
    
    //
    // Plot the whole waveform
    //
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    
    //
    // Get the audio data from the audio file
    //
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
    {
        [weakSelf.audioPlot updateBuffer:waveformData[0]
                          withBufferSize:length];
    }];
}

@end
