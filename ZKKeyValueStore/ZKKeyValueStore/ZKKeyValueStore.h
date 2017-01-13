//
//  ZKKeyValueStore.h
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ZKExt.h"


@interface ZKKeyValueStore : NSObject

//单例
+ (ZKKeyValueStore *)sharedInstance;

/**
 存对象

 @param Object 对象
 @param key  key
 */
- (void)storeObject:(id)Object andKey:(NSString*)key;


/**
 取对象字典

 @param key key值
 @return <#return value description#>
 */
- (id)getObjectForKey:(NSString*)key;


@end
