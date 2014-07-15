//
//  EZOutput.m
//  EZAudio
//
//  Created by Syed Haris Ali on 12/2/13.
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

#import "EZOutput.h"

#import "EZAudio.h"

@interface EZOutput (){
  BOOL                        _customASBD;
  BOOL                        _isPlaying;
  AudioStreamBasicDescription _outputASBD;
  AudioUnit                   _outputUnit;
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
  
//  NSLog(@"output something");
  
  EZOutput *output = (__bridge EZOutput*)inRefCon;
  // Manual override
  if( [output.outputDataSource respondsToSelector:@selector(output:callbackWithActionFlags:inTimeStamp:inBusNumber:inNumberFrames:ioData:)] ){
    [output.outputDataSource output:output
            callbackWithActionFlags:ioActionFlags
                        inTimeStamp:inTimeStamp
                        inBusNumber:inBusNumber
                     inNumberFrames:inNumberFrames
                             ioData:ioData];
  }
  else if( [output.outputDataSource respondsToSelector:@selector(outputShouldUseCircularBuffer:)] ){
    
    TPCircularBuffer *circularBuffer = [output.outputDataSource outputShouldUseCircularBuffer:output];
    if( !circularBuffer ){
      AudioUnitSampleType *left  = (AudioUnitSampleType*)ioData->mBuffers[0].mData;
      AudioUnitSampleType *right = (AudioUnitSampleType*)ioData->mBuffers[1].mData;
      for(int i = 0; i < inNumberFrames; i++ ){
        left[  i ] = 0.0f;
        right[ i ] = 0.0f;
      }
      return noErr;
    };
    
    /**
     Thank you Michael Tyson (A Tasty Pixel) for writing the TPCircularBuffer, you are amazing!
     */
    
    // Get the desired amount of bytes to copy
    int32_t bytesToCopy = ioData->mBuffers[0].mDataByteSize;
    AudioSampleType *left  = (AudioSampleType*)ioData->mBuffers[0].mData;
    AudioSampleType *right = (AudioSampleType*)ioData->mBuffers[1].mData;
    
    // Get the available bytes in the circular buffer
    int32_t availableBytes;
    AudioSampleType *buffer = TPCircularBufferTail(circularBuffer,&availableBytes);
    
    // Ideally we'd have all the bytes to be copied, but compare it against the available bytes (get min)
    int32_t amount = MIN(bytesToCopy,availableBytes);
    memcpy( left,  buffer, amount );
    memcpy( right, buffer, amount );
    
    // Consume those bytes ( this will internally push the head of the circular buffer )
    TPCircularBufferConsume(circularBuffer,amount);
    
  }
  // Provided an AudioBufferList (defaults to silence)
  else if( [output.outputDataSource respondsToSelector:@selector(output:shouldFillAudioBufferList:withNumberOfFrames:)] ) {
    [output.outputDataSource output:output
          shouldFillAudioBufferList:ioData
                 withNumberOfFrames:inNumberFrames];
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

-(id)         initWithDataSource:(id<EZOutputDataSource>)dataSource
 withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
  self = [super init];
  if(self){
    _customASBD = YES;
    _outputASBD = audioStreamBasicDescription;
    self.outputDataSource = dataSource;
    [self _configureOutput];
  }
  return self;
}

#pragma mark - Class Initializers
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource {
  return [[EZOutput alloc] initWithDataSource:dataSource];
}

+(EZOutput *)outputWithDataSource:(id<EZOutputDataSource>)dataSource
  withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
  return [[EZOutput alloc] initWithDataSource:dataSource withAudioStreamBasicDescription:audioStreamBasicDescription];
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

#pragma mark - Audio Component Initialization
-(AudioComponentDescription)_getOutputAudioComponentDescription {
 // Create an output component description for default output device
  AudioComponentDescription outputComponentDescription;
  outputComponentDescription.componentFlags        = 0;
  outputComponentDescription.componentFlagsMask    = 0;
  outputComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  #if TARGET_OS_IPHONE
    outputComponentDescription.componentSubType      = kAudioUnitSubType_RemoteIO;
  #elif TARGET_OS_MAC
    outputComponentDescription.componentSubType      = kAudioUnitSubType_DefaultOutput;
  #endif
  outputComponentDescription.componentType         = kAudioUnitType_Output;
  return outputComponentDescription;
}

-(AudioComponent)_getOutputComponentWithAudioComponentDescription:(AudioComponentDescription)outputComponentDescription {
  // Try and find the component
  AudioComponent outputComponent = AudioComponentFindNext( NULL , &outputComponentDescription );
  NSAssert(outputComponent,@"Couldn't get input component unit!");
  return outputComponent;
}

-(void)_createNewInstanceForOutputComponent:(AudioComponent)outputComponent {
  //
  [EZAudio checkResult:AudioComponentInstanceNew( outputComponent, &_outputUnit )
             operation:"Failed to open component for output unit"];
}

#pragma mark - Configure The Output Unit

//-(void)_configureOutput {
//  
//  // Get component description for output
//  AudioComponentDescription outputComponentDescription = [self _getOutputAudioComponentDescription];
//  
//  // Get the output component
//  AudioComponent outputComponent = [self _getOutputComponentWithAudioComponentDescription:outputComponentDescription];
//  
//  // Create a new instance of the component and store it for internal use
//  [self _createNewInstanceForOutputComponent:outputComponent];
//  
//}

#if TARGET_OS_IPHONE
-(void)_configureOutput {
  
  //
  AudioComponentDescription outputcd;
  outputcd.componentFlags        = 0;
  outputcd.componentFlagsMask    = 0;
  outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
  outputcd.componentSubType      = kAudioUnitSubType_RemoteIO;
  outputcd.componentType         = kAudioUnitType_Output;
  
  //
  AudioComponent comp = AudioComponentFindNext(NULL,&outputcd);
  [EZAudio checkResult:AudioComponentInstanceNew(comp,&_outputUnit)
             operation:"Failed to get output unit"];
  
  // Setup the output unit for playback
  UInt32           oneFlag = 1;
  AudioUnitElement bus0    = 0;
  [EZAudio checkResult:AudioUnitSetProperty(_outputUnit,
                                            kAudioOutputUnitProperty_EnableIO,
                                            kAudioUnitScope_Output,
                                            bus0,
                                            &oneFlag,
                                            sizeof(oneFlag))
             operation:"Failed to enable output unit"];
  
  // Get the hardware sample rate
  Float64 hardwareSampleRate = 44100;
#if !(TARGET_IPHONE_SIMULATOR)
  hardwareSampleRate = [[AVAudioSession sharedInstance] sampleRate];
#endif
  
  // Setup an ASBD in canonical format by default
  if( !_customASBD ){
    _outputASBD = [EZAudio stereoCanonicalNonInterleavedFormatWithSampleRate:hardwareSampleRate];
  }
  
  // Set the format for output
  [EZAudio checkResult:AudioUnitSetProperty(_outputUnit,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Input,
                                            bus0,
                                            &_outputASBD,
                                            sizeof(_outputASBD))
             operation:"Couldn't set the ASBD for input scope/bos 0"];
  
  //
  AURenderCallbackStruct input;
  input.inputProc = OutputRenderCallback;
  input.inputProcRefCon = (__bridge void *)self;
  [EZAudio checkResult:AudioUnitSetProperty(_outputUnit,
                                            kAudioUnitProperty_SetRenderCallback,
                                            kAudioUnitScope_Input,
                                            bus0,
                                            &input,
                                            sizeof(input))
             operation:"Failed to set the render callback on the output unit"];
  
  //
  [EZAudio checkResult:AudioUnitInitialize(_outputUnit)
             operation:"Couldn't initialize output unit"];
  
  
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

  
  // Setup an ASBD in canonical format by default
  if( !_customASBD ){
    _outputASBD = [EZAudio stereoCanonicalNonInterleavedFormatWithSampleRate:44100];
  }
  
  // Set the format for output
  [EZAudio checkResult:AudioUnitSetProperty(_outputUnit,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Input,
                                            0,
                                            &_outputASBD,
                                            sizeof(_outputASBD))
             operation:"Couldn't set the ASBD for input scope/bos 0"];
  
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
    [EZAudio checkResult:AudioOutputUnitStop(_outputUnit)
               operation:"Failed to stop output unit"];
    _isPlaying = NO;
  }
}

#pragma mark - Getters
-(AudioStreamBasicDescription)audioStreamBasicDescription {
  return _outputASBD;
}

-(BOOL)isPlaying {
  return _isPlaying;
}

#pragma mark - Setters
-(void)setAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
  BOOL wasPlaying = NO;
  if( self.isPlaying ){
    [self stopPlayback];
    wasPlaying = YES;
  }
  _customASBD = YES;
  _outputASBD = asbd;
  // Set the format for output
  [EZAudio checkResult:AudioUnitSetProperty(_outputUnit,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Input,
                                            0,
                                            &_outputASBD,
                                            sizeof(_outputASBD))
             operation:"Couldn't set the ASBD for input scope/bos 0"];
  if( wasPlaying )
  {
    [self startPlayback];
  }
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
