//
//  EZMicrophone.h
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

#import  <Foundation/Foundation.h>
#import  <AudioToolbox/AudioToolbox.h>
#import  "AEFloatConverter.h"
#import  "TargetConditionals.h"

@class EZAudio;
@class EZMicrophone;

#pragma mark - EZMicrophoneDelegate
/**
 The delegate for the EZMicrophone provides a receiver for the incoming audio data events. When the microphone has been successfully internally configured it will try to send its delegate an AudioStreamBasicDescription describing the format of the incoming audio data. 
 
 The audio data itself is sent back to the delegate in various forms:
 
   -`microphone:hasAudioReceived:withBufferSize:withNumberOfChannels:`
     Provides float arrays instead of the AudioBufferList structure to hold the audio data. There could be a number of float arrays depending on the number of channels (see the function description below). These are useful for doing any visualizations that would like to make use of the raw audio data.
 
   -`microphone:hasBufferList:withBufferSize:withNumberOfChannels:`
     Provides the AudioBufferList structures holding the audio data. These are the native structures Core Audio uses to hold the buffer information and useful for piping out directly to an output (see EZOutput).
 
 */
@protocol EZMicrophoneDelegate <NSObject>

@optional
///-----------------------------------------------------------
/// @name Audio Data Description
///-----------------------------------------------------------

/**
 Returns back the audio stream basic description as soon as it has been initialized. This is guaranteed to occur before the stream callbacks, `microphone:hasBufferList:withBufferSize:withNumberOfChannels:` or `microphone:hasAudioReceived:withBufferSize:withNumberOfChannels:`
 @param microphone The instance of the EZMicrophone that triggered the event.
 @param audioStreamBasicDescription The AudioStreamBasicDescription that was created for the microphone instance.
 */
-(void)              microphone:(EZMicrophone *)microphone
 hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;

///-----------------------------------------------------------
/// @name Audio Data Callbacks
///-----------------------------------------------------------

/**
 Returns back a float array of the audio received. This occurs on the background thread so any drawing code must explicity perform its functions on the main thread.
 @param microphone       The instance of the EZMicrophone that triggered the event.
 @param buffer           The audio data as an array of float arrays. In a stereo signal buffer[0] represents the left channel while buffer[1] would represent the right channel.
 @param bufferSize       The size of each of the buffers (the length of each float array).
 @param numberOfChannels The number of channels for the incoming audio.
 @warning This function executes on a background thread to avoid blocking any audio operations. If operations should be performed on any other thread (like the main thread) it should be performed within a dispatch block like so: dispatch_async(dispatch_get_main_queue(), ^{ ...Your Code... })
 */
-(void)    microphone:(EZMicrophone*)microphone
     hasAudioReceived:(float**)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels;

/**
 Returns back the buffer list containing the audio received. This occurs on the background thread so any drawing code must explicity perform its functions on the main thread.
 @param microphone       The instance of the EZMicrophone that triggered the event.
 @param bufferList       The AudioBufferList holding the audio data.
 @param bufferSize       The size of each of the buffers of the AudioBufferList.
 @param numberOfChannels The number of channels for the incoming audio.
 @warning This function executes on a background thread to avoid blocking any audio operations. If operations should be performed on any other thread (like the main thread) it should be performed within a dispatch block like so: dispatch_async(dispatch_get_main_queue(), ^{ ...Your Code... })
 */
-(void)    microphone:(EZMicrophone*)microphone
        hasBufferList:(AudioBufferList*)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels;

@end

#pragma mark - EZMicrophone
/**
 The EZMicrophone provides a component to get audio data from the default device microphone. On OSX this is the default selected input device in the system preferences while on iOS this defaults to use the default RemoteIO audio unit. The microphone data is converted to a float buffer array and returned back to the caller via the EZMicrophoneDelegate protocol.
 */
@interface EZMicrophone : NSObject

/**
 The EZMicrophoneDelegate for which to handle the microphone callbacks
 */
@property (nonatomic,assign) id<EZMicrophoneDelegate> microphoneDelegate;

/**
 A bool describing whether the microphone is on and passing back audio data to its delegate.
 */
@property (nonatomic,assign) BOOL microphoneOn;

#pragma mark - Initializers
///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback. This will not start fetching the audio until startFetchingAudio has been called. Use initWithMicrophoneDelegate:startsImmediately: to instantiate this class and immediately start fetching audio data.
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */
-(EZMicrophone*)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate;

/**
 Creates an instance of the EZMicrophone with a custom AudioStreamBasicDescription and provides the caller to specify a delegate to respond to the audioReceived callback. This will not start fetching the audio until startFetchingAudio has been called. Use initWithMicrophoneDelegate:startsImmediately: to instantiate this class and immediately start fetching audio data.
 @param 	microphoneDelegate 	        A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param 	audioStreamBasicDescription A custom AudioStreamBasicFormat for the microphone input.
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */
-(EZMicrophone*)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
           withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param 	startsImmediately 	A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */
-(EZMicrophone*)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                          startsImmediately:(BOOL)startsImmediately;

/**
 Creates an instance of the EZMicrophone with a custom AudioStreamBasicDescription and provides the caller with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param 	audioStreamBasicDescription A custom AudioStreamBasicFormat for the microphone input.
 @param 	startsImmediately 	A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 @return	An instance of the EZMicrophone class. This should be strongly retained.
 */
-(EZMicrophone*)initWithMicrophoneDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
           withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
                         startsImmediately:(BOOL)startsImmediately;

#pragma mark - Class Initializers
///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback. This will not start fetching the audio until startFetchingAudio has been called. Use microphoneWithDelegate:startsImmediately: to instantiate this class and immediately start fetching audio data.
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @return	An instance of the EZMicrophone class. This should be declared as a strong property!
 */
+(EZMicrophone*)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate;

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback. This will not start fetching the audio until startFetchingAudio has been called. Use microphoneWithDelegate:startsImmediately: to instantiate this class and immediately start fetching audio data.
 @param 	microphoneDelegate 	A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param 	audioStreamBasicDescription A custom AudioStreamBasicFormat for the microphone input.
 @return	An instance of the EZMicrophone class. This should be declared as a strong property!
 */
+(EZMicrophone*)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
       withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 
 @param microphoneDelegate A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param startsImmediately  A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 @return An instance of the EZMicrophone class. This should be strongly retained.
 */
+(EZMicrophone*)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
                      startsImmediately:(BOOL)startsImmediately;

/**
 Creates an instance of the EZMicrophone with a delegate to respond to the audioReceived callback and allows the caller to specify whether they'd immediately like to start fetching the audio data.
 
 @param microphoneDelegate A EZMicrophoneDelegate delegate that will receive the audioReceived callback.
 @param audioStreamBasicDescription A custom AudioStreamBasicFormat for the microphone input.
 @param startsImmediately  A boolean indicating whether to start fetching the data immediately. IF YES, the delegate's audioReceived callback will immediately start getting called.
 @return An instance of the EZMicrophone class. This should be strongly retained.
 */
+(EZMicrophone*)microphoneWithDelegate:(id<EZMicrophoneDelegate>)microphoneDelegate
       withAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
                     startsImmediately:(BOOL)startsImmediately;

#pragma mark - Singleton
///-----------------------------------------------------------
/// @name Shared Instance
///-----------------------------------------------------------

/**
 A shared instance of the microphone component. Most applications will only need to use one instance of the microphone component across multiple views. Make sure to call the `startFetchingAudio` method to receive the audio data in the microphone delegate.
 @return A shared instance of the `EZAudioMicrophone` component.
 */
+(EZMicrophone*)sharedMicrophone;

#pragma mark - Events
///-----------------------------------------------------------
/// @name Starting/Stopping The Microphone
///-----------------------------------------------------------

/**
 Starts fetching audio from the default microphone. Will notify delegate with audioReceived callback.
 */
-(void)startFetchingAudio;

/**
 Stops fetching audio. Will stop notifying the delegate's audioReceived callback.
 */
-(void)stopFetchingAudio;

#pragma mark - Getters
///-----------------------------------------------------------
/// @name Getting The Microphone's Audio Format
///-----------------------------------------------------------

/**
 Provides the AudioStreamBasicDescription structure containing the format of the microphone's audio.
 @return An AudioStreamBasicDescription structure describing the format of the microphone's audio.
 */
-(AudioStreamBasicDescription)audioStreamBasicDescription;

#pragma mark - Setters
///-----------------------------------------------------------
/// @name Customizing The Microphone Input Format
///-----------------------------------------------------------

/**
 Sets the AudioStreamBasicDescription on the microphone input.
 @warning Do not set this while fetching audio (startFetchingAudio)
 @param asbd The new AudioStreamBasicDescription to use in place of the current audio format description.
 */
-(void)setAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;

@end
