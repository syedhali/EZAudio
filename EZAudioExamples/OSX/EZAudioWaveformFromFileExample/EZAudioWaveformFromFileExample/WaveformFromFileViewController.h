//
//  WaveformFromFileViewController.h
//  EZAudioWaveformFromFileExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Import EZAudio header
#import "EZAudio.h"

/**
 Here's the default audio file included with the example
 */
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

@interface WaveformFromFileViewController : NSViewController <NSOpenSavePanelDelegate>

#pragma mark - Components
/**
 The EZAudioFile representing of the currently selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;

/**
 The CoreGraphics based audio plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlot;

/**
 A BOOL indicating whether or not we've reached the end of the file
 */
@property (nonatomic,assign) BOOL eof;

#pragma mark - UI Extras
/**
 A label to display the current file path with the waveform shown
 */
@property (nonatomic,weak) IBOutlet NSTextField *filePathLabel;

#pragma mark - Actions
/**
 Prompts the file manager and loads in a new audio file into the EZAudioFile representation.
 */
-(IBAction)openFile:(id)sender;

@end
