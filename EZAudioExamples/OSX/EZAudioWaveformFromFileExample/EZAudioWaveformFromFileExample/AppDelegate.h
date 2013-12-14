//
//  AppDelegate.h
//  EZAudioWaveformFromFileExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WaveformFromFileViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

/**
 Create the WaveformFromFileViewController
 */
@property (nonatomic,strong) WaveformFromFileViewController *waveformFromFileViewController;

@end
