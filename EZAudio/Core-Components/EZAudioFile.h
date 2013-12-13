//
//  EZAudioFile.h
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class EZAudio;

/**

 */
@interface EZAudioFile : NSObject

#pragma mark - Blocks
typedef void (^BufferListReadCompletionBlock)(AudioBufferList *audioBufferList,UInt32 bufferSize,BOOL *eof);
typedef void (^FloatReadCompletionBlock)(float *audioData,UInt32 bufferSize,BOOL *eof);

#pragma mark - Initializers
///-----------------------------------------------------------
/// @name Initialization
///-----------------------------------------------------------

/**
 *  <#Description#>
 *
 *  @param url <#url description#>
 *
 *  @return <#return value description#>
 */
-(EZAudioFile*)initWithURL:(NSURL*)url;

#pragma mark - Class Initializers
///-----------------------------------------------------------
/// @name Class Initializer
///-----------------------------------------------------------

/**
 *  <#Description#>
 *
 *  @param url <#url description#>
 *
 *  @return <#return value description#>
 */
+(EZAudioFile*)audioFileWithURL:(NSURL*)url;

#pragma mark - Class Methods
///-----------------------------------------------------------
/// @name Class Methods
///-----------------------------------------------------------

/**
 Provides an array of supported file types by their extensions (i.e. "mp3", "caf", etc.). Useful when allowing users to select files with a file panel.
 @return An array containing the supported audio file types as NSString objects.
 */
+(NSArray*)supportedAudioFileTypes;

#pragma mark - Events
///-----------------------------------------------------------
/// @name Reading The Audio File
///-----------------------------------------------------------

/**
   <#Description#>
 
   @param completionBlock <#completionBlock description#>
 */
-(void)readEntireFileWithBufferListCompletionBlock:(BufferListReadCompletionBlock)completionBlock;

/**
   <#Description#>
 
   @param completionBlock <#completionBlock description#>
 */
-(void)readEntireFileWithFloatCompletionBlock:(FloatReadCompletionBlock)completionBlock;

/**
 *  <#Description#>
 *
 *  @param frames          <#frames description#>
 *  @param audioBufferList <#audioBufferList description#>
 *  @param bufferSize      <#bufferSize description#>
 *  @param eof             <#eof description#>
 */
-(void)readFrames:(UInt32)frames
  audioBufferList:(AudioBufferList*)audioBufferList
       bufferSize:(UInt32*)bufferSize
              eof:(BOOL*)eof;

/**
   <#Description#>
 
   @param frames          <#frames description#>
   @param completionBlock <#completionBlock description#>
 */
-(void)readFrames:(UInt32)frames withBufferListCompletionBlock:(BufferListReadCompletionBlock)completionBlock;

/**
   <#Description#>
 
   @param frames          <#frames description#>
   @param completionBlock <#completionBlock description#>
 */
-(void)readFrames:(UInt32)frames withFloatCompletionBlock:(FloatReadCompletionBlock)completionBlock;

///-----------------------------------------------------------
/// @name Seeking Through The Audio File
///-----------------------------------------------------------

/**
 *  <#Description#>
 *
 *  @param frame <#frame description#>
 */
-(void)seekToFrame:(SInt64)frame;

#pragma mark - Getters
///-----------------------------------------------------------
/// @name Getting Information About The Audio File
///-----------------------------------------------------------

/**
 Provides the AudioStreamBasicDescription structure used within the app. The file's format will be converted to this format and then sent back as either a float array or a `AudioBufferList` pointer.
 @return An AudioStreamBasicDescription structure describing the format of the audio file.
 */
-(AudioStreamBasicDescription)clientFormat;

/**
 Provides the AudioStreamBasicDescription structure containing the format of the file.
 @return An AudioStreamBasicDescription structure describing the format of the audio file.
 */
-(AudioStreamBasicDescription)fileFormat;

/**
 Provides the frame index (a.k.a the seek positon) within the audio file as an integer. This can be helpful when seeking through the audio file.
 @return The current frame index within the audio file as a SInt64.
 */
-(SInt64)frameIndex;

/**
 Provides the total duration of the audio file in seconds.
 @return The total duration of the audio file as a Float32.
 */
-(Float32)totalDuration;

/**
 Provides the total frame count of the audio file.
 @return The total number of frames in the audio file as a SInt64.
 */
-(SInt64)totalFrames;

#pragma mark - Helpers
///-----------------------------------------------------------
/// @name Manipulating The Audio Data
///-----------------------------------------------------------

/**
 Provides the minimum number of buffers that would be required with the constant frames read rate provided.
 @return The minimum number of buffers required for the constant frames read rate provided as a UInt32.
 */
-(UInt32)minBuffersWithFrameRate:(UInt32)frameRate;

/**
 Provides a frame rate to use when drawing and averaging a bin of values to create each point in a graph. The ideal amount of end buffers seems to be between 1000-3000 so we determine a frame rate per audio file that can achieve a high degree of detail for the entire waveform.
 @return A frame rate value as a UInt32 to use when reading frames in a file.
 @see `readFrames:withFloatCompletionBlock:` Output of this function can be used in the provided read functions
 */
-(UInt32)recommendedDrawingFrameRate;

@end
