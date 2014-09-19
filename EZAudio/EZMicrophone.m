//
//  EZMicrophone.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
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

#import "EZMicrophone.h"

#ifndef MAC_OS_X_VERSION_10_7
// CoreServices defines eofErr, replaced in 10.7 by kAudioFileEndOfFileError
#include <CoreServices/CoreServices.h>
#endif

#import "EZAudio.h"

/// Buses
static const AudioUnitScope kEZAudioMicrophoneInputBus  = 1;
static const AudioUnitScope kEZAudioMicrophoneOutputBus = 0;

/// Flags
#if TARGET_OS_IPHONE
static const UInt32 kEZAudioMicrophoneDisableFlag = 1;
#elif TARGET_OS_MAC
static const UInt32 kEZAudioMicrophoneDisableFlag = 0;
#endif
static const UInt32 kEZAudioMicrophoneEnableFlag  = 1;

@interface EZMicrophone (){
  /// Internal
  BOOL _customASBD;
  BOOL _isConfigured;
  BOOL _isFetching;
  
  /// Stream Description
  AEFloatConverter            *converter;
  AudioStreamBasicDescription streamFormat;
  
  /// Audio Graph and Input/Output Units
  AudioUnit microphoneInput;
  
  /// Audio Buffers
  float           **floatBuffers;
  AudioBufferList *microphoneInputBuffer;
  
  /// Device Parameters
  Float64 _deviceSampleRate;
  Float32 _deviceBufferDuration;
  UInt32  _deviceBufferFrameSize;
  
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
  Float64 inputScopeSampleRate;
#endif
  
}
@end

@implementation EZMicrophone
@synthesize microphoneDelegate = _microphoneDelegate;
@synthesize microphoneOn = _microphoneOn;

#pragma mark - Callbacks
static OSStatus inputCallback(void                          *inRefCon,
                              AudioUnitRenderActionFlags    *ioActionFlags,
                              const AudioTimeStamp          *inTimeStamp,
                              UInt32                        inBusNumber,
                              UInt32                        inNumberFrames,
                              AudioBufferList               *ioData ) {
  EZMicrophone *microphone = (__bridge EZMicrophone*)inRefCon;
  OSStatus      result     = noErr;
  // Render audio into buffer
  result = AudioUnitRender(microphone->microphoneInput,
                           ioActionFlags,
                           inTimeStamp,
                           inBusNumber,
                           inNumberFrames,
                           microphone->microphoneInputBuffer);
  if( !result ){
    // ----- Notify delegate (OF-style) -----
    // Audio Received (float array)
    if( microphone.microphoneDelegate ){
      // THIS IS NOT OCCURING ON THE MAIN THREAD
      if( [microphone.microphoneDelegate respondsToSelector:@selector(microphone:hasAudioReceived:withBufferSize:withNumberOfChannels:)] ){
        AEFloatConverterToFloat(microphone->converter,
                                microphone->microphoneInputBuffer,
                                microphone->floatBuffers,
                                inNumberFrames);
        [microphone.microphoneDelegate microphone:microphone
                                 hasAudioReceived:microphone->floatBuffers
                                   withBufferSize:inNumberFrames
                             withNumberOfChannels:microphone->streamFormat.mChannelsPerFrame];
      }
    }
    // Audio Received (buffer list)
    if( microphone.microphoneDelegate ){
      if( [microphone.microphoneDelegate respondsToSelector:@selector(microphone:hasBufferList:withBufferSize:withNumberOfChannels:)] ){
        [microphone.microphoneDelegate microphone:microphone
                                    hasBufferList:microphone->microphoneInputBuffer
                                   withBufferSize:inNumberFrames
                             withNumberOfChannels:microphone->streamFormat.mChannelsPerFrame];
      }
    }
  }
  return result;
}

#pragma mark - Initialization
-(id)init {
  self = [super init];
  if(self){
    // Clear the float buffer
    floatBuffers = NULL;
    // We're not fetching anything yet
    _isConfigured = NO;
    _isFetching   = NO;
    if( !_isConfigured ){
      // Create the input audio graph
      [self _createInputUnit];
      // We're configured meow
      _isConfigured = YES;
    }
  }
  return self;
}

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate {
  self = [super init];
  if(self){
    self.microphoneDelegate = microphoneDelegate;
    // Clear the float buffer
    floatBuffers = NULL;
    // We're not fetching anything yet
    _isConfigured = NO;
    _isFetching   = NO;
    if( !_isConfigured ){
      // Create the input audio graph
      [self _createInputUnit];
      // We're configured meow
      _isConfigured = YES;
    }
  }
  return self;
}

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
            withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
  self = [self initWithMicrophoneDelegate:microphoneDelegate];
  if(self){
    _customASBD  = YES;
    streamFormat = audioStreamBasicDescription;
  }
  return self;
}

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                           startsImmediately:(BOOL)startsImmediately {
  self = [self initWithMicrophoneDelegate:microphoneDelegate];
  if(self){
    startsImmediately ? [self startFetchingAudio] : -1;
  }
  return self;
}

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
            withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
                          startsImmediately:(BOOL)startsImmediately {
  self = [self initWithMicrophoneDelegate:microphoneDelegate withAudioStreamBasicDescription:audioStreamBasicDescription];
  if(self){
    startsImmediately ? [self startFetchingAudio] : -1;
  }
  return self;
}

#pragma mark - Class Initializers
+(EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate {
  return [[EZMicrophone alloc] initWithMicrophoneDelegate:microphoneDelegate];
}

+(EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
        withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
  return [[EZMicrophone alloc] initWithMicrophoneDelegate:microphoneDelegate
                          withAudioStreamBasicDescription:audioStreamBasicDescription];
}

+(EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                       startsImmediately:(BOOL)startsImmediately {
  return [[EZMicrophone alloc] initWithMicrophoneDelegate:microphoneDelegate
                                         startsImmediately:startsImmediately];
}

+(EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
        withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
                      startsImmediately:(BOOL)startsImmediately {
  return [[EZMicrophone alloc] initWithMicrophoneDelegate:microphoneDelegate
                          withAudioStreamBasicDescription:audioStreamBasicDescription
                                        startsImmediately:startsImmediately];
}

#pragma mark - Singleton
+(EZMicrophone*)sharedMicrophone {
  static EZMicrophone *_sharedMicrophone = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedMicrophone = [[EZMicrophone alloc] init];
  });
  return _sharedMicrophone;
}

#pragma mark - Events
-(void)startFetchingAudio {
  if( !_isFetching ){
    // Start fetching input
    [EZAudio checkResult:AudioOutputUnitStart(self->microphoneInput)
               operation:"Microphone failed to start fetching audio"];
    _isFetching = YES;
    self.microphoneOn = YES;
  }
}

-(void)stopFetchingAudio {
  // Stop fetching input data
  if( _isConfigured ){
    if( _isFetching ){
      [EZAudio checkResult:AudioOutputUnitStop(self->microphoneInput)
                 operation:"Microphone failed to stop fetching audio"];
      _isFetching = NO;
      self.microphoneOn = NO;
    }
  }
}

#pragma mark - Getters
-(AudioStreamBasicDescription)audioStreamBasicDescription {
  return streamFormat;
}

#pragma mark - Setter
-(void)setMicrophoneOn:(BOOL)microphoneOn {
  _microphoneOn = microphoneOn;
  if( microphoneOn ){
    [self startFetchingAudio];
  }
  else {
    [self stopFetchingAudio];
  }
}

-(void)setAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
  if( self.microphoneOn ){
    NSAssert(self.microphoneOn,@"Cannot set the AudioStreamBasicDescription while microphone is fetching audio");
  }
  else {
    _customASBD = YES;
    streamFormat = asbd;
    [self _configureStreamFormatWithSampleRate:_deviceSampleRate];
  }  
}

#pragma mark - Configure The Input Unit

-(void)_createInputUnit {
  
  // Get component description for input
  AudioComponentDescription inputComponentDescription = [self _getInputAudioComponentDescription];
  
  // Get the input component
  AudioComponent inputComponent = [self _getInputComponentWithAudioComponentDescription:inputComponentDescription];
  
  // Create a new instance of the component and store it for internal use
  [self _createNewInstanceForInputComponent:inputComponent];
  
  // Enable Input Scope
  [self _enableInputScope];
  
  // Disable Output Scope
  [self _disableOutputScope];
  
  // Get the default device if we need to (OSX only, iOS uses RemoteIO)
  #if TARGET_OS_IPHONE
    // Do nothing (using RemoteIO)
  #elif TARGET_OS_MAC
    [self _configureDefaultDevice];
  #endif
  
  // Configure device and pull hardware specific sampling rate (default = 44.1 kHz)
  _deviceSampleRate = [self _configureDeviceSampleRateWithDefault:44100.0];
  
  // Configure device and pull hardware specific buffer duration (default = 0.0232)
  _deviceBufferDuration = [self _configureDeviceBufferDurationWithDefault:0.0232];
  
  // Configure the stream format with the hardware sample rate
  [self _configureStreamFormatWithSampleRate:_deviceSampleRate];
  
  // Notify delegate the audio stream basic description was successfully created
  [self _notifyDelegateOfStreamFormat];
  
  // Get buffer frame size
  _deviceBufferFrameSize = [self _getBufferFrameSize];
  
  // Create the audio buffer list and pre-malloc the buffers in the list
  [self _configureAudioBufferListWithFrameSize:_deviceBufferFrameSize];
  
  // Set the float converter's stream format
  [self _configureFloatConverterWithFrameSize:_deviceBufferFrameSize];
  
  // Setup input callback
  [self _configureInputCallback];
  
  // Disable buffer allocation (optional - do this if we want to pass in our own)
  [self _disableCallbackBufferAllocation];
  
  // Initialize the audio unit
  [EZAudio checkResult:AudioUnitInitialize( microphoneInput )
             operation:"Couldn't initialize the input unit"];
  
}

#pragma mark - Audio Component Initialization
-(AudioComponentDescription)_getInputAudioComponentDescription {
  
  // Create an input component description for mic input
  AudioComponentDescription inputComponentDescription;
  inputComponentDescription.componentType             = kAudioUnitType_Output;
  inputComponentDescription.componentManufacturer     = kAudioUnitManufacturer_Apple;
  inputComponentDescription.componentFlags            = 0;
  inputComponentDescription.componentFlagsMask        = 0;
  #if TARGET_OS_IPHONE
    inputComponentDescription.componentSubType          = kAudioUnitSubType_RemoteIO;
  #elif TARGET_OS_MAC
    inputComponentDescription.componentSubType          = kAudioUnitSubType_HALOutput;
  #endif
  
  // Return the successfully created input component description
  return inputComponentDescription;
  
}

-(AudioComponent)_getInputComponentWithAudioComponentDescription:(AudioComponentDescription)audioComponentDescription {
  
  // Try and find the component
  AudioComponent inputComponent = AudioComponentFindNext( NULL , &audioComponentDescription );
  NSAssert(inputComponent,@"Couldn't get input component unit!");
  return inputComponent;
  
}

-(void)_createNewInstanceForInputComponent:(AudioComponent)audioComponent {
  
  [EZAudio checkResult:AudioComponentInstanceNew(audioComponent,
                                                 &microphoneInput )
             operation:"Couldn't open component for microphone input unit."];
  
}

#pragma mark - Input/Output Scope Initialization
-(void)_disableOutputScope {
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioOutputUnitProperty_EnableIO,
                                            kAudioUnitScope_Output,
                                            kEZAudioMicrophoneOutputBus,
                                            &kEZAudioMicrophoneDisableFlag,
                                            sizeof(kEZAudioMicrophoneDisableFlag))
             operation:"Couldn't disable output on I/O unit."];
}

-(void)_enableInputScope {
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioOutputUnitProperty_EnableIO,
                                            kAudioUnitScope_Input,
                                            kEZAudioMicrophoneInputBus,
                                            &kEZAudioMicrophoneEnableFlag,
                                            sizeof(kEZAudioMicrophoneEnableFlag))
             operation:"Couldn't enable input on I/O unit."];
}

#pragma mark - Pull Default Device (OSX)
#if TARGET_OS_IPHONE
  // Not needed, using RemoteIO
#elif TARGET_OS_MAC
-(void)_configureDefaultDevice {
  // Get the default audio input device (pulls an abstract type from system preferences)
  AudioDeviceID defaultDevice = kAudioObjectUnknown;
  UInt32 propSize = sizeof(defaultDevice);
  AudioObjectPropertyAddress defaultDeviceProperty;
  defaultDeviceProperty.mSelector                  = kAudioHardwarePropertyDefaultInputDevice;
  defaultDeviceProperty.mScope                     = kAudioObjectPropertyScopeGlobal;
  defaultDeviceProperty.mElement                   = kAudioObjectPropertyElementMaster;
  [EZAudio checkResult:AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                                  &defaultDeviceProperty,
                                                  0,
                                                  NULL,
                                                  &propSize,
                                                  &defaultDevice)
             operation:"Couldn't get default input device"];
  
  // Set the default device on the microphone input unit
  propSize = sizeof(defaultDevice);
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioOutputUnitProperty_CurrentDevice,
                                            kAudioUnitScope_Global,
                                            kEZAudioMicrophoneOutputBus,
                                            &defaultDevice,
                                            propSize)
             operation:"Couldn't set default device on I/O unit"];
  
  // Get the stream format description from the newly created input unit and assign it to the output of the input unit
  AudioStreamBasicDescription inputScopeFormat;
  propSize = sizeof(AudioStreamBasicDescription);
  [EZAudio checkResult:AudioUnitGetProperty(microphoneInput,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Output,
                                            kEZAudioMicrophoneInputBus,
                                            &inputScopeFormat,
                                            &propSize)
             operation:"Couldn't get ASBD from input unit (1)"];
  
  // Assign the same stream format description from the output of the input unit and pull the sample rate
  AudioStreamBasicDescription outputScopeFormat;
  propSize = sizeof(AudioStreamBasicDescription);
  [EZAudio checkResult:AudioUnitGetProperty(microphoneInput,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Input,
                                            kEZAudioMicrophoneInputBus,
                                            &outputScopeFormat,
                                            &propSize)
             operation:"Couldn't get ASBD from input unit (2)"];
  
  // Store the input scope's sample rate
  inputScopeSampleRate = inputScopeFormat.mSampleRate;
  
}
#endif

#pragma mark - Pull Sample Rate
-(Float64)_configureDeviceSampleRateWithDefault:(float)defaultSampleRate {
  Float64 hardwareSampleRate = defaultSampleRate;
  #if TARGET_OS_IPHONE
    // Use approximations for simulator and pull from real device if connected
    #if !(TARGET_IPHONE_SIMULATOR)
    // Sample Rate
    hardwareSampleRate = [[AVAudioSession sharedInstance] sampleRate];
    #endif
  #elif TARGET_OS_MAC
    hardwareSampleRate = inputScopeSampleRate;
  #endif
  return hardwareSampleRate;
}

#pragma mark - Pull Buffer Duration
-(Float32)_configureDeviceBufferDurationWithDefault:(float)defaultBufferDuration {
  Float32 bufferDuration = defaultBufferDuration; // Type 1/43 by default
  #if TARGET_OS_IPHONE
  // Use approximations for simulator and pull from real device if connected
    #if !(TARGET_IPHONE_SIMULATOR)
        NSError *err;
        [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:bufferDuration error:&err];
        if (err) {
            NSLog(@"Error setting preferredIOBufferDuration for audio session: %@", err.localizedDescription);
        }
        
        // Buffer Size
        bufferDuration = [[AVAudioSession sharedInstance] IOBufferDuration];
    #endif
  #elif TARGET_OS_MAC
  
  #endif
  return bufferDuration;
}

#pragma mark - Pull Buffer Frame Size
-(UInt32)_getBufferFrameSize {
  UInt32 bufferFrameSize;
  UInt32 propSize = sizeof(bufferFrameSize);
  [EZAudio checkResult:AudioUnitGetProperty(microphoneInput,
                                            #if TARGET_OS_IPHONE
                                              kAudioUnitProperty_MaximumFramesPerSlice,
                                            #elif TARGET_OS_MAC
                                              kAudioDevicePropertyBufferFrameSize,
                                            #endif
                                            kAudioUnitScope_Global,
                                            kEZAudioMicrophoneOutputBus,
                                            &bufferFrameSize,
                                            &propSize)
             operation:"Failed to get buffer frame size"];
  return bufferFrameSize;
}

#pragma mark - Stream Format Initialization
-(void)_configureStreamFormatWithSampleRate:(Float64)sampleRate {
  // Set the stream format
  if( !_customASBD ){
    streamFormat = [EZAudio stereoCanonicalNonInterleavedFormatWithSampleRate:sampleRate];
  }
  else {
    streamFormat.mSampleRate = sampleRate;
  }
  UInt32 propSize = sizeof(streamFormat);
  // Set the stream format for output on the microphone's input scope
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Input,
                                            kEZAudioMicrophoneOutputBus,
                                            &streamFormat,
                                            propSize)
             operation:"Could not set microphone's stream format bus 0"];
  
  // Set the stream format for the input on the microphone's output scope
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioUnitProperty_StreamFormat,
                                            kAudioUnitScope_Output,
                                            kEZAudioMicrophoneInputBus,
                                            &streamFormat,
                                            propSize)
             operation:"Could not set microphone's stream format bus 1"];
}

-(void)_notifyDelegateOfStreamFormat {
  if( _microphoneDelegate ){
    if( [_microphoneDelegate respondsToSelector:@selector(microphone:hasAudioStreamBasicDescription:) ] ){
      [_microphoneDelegate microphone:self
       hasAudioStreamBasicDescription:streamFormat];
    }
  }
}

#pragma mark - AudioBufferList Initialization
-(void)_configureAudioBufferListWithFrameSize:(UInt32)bufferFrameSize {
  UInt32 bufferSizeBytes = bufferFrameSize * streamFormat.mBytesPerFrame;
  UInt32 propSize = offsetof( AudioBufferList, mBuffers[0] ) + ( sizeof( AudioBuffer ) *streamFormat.mChannelsPerFrame );
  microphoneInputBuffer                 = (AudioBufferList*)malloc(propSize);
  microphoneInputBuffer->mNumberBuffers = streamFormat.mChannelsPerFrame;
  for( UInt32 i = 0; i < microphoneInputBuffer->mNumberBuffers; i++ ){
    microphoneInputBuffer->mBuffers[i].mNumberChannels = streamFormat.mChannelsPerFrame;
    microphoneInputBuffer->mBuffers[i].mDataByteSize   = bufferSizeBytes;
    microphoneInputBuffer->mBuffers[i].mData           = malloc(bufferSizeBytes);
  }
}

#pragma mark - Float Converter Initialization
-(void)_configureFloatConverterWithFrameSize:(UInt32)bufferFrameSize {
  UInt32 bufferSizeBytes = bufferFrameSize * streamFormat.mBytesPerFrame;
  converter              = [[AEFloatConverter alloc] initWithSourceFormat:streamFormat];
  floatBuffers           = (float**)malloc(sizeof(float*)*streamFormat.mChannelsPerFrame);
  assert(floatBuffers);
  for ( int i=0; i<streamFormat.mChannelsPerFrame; i++ ) {
    floatBuffers[i] = (float*)malloc(bufferSizeBytes);
    assert(floatBuffers[i]);
  }
}

#pragma mark - Input Callback Initialization
-(void)_configureInputCallback {
  AURenderCallbackStruct microphoneCallbackStruct;
  microphoneCallbackStruct.inputProc       = inputCallback;
  microphoneCallbackStruct.inputProcRefCon = (__bridge void *)self;
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioOutputUnitProperty_SetInputCallback,
                                            kAudioUnitScope_Global,
                                            // output bus for mac
                                            #if TARGET_OS_IPHONE
                                              kEZAudioMicrophoneInputBus,
                                            #elif TARGET_OS_MAC
                                              kEZAudioMicrophoneOutputBus,
                                            #endif
                                            &microphoneCallbackStruct,
                                            sizeof(microphoneCallbackStruct))
             operation:"Couldn't set input callback"];
}

-(void)_disableCallbackBufferAllocation {
  [EZAudio checkResult:AudioUnitSetProperty(microphoneInput,
                                            kAudioUnitProperty_ShouldAllocateBuffer,
                                            kAudioUnitScope_Output,
                                            kEZAudioMicrophoneInputBus,
                                            &kEZAudioMicrophoneDisableFlag,
                                            sizeof(kEZAudioMicrophoneDisableFlag))
             operation:"Could not disable audio unit allocating its own buffers"];
}

@end
