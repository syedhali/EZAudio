//
//  AppDelegate.h
//  SHAAudioExample-OSX
//
//  Created by Syed Haris Ali on 11/26/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "ReadFileViewController.h"
#import "SampleViewController.h"
#import "SampleGLViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

#pragma mark - Enumerations
/**
 *	@brief	Helps add verbosity to the order of the upper left's segmented controls. Same
 *          order as they appear on the toolbar!
 */
typedef enum {
  SampleOpenGLViewController,
  SampleCoreGraphicsViewController,
  SampleReadFileViewController
} SamplePage;

@property (assign) IBOutlet NSWindow *window;

/**
 *	@brief	The CoreGraphics sample view controller.
 */
@property (nonatomic,strong) SampleViewController *coreGraphicsViewController;

/**
 *	@brief	The OpenGL sample view controller.
 */
@property (nonatomic,strong) SampleGLViewController *openGLViewController;

/**
 *	@brief	The Read File example view controller
 */
@property (nonatomic,strong) ReadFileViewController *readFileViewController;

/**
 *	@brief	The view controller displayed represented by the selected tab
 */
@property (nonatomic,assign) SamplePage selectedPage;

#pragma mark - Events
-(IBAction)transitionViewController:(id)sender;

@end