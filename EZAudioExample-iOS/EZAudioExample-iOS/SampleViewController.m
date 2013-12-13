//
//  SampleViewController.m
//  SHAAudioExample-iOS
//
//  Created by Syed Haris Ali on 11/22/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController () {
  BOOL _showingOptions;
}
@end

@implementation SampleViewController
/**
 * SHAAudio related properties
 */
@synthesize audioPlot;
@synthesize microphone;
/**
 * Example View Controller properties
 */
@synthesize fillSwitch;
@synthesize gainLabel;
@synthesize gainSlider;
@synthesize mirrorSwitch;
@synthesize optionsView;
@synthesize waveformSegmentedControl;

#pragma mark - View Loaded
-(void)viewDidLoad {
  [super viewDidLoad];
  
  /**
   * Create the microphone and set its delegate to this class.
   * The microphone will configure itself and start passing back
   * audio data to the delegate method below.
   */
  self.microphone = [EZMicrophone microphoneWithDelegate:self
                                       startsImmediately:YES];
  
  /**
   * Setup the controls for the options view
   */
  [self _setupOptionsControls];
  
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if( _showingOptions && self.optionsView.frame.size.height == 0.0f ){
    [self _showOptions:_showingOptions
              animated:YES];
  }
  if( !self.microphone.microphoneOn ){
    [self.microphone startFetchingAudio];
  }
}

-(void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  if( self.microphone.microphoneOn ){
    [self.microphone stopFetchingAudio];
  }
}

#pragma mark - Microphone Delegate
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  
  /**
   * Add dynamic color to the view depending on the root mean squared of the buffer's amplitude
   */
  float rms            = 3.2*[EZAudio RMS:buffer[0] length:bufferSize];
  
  /**
   * This block does not execute on the main thread so any drawing code must be contained in a main thread
   * dispatch block
   */
  dispatch_async(dispatch_get_main_queue(), ^{
    
    if( [self.audioPlot isKindOfClass:EZAudioPlotGL.class] ){
      self.audioPlot.color = [UIColor colorWithHue:rms
                                        saturation:1-rms
                                        brightness:1.0
                                             alpha:1.0];
      self.audioPlot.backgroundColor = [UIColor colorWithHue:rms
                                                  saturation:rms
                                                  brightness:rms
                                                       alpha:1.0];
    }
    else {
      self.audioPlot.color = [UIColor colorWithHue:1-rms
                                        saturation:rms
                                        brightness:rms
                                             alpha:1.0];
      self.audioPlot.backgroundColor = [UIColor colorWithHue:rms
                                                  saturation:1-rms
                                                  brightness:1-rms
                                                       alpha:1.0];
    }
    
    /**
     * We are now receiving the microphone data as a float buffer (float *).
     * The float ** represents two channels, buffer[0] = left channel, buffer[1] = right channel.
     * Perform whatever processing you like at this step, I'm going to pass the buffer
     * directly into the audio plot. Now how easy was that!
     */
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    
  });
  
}

#pragma mark - Events
-(void)changedFillSwitchValue:(id)sender {
  self.audioPlot.shouldFill = ((UISwitch*)sender).isOn;
}

-(void)changedGainSliderValue:(id)sender {
  float value = ((UISlider*)sender).value;
  self.audioPlot.gain = value;
  self.gainLabel.text = [NSString stringWithFormat:@"%.4f",value];
}

-(void)changedMirrorSwitchValue:(id)sender {
  self.audioPlot.shouldMirror = ((UISwitch*)sender).isOn;
}

-(void)changedWaveformSegmentedControl:(id)sender {
  self.audioPlot.plotType = ((UISegmentedControl*)sender).selectedSegmentIndex;
}

-(void)toggleMicrophone:(id)sender {
  self.microphone.microphoneOn = !self.microphone.microphoneOn;
}

-(void)toggleOptions:(id)sender {
  UIButton *button = (UIButton*)sender;
  [button setTitle:( !_showingOptions ? @"Hide Options" : @"Show Options" )
          forState:UIControlStateNormal];
  [self _showOptions:!_showingOptions
            animated:YES];
  _showingOptions = !_showingOptions;
}

-(void)_showOptions:(BOOL)show
           animated:(BOOL)animated {
  // Get the right height for the right device
  CGFloat defaultHeight = 0;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    defaultHeight = 200;
  }
  else {
    defaultHeight = 166;
  }
  CGRect optionsFrame = self.optionsView.frame;
  CGRect plotFrame    = self.audioPlot.frame;
  
  if( show ){
    optionsFrame.size.height  =  defaultHeight;
    optionsFrame.origin.y    -= defaultHeight;
    plotFrame.size.height    -= defaultHeight;
  }
  else {
    optionsFrame.size.height  =  0;
    optionsFrame.origin.y    += defaultHeight;
    plotFrame.size.height    += defaultHeight;
  }
  
  if( animated ){
    [UIView animateWithDuration:0.3 animations:^{
      self.optionsView.frame = optionsFrame;
      self.audioPlot.frame   = plotFrame;
//      if( show ){
//        [self.view bringSubviewToFront:self.optionsView];
//      }
    }];
  }
  else {
    self.optionsView.frame = optionsFrame;
    self.audioPlot.frame   = plotFrame;
//    if( show ){
//      [self.view bringSubviewToFront:self.optionsView];
//    }
  }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  NSLog(@"received touch event on view: %@",self);
}

#pragma mark - Bindings
-(void)_setupOptionsControls {
  
  self.fillSwitch.on    = self.audioPlot.shouldFill;
  self.gainLabel.text   = [NSString stringWithFormat:@"%.4f",self.audioPlot.gain];
  self.gainSlider.value = self.audioPlot.gain;
  self.mirrorSwitch.on  = self.audioPlot.shouldMirror;
  self.waveformSegmentedControl.selectedSegmentIndex = self.audioPlot.plotType;
  
}

#pragma mark - Orientation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  if( _showingOptions && self.optionsView.frame.size.height == 0.0f ){
    [self _showOptions:_showingOptions
              animated:YES];
  }
}

#pragma mark - Status Bar
-(UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

@end