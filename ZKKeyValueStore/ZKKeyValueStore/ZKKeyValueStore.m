//
//  ZKKeyValueStore.m
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//


#define DBNAME @"zkdb.db"
#define TABLENAME @"zkTable"
#define SEEDNAME @"zkSeed"


#import "ZKKeyValueStore.h"
#import "YTKKeyValueStore.h"

@interface ZKKeyValueStore()


@property (nonatomic,strong)NSArray *typeArray;

@property (nonatomic,strong)YTKKeyValueStore *store;


@end


@implementation ZKKeyValueStore


static ZKKeyValueStore *_sharedInstance;

//初始化
+ (ZKKeyValueStore *)sharedInstance{
    static dispatch_once_t onceman;
    dispatch_once(&onceman, ^{
        _sharedInstance = [[self alloc] init];
        YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:DBNAME];
        [store createTableWithName:TABLENAME];
        _sharedInstance.store = store;
        //这个类型Array是做容器类型判断用的
        _sharedInstance.typeArray = @[@"NSArray",@"NSMutableArray",@"__NSArrayI",@"__NSSetI",@"NSMutableSet",@"NSSet",@"__NSSetM",@"NSMutableDictionary",@"__NSDictionaryI",@"NSDictionary"];
        store = nil;
    });
    return _sharedInstance;
}


//存对象
- (void)storeObject:(id)Object andKey:(NSString*)key {
    if ([Object isKindOfClass:[NSString class]]) {
        [_store putString:Object withId:key intoTable:TABLENAME];
    }else if ([Object isKindOfClass:[NSNumber class]]) {
        [_store putNumber:Object withId:key intoTable:TABLENAME];
    }else {
        if ([Object isKindOfClass:[NSArray class]] || [Object isKindOfClass:[NSDictionary class]] || [Object isKindOfClass:[NSSet class]]) {
            if ([Object isKindOfClass:[NSSet class]]) {
                [_store putObject:[(NSSet*)Object allObjects] withId:key intoTable:TABLENAME];
            }else {
                [_store putObject:Object withId:key intoTable:TABLENAME];
            }
        }else {
            //转成NSDictionary
            NSDictionary *objDict = [Object getDictionaryWithSelf];
            //保存到表里
            [_store putObject:objDict withId:key intoTable:TABLENAME];
        }
    }
    NSString *classKey = [NSString stringWithFormat:@"%@%@",SEEDNAME,key];
    [_store putString:NSStringFromClass([Object class]) withId:classKey intoTable:TABLENAME];
}

//取对象
- (id)getObjectForKey:(NSString*)key {
    id queryUser = [_store getObjectById:key fromTable:TABLENAME];
    NSString *classKey = [NSString stringWithFormat:@"%@%@",SEEDNAME,key];
    NSString *className = [_store getStringById:classKey fromTable:TABLENAME];
    NSLog(@"class==%@",className);
   //判断类型
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
    if (bundle == [NSBundle mainBundle]) {
        //这就是自定义的类
        id instance = [[NSClassFromString(className) alloc] init];
        [(NSObject*)instance setPropertyWithDict:(NSDictionary*)queryUser];
        return instance;
    }else if ([self isContainKindOfType:className]){
        //判断是不是容器类，如果是容器类，直接返回queryUser;
        return queryUser;
    }else {
        if (queryUser) {
            if ([queryUser isKindOfClass:NSClassFromString(@"NSArray")]) {
                NSArray *array = (NSArray*)queryUser;
                return [array lastObject];
            }else {
                return queryUser;
            }
        }else {
            return nil;
        }
    }
}


//判断某个类是不是容器类,用类名和instance的判断方式是不一样的
- (BOOL)isContainKindOfType:(NSString*)className {
    BOOL ret = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", className];
    NSArray *results = [self.typeArray filteredArrayUsingPredicate:predicate];
    if (results && results.count > 0) {
        ret = YES;
    }
    return ret;
}


@end
