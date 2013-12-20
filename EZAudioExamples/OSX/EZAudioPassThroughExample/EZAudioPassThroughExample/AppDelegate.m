//
//  AppDelegate.m
//  EZAudioPassThroughExample
//
//  Created by Syed Haris Ali on 12/20/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize passThroughViewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

  // Swap in our view controller in the window's content view
  self.passThroughViewController = [[PassThroughViewController alloc] init];
  // Resize view controller to content view's current size
  self.passThroughViewController.view.frame = [self.window.contentView frame];
  // Add resizing flags to make the view controller resize with the window
  self.passThroughViewController.view.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
  // Add in the core graphics view controller as subview
  [self.window.contentView addSubview:self.passThroughViewController.view];
  
}

@end
