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
-(AudioBufferList*)output:(EZOutput*)output needsBufferListWithFrames:(UInt32)frames withBufferSize:(UInt32*)bufferSize;
-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput*)output;

@end

/**
 
 */
@interface EZOutput : NSObject

#pragma mark - Properties
@property (nonatomic,assign) id<EZOutputDataSource>outputDataSource;

#pragma mark - Initialization
-(id)initWithDataSource:(id<EZOutputDataSource>)dataSource;

#pragma mark - Class Initializers
+(EZOutput*)outputWithDataSource:(id<EZOutputDataSource>)dataSource;

#pragma mark - Singleton
+(EZOutput*)sharedOutput;

#pragma mark - Events
-(void)startPlayback;
-(void)stopPlayback;

#pragma mark - Getters
-(BOOL)isPlaying;

@end
