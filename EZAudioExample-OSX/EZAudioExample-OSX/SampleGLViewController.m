//
//  SampleGLViewController.m
//  SHAAudioExample-OSX
//
//  Created by Syed Haris Ali on 11/26/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "SampleGLViewController.h"

@interface SampleGLViewController (){
  EZRecorder *recorder;
}
@end

@implementation SampleGLViewController

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
+(SampleGLViewController *)sampleGLViewController {
  return [[SampleGLViewController alloc] init];
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
  
  float rms = 3.2*[EZAudio RMS:buffer[0] length:bufferSize];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    self.audioPlotGL.color = [NSColor colorWithCalibratedHue:rms
                                                  saturation:1-rms
                                                  brightness:1.0
                                                       alpha:1.0];
    self.audioPlotGL.backgroundColor = [NSColor colorWithCalibratedHue:rms
                                                            saturation:rms
                                                            brightness:rms
                                                                 alpha:1.0];
    [self.audioPlotGL updateBuffer:buffer[0]
                    withBufferSize:bufferSize];
  });

}

//-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
//  recorder = [EZRecorder recorderWithDestinationURL:[NSURL fileURLWithPath:@"/Users/syedali/Documents/tests/tests.caf"]
//                                  destinationFormat:[EZRecorder defaultDestinationFormat]
//                                    andSourceFormat:audioStreamBasicDescription];
//}
//
//-(void)microphone:(EZMicrophone *)microphone
//    hasBufferList:(AudioBufferList *)bufferList
//   withBufferSize:(UInt32)bufferSize
//withNumberOfChannels:(UInt32)numberOfChannels {
//  [recorder appendDataFromBufferList:bufferList withBufferSize:bufferSize];
//}

#pragma mark - SplitView Delegate
-(void)splitViewWillResizeSubviews:(NSNotification *)notification
{
  [self.view.window disableScreenUpdatesUntilFlush];
}

@end
