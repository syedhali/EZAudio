//
//  ReadFileViewController.h
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "BaseViewController.h"

@interface ReadFileViewController : BaseViewController <EZOutputDataSource,NSOpenSavePanelDelegate>

#pragma mark - Example Components
/**
 The Core Graphics based audio plot to visualize the samples (slower)
 */
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlot;

/**
 BOOL indicating whether we've reached the end of the audio file
 */
@property (nonatomic,assign) BOOL eof;

#pragma mark - Class Initializer
/**
 Easy class initializer for a read file view controller
 @return	A `ReadFileViewController` instance.
 */
+(ReadFileViewController*)readFileViewController;

#pragma mark - Events
-(IBAction)chooseFile:(id)sender;
-(IBAction)play:(id)sender;
-(IBAction)saveWaveform:(id)sender;

@end
