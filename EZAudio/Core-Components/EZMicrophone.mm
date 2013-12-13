//
//  EZMicrophone.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "EZMicrophone.h"

#ifndef MAC_OS_X_VERSION_10_7
// CoreServices defines eofErr, replaced in 10.7 by kAudioFileEndOfFileError
#include <CoreServices/CoreServices.h>
#endif

#import "../EZAudio.h"

@interface EZMicrophone (){
  /// Internal
  BOOL _isConfigured;
  BOOL _isFetching;
  
  /// Stream Description
  AEFloatConverter *converter;
  AudioStreamBasicDescription streamFormat;
  
  /// Audio Graph and Input/Output Units
  AUGraph   graph;
  AudioUnit microphoneInput;
  AudioUnit outputUnit;
  
  /// Audio Buffers
  float           **floatBuffers;
  AudioBufferList *microphoneInputBuffer;
  
  /// Sample Time Offsets
  Float64 firstInputSampleTime;
  Float64 inToOutSampleTimeOffset;
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
  OSStatus      result      = noErr;

#if TARGET_OS_IPHONE
  // Render audio into buffer
  result = AudioUnitRender(microphone->microphoneInput,
                           ioActionFlags,
                           inTimeStamp,
                           1,
                           inNumberFrames,
                           microphone->microphoneInputBuffer);
  //  CheckResult(result, "Could not render audio unit input buffer");
  if( !result ){
    AEFloatConverterToFloat(microphone->converter,
                            microphone->microphoneInputBuffer,
                            microphone->floatBuffers,
                            inNumberFrames);
  }
#elif TARGET_OS_MAC
  // Retrive the captured samples from the input
  result = AudioUnitRender(microphone->microphoneInput,
                           ioActionFlags,
                           inTimeStamp,
                           inBusNumber,
                           inNumberFrames,
                           microphone->microphoneInputBuffer);
  if( !result ){
    AEFloatConverterToFloat(microphone->converter,
                            microphone->microphoneInputBuffer,
                            microphone->floatBuffers,
                            inNumberFrames);
  }
#endif
  if( !result ){
    // Notify delegate (OF-style)
    @autoreleasepool {
      // Audio Received (float array)
      if( microphone.microphoneDelegate ){
        // THIS IS NOT OCCURING ON THE MAIN THREAD
        [microphone.microphoneDelegate microphone:microphone
                                 hasAudioReceived:microphone->floatBuffers
                                   withBufferSize:inNumberFrames
                             withNumberOfChannels:microphone->streamFormat.mChannelsPerFrame];
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
  }
  return self;
}

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate {
  self = [self init];
  if(self){
    self.microphoneDelegate = microphoneDelegate;
  }
  return self;
}

-(EZMicrophone *)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                           startsImmediately:(BOOL)startsImmediately {
  self = [self initWithMicrophoneDelegate:microphoneDelegate];
  if(self){
    if(startsImmediately){
      [self startFetchingAudio];
    }
  }
  return self;
}

#pragma mark - Class Initializers
+(EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate {
  return [[EZMicrophone alloc] initWithMicrophoneDelegate:microphoneDelegate];
}

+(EZMicrophone *)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                       startsImmediately:(BOOL)startsImmediately {
  return [[EZMicrophone alloc] initWithMicrophoneDelegate:microphoneDelegate
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
    if( !_isConfigured ){
      // Create the input audio graph
      [self _createInputUnit];
      // We're configured meow
      _isConfigured = YES;
    }
    // Start fetching input
    CheckResult(AudioOutputUnitStart(self->microphoneInput),
                "Microphone failed to start fetching audio");
    _isFetching = YES;
    self.microphoneOn = YES;
  }
}

-(void)stopFetchingAudio {
  // Stop fetching input data
  if( _isConfigured ){
    if( _isFetching ){
      CheckResult(AudioOutputUnitStop(self->microphoneInput),
                  "Microphone failed to stop fetching audio");
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

#if TARGET_OS_IPHONE
-(void)_createInputUnit {
  
  // Create localized copy of self
  EZMicrophone *microphone = (EZMicrophone*)self;
  
  AudioComponentDescription inputComponentDescription = {
    .componentType         = kAudioUnitType_Output,
    .componentSubType      = kAudioUnitSubType_RemoteIO,
    .componentManufacturer = kAudioUnitManufacturer_Apple,
    .componentFlags        = 0,
    .componentFlagsMask    = 0
  };
  
  // Try and find the component
  AudioComponent inputComponent = AudioComponentFindNext( NULL , &inputComponentDescription );
  if( inputComponent == NULL ){
    NSLog(@"Couldn't get input component unit!");
    return;
  }
  
  // Create a new instance of the component and store it for internal use
  CheckResult( AudioComponentInstanceNew(inputComponent,
                                         &microphone->microphoneInput),
              "Couldn't open component for microphone input unit.");
  
  // Enable I/O on microphone input unit
  UInt32         disableFlag = 1; UInt32         enableFlag = 1;
  AudioUnitScope outputBus   = 0; AudioUnitScope inputBus   = 1;
  CheckResult(AudioUnitSetProperty(microphone->microphoneInput,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Input,
                                   inputBus,
                                   &enableFlag,
                                   sizeof(enableFlag)),
              "Couldn't enable input on the remote i/o unit");
  
  
  // Could set the output if we wanted to play out the mic's buffer
  CheckResult(AudioUnitSetProperty(microphone->microphoneInput,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Output,
                                   outputBus,
                                   &disableFlag,
                                   sizeof(disableFlag)),
              "Couldn't enable input on the remote i/o unit");
  
  // Initialize the audio session
  // Get the hardware sample rate
  Float64 hardwareSampleRate = 44100;
#if !(TARGET_IPHONE_SIMULATOR)
  UInt32 propSize = sizeof(hardwareSampleRate);
  CheckResult(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
                                      &propSize,
                                      &hardwareSampleRate),
              "Could not get hardware sample rate");
#endif
  
  // Set the stream format
  microphone->streamFormat                   = {0};
  microphone->streamFormat.mBitsPerChannel   = 8 * sizeof(AudioUnitSampleType);
  microphone->streamFormat.mBytesPerFrame    = sizeof(AudioUnitSampleType);
  microphone->streamFormat.mBytesPerPacket   = sizeof(AudioUnitSampleType);
  microphone->streamFormat.mChannelsPerFrame = 2;
  microphone->streamFormat.mFormatFlags      = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
  microphone->streamFormat.mFormatID         = kAudioFormatLinearPCM;
  microphone->streamFormat.mFramesPerPacket  = 1;
	microphone->streamFormat.mSampleRate       = hardwareSampleRate;
  
  // Get the buffer duration (approximate for simulator, real device will have it's preferred value set)
  Float32 bufferDuration = 0.0232;
  UInt32 propertySize = sizeof(bufferDuration);
#if !(TARGET_IPHONE_SIMULATOR)
  CheckResult(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                                      sizeof(propertySize),
                                      &bufferDuration),
              "Couldn't set the preferred buffer duration");
  // Get the preferred buffer size
  CheckResult(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration,
                                      &propertySize,
                                      &bufferDuration),
              "Could not get preferred buffer size");
#endif
  
  // Create the audio buffer list and pre-malloc the buffers in the list
  propertySize = offsetof( AudioBufferList, mBuffers[0] ) + ( sizeof( AudioBuffer ) * microphone->streamFormat.mChannelsPerFrame );
  microphone->microphoneInputBuffer = (AudioBufferList*)malloc(propertySize);
  
  // Get the maximum number of frames
  UInt32 bufferSizeFrames;
  
  propertySize = sizeof(UInt32);
  CheckResult(AudioUnitGetProperty(microphone->microphoneInput,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   outputBus,
                                   &bufferSizeFrames,
                                   &propertySize),
              "Failed to get maximum number of frames");
  
  microphone->microphoneInputBuffer->mNumberBuffers = microphone->streamFormat.mChannelsPerFrame;
  UInt32 bufferSizeBytes = bufferSizeFrames * microphone->streamFormat.mBytesPerFrame;
  for( UInt32 i = 0; i < microphone->microphoneInputBuffer->mNumberBuffers; i++ ){
    microphone->microphoneInputBuffer->mBuffers[i].mNumberChannels = 1;
    microphone->microphoneInputBuffer->mBuffers[i].mDataByteSize   = bufferSizeBytes;
    microphone->microphoneInputBuffer->mBuffers[i].mData           = malloc(bufferSizeBytes);
  }
  
  // Setup the converter, but do a lazy set for the float buffer
  microphone->converter    = [[AEFloatConverter alloc] initWithSourceFormat:microphone->streamFormat];
  microphone->floatBuffers = (float**)malloc(sizeof(float*)*microphone->streamFormat.mChannelsPerFrame);
  for ( int i=0; i<microphone->streamFormat.mChannelsPerFrame; i++ ) {
    microphone->floatBuffers[i] = (float*)malloc(bufferSizeBytes);
    assert(microphone->floatBuffers[i]);
  }
  
  // Set the stream format for output on the microphone's input scope
  CheckResult(AudioUnitSetProperty(microphone->microphoneInput,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   outputBus,
                                   &microphone->streamFormat,
                                   sizeof(microphone->streamFormat)),
              "Could not set microphone's stream format bus 0");
  
  // Set the stream format for the input on the microphone's output scope
  CheckResult(AudioUnitSetProperty(microphone->microphoneInput,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Output,
                                   inputBus,
                                   &microphone->streamFormat,
                                   sizeof(microphone->streamFormat)),
              "Could not set microphone's stream format bus 1");

  // Notify delegate the audio stream basic description was successfully created
  if( microphone.microphoneDelegate ){
    if( [microphone.microphoneDelegate respondsToSelector:@selector(microphone:hasAudioStreamBasicDescription:) ] ){
      [microphone.microphoneDelegate microphone:microphone
                 hasAudioStreamBasicDescription:microphone->streamFormat];
    }
  }
  
  // Set the callback
  // Setup input callback
  AURenderCallbackStruct microphoneCallbackStruct;
  microphoneCallbackStruct.inputProc       = inputCallback;
  microphoneCallbackStruct.inputProcRefCon = (__bridge void *)microphone;
  CheckResult(AudioUnitSetProperty(microphone->microphoneInput,
                                   kAudioOutputUnitProperty_SetInputCallback,
                                   kAudioUnitScope_Global,
                                   inputBus,
                                   &microphoneCallbackStruct,
                                   sizeof(microphoneCallbackStruct)),
              "Couldn't set input callback");
  
  // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
  CheckResult(AudioUnitSetProperty(microphone->microphoneInput,
                                   kAudioUnitProperty_ShouldAllocateBuffer,
                                   kAudioUnitScope_Output,
                                   inputBus,
                                   &disableFlag,
                                   sizeof(disableFlag)),
              "Could not disable audio unit allocating its own buffers");
  
  // Initialize the audio unit
  CheckResult(AudioUnitInitialize( microphone->microphoneInput ),
              "Couldn't initialize the input unit");
  
}
#elif TARGET_OS_MAC
-(void)_createInputUnit {
  
  // Create localized copy of self
  EZMicrophone *microphone = (EZMicrophone*)self;
  
  // Create component description for input HAL
  AudioComponentDescription inputComponentDescription = {0};
  inputComponentDescription.componentType             = kAudioUnitType_Output;
  inputComponentDescription.componentSubType          = kAudioUnitSubType_HALOutput;
  inputComponentDescription.componentManufacturer     = kAudioUnitManufacturer_Apple;
  
  // Try and find the component
  AudioComponent inputComponent = AudioComponentFindNext( NULL , &inputComponentDescription );
  if( inputComponent == NULL ){
    NSLog(@"Couldn't get input component unit!");
    return;
  }
  
  // Create a new instance of the component and store it for internal use
  CheckResult(AudioComponentInstanceNew( inputComponent,
                                        &microphone->microphoneInput ),
              "Couldn't open component for microphone input unit.");
  
  // Enable I/O on microphone input unit
  UInt32         disableFlag = 0; UInt32         enableFlag = 1;
  AudioUnitScope outputBus   = 0; AudioUnitScope inputBus   = 1;
  // Input Scope
  CheckResult(AudioUnitSetProperty( microphone->microphoneInput,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Input,
                                   inputBus,
                                   &enableFlag,
                                   sizeof(enableFlag)),
              "Couldn't enable input on I/O unit.");
  // Output Scope
  CheckResult(AudioUnitSetProperty( microphone->microphoneInput,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Output,
                                   outputBus,
                                   &disableFlag,
                                   sizeof(enableFlag)),
              "Couldn't disable output on I/O unit.");
  
  // Get the default audio input device (pulls an abstract type from system preferences)
  AudioDeviceID              defaultDevice         = kAudioObjectUnknown;
  UInt32                     propertySize          = sizeof(defaultDevice);
  AudioObjectPropertyAddress defaultDeviceProperty;
  defaultDeviceProperty.mSelector                  = kAudioHardwarePropertyDefaultInputDevice;
  defaultDeviceProperty.mScope                     = kAudioObjectPropertyScopeGlobal;
  defaultDeviceProperty.mElement                   = kAudioObjectPropertyElementMaster;
  CheckResult(AudioObjectGetPropertyData( kAudioObjectSystemObject,
                                         &defaultDeviceProperty,
                                         0,
                                         NULL,
                                         &propertySize,
                                         &defaultDevice),
              "Couldn't get default input device");
  
  // Set the default device on the microphone input unit
  CheckResult(AudioUnitSetProperty( microphone->microphoneInput,
                                   kAudioOutputUnitProperty_CurrentDevice,
                                   kAudioUnitScope_Global,
                                   outputBus,
                                   &defaultDevice,
                                   sizeof(defaultDevice)),
              "Couldn't set default device on I/O unit");
  
  // Get the stream format description from the newly created input unit and assign it to the output of the input unit
  propertySize = sizeof(AudioStreamBasicDescription);
  CheckResult(AudioUnitGetProperty( microphone->microphoneInput,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Output,
                                   inputBus,
                                   &microphone->streamFormat,
                                   &propertySize),
              "Couldn't get ASBD from input unit (1)");
  
  // Assign the same stream format description from the output of the input unit and pull the sample rate
  AudioStreamBasicDescription deviceFormat;
  CheckResult(AudioUnitGetProperty( microphone->microphoneInput,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   inputBus,
                                   &deviceFormat,
                                   &propertySize),
              "Couldn't get ASBD from input unit (2)");
  
  microphone->streamFormat                   = {0};
  microphone->streamFormat.mBitsPerChannel   = 8 * sizeof(AudioUnitSampleType);
  microphone->streamFormat.mBytesPerFrame    = sizeof(AudioUnitSampleType);
  microphone->streamFormat.mBytesPerPacket   = sizeof(AudioUnitSampleType);
  microphone->streamFormat.mChannelsPerFrame = 2;
  microphone->streamFormat.mFormatFlags      = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
  microphone->streamFormat.mFormatID         = kAudioFormatLinearPCM;
  microphone->streamFormat.mFramesPerPacket  = 1;
	microphone->streamFormat.mSampleRate       = deviceFormat.mSampleRate;
  
  // Readjust property size for ASBD and set the value on the input unit
  propertySize = sizeof(AudioStreamBasicDescription);
  CheckResult(AudioUnitSetProperty( microphone->microphoneInput,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Output,
                                   inputBus,
                                   &microphone->streamFormat,
                                   propertySize),
              "Couldn't set ASBD on input unit");
  
  // Notify delegate the audio stream basic description was successfully created
  if( microphone.microphoneDelegate ){
    if( [microphone.microphoneDelegate respondsToSelector:@selector(microphone:hasAudioStreamBasicDescription:) ] ){
      [microphone.microphoneDelegate microphone:microphone
                 hasAudioStreamBasicDescription:microphone->streamFormat];
    }
  }
  
  // Setup the audio buffers to capture the input audio
  UInt32 bufferSizeFrames = 0;
  propertySize = sizeof(UInt32);
  CheckResult(AudioUnitGetProperty(microphone->microphoneInput,
                                   kAudioDevicePropertyBufferFrameSize,
                                   kAudioUnitScope_Global,
                                   outputBus,
                                   &bufferSizeFrames,
                                   &propertySize),
              "Could not get buffer frame size from input unit");
  
  UInt32 bufferSizeBytes = bufferSizeFrames * sizeof(Float32);
  
  // Create the audio buffer list and pre-malloc the buffers in the list
  propertySize = offsetof( AudioBufferList, mBuffers[0] ) + ( sizeof( AudioBuffer ) * microphone->streamFormat.mChannelsPerFrame );
  microphone->microphoneInputBuffer                 = (AudioBufferList*)malloc(propertySize);
  microphone->microphoneInputBuffer->mNumberBuffers = microphone->streamFormat.mChannelsPerFrame;
  for( UInt32 i = 0; i < microphone->microphoneInputBuffer->mNumberBuffers; i++ ){
    microphone->microphoneInputBuffer->mBuffers[i].mNumberChannels = 1;
    microphone->microphoneInputBuffer->mBuffers[i].mDataByteSize   = bufferSizeBytes;
    microphone->microphoneInputBuffer->mBuffers[i].mData           = malloc(bufferSizeBytes);
  }
  
  // Set the convert's stream format
  microphone->converter    = [[AEFloatConverter alloc] initWithSourceFormat:microphone->streamFormat];
  microphone->floatBuffers = (float**)malloc(sizeof(float*)*microphone->streamFormat.mChannelsPerFrame);
  assert(microphone->floatBuffers);
  for ( int i=0; i<microphone->streamFormat.mChannelsPerFrame; i++ ) {
    microphone->floatBuffers[i] = (float*)malloc(bufferSizeBytes);
    assert(microphone->floatBuffers[i]);
  }
  
  // Setup input callback
  AURenderCallbackStruct microphoneCallbackStruct;
  microphoneCallbackStruct.inputProc       = inputCallback;
  microphoneCallbackStruct.inputProcRefCon = (__bridge void *)microphone;
  CheckResult(AudioUnitSetProperty( microphone->microphoneInput,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Global,
                                    0,
                                    &microphoneCallbackStruct,
                                    sizeof(microphoneCallbackStruct)),
              "Couldn't set input callback");
  
  // Initialize the audio unit
  CheckResult(AudioUnitInitialize( microphone->microphoneInput ),
              "Couldn't initialize the input unit");
  microphone->firstInputSampleTime    = -1;
  microphone->inToOutSampleTimeOffset = -1;
  
}
#endif

@end
