//
//  Created by Anton Spivak.
//

#import "OverlayWindow.h"

@implementation OverlayWindow

- (CGFloat)windowLevel {
    return CGFLOAT_MAX - 1;
}

@end
