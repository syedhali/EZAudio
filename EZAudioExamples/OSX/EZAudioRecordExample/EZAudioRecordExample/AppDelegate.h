//
//  AppDelegate.h
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RecordViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

/**
 Create our RecordViewController
 */
@property (nonatomic,strong) RecordViewController *recordViewController;

@end
