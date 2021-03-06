//
//  Created by Anton Spivak.
//  

#import <Foundation/Foundation.h>

#if !TARGET_OS_OSX

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface GestureRecognizer : NSObject

+ (void)useGestureRecognizerShouldReceiveTouchHandler:(BOOL(^)(UIGestureRecognizer *gestureRecognizer))handler;

@end

NS_ASSUME_NONNULL_END

#endif
