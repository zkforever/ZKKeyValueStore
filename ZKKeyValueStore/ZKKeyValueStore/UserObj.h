//
//  UserObj.h
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObj : NSObject

@property (nonatomic,assign)int userId;
@property (nonatomic,assign)int age;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,assign)double account;//财富
@property (nonatomic,assign)float testAccount;
@property (nonatomic,strong)UserObj *user1;
@property (nonatomic,strong)NSMutableArray *testArray;



@end
