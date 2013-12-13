//
//  AppDelegate.m
//  SHAAudioExample-OSX
//
//  Created by Syed Haris Ali on 11/26/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "AppDelegate.h"

// Duration of view swapping animation
#define TransitionAnimationDuration powf(3.0/4.0,5.0)

@implementation AppDelegate
@synthesize coreGraphicsViewController;
@synthesize openGLViewController;
@synthesize selectedPage;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
  [self _setupSampleViewControllers];
  
  // Start with the OpenGL view
  [self swapInViewController:self.openGLViewController forPage:SampleOpenGLViewController];
}

-(void)_setupSampleViewControllers {
  self.coreGraphicsViewController = [SampleViewController   sampleViewController];
  self.openGLViewController       = [SampleGLViewController sampleGLViewController];
  self.readFileViewController     = [ReadFileViewController readFileViewController];
  self.selectedPage               = -1;
}

#pragma mark - Events
-(void)transitionViewController:(id)sender {
  SamplePage selectedSegment = (SamplePage)((NSSegmentedControl*)sender).selectedSegment;
  if( selectedSegment == self.selectedPage ) return;
  id selectedViewController  = [self _viewControllerForPage:selectedSegment];
  [self swapInViewController:selectedViewController forPage:selectedSegment];
}

#pragma mark - Transition
-(void)swapInViewController:(NSViewController*)viewController
                    forPage:(SamplePage)page {
  // Remove the previous view
  [self _removeCurrentViewController];
  // Notify removed view is has been removed
  [self _notifyViewDidDisappearWithPage:self.selectedPage];
  // Put in the view
  [self _animateInView:viewController.view];
  self.selectedPage = page;
  // Notify view did appear
  [self _notifyViewDidAppearWithPage:page];
}

#pragma mark - Transition Utility
-(void)_animateInView:(NSView*)view {
  [view setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
  [view setFrameSize:self._contentView.frame.size];
  [view setFrameOrigin:NSMakePoint(0.0f,-view.frame.size.height)];
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:TransitionAnimationDuration];
  [view.animator setFrameOrigin:NSMakePoint(0.0f,0.0f)];
  [[self._contentView animator] addSubview:view];
  [NSAnimationContext endGrouping];
}

-(void)_notifyViewDidAppearWithPage:(SamplePage)page {
  id viewController = [self _viewControllerForPage:page];
  if( [viewController respondsToSelector:@selector(viewDidAppear)] ){
    [viewController performSelector:@selector(viewDidAppear)
                         withObject:nil
                         afterDelay:TransitionAnimationDuration];
  }
}

-(void)_notifyViewDidDisappearWithPage:(SamplePage)page {
  id viewController = [self _viewControllerForPage:page];
  if( [viewController respondsToSelector:@selector(viewDidDisappear)] ){
    [viewController performSelector:@selector(viewDidDisappear)
                         withObject:nil
                         afterDelay:TransitionAnimationDuration];
  }
}

-(void)_removeCurrentViewController {
  for( id subview in self._contentView.subviews ){
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:TransitionAnimationDuration];
    [[subview animator] setFrameOrigin:NSMakePoint(0.0f,-[subview frame].size.height)];
    [NSAnimationContext endGrouping];
    [subview performSelector:@selector(removeFromSuperview)
                  withObject:nil
                  afterDelay:TransitionAnimationDuration] ;
  }
}

#pragma mark - Utility
-(NSView*)_contentView {
  return (NSView*)self.window.contentView;
}

-(id)_viewControllerForPage:(SamplePage)page {
  id viewController = nil;
  switch (page) {
    case SampleCoreGraphicsViewController:
      viewController = self.coreGraphicsViewController;
      break;
    case SampleOpenGLViewController:
      viewController = self.openGLViewController;
      break;
    case SampleReadFileViewController:
      viewController = self.readFileViewController;
      break;
    default:
      break;
  }
  return viewController;
}

@end