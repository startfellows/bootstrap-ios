//
//  Created by Anton Spivak.
//  

#import "Functions.h"

void objective_try(void (^try_block)(void), void (^catch_block)(NSException *), void (^finnaly_block)(void)) {
    @try {
        try_block();
    } @catch (NSException *exception) {
        catch_block(exception);
    } @finally {
        finnaly_block();
    }
}
