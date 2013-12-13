//
//  CoreGraphicsWaveformViewController.m
//  EZAudioCoreGraphicsWaveformExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "CoreGraphicsWaveformViewController.h"

@interface CoreGraphicsWaveformViewController ()

@end

@implementation CoreGraphicsWaveformViewController

#pragma mark - Initialization
-(id)init {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nibBundleOrNil];
  if(self){
    [self initializeViewController];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nibBundleOrNil];
  if(self){
    [self initializeViewController];
  }
  return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nibBundleOrNil];
  if(self){
    [self initializeViewController];
  }
  return self;
}

#pragma mark - Initialize View Controller
-(void)initializeViewController {
  // Create an instance of the microphone
  self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

#pragma mark - Actions


#pragma mark - EZMicrophoneDelegate

@end
