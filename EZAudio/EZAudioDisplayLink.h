//
//  EZAudioDisplayLink.h
//  EZAudioCoreGraphicsWaveformExample
//
//  Created by Syed Haris Ali on 6/5/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class EZAudioDisplayLink;

//------------------------------------------------------------------------------
#pragma mark - EZAudioDisplayLinkDelegate
//------------------------------------------------------------------------------

@protocol EZAudioDisplayLinkDelegate <NSObject>

- (void)displayLinkNeedsDisplay:(EZAudioDisplayLink *)displayLink;

@end

@interface EZAudioDisplayLink : NSObject

+ (instancetype)displayLinkWithDelegate:(id<EZAudioDisplayLinkDelegate>)delegate;

@property (nonatomic, weak) id<EZAudioDisplayLinkDelegate> delegate;

- (void)start;
- (void)stop;

@end
