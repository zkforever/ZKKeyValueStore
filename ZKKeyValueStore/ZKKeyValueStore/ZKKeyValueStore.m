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
//        _sharedInstance.typeArray = @[@"NSArray",@"NSMutableArray",@"__NSArrayI",@"__NSArrayM",@"__NSSetI",@"__NSSetM",@"NSMutableSet",@"NSSet",@"__NSSetM",@"NSMutableDictionary",@"__NSDictionaryI",@"NSDictionary"];
          _sharedInstance.typeArray = @[[NSArray class],[NSSet class],[NSDictionary class]];
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
                id dic = [[(NSSet*)Object allObjects] yy_modelToJSONObject];
                [_store putObject:dic withId:key intoTable:TABLENAME];
            }else {
                id dic = [Object yy_modelToJSONObject];
                [_store putObject:dic withId:key intoTable:TABLENAME];
            }
        }else {
            //转成NSDictionary
            NSDictionary *objDict = [Object yy_modelToJSONObject];
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
    if (!queryUser) {
        return nil;
    }
    NSString *classKey = [NSString stringWithFormat:@"%@%@",SEEDNAME,key];
    NSString *className = [_store getStringById:classKey fromTable:TABLENAME];
    NSLog(@"class==%@",className);
   //判断类型
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
    if (bundle == [NSBundle mainBundle]) {
        //这就是自定义的类
        id instance = [[NSClassFromString(className) alloc] init];
        [(NSObject*)instance yy_modelSetWithDictionary:(NSDictionary*)queryUser];
        return instance;
    }else if ([self isContainKindOfType:className]){
        //判断是不是容器类，如果是容器类，直接返回queryUser;
        id obj = [NSObject yy_modelWithObj:queryUser];
        return obj;
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



//删对象
- (void)deleteObject:(NSString*)key {
    [_store deleteObjectById:key fromTable:TABLENAME];
}

//判断某个类是不是容器类,用类名和instance的判断方式是不一样的
- (BOOL)isContainKindOfType:(NSString*)className {
    BOOL ret = NO;
    for (Class cls in self.typeArray) {
        if ([NSClassFromString(className) isSubclassOfClass:cls]) {
            ret = YES;
            break;
        }
    }
    return ret;
}


@end
