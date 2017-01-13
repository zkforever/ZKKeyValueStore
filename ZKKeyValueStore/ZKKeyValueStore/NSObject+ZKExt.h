//
//  NSObject+ZKExt.h
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(NSObject_ZKExt)<NSCopying>

//获取属性并转成NSDictory
- (NSDictionary*)getDictionaryWithSelf;

//设置属性
- (void)setPropertyWithDict:(NSDictionary*)dict;

//映射字典，重写此方法修改映射字典
- (NSDictionary*)getMapDict;


@end
