//
//  Created by Anton Spivak.
//

#if !TARGET_OS_OSX

#import "OverlayWindow.h"

@implementation OverlayWindow

- (CGFloat)windowLevel {
    return CGFLOAT_MAX - 1;
}

@end

#endif
