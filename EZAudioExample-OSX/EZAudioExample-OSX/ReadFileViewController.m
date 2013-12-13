//
//  ReadFileViewController.m
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "ReadFileViewController.h"

@interface ReadFileViewController ()
/**
 *  The selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;
/**
 *  The URL selected from the open file panel
 */
@property (nonatomic,strong) NSURL *selectedURL;
@end

@implementation ReadFileViewController
@synthesize audioFile   = _audioFile;
@synthesize audioPlot   = _audioPlot;
@synthesize eof         = _eof;
@synthesize selectedURL = _selectedURL;

#pragma mark - Initialization
-(id)init {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if (self) {
    [self initializeViewController];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if (self) {
    [self initializeViewController];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if (self) {
    [self initializeViewController];
  }
  return self;
}

-(void)initializeViewController {
  // Initialize stuff here (before awake)
}

#pragma mark - Awake
-(void)awakeFromNib {
  self.audioPlot.plotType = EZPlotTypeBuffer;
  self.audioPlot.shouldMirror = YES;
  self.audioPlot.shouldFill = YES;
//  self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.796 green: 0.749 blue: 0.663 alpha: 1];
//  self.audioPlot.color = [NSColor colorWithCalibratedRed: 0.481 green: 0.548 blue: 0.637 alpha: 1];
  self.audioPlot.color = [NSColor orangeColor];
  self.audioPlot.backgroundColor = [NSColor clearColor];
}

#pragma mark - Class Initializer
+(ReadFileViewController *)readFileViewController {
  return [[ReadFileViewController alloc] init];
}

#pragma mark - Events
-(void)chooseFile:(id)sender {
  NSOpenPanel* openDlg = [NSOpenPanel openPanel];
  openDlg.canChooseFiles = YES;
  openDlg.canChooseDirectories = NO;
  openDlg.delegate = self;
  if( [openDlg runModal] == NSOKButton ){
    NSArray *selectedFiles = [openDlg URLs];
    
    // Stop playback
    NSLog(@"Stopping output playback");
    [[EZOutput sharedOutput] stopPlayback];
    
    NSLog(@"Loading in new url");
    self.selectedURL = selectedFiles.firstObject;
    
    NSLog(@"Creating new audio file");
    self.audioFile   = [EZAudioFile audioFileWithURL:self.selectedURL];
    self.eof         = NO;
    
    NSLog(@"Getting new frame rate and buffer length");
    UInt32 frameRate = [self.audioFile recommendedDrawingFrameRate];
    UInt32 buffers   = [self.audioFile minBuffersWithFrameRate:frameRate];
    
    NSLog(@"Creating the waveform");
    // Take a snapshot of the waveform
    __block float rms;
    float data[buffers];
    for( int i = 0; i < buffers; i++ ){
      AudioBufferList *bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
      UInt32 bufferSize;
      BOOL eof;
      
      [self.audioFile readFrames:frameRate
                 audioBufferList:bufferList
                      bufferSize:&bufferSize
                             eof:&eof];
      
      self.eof = eof;
      rms = [EZAudio RMS:bufferList->mBuffers[0].mData length:bufferSize];
      data[i] = rms;
      
      for( int i = 0; i < bufferList->mNumberBuffers; i++ ){
        if( bufferList->mBuffers[i].mData ){
          free(bufferList->mBuffers[i].mData);
        }
      }
      free(bufferList);
      
    }
    [self.audioPlot updateBuffer:data withBufferSize:buffers];
    
  }
}

-(void)play:(id)sender {
  if( ![[EZOutput sharedOutput] isPlaying] ){
    [self.audioFile seekToFrame:0];
    [EZOutput sharedOutput].outputDataSource = self;
    [[EZOutput sharedOutput] startPlayback];
  }
  else {
    [EZOutput sharedOutput].outputDataSource = nil;
    [[EZOutput sharedOutput] stopPlayback];
  }
}

-(void)saveWaveform:(id)sender {
//  NSRect bounds = 1440 × 392
  NSBitmapImageRep* rep = [self.audioPlot bitmapImageRepForCachingDisplayInRect:self.audioPlot.bounds];
  [self.audioPlot cacheDisplayInRect:self.audioPlot.bounds toBitmapImageRep:rep];
  NSData *data = [rep representationUsingType:NSPNGFileType properties:nil];
  [data writeToFile:@"/Users/syedali/Documents/tests/tests.png" atomically: NO];
}

#pragma mark - Panel Delegate
/**
 * Here's an example of filtering the NSOpenPanel by only the supported audio file types provided by `EZAudioFile`
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

#pragma mark - OutputDataSource
-(AudioBufferList *)output:(EZOutput *)output needsBufferListWithFrames:(UInt32)frames withBufferSize:(UInt32 *)bufferSize {
  if( self.eof ){
    return NULL;
  }
  AudioBufferList *bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
  BOOL eof;
  [self.audioFile readFrames:frames audioBufferList:bufferList bufferSize:bufferSize eof:&eof];
  self.eof = eof;
  if( eof ){
    free(bufferList);
    return NULL;
  }
  else {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0ul), ^{
      dispatch_async(dispatch_get_main_queue(), ^{
        if( [EZOutput sharedOutput].isPlaying ){
          [self.audioPlot updateBuffer:bufferList->mBuffers[0].mData withBufferSize:*bufferSize];
        }
        for( int i = 0; i < bufferList->mNumberBuffers; i++ ){
          if( bufferList->mBuffers[i].mData ){
            free(bufferList->mBuffers[i].mData);
          }
        }
        free(bufferList);
      });
    });
  }
  return bufferList;
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
  return self.audioFile.clientFormat;
}

@end
