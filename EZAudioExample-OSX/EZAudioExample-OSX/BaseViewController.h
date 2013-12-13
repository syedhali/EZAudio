//
//  BaseViewController.h
//  EZAudioExample-OSX
//
//  Created by Syed Haris Ali on 12/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EZAudio.h"

/**
 Reusable view controller with helpful properties and methods for the subclass.
 */
@interface BaseViewController : NSViewController

#pragma mark - View Display
/**
 Because we're manually switch in and out views the sender (AppDelegate in this case) needs to notify the view it's visible and stuff should happen.
 */
-(void)viewDidAppear;

/**
 Because we're manually switch in and out views the sender (AppDelegate in this case) needs to notify the view it's no longer visible and stuff should stop happening.
 */
-(void)viewDidDisappear;

@end
