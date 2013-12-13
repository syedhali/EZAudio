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
 *	@brief	Basic check result function useful for checking each step of the audio setup process
 *
 *	@param 	result 	The OSStatus representing the result of an operation
 *	@param 	operation 	A string (const char, not NSString) describing the operation taking place (will print if fails)
 */
void CheckResult(OSStatus result, const char *operation);

/**
 *  <#Description#>
 *
 *  @param result    <#result description#>
 *  @param operation <#operation description#>
 */
+(void)checkResult:(OSStatus)result
         operation:(const char*)operation;

/**
 *	@brief	<#Description#>
 *
 *	@param 	value 	<#value description#>
 *	@param 	leftMin 	<#leftMin description#>
 *	@param 	leftMax 	<#leftMax description#>
 *	@param 	rightMin 	<#rightMin description#>
 *	@param 	rightMax 	<#rightMax"] description#>
 *
 *	@return	<#return value description#>
 */
+(float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax;

/**
 *	@brief	Nicely logs out the contents of an AudioStreamBasicDescription struct
 *
 *	@param 	asbd 	The AudioStreamBasicDescription struct with content to print out
 */
+(void)printASBD:(AudioStreamBasicDescription)asbd;

/**
 *	@brief	Calculates the root mean squared for a buffer.
 *
 *	@param 	buffer 	A float buffer array of values whose root mean squared to calculate
 *	@param 	bufferSize 	The size of the float buffer
 *
 *	@return	The root mean squared of the buffer
 */
+(float)RMS:(float*)buffer
     length:(int)bufferSize;

/**
 Just a wrapper around the setCanonical function provided in the Core Audio Utility C++ class.
 *
 *  @param asbd        <#asbd description#>
 *  @param nChannels   <#nChannels description#>
 *  @param interleaved <#interleaved description#>
 */
+(void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
                              numberOfChannels:(UInt32)nChannels
                                   interleaved:(BOOL)interleaved;

@end
