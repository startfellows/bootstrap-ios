//
//  Created by Anton Spivak.
//  

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern void objective_try(void (^try_block)(void), void (^catch_block)(NSException *), void (^finnaly_block)(void));

NS_ASSUME_NONNULL_END
