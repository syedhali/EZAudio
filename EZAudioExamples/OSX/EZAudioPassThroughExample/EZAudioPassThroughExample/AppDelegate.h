//
//  AppDelegate.h
//  EZAudioPassThroughExample
//
//  Created by Syed Haris Ali on 12/20/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PassThroughViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

/**
 The PassThroughViewController
 */
@property (nonatomic,strong) PassThroughViewController *passThroughViewController;

@end
