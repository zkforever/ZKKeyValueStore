//
//  UserObj.h
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassObj.h"
#import "NSObject+ZKExt.h"


@interface UserObj : NSObject

@property (nonatomic,assign)int userId;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong)ClassObj *aClass;
//@property (nonatomic,strong)NSMutableArray *testArray;



@end
