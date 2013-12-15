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
  
  // The EZAudioFile provides convenience methods to optimize the waveform drawings. It will choose a proper window to iterate through the file that will generate roughly ~2048 buffers and so 2048 points on the waveform graph. This ensures that we get a good looking plot for both very small and very large files
  UInt32 frameRate = [self.audioFile recommendedDrawingFrameRate];
  UInt32 buffers   = [self.audioFile minBuffersWithFrameRate:frameRate];
  
  // Check if we have allocated a read buffer
  if( readBuffer == NULL ){
    readBuffer = (AudioBufferList*)malloc(sizeof(AudioBufferList));
  }
  
  // Take a snapshot of each buffer through the audio file to form the waveform
  __block float rms;
  float data[buffers];
  for( int i = 0; i < buffers; i++ ){
    
    // Allocate a buffer list to hold the audio file's data
    UInt32          bufferSize;
    BOOL            eof;
    
    // Read some data from the audio file (the audio file internally maintains the seek position you're at). You can manually seek to whatever position in the audio file using the seekToFileOffset: function on the EZAudioFile.
    [self.audioFile readFrames:frameRate
               audioBufferList:readBuffer
                    bufferSize:&bufferSize
                           eof:&eof];
    
    // Get the RMS of the buffeer
    rms = [EZAudio RMS:readBuffer->mBuffers[0].mData length:bufferSize];
    data[i] = rms;
    
  }
  
  // Since we malloc'ed, we should cleanup
  [EZAudio freeBufferList:readBuffer];
  
  // Update the audio plot once all the snapshots have been taken
  [self.audioPlot updateBuffer:data withBufferSize:buffers];
  
}

@end
