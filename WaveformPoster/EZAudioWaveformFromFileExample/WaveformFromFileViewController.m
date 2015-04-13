//
//  WaveformFromFileViewController.m
//  EZAudioWaveformFromFileExample
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
    self.audioPlot.wantsLayer = YES;
    self.audioPlot.backgroundColor = [NSColor clearColor];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    self.audioPlot.color           = [NSColor colorWithCalibratedRed:0
                                                               green:0.676
                                                                blue:0.575
                                                               alpha:1];
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

- (void)snapshot:(id)sender
{
    NSBitmapImageRep* imageRep = [self.audioPlot bitmapImageRepForCachingDisplayInRect:self.audioPlot.bounds];
    [self.audioPlot cacheDisplayInRect:self.audioPlot.bounds toBitmapImageRep:imageRep];
    NSData* data = [imageRep representationUsingType:NSPNGFileType properties:nil];
    [data writeToFile:@"/Users/haris/Documents/waveform.png" atomically:NO];
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
