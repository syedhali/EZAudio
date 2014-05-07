//
//  EZAudioPlayer.m
//  EZAudio
//
//  Created by Syed Haris Ali on 1/16/14.
//  Copyright (c) 2014 Syed Haris Ali. All rights reserved.
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

#import "EZAudioPlayer.h"

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#endif
@interface EZAudioPlayer () <EZAudioFileDelegate,EZOutputDataSource>
{
  BOOL _eof;
}
@property (nonatomic,strong,setter=setAudioFile:) EZAudioFile *audioFile;
@property (nonatomic,strong,setter=setOutput:)    EZOutput    *output;
@end

@implementation EZAudioPlayer
@synthesize audioFile = _audioFile;
@synthesize audioPlayerDelegate = _audioPlayerDelegate;
@synthesize output = _output;
@synthesize shouldLoop = _shouldLoop;

#pragma mark - Initializers
-(id)init {
  self = [super init];
  if(self){
    [self _configureAudioPlayer];
  }
  return self;
}

-(EZAudioPlayer*)initWithEZAudioFile:(EZAudioFile *)audioFile {
  return [self initWithEZAudioFile:audioFile withDelegate:nil];
}

-(EZAudioPlayer *)initWithEZAudioFile:(EZAudioFile *)audioFile
                         withDelegate:(id<EZAudioPlayerDelegate>)audioPlayerDelegate {
  self = [super init];
  if(self){
    // This should make a separate reference to the audio file
    [self _configureAudioPlayer];
    self.audioFile           = audioFile;
    self.audioPlayerDelegate = audioPlayerDelegate;
  }
  return self;
}

-(EZAudioPlayer *)initWithURL:(NSURL *)url {
  return [self initWithURL:url withDelegate:nil];
}

-(EZAudioPlayer *)initWithURL:(NSURL *)url
                 withDelegate:(id<EZAudioPlayerDelegate>)audioPlayerDelegate {
  self = [super init];
  if(self){
    [self _configureAudioPlayer];
    self.audioFile           = [EZAudioFile audioFileWithURL:url andDelegate:self];
    self.audioPlayerDelegate = audioPlayerDelegate;
  }
  return self;
}

#pragma mark - Class Initializers
+(EZAudioPlayer *)audioPlayerWithEZAudioFile:(EZAudioFile *)audioFile {
  return [[EZAudioPlayer alloc] initWithEZAudioFile:audioFile];
}

+(EZAudioPlayer *)audioPlayerWithEZAudioFile:(EZAudioFile *)audioFile
                                withDelegate:(id<EZAudioPlayerDelegate>)audioPlayerDelegate {
  return [[EZAudioPlayer alloc] initWithEZAudioFile:audioFile
                                       withDelegate:audioPlayerDelegate];
}

+(EZAudioPlayer *)audioPlayerWithURL:(NSURL *)url {
  return [[EZAudioPlayer alloc] initWithURL:url];
}

+(EZAudioPlayer *)audioPlayerWithURL:(NSURL *)url
                        withDelegate:(id<EZAudioPlayerDelegate>)audioPlayerDelegate {
  return [[EZAudioPlayer alloc] initWithURL:url
                               withDelegate:audioPlayerDelegate];
}

#pragma mark - Singleton
+(EZAudioPlayer *)sharedAudioPlayer {
  static EZAudioPlayer *_sharedAudioPlayer = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedAudioPlayer = [[EZAudioPlayer alloc] init];
  });
  return _sharedAudioPlayer;
}

#pragma mark - Private Configuration
-(void)_configureAudioPlayer {
  
  // Defaults
  self.output = [EZOutput sharedOutput];
  
#if TARGET_OS_IPHONE
  // Configure the AVSession
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  NSError *err = NULL;
  [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
  if( err ){
    NSLog(@"There was an error creating the audio session");
  }
  [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
  if( err ){
    NSLog(@"There was an error sending the audio to the speakers");
  }
#elif TARGET_OS_MAC
#endif
  
}

#pragma mark - Getters
-(EZAudioFile*)audioFile {
  return _audioFile;
}

-(float)currentTime {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  return [EZAudio MAP:self.audioFile.frameIndex
              leftMin:0
              leftMax:self.audioFile.totalFrames
             rightMin:0
             rightMax:self.audioFile.totalDuration];
}

-(BOOL)endOfFile {
  return _eof;
}

-(SInt64)frameIndex {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  return _audioFile.frameIndex;
}

-(BOOL)isPlaying {
  return self.output.isPlaying;
}

-(EZOutput*)output {
  NSAssert(_output,@"No output was found, this should by default be the EZOutput shared instance");
  return _output;
}

-(float)totalDuration {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  return _audioFile.totalDuration;
}

-(SInt64)totalFrames {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  return _audioFile.totalFrames;
}

-(NSURL *)url {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  return _audioFile.url;
}

#pragma mark - Setters
-(void)setAudioFile:(EZAudioFile *)audioFile {
  if( _audioFile ){
    _audioFile.audioFileDelegate = nil;
  }
  _eof       = NO;
  _audioFile = [EZAudioFile audioFileWithURL:audioFile.url andDelegate:self];
  NSAssert(_output,@"No output was found, this should by default be the EZOutput shared instance");
  [_output setAudioStreamBasicDescription:self.audioFile.clientFormat];    
}

-(void)setOutput:(EZOutput*)output {
  _output                  = output;
  _output.outputDataSource = self;
}

#pragma mark - Methods
-(void)play {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  if( _audioFile ){
    [_output startPlayback];
    if( self.frameIndex != self.totalFrames ){
      _eof = NO;
    }
    if( self.audioPlayerDelegate ){
      if( [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayer:didResumePlaybackOnAudioFile:)] ){
        // Notify the delegate we're starting playback
        [self.audioPlayerDelegate audioPlayer:self didResumePlaybackOnAudioFile:_audioFile];
      }
    }
  }
}

-(void)pause {
  NSAssert(self.audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  if( _audioFile ){
    [_output stopPlayback];
    if( self.audioPlayerDelegate ){
      if( [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayer:didPausePlaybackOnAudioFile:)] ){
        // Notify the delegate we're pausing playback
        [self.audioPlayerDelegate audioPlayer:self didPausePlaybackOnAudioFile:_audioFile];
      }
    }
  }
}

-(void)seekToFrame:(SInt64)frame {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  if( _audioFile ){
    [_audioFile seekToFrame:frame];
  }
  if( self.frameIndex != self.totalFrames ){
    _eof = NO;
  }
}

-(void)stop {
  NSAssert(_audioFile,@"No audio file to perform the seek on, check that EZAudioFile is not nil");
  if( _audioFile ){
    [_output stopPlayback];
    [_audioFile seekToFrame:0];
    _eof = NO;
  }
}

#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  if( self.audioPlayerDelegate ){
    if( [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayer:readAudio:withBufferSize:withNumberOfChannels:inAudioFile:)] ){
      [self.audioPlayerDelegate audioPlayer:self
                                  readAudio:buffer
                             withBufferSize:bufferSize
                       withNumberOfChannels:numberOfChannels
                                inAudioFile:audioFile];
    }
  }
}

-(void)audioFile:(EZAudioFile *)audioFile updatedPosition:(SInt64)framePosition {
  if( self.audioPlayerDelegate ){
    if( [self.audioPlayerDelegate respondsToSelector:@selector(audioPlayer:updatedPosition:inAudioFile:)] ){
      [self.audioPlayerDelegate audioPlayer:self
                            updatedPosition:framePosition
                                inAudioFile:audioFile];
    }
  }
}

#pragma mark - EZOutputDataSource
-(void)             output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
{
    if( self.audioFile )
    {
        UInt32 bufferSize;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&_eof];
        if( _eof && self.shouldLoop )
        {
            [self seekToFrame:0];
        }
    }
}

@end
