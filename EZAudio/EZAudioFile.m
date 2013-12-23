//
//  EZAudioFile.m
//  EZAudio
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

#import "EZAudioFile.h"

#import "EZAudio.h"

@interface EZAudioFile (){
  
  // Reading from the audio file
  ExtAudioFileRef             _audioFile;
  AudioStreamBasicDescription _clientFormat;
  AudioStreamBasicDescription _fileFormat;
  float                       **_floatBuffers;
  AEFloatConverter            *_floatConverter;
  SInt64                      _frameIndex;
  CFURLRef                    _sourceURL;
  Float32                     _totalDuration;
  SInt64                      _totalFrames;
  
  // Waveform Data
  float  *_waveformData;
  UInt32 _waveformFrameRate;
  UInt32 _waveformTotalBuffers;
  
}
@end

@implementation EZAudioFile
@synthesize audioFileDelegate = _audioFileDelegate;

#pragma mark - Initializers
-(EZAudioFile*)initWithURL:(NSURL*)url {
  self = [super init];
  if(self){
    _sourceURL = (__bridge CFURLRef)url;
    [self _configureAudioFile];
  }
  return self;
}

-(EZAudioFile *)initWithURL:(NSURL *)url andDelegate:(id<EZAudioFileDelegate>)delegate {
  self = [self initWithURL:url];
  if(self){
    self.audioFileDelegate = delegate;
  }
  return self;
}

#pragma mark - Class Initializers
+(EZAudioFile*)audioFileWithURL:(NSURL*)url {
  return [[EZAudioFile alloc] initWithURL:url];
}

+(EZAudioFile *)audioFileWithURL:(NSURL *)url andDelegate:(id<EZAudioFileDelegate>)delegate {
  return [[EZAudioFile alloc] initWithURL:url andDelegate:delegate];
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
  
  // Total duration
  _totalDuration = _totalFrames / _fileFormat.mSampleRate;
  
  // Set the client format on the stream
  _clientFormat.mBitsPerChannel   = 8 * sizeof(AudioUnitSampleType);
  _clientFormat.mBytesPerFrame    = sizeof(AudioUnitSampleType);
  _clientFormat.mBytesPerPacket   = sizeof(AudioUnitSampleType);
  _clientFormat.mChannelsPerFrame = 1;
  _clientFormat.mFormatFlags      = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
  _clientFormat.mFormatID         = kAudioFormatLinearPCM;
  _clientFormat.mFramesPerPacket  = 1;
	_clientFormat.mSampleRate       = 44100;
  
  [EZAudio checkResult:ExtAudioFileSetProperty(_audioFile,
                                               kExtAudioFileProperty_ClientDataFormat,
                                               sizeof (AudioStreamBasicDescription),
                                               &_clientFormat)
             operation:"Couldn't set client data format on input ext file"];
  
  // Allocate the float buffers
  _floatConverter = [[AEFloatConverter alloc] initWithSourceFormat:_clientFormat];
  _floatBuffers   = (float**)malloc( sizeof(float*) * _clientFormat.mChannelsPerFrame );
  UInt32 outputBufferSize = 32 * 1024; // 32 KB
  for ( int i=0; i< _clientFormat.mChannelsPerFrame; i++ ) {
    _floatBuffers[i] = (float*)malloc(outputBufferSize);
  }
  
}

#pragma mark - Events
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
    audioBufferList->mBuffers[0].mData = (AudioUnitSampleType*)malloc(sizeof(AudioUnitSampleType*)*outputBufferSize);
    [EZAudio checkResult:ExtAudioFileRead(_audioFile,
                                          &frames,
                                          audioBufferList)
               operation:"Failed to read audio data from audio file"];
    *bufferSize = audioBufferList->mBuffers[0].mDataByteSize/sizeof(AudioUnitSampleType);
    *eof = frames == 0;
    _frameIndex += frames;
    if( self.audioFileDelegate ){
      if( [self.audioFileDelegate respondsToSelector:@selector(audioFile:updatedPosition:)] ){
        [self.audioFileDelegate audioFile:self
                          updatedPosition:_frameIndex];
      }
      if( [self.audioFileDelegate respondsToSelector:@selector(audioFile:readAudio:withBufferSize:withNumberOfChannels:)] ){
        AEFloatConverterToFloat(_floatConverter,audioBufferList,_floatBuffers,frames);
        [self.audioFileDelegate audioFile:self
                                readAudio:_floatBuffers
                           withBufferSize:frames
                     withNumberOfChannels:_clientFormat.mChannelsPerFrame];
      }
    }
  }
}

-(void)seekToFrame:(SInt64)frame {
  [EZAudio checkResult:ExtAudioFileSeek(_audioFile,frame)
             operation:"Failed to seek frame position within audio file"];
  _frameIndex = frame;
  if( self.audioFileDelegate ){
    if( [self.audioFileDelegate respondsToSelector:@selector(audioFile:updatedPosition:)] ){
      [self.audioFileDelegate audioFile:self updatedPosition:_frameIndex];
    }
  }
}

#pragma mark - Getters
-(void)getWaveformDataWithCompletionBlock:(WaveformDataCompletionBlock)waveformDataCompletionBlock {
  
  SInt64 currentFramePosition = _frameIndex;
  
  if( _waveformData ){
    
    waveformDataCompletionBlock( _waveformData, _waveformTotalBuffers );
    
  }
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0ul), ^{
      
    _waveformFrameRate    = [self recommendedDrawingFrameRate];
    _waveformTotalBuffers = [self minBuffersWithFrameRate:_waveformFrameRate];
    _waveformData         = (float*)malloc(sizeof(float)*_waveformTotalBuffers);
    
    for( int i = 0; i < _waveformTotalBuffers; i++ ){
      
      // Take a snapshot of each buffer through the audio file to form the waveform
      AudioBufferList *bufferList = [EZAudio audioBufferList];
      UInt32          bufferSize;
      BOOL            eof;
      
      // Setup the buffers
      UInt32 outputBufferSize = 32 * _waveformFrameRate; // 32 KB
      bufferList->mNumberBuffers = 1;
      bufferList->mBuffers[0].mNumberChannels = _clientFormat.mChannelsPerFrame;
      bufferList->mBuffers[0].mDataByteSize = outputBufferSize;
      bufferList->mBuffers[0].mData = (AudioUnitSampleType*)malloc(sizeof(AudioUnitSampleType*)*outputBufferSize);
      
      // Read in the specified number of frames
      [EZAudio checkResult:ExtAudioFileRead(_audioFile,
                                            &_waveformFrameRate,
                                            bufferList)
                 operation:"Failed to read audio data from audio file"];
      bufferSize = bufferList->mBuffers[0].mDataByteSize/sizeof(AudioUnitSampleType);
      eof = _waveformFrameRate == 0;
      _frameIndex += _waveformFrameRate;
      
      // Convert to floats
      AEFloatConverterToFloat(_floatConverter,bufferList,_floatBuffers,_waveformFrameRate);
      
      // Calculate RMS of each buffer
      float rms = [EZAudio RMS:_floatBuffers[0]
                        length:bufferSize];
      _waveformData[i] = rms;
      
      // Since we malloc'ed, we should cleanup
      [EZAudio freeBufferList:bufferList];
      
    }
    
    // Seek the audio file back to the beginning
    [EZAudio checkResult:ExtAudioFileSeek(_audioFile,currentFramePosition)
               operation:"Failed to seek frame position within audio file"];
    _frameIndex = currentFramePosition;
    
    // Once we're done send off the waveform data
    dispatch_async(dispatch_get_main_queue(), ^{
      waveformDataCompletionBlock( _waveformData, _waveformTotalBuffers );
    });

  });
  
}

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
  if( _waveformData ){
    free(_waveformData);
  }
  [EZAudio checkResult:ExtAudioFileDispose(_audioFile)
             operation:"Failed to dispose of extended audio file."];
}

@end
