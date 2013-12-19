//
//  WaveformFromFileViewController.m
//  EZAudioWaveformFromFileExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "WaveformFromFileViewController.h"

@interface WaveformFromFileViewController (){
  AudioBufferList *readBuffer;
}
@end

@implementation WaveformFromFileViewController
@synthesize audioPlot = _audioPlot;
@synthesize audioFile = _audioFile;
@synthesize eof = _eof;
@synthesize filePathLabel = _filePathLabel;

#pragma mark - Customize the Audio Plot
-(void)viewDidLoad {
  
  [super viewDidLoad];
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.993 green: 0.881 blue: 0.751 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [UIColor colorWithRed: 0.219 green: 0.234 blue: 0.29 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  // Fill
  self.audioPlot.shouldFill      = YES;
  // Mirror
  self.audioPlot.shouldMirror    = YES;
  
  /*
   Load in the sample file
   */
  [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
  
}

#pragma mark - Action Extensions
-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
  
  self.audioFile          = [EZAudioFile audioFileWithURL:filePathURL];
  self.eof                = NO;
  self.filePathLabel.text = filePathURL.lastPathComponent;
  
  // Plot the whole waveform
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  self.audioPlot.shouldFill      = YES;
  self.audioPlot.shouldMirror    = YES;
  [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
    [self.audioPlot updateBuffer:waveformData withBufferSize:length];
  }];
  
}

@end
