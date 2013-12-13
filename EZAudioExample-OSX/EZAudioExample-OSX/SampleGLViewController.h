//
//  SampleGLViewController.h
//  SHAAudioExample-OSX
//
//  Created by Syed Haris Ali on 11/26/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "BaseViewController.h"

@interface SampleGLViewController : BaseViewController <EZMicrophoneDelegate,NSSplitViewDelegate>

#pragma mark - Example Components
/**
 The Open GL audio plot to visualize the samples (high performance, GPU-based)
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlotGL;

#pragma mark - Properties
/**
 Boolean indicating whether the plot should vary the colors based on the audio data's amplitude.
 */
@property (nonatomic,assign) BOOL dynamicColors;

#pragma mark - Class Initializer
/**
 Easy class initializer for a sample view controller
 @return	A #SampleViewController instance.
 */
+(SampleGLViewController *)sampleGLViewController;

@end
