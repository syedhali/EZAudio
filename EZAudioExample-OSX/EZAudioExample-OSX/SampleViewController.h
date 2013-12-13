//
//  SampleViewController.h
//  SHAAudioExample-OSX
//
//  Created by Syed Haris Ali on 11/26/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "BaseViewController.h"

@interface SampleViewController : BaseViewController <EZMicrophoneDelegate,NSSplitViewDelegate>

#pragma mark - Example Components
/**
 The Core Graphics based audio plot to visualize the samples (slower)
 */
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlot;

#pragma mark - Class Initializer
/**
 Easy class initializer for a sample view controller
 @return	A #SampleViewController instance.
 */
+(SampleViewController *)sampleViewController;

@end
