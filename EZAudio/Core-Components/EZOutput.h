//
//  EZOutput.h
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
#import <AudioUnit/AudioUnit.h>
#endif
@class EZOutput;

/**
 
 */
@protocol EZOutputDataSource <NSObject>

@required
/**
 *  <#Description#>
 *
 *  @param output     <#output description#>
 *  @param frames     <#frames description#>
 *  @param bufferSize <#bufferSize description#>
 *
 *  @return <#return value description#>
 */
-(AudioBufferList*)  output:(EZOutput*)output
  needsBufferListWithFrames:(UInt32)frames
             withBufferSize:(UInt32*)bufferSize;

/**
 *  <#Description#>
 *
 *  @param output <#output description#>
 *
 *  @return <#return value description#>
 */
-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput*)output;

@end

/**
 
 */
@interface EZOutput : NSObject

#pragma mark - Properties
/**
 *  <#Description#>
 */
@property (nonatomic,assign) id<EZOutputDataSource>outputDataSource;

#pragma mark - Initialization
/**
 *  <#Description#>
 *
 *  @param dataSource <#dataSource description#>
 *
 *  @return <#return value description#>
 */
-(id)initWithDataSource:(id<EZOutputDataSource>)dataSource;

#pragma mark - Class Initializers
/**
 *  <#Description#>
 *
 *  @param dataSource <#dataSource description#>
 *
 *  @return <#return value description#>
 */
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource;

#pragma mark - Singleton
/**
 
 *  @return <#return value description#>
 */
+(EZOutput*)sharedOutput;

#pragma mark - Events
/**
 
 */
-(void)startPlayback;

/**
 
 */
-(void)stopPlayback;

#pragma mark - Getters
/**
 
 *  @return <#return value description#>
 */
-(BOOL)isPlaying;

@end
