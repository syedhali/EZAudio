//
//  EZMicrophone.h
//  SHAAudio
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import  <Foundation/Foundation.h>
#import  <AudioToolbox/AudioToolbox.h>
#import  "../3rd-Party-Components/AEFloatConverter.h"
#import  "TargetConditionals.h"

@class EZAudio;
@class EZMicrophone;

#pragma mark - EZMicrophoneDelegate
/**
 *  <#Description#>
 */
@protocol EZMicrophoneDelegate <NSObject>

@optional
/**
 Returns back the buffer list containing the audio received. This occurs on the background thread so any drawing code must explicity perform its functions on the main thread.
 
 @param microphone       <#microphone description#>
 @param bufferList       <#bufferList description#>
 @param bufferSize       <#bufferSize description#>
 @param numberOfChannels <#numberOfChannels description#>
 
 @warning This function executes on a background thread to avoid blocking any audio operations. If operations should be performed on any other thread (like the main thread) it should be performed within a dispatch block like so: dispatch_async(dispatch_get_main_queue(), ^{ ...Your Code... })
 
 */
-(void)    microphone:(EZMicrophone*)microphone
        hasBufferList:(AudioBufferList*)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels;

/**
 Returns back the audio stream basic description as soon as it has been initialized. This is guaranteed to occur before the stream callbacks, `microphone:hasBufferList:withBufferSize:withNumberOfChannels:` or `microphone:hasAudioReceived:withBufferSize:withNumberOfChannels:`

 @param microphone                  The `EZMicrophone` instance for which the audio stream basic description was created
 @param audioStreamBasicDescription The `AudioStreamBasicDescription` that was created for the microphone instance
 */
-(void)              microphone:(EZMicrophone *)microphone
 hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;

@required
/**
 
 Returns back a float array of the audio received. This occurs on the background thread so any drawing code must explicity perform its functions on the main thread.
 
 @param microphone       <#microphone description#>
 @param buffer           <#buffer description#>
 @param bufferSize       <#bufferSize description#>
 @param numberOfChannels <#numberOfChannels description#>
 
  @warning This function executes on a background thread to avoid blocking any audio operations. If operations should be performed on any other thread (like the main thread) it should be performed within a dispatch block like so: dispatch_async(dispatch_get_main_queue(), ^{ ...Your Code... })
 
 */
-(void)    microphone:(EZMicrophone*)microphone
     hasAudioReceived:(float**)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels;

@end

#pragma mark - EZMicrophone
/**
 A component to get audio data from the default microphone. On OSX this is the default selected input device in the system preferences while on iOS this defaults to use the default RemoteIO audio unit. The microphone data is converted to a float buffer array and returned back to the caller via the `EZMicrophoneDelegate` protocol.
 */
@interface EZMicrophone : NSObject

/**
 The receiver for which to handle the microphone callbacks
 */
@property (nonatomic,assign) id<EZMicrophoneDelegate> microphoneDelegate;

/**
 A bool describing whether the microphone is on and passing back audio data to its delegate.
 */
@property (nonatomic,assign) BOOL microphoneOn;

#pragma mark - Initializers
/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback. This will not start fetching the audio until startFetchingAudio has been called. Use initWithMicrophoneDelegate:startsImmediately: to instantiate this class and immediately start fetching audio data.
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */
-(EZMicrophone*)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate;

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param 	startsImmediately 	A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */
-(EZMicrophone*)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                          startsImmediately:(BOOL)startsImmediately;

#pragma mark - Class Initializers
/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback. This will not start fetching the audio until startFetchingAudio has been called. Use microphoneWithDelegate:startsImmediately: to instantiate this class and immediately start fetching audio data.
 
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 
 @return	An instance of the EZMicrophone class. This should be declared as a strong property!
 */
+(EZMicrophone*)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate;

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param 	startsImmediately 	A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 
 @param microphoneDelegate A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param startsImmediately  A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 @return An instance of the EZMicrophone class. This should be strongly retained.
 */
+(EZMicrophone*)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                      startsImmediately:(BOOL)startsImmediately;

#pragma mark - Singleton
/**
 A shared instance of the microphone component. Most applications will only need to use one instance of the microphone component across multiple views. Make sure to call the `startFetchingAudio` method to receive the audio data in the microphone delegate.
 @return A shared instance of the `EZAudioMicrophone` component.
 */
+(EZMicrophone*)sharedMicrophone;

#pragma mark - Events
/**
 Starts fetching audio from the default microphone. Will notify delegate with audioReceived callback.
 */
-(void)startFetchingAudio;

/**
 Stops fetching audio. Will stop notifying the delegate's audioReceived callback.
 */
-(void)stopFetchingAudio;

#pragma mark - Getters
/**
 Provides the AudioStreamBasicDescription structure containing the format of the microphone's audio.
 @return An AudioStreamBasicDescription structure describing the format of the microphone's audio.
 */
-(AudioStreamBasicDescription)audioStreamBasicDescription;

@end
