//
//  SHAAudio.h
//  SHAAudio
//
//  Created by Syed Haris Ali on 11/21/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 3rd Party Utilties
#import "AEFloatConverter.h"
#import "TPCircularBuffer.h"

#pragma mark - Core Components
#import "EZAudioFile.h"
#import "EZMicrophone.h"
#import "EZOutput.h"
#import "EZRecorder.h"

#pragma mark - Interface Components
#import "EZPlot.h"
#import "EZAudioPlot.h"
#import "EZAudioPlotGL.h"
#import "EZAudioPlotGLKViewController.h"

@interface EZAudio : NSObject

#pragma mark - Utility
/**
 Allocates an AudioBufferList structure. Make sure to call freeBufferList when done using AudioBufferList or it will leak.
 @return An AudioBufferList struct that has been allocated in memory
 */
+(AudioBufferList*)audioBufferList;

/**
 Basic check result function useful for checking each step of the audio setup process
 @param result    The OSStatus representing the result of an operation
 @param operation A string (const char, not NSString) describing the operation taking place (will print if fails)
 */
+(void)checkResult:(OSStatus)result
         operation:(const char*)operation;

/**
 Maps a value from one coordinate system into another one. Takes in the current value to map, the minimum and maximum values of the first coordinate system, and the minimum and maximum values of the second coordinate system and calculates the mapped value in the second coordinate system's constraints.
 @param 	value 	The value expressed in the first coordinate system
 @param 	leftMin 	The minimum of the first coordinate system
 @param 	leftMax 	The maximum of the first coordinate system
 @param 	rightMin 	The minimum of the second coordindate system
 @param 	rightMax 	The maximum of the second coordinate system
 @return	The mapped value in terms of the second coordinate system
 */
+(float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax;

/**
 Nicely logs out the contents of an AudioStreamBasicDescription struct
 @param 	asbd 	The AudioStreamBasicDescription struct with content to print out
 */
+(void)printASBD:(AudioStreamBasicDescription)asbd;

/**
 Calculates the root mean squared for a buffer.
 @param 	buffer 	A float buffer array of values whose root mean squared to calculate
 @param 	bufferSize 	The size of the float buffer
 @return	The root mean squared of the buffer
 */
+(float)RMS:(float*)buffer
     length:(int)bufferSize;

/**
 Just a wrapper around the setCanonical function provided in the Core Audio Utility C++ class.
 @param asbd        The AudioStreamBasicDescription structure to modify
 @param nChannels   The number of expected channels on the description
 @param interleaved A flag indicating whether the stereo samples should be interleaved in the buffer
 */
+(void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
                              numberOfChannels:(UInt32)nChannels
                                   interleaved:(BOOL)interleaved;


/**
 Deallocates an AudioBufferList structure from memory.
 @param bufferList A pointer to the buffer list you would like to free
 */
+(void)freeBufferList:(AudioBufferList*)bufferList;

@end
