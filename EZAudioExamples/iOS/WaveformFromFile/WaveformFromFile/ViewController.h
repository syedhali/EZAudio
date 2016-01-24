//
//  ViewController.h
//  WaveformFromFile
//
//  Created by Syed Haris Ali on 1/23/16.
//  Copyright © 2016 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// First import the EZAudio header
//
#include <EZAudio/EZAudio.h>

//
// Here's the default audio file included with the example
//
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

//------------------------------------------------------------------------------
#pragma mark - ViewController
//------------------------------------------------------------------------------

@interface ViewController : UIViewController

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

//
// The EZAudioFile representing of the currently selected audio file
//
@property (nonatomic,strong) EZAudioFile *audioFile;

//
// The CoreGraphics based audio plot
//
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlot;

//
// A label to display the current file path with the waveform shown
//
@property (nonatomic,weak) IBOutlet UILabel *filePathLabel;

@end

