//------------------------------------------------------------------------------
#pragma mark - Interface Components
//------------------------------------------------------------------------------

#import "EZAudioDisplayLink.h"
#import "EZAudioPlot.h"
#import "EZPlot.h"

@interface EZAudioUI : NSObject

//------------------------------------------------------------------------------
#pragma mark - Color Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Color Utility
///-----------------------------------------------------------

/**
 Helper function to get the color components from a CGColorRef in the RGBA
 colorspace.
 @param color A CGColorRef that represents a color.
 @param red   A pointer to a CGFloat to hold the value of the red component.
 This value will be between 0 and 1.
 @param green A pointer to a CGFloat to hold the value of the green component.
 This value will be between 0 and 1.
 @param blue  A pointer to a CGFloat to hold the value of the blue component.
 This value will be between 0 and 1.
 @param alpha A pointer to a CGFloat to hold the value of the alpha component.
 This value will be between 0 and 1.
 */
+ (void)getColorComponentsFromCGColor:(CGColorRef)color
                                  red:(CGFloat *)red
                                green:(CGFloat *)green
                                 blue:(CGFloat *)blue
                                alpha:(CGFloat *)alpha;

@end
