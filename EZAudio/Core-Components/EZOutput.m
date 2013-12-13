//
//  EZOutput.m
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "EZOutput.h"

#import "../EZAudio.h"

@interface EZOutput (){
  BOOL      _isPlaying;
  AudioUnit _outputUnit;
}
@end

@implementation EZOutput
@synthesize outputDataSource = _outputDataSource;

static OSStatus OutputRenderCallback(void                        *inRefCon,
                                     AudioUnitRenderActionFlags  *ioActionFlags,
                                     const AudioTimeStamp        *inTimeStamp,
                                     UInt32                      inBusNumber,
                                     UInt32                      inNumberFrames,
                                     AudioBufferList             *ioData){
  EZOutput *output = (__bridge EZOutput*)inRefCon;
  
  UInt32 bufferSize;
  AudioBufferList *bufferList = [output.outputDataSource output:output
                                      needsBufferListWithFrames:inNumberFrames
                                                 withBufferSize:&bufferSize];
  
  for(int i = 0; i < inNumberFrames; i++ ){
    Float32 *left  = (Float32*)ioData->mBuffers[0].mData;
    Float32 *right = (Float32*)ioData->mBuffers[1].mData;
    if( bufferList ){
      Float32 *interleaved = (Float32*)bufferList->mBuffers[0].mData;
      left[i]  = interleaved[i];
      right[i] = interleaved[i];
    }
    else {
      left[i] = 0.0f;
      right[i] = 0.0f;
    }
  }
  
  return noErr;
}

#pragma mark - Initialization
-(id)init {
  self = [super init];
  if(self){
    [self _configureOutput];
  }
  return self;
}

-(id)initWithDataSource:(id<EZOutputDataSource>)dataSource {
  self = [super init];
  if(self){
    self.outputDataSource = dataSource;
    [self _configureOutput];
  }
  return self;
}

#pragma mark - Class Initializers
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource {
  return [[EZOutput alloc] initWithDataSource:dataSource];
}

#pragma mark - Singleton
+(EZOutput*)sharedOutput {
  static EZOutput *_sharedOutput = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedOutput = [[EZOutput alloc] init];
  });
  return _sharedOutput;
}

#pragma mark - Private Configuration

#if TARGET_OS_IPHONE
-(void)_configureOutput {
  
}
#elif TARGET_OS_MAC
-(void)_configureOutput {
  
  //
  AudioComponentDescription outputcd;
  outputcd.componentType         = kAudioUnitType_Output;
  outputcd.componentSubType      = kAudioUnitSubType_DefaultOutput;
  outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  //
  AudioComponent comp = AudioComponentFindNext(NULL,&outputcd);
  if( comp == NULL ){
    NSLog(@"Failed to get output unit");
    exit(-1);
  }
  [EZAudio checkResult:AudioComponentInstanceNew(comp,&_outputUnit)
             operation:"Failed to open component for output unit"];
  
  //
  AURenderCallbackStruct input;
  input.inputProc = OutputRenderCallback;
  input.inputProcRefCon = (__bridge void *)(self);
  [EZAudio checkResult:AudioUnitSetProperty(_outputUnit,
                                            kAudioUnitProperty_SetRenderCallback,
                                            kAudioUnitScope_Input,
                                            0,
                                            &input,
                                            sizeof(input))
             operation:"Failed to set the render callback on the output unit"];
  
  //
  [EZAudio checkResult:AudioUnitInitialize(_outputUnit)
             operation:"Couldn't initialize output unit"];
  
}
#endif

#pragma mark - Events
-(void)startPlayback {
  if( !_isPlaying ){
    [EZAudio checkResult:AudioOutputUnitStart(_outputUnit)
               operation:"Failed to start output unit"];
    _isPlaying = YES;
  }
}

-(void)stopPlayback {
  if( _isPlaying ){
    NSLog(@"Attempting to stop output unit");
    [EZAudio checkResult:AudioOutputUnitStop(_outputUnit)
               operation:"Failed to stop output unit"];
    NSLog(@"Finished execution of output unit stop");
    _isPlaying = NO;
  }
}

#pragma mark - Getters
-(BOOL)isPlaying {
  return _isPlaying;
}

-(void)dealloc {
  [EZAudio checkResult:AudioOutputUnitStop(_outputUnit)
             operation:"Failed to uninitialize output unit"];
  [EZAudio checkResult:AudioUnitUninitialize(_outputUnit)
             operation:"Failed to uninitialize output unit"];
  [EZAudio checkResult:AudioComponentInstanceDispose(_outputUnit)
             operation:"Failed to uninitialize output unit"];
}

@end
