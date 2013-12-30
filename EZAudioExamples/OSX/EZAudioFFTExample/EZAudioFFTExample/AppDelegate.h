//
//  AppDelegate.h
//  EZAudioFFTExample
//
//  Created by Syed Haris Ali on 12/29/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FFTViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

/**
 The FFTViewController
 */
@property (nonatomic,strong) FFTViewController *fftViewController;

@end
