//
//  PassThroughViewController.m
//  EZAudioPassThroughExample
//
//  Created by Syed Haris Ali on 12/20/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "PassThroughViewController.h"

@interface PassThroughViewController (){
  TPCircularBuffer _circularBuffer;
}
@end

@implementation PassThroughViewController

#pragma mark - Initialization
-(id)init {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
  }
  return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
  }
  return self;
}

#pragma mark - Customize the Audio Plot
-(void)awakeFromNib {
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [NSColor colorWithCalibratedRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  
  /**
   Initialize the circular buffer
   */
  TPCircularBufferInit(&_circularBuffer,1024);
  
  /*
   Start the microphone
   */
  [EZMicrophone sharedMicrophone].microphoneDelegate = self;
  [[EZMicrophone sharedMicrophone] startFetchingAudio];
  
  /**
   Start the output
   */
  [EZOutput sharedOutput].outputDataSource = self;
  [[EZOutput sharedOutput] startPlayback];
  
}

#pragma mark - Actions
-(void)changePlotType:(id)sender {
  NSInteger selectedSegment = [sender selectedSegment];
  switch(selectedSegment){
    case 0:
      [self drawBufferPlot];
      break;
    case 1:
      [self drawRollingPlot];
      break;
    default:
      break;
  }
}

-(void)toggleMicrophone:(id)sender {
  switch([sender state]){
    case NSOffState:
      [[EZMicrophone sharedMicrophone] stopFetchingAudio];
      break;
    case NSOnState:
      [[EZMicrophone sharedMicrophone] startFetchingAudio];
      break;
    default:
      break;
  }
}

#pragma mark - Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input eample)
 */
-(void)drawBufferPlot {
  // Change the plot type to the buffer plot
  self.audioPlot.plotType = EZPlotTypeBuffer;
  // Don't mirror over the x-axis
  self.audioPlot.shouldMirror = NO;
  // Don't fill
  self.audioPlot.shouldFill = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
  self.audioPlot.plotType = EZPlotTypeRolling;
  self.audioPlot.shouldFill = YES;
  self.audioPlot.shouldMirror = YES;
}

#pragma mark - EZMicrophoneDelegate
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  /**
   Append the audio data to a circular buffer
   */
  TPCircularBufferProduceBytes(&_circularBuffer,
                               bufferList->mBuffers[0].mData,
                               bufferList->mBuffers[0].mDataByteSize);
}

#pragma mark - EZOutputDelegate
-(void)output:(EZOutput *)output
callbackWithActionFlags:(AudioUnitRenderActionFlags *)ioActionFlags
  inTimeStamp:(const AudioTimeStamp *)inTimeStamp
  inBusNumber:(UInt32)inBusNumber
inNumberFrames:(UInt32)inNumberFrames
       ioData:(AudioBufferList *)ioData {
  
  /**
   Below is how you could pass the data to the output using the circular buffer.
   Thank you Michael Tyson (A Tasty Pixel) for writing the TPCircularBuffer, you are amazing!
   */
  
  // Get the desired amount of bytes to copy
  int32_t bytesToCopy = ioData->mBuffers[0].mDataByteSize;
  AudioSampleType *targetBuffer = (AudioSampleType*)ioData->mBuffers[0].mData;
  
  // Get the available bytes in the circular buffer
  int32_t availableBytes;
  AudioSampleType *buffer = TPCircularBufferTail(&_circularBuffer,&availableBytes);
  
  // Ideally we'd have all the bytes to be copied, but compare it against the available bytes (get min)
  int32_t amount = MIN(bytesToCopy,availableBytes);
  memcpy(targetBuffer,buffer,amount);
  
  // Consume those bytes ( this will internally push the head of the circular buffer )
  TPCircularBufferConsume(&_circularBuffer,amount);
  
}

#pragma mark - Cleanup
-(void)dealloc {
  TPCircularBufferClear(&_circularBuffer);
}

@end
