//
//  NSObject+Properties.h
//  ZKKeyValueStore
//
//  Created by Louis on 2017/3/27.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Properties)

@property (nonatomic, strong) NSDictionary *mapDictionary;

- (void)setDataDictionary:(NSDictionary*)dataDictionary;

- (NSDictionary *)dataDictionary;

@end
