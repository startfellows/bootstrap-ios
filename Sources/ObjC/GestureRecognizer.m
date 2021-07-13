//
//  Created by Anton Spivak.
//  

#if !TARGET_OS_OSX

#import "GestureRecognizer.h"
#import <objc/runtime.h>

static BOOL(^gestureRecognizerShouldReceiveTouchHandler)(UIGestureRecognizer *gestureRecognizer) = nil;

@implementation GestureRecognizer

+ (void)load {
    SEL sel = NSSelectorFromString(@"_shouldReceiveTouch:withEvent:");
    
    Method m1 = class_getInstanceMethod([UIGestureRecognizer class], sel);
    Method m2 = class_getInstanceMethod([GestureRecognizer class], sel);
    
    method_exchangeImplementations(m1, m2);
}

+ (void)useGestureRecognizerShouldReceiveTouchHandler:(BOOL(^)(UIGestureRecognizer *gestureRecognizer))handler {
    gestureRecognizerShouldReceiveTouchHandler = handler;
}

- (BOOL)_shouldReceiveTouch:(id)arg1 withEvent:(id)arg2 {
    // self here is UIGestureRecognizer
    UIGestureRecognizer *gestureRecognizer = (id)self;
    
    BOOL handler = YES;
    if (gestureRecognizerShouldReceiveTouchHandler != nil) {
        handler = gestureRecognizerShouldReceiveTouchHandler(gestureRecognizer);
    }
    
    IMP imp = [[GestureRecognizer class] instanceMethodForSelector:_cmd];
    BOOL(*original)(id, SEL, id, id) = (BOOL(*)(id, SEL, id, id))imp;
    return original(gestureRecognizer, _cmd, arg1, arg2) && handler;
}

@end

#endif
