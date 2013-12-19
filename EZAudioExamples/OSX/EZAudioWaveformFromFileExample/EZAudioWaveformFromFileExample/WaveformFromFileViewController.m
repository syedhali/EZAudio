//
//  WaveformFromFileViewController.m
//  EZAudioWaveformFromFileExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "WaveformFromFileViewController.h"

@interface WaveformFromFileViewController (){
  AudioBufferList *readBuffer;
}
@end

@implementation WaveformFromFileViewController
@synthesize audioFile;
@synthesize audioPlot;
@synthesize eof = _eof;

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
  self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.993 green: 0.881 blue: 0.751 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [NSColor colorWithCalibratedRed: 0.219 green: 0.234 blue: 0.29 alpha: 1];
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

#pragma mark - Action Extensions
-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
  
  self.audioFile                 = [EZAudioFile audioFileWithURL:filePathURL];
  self.eof                       = NO;
  self.filePathLabel.stringValue = filePathURL.lastPathComponent;
  
  // Plot the whole waveform
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  self.audioPlot.shouldFill      = YES;
  self.audioPlot.shouldMirror    = YES;
  [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
    [self.audioPlot updateBuffer:waveformData withBufferSize:length];
  }];
  
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
