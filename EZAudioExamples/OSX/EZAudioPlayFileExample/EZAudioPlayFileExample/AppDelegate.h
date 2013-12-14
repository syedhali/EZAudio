//
//  AppDelegate.h
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlayFileViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

/**
 Create our CoreGraphicsWaveformViewController
 */
@property (nonatomic,strong) PlayFileViewController *playFileViewController;

@end
