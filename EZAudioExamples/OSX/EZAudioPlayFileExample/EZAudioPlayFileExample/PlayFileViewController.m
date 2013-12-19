//
//  PlayFileViewController.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "PlayFileViewController.h"

@interface PlayFileViewController ()

@end

@implementation PlayFileViewController
@synthesize audioFile;
@synthesize audioPlot;
@synthesize eof = _eof;
@synthesize framePositionSlider;

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
}

#pragma mark - Customize the Audio Plot
-(void)awakeFromNib {
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.943 green: 0.738 blue: 0.305 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [NSColor colorWithCalibratedRed: 0.97 green: 0.493 blue: 0.002 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  // Fill
  self.audioPlot.shouldFill      = YES;
  // Mirror
  self.audioPlot.shouldMirror    = YES;
  
  /*
   Try opening the sample file
   */
  [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
  
}

#pragma mark - Actions
-(void)changePlotType:(id)sender {
  NSInteger selectedSegment = [sender selectedSegment];
  switch(selectedSegment){
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

-(void)openFile:(id)sender {
  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  openDlg.canChooseFiles = YES;
  openDlg.canChooseDirectories = NO;
  openDlg.delegate = self;
  if( [openDlg runModal] == NSOKButton ){
    NSArray *selectedFiles = [openDlg URLs];
    [self openFileWithFilePathURL:selectedFiles.firstObject];
  }
}

-(void)play:(id)sender {
  if( ![[EZOutput sharedOutput] isPlaying] ){
    if( self.eof ){
      [self.audioFile seekToFrame:0];
    }
    [EZOutput sharedOutput].outputDataSource = self;
    [[EZOutput sharedOutput] startPlayback];
  }
  else {
    [EZOutput sharedOutput].outputDataSource = nil;
    [[EZOutput sharedOutput] stopPlayback];
  }
}

-(void)seekToFrame:(id)sender {
  [self.audioFile seekToFrame:(SInt64)[(NSSlider*)sender doubleValue]];
}

#pragma mark - Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
 */
-(void)drawBufferPlot {
  // Change the plot type to the buffer plot
  self.audioPlot.plotType = EZPlotTypeBuffer;
  // Don't fill
  self.audioPlot.shouldFill = NO;
  // Don't mirror over the x-axis
  self.audioPlot.shouldMirror = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
  // Change the plot type to the rolling plot
  self.audioPlot.plotType = EZPlotTypeRolling;
  // Fill the waveform
  self.audioPlot.shouldFill = YES;
  // Mirror over the x-axis
  self.audioPlot.shouldMirror = YES;
}

-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
  
  // Stop playback
  [[EZOutput sharedOutput] stopPlayback];
  
  self.audioFile                    = [EZAudioFile audioFileWithURL:filePathURL andDelegate:self];
  self.eof                          = NO;
  self.filePathLabel.stringValue    = filePathURL.lastPathComponent;
  self.framePositionSlider.minValue = 0.0f;
  self.framePositionSlider.maxValue = (double)self.audioFile.totalFrames;

  // Plot the whole waveform
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  self.audioPlot.shouldFill      = YES;
  self.audioPlot.shouldMirror    = YES;
  [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
    [self.audioPlot updateBuffer:waveformData withBufferSize:length];
  }];
  
}

#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile readAudio:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
  if( [EZOutput sharedOutput].isPlaying ){
    if( self.audioPlot.plotType == EZPlotTypeBuffer  &&
        self.audioPlot.shouldFill == YES              &&
        self.audioPlot.shouldMirror == YES ){
      self.audioPlot.shouldFill = NO;
      self.audioPlot.shouldMirror = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
  }
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
  dispatch_async(dispatch_get_main_queue(), ^{
    if( ![self.framePositionSlider.cell isHighlighted] ){
      self.framePositionSlider.floatValue = (float)framePosition;
    }
  });
}

#pragma mark - EZOutputDataSource
-(AudioBufferList *)output:(EZOutput *)output
 needsBufferListWithFrames:(UInt32)frames
            withBufferSize:(UInt32 *)bufferSize {
  if( self.audioFile ){
    
    // Reached the end of the file
    if( self.eof ){
      
      // Here's what you do to loop the file
      [self.audioFile seekToFrame:0];
      self.eof = NO;
      
      return nil;
    }
    
    // Allocate a buffer list to hold the file's data
    AudioBufferList *bufferList = [EZAudio audioBufferList];
    BOOL eof;
    [self.audioFile readFrames:frames
               audioBufferList:bufferList
                    bufferSize:bufferSize
                           eof:&eof];
    self.eof = eof;
    
    // Reached the end of the file on the last read
    if( eof ){
      [EZAudio freeBufferList:bufferList];
      [self.audioFile seekToFrame:0];
      return nil;
    }
    return bufferList;
  }
  return nil;
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
  return self.audioFile.clientFormat;
}

#pragma mark - NSOpenSavePanelDelegate
/**
 Here's an example how to filter the open panel to only show the supported file types by the EZAudioFile (which are just the audio file types supported by Core Audio).
 */
-(BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
  NSString* ext = [filename pathExtension];
  if ([ext isEqualToString:@""] || [ext isEqualToString:@"/"] || ext == nil || ext == NULL || [ext length] < 1) {
    return YES;
  }
  NSArray *fileTypes = [EZAudioFile supportedAudioFileTypes];
  NSEnumerator* tagEnumerator = [fileTypes objectEnumerator];
  NSString* allowedExt;
  while ((allowedExt = [tagEnumerator nextObject]))
  {
    if ([ext caseInsensitiveCompare:allowedExt] == NSOrderedSame)
    {
      return YES;
    }
  }
  return NO;
}

@end
