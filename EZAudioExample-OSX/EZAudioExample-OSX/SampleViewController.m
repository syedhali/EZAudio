//
//  SampleViewController.m
//  SHAAudioExample-OSX
//
//  Created by Syed Haris Ali on 11/26/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "SampleViewController.h"

@implementation SampleViewController
@synthesize audioPlot;

#pragma mark - Initialization
-(id)init {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if (self) {
    [self initializeViewController];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if (self) {
    [self initializeViewController];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if (self) {
    [self initializeViewController];
  }
  return self;
}

-(void)initializeViewController {
  // Initialize stuff here (before awake)
}

#pragma mark - Class Initializers
+(SampleViewController *)sampleViewController {
  return [[SampleViewController alloc] init];
}

#pragma mark - Awake
-(void)awakeFromNib {
  // View loaded
}

#pragma mark - View Display
-(void)viewDidAppear {
  [EZMicrophone sharedMicrophone].microphoneDelegate = self;
  if( ![EZMicrophone sharedMicrophone].microphoneOn ){
    // Tell the microphone to start fetching audio
    [[EZMicrophone sharedMicrophone] startFetchingAudio];
  }
}

-(void)viewDidDisappear {
  if( [EZMicrophone sharedMicrophone].microphoneOn ){
    // Tell the microphone to stop fetching audio
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
  }
  [EZMicrophone sharedMicrophone].microphoneDelegate = nil;
}

#pragma mark - Microphone Delegate
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.audioPlot updateBuffer:buffer[0]
                  withBufferSize:bufferSize];
  });
}

#pragma mark - SplitView Delegate
-(void)splitViewWillResizeSubviews:(NSNotification *)notification
{
  [self.view.window disableScreenUpdatesUntilFlush];
}

@end
