//
//  EZAudioUI.m
//  EZAudio
//
//  Created by Haris Ali on 9/8/25.
//

#import "EZAudioUI.h"

NS_ASSUME_NONNULL_BEGIN

@implementation EZAudioUI

//------------------------------------------------------------------------------
#pragma mark - Color Utility
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Color Utility
///-----------------------------------------------------------

+ (void)getColorComponentsFromCGColor:(CGColorRef)color
                                  red:(CGFloat *)red
                                green:(CGFloat *)green
                                 blue:(CGFloat *)blue
                                alpha:(CGFloat *)alpha
{
    size_t componentCount = CGColorGetNumberOfComponents(color);
    if (componentCount == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
    }
}

@end

NS_ASSUME_NONNULL_END
