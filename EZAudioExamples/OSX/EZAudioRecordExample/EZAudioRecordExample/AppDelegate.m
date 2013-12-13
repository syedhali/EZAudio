//
//  AppDelegate.m
//  EZAudioRecordExample
//
//  Created by Syed Haris Ali on 12/13/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  
  // Swap in our view controller in the window's content view
  self.recordViewController = [[RecordViewController alloc] init];
  // Resize view controller to content view's current size
  self.recordViewController.view.frame = [self.window.contentView frame];
  // Add resizing flags to make the view controller resize with the window
  self.recordViewController.view.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
  // Add in the core graphics view controller as subview
  [self.window.contentView addSubview:self.recordViewController.view];
  
}

@end
