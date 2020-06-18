//
//  MOPerManager.h
//  MOPeripheralDemo
//
//  Created by moxiaoyan on 2020/6/16.
//  Copyright © 2020 moxiaoyan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOPerManager : NSObject

+ (instancetype)shareInstance;
- (void)stopAdvertising;
- (void)startAdvertising;

@end

NS_ASSUME_NONNULL_END
