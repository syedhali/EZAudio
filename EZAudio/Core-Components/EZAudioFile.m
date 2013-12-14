//
//  EZAudioFile.m
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "EZAudioFile.h"

#import "../EZAudio.h"

@interface EZAudioFile (){
  ExtAudioFileRef             _audioFile;
  AudioStreamBasicDescription _clientFormat;
  AudioStreamBasicDescription _fileFormat;
  SInt64                      _frameIndex;
  CFURLRef                    _sourceURL;
  Float32                     _totalDuration;
  SInt64                      _totalFrames;
}
@end

@implementation EZAudioFile
//@synthesize audioFileDelegate = _audioFileDelegate;

#pragma mark - Initializers
-(EZAudioFile*)initWithURL:(NSURL*)url {
  self = [super init];
  if(self){
    _sourceURL = (__bridge CFURLRef)url;
    [self _configureAudioFile];
  }
  return self;
}

#pragma mark - Class Initializers
+(EZAudioFile*)audioFileWithURL:(NSURL*)url {
  return [[EZAudioFile alloc] initWithURL:url];
}

#pragma mark - Class Methods
+(NSArray *)supportedAudioFileTypes {
  return @[ @"aac",
            @"caf",
            @"aif",
            @"aiff",
            @"aifc",
            @"mp3",
            @"mp4",
            @"m4a",
            @"snd",
            @"au",
            @"sd2",
            @"wav" ];
}

#pragma mark - Private Configuation
-(void)_configureAudioFile {
  
  // Source URL should not be nil
  NSAssert(_sourceURL,@"Source URL was not specified correctly.");
  
  // Try to open the file for reading
  [EZAudio checkResult:ExtAudioFileOpenURL(_sourceURL,&_audioFile)
             operation:"Failed to open audio file for reading"];
  
  // Try pulling the stream description
  UInt32 size = sizeof(_fileFormat);
  [EZAudio checkResult:ExtAudioFileGetProperty(_audioFile,kExtAudioFileProperty_FileDataFormat, &size, &_fileFormat)
             operation:"Failed to get audio stream basic description of input file"];
  [EZAudio printASBD:_fileFormat];
  
  // Try pulling the total frame size
  size = sizeof(_totalFrames);
  [EZAudio checkResult:ExtAudioFileGetProperty(_audioFile,kExtAudioFileProperty_FileLengthFrames, &size, &_totalFrames)
             operation:"Failed to get total frames of input file"];
  NSLog(@"total frames: %lld",_totalFrames);
  
  // Total duration
  _totalDuration = _totalFrames / _fileFormat.mSampleRate;
  NSLog(@"total duration: %f",_totalDuration);
  
  // Set the client format on the stream
	_clientFormat.mSampleRate = 44100;
	_clientFormat.mFormatID = kAudioFormatLinearPCM;
	_clientFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat;
	_clientFormat.mBitsPerChannel = sizeof(Float32) * 8;
	_clientFormat.mChannelsPerFrame = 1; // set this to 2 for stereo
	_clientFormat.mBytesPerFrame = _clientFormat.mChannelsPerFrame * sizeof(Float32);
	_clientFormat.mFramesPerPacket = 1;
	_clientFormat.mBytesPerPacket = _clientFormat.mFramesPerPacket * _clientFormat.mBytesPerFrame;
  
  [EZAudio checkResult:ExtAudioFileSetProperty(_audioFile,
                                               kExtAudioFileProperty_ClientDataFormat,
                                               sizeof (AudioStreamBasicDescription),
                                               &_clientFormat)
             operation:"Couldn't set client data format on input ext file"];
}

#pragma mark - Events
-(void)readEntireFileWithBufferListCompletionBlock:(BufferListReadCompletionBlock)completionBlock {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0ul),^{
    // Check to see if we're not already at the beginning of the file
    if( _frameIndex != 0 ){
      [EZAudio checkResult:ExtAudioFileSeek(_audioFile,0)
                 operation:"Failed to seek to beginning of file"];
    }
    [self readFrames:(UInt32)_totalFrames withBufferListCompletionBlock:^(AudioBufferList *audioBufferList, UInt32 bufferSize, BOOL *eof) {
      dispatch_async(dispatch_get_main_queue(),^{
        completionBlock(audioBufferList,bufferSize,eof);
      });
    }];
  });
}

-(void)readEntireFileWithFloatCompletionBlock:(FloatReadCompletionBlock)completionBlock {
  [self readEntireFileWithBufferListCompletionBlock:^(AudioBufferList *audioBufferList, UInt32 bufferSize, BOOL *eof) {
    completionBlock( (Float32*)audioBufferList->mBuffers[0].mData, bufferSize, eof );
  }];
}

-(void)readFrames:(UInt32)frames
  audioBufferList:(AudioBufferList *)audioBufferList
       bufferSize:(UInt32 *)bufferSize
              eof:(BOOL *)eof {
  @autoreleasepool {
    // Setup the buffers
    UInt32 outputBufferSize = 32 * frames; // 32 KB
    audioBufferList->mNumberBuffers = 1;
    audioBufferList->mBuffers[0].mNumberChannels = _clientFormat.mChannelsPerFrame;
    audioBufferList->mBuffers[0].mDataByteSize = outputBufferSize;
    audioBufferList->mBuffers[0].mData = (Float64 *)malloc(sizeof(Float64 *)*outputBufferSize);
    [EZAudio checkResult:ExtAudioFileRead(_audioFile,
                                          &frames,
                                          audioBufferList)
               operation:"Failed to read audio data from audio file"];
    *bufferSize = audioBufferList->mBuffers[0].mDataByteSize/sizeof(Float32);
    *eof = frames == 0;
    _frameIndex += frames;
  }
}

-(void)readFrames:(UInt32)frames withBufferListCompletionBlock:(BufferListReadCompletionBlock)completionBlock {
  AudioBufferList *bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
  UInt32 bufferSize;
  BOOL eof;
  [self readFrames:frames
   audioBufferList:bufferList
        bufferSize:&bufferSize
               eof:&eof];
  completionBlock( bufferList, bufferSize, &eof );
}

-(void)readFrames:(UInt32)frames withFloatCompletionBlock:(FloatReadCompletionBlock)completionBlock {
  [self readFrames:frames withBufferListCompletionBlock:^(AudioBufferList *audioBufferList, UInt32 bufferSize, BOOL *eof) {
    completionBlock( (Float32*)audioBufferList->mBuffers[0].mData, bufferSize, eof );
  }];
}

-(void)seekToFrame:(SInt64)frame {
  [EZAudio checkResult:ExtAudioFileSeek(_audioFile,frame)
             operation:"Failed to seek frame position within audio file"];
  _frameIndex = frame;
}

#pragma mark - Getters
-(AudioStreamBasicDescription)clientFormat {
  return _clientFormat;
}

-(AudioStreamBasicDescription)fileFormat {
  return _fileFormat;
}

-(SInt64)frameIndex {
  return _frameIndex;
}

-(Float32)totalDuration {
  return _totalDuration;
}

-(SInt64)totalFrames {
  return _totalFrames;
}

#pragma mark - Helpers
-(UInt32)minBuffersWithFrameRate:(UInt32)frameRate {
  frameRate = frameRate > 0 ? frameRate : 1;
  return (UInt32) _totalFrames / frameRate + 1;
}

-(UInt32)recommendedDrawingFrameRate {
  return (UInt32) _totalFrames / 2057 - 1;
}

#pragma mark - Cleanup
-(void)dealloc {
  [EZAudio checkResult:ExtAudioFileDispose(_audioFile)
             operation:"Failed to dispose of extended audio file."];
}

@end
