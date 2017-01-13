//
//  NSObject+ZKExt.m
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "NSObject+ZKExt.h"
#import <objc/runtime.h>

@implementation NSObject(NSObject_ZKExt)

- (id)copyWithZone:(NSZone *)zone {
    id obj = [[self class] new];
    //取出自身属性对应的字典
    NSDictionary *selfDict = [NSDictionary dictionaryWithDictionary:[self getDictionaryWithSelf]];
    //设置字典
    [obj setPropertyWithDict:selfDict];
    return obj;
}


//获取自身所有属性并转成NSDictionary
- (NSDictionary*)getDictionaryWithSelf {
    return [self getDictionaryFromObject_Ext:self];
}


- (NSDictionary*)getMapDict {
    //key为属性名称，value为映射的键
    return nil;
}

//用NSDictionary设置属性
- (void)setPropertyWithDict:(NSDictionary*)dict {
    //获得映射字典
    NSDictionary *mapDictionary = [self getMapDict];
    //如果子类没有重写getMapDict方法，则使用默认映射字典
    if (mapDictionary == nil) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:dict.count];
        for (NSString *key in dict) {
            [tempDict setObject:key forKey:key];
        }
        mapDictionary = tempDict;
    }
    //遍历map字典
    NSEnumerator *keyEnumerator = [mapDictionary keyEnumerator];
    id attributeName = nil;
    while ((attributeName = [keyEnumerator nextObject])) {
        //获得映射字典的值，也就是传入字典的键
        NSString *aDictKey = [mapDictionary objectForKey:attributeName];
            //获得传入字典的键对应的值，也就是要赋给属性的值
        id aDictValue = [dict valueForKey:aDictKey];
        if (aDictValue && ![aDictValue isEqual:[NSNull null]]) {
            //判断value是否是容器类，如果是容器类的话，做一次序列化
            if ([self isContainerClass:aDictValue]) {
                id archiverValue = [NSKeyedUnarchiver unarchiveObjectWithData:
                                              [NSKeyedArchiver archivedDataWithRootObject: aDictValue]];
                [self setValue:archiverValue forKey:attributeName];
                
            }else{
                [self setValue:aDictValue forKey:attributeName];
            }
        }
    }
    
    //当映射的字典与传来的字典大小不一样时，可能是部分映射，要找到self的默认属性，然后把默认属性加上去
    if (mapDictionary.count != [dict count]) {
        keyEnumerator = [dict keyEnumerator];
        while ((attributeName = [keyEnumerator nextObject])) {
            id aDictValue = [dict valueForKey:attributeName];
            if (aDictValue && ![aDictValue isEqual:[NSNull null]]) {
                if ([self isContainProperty:attributeName]) {
                    //判断value是否是容器类，如果是容器类的话，做一次序列化,保证是完全copy
                    if ([self isContainerClass:aDictValue]) {
                        id archiverValue = [NSKeyedUnarchiver unarchiveObjectWithData:
                                            [NSKeyedArchiver archivedDataWithRootObject: aDictValue]];
                        [self setValue:archiverValue forKey:attributeName];
                        
                    }else{
                        [self setValue:aDictValue forKey:attributeName];
                    }
                }
            }
        }
    }
    
}

//判断是不是容器类
- (BOOL)isContainerClass:(id)instance {
    if ([instance isKindOfClass:[NSArray class]] || [instance isKindOfClass:[NSMutableArray class]] || [instance isKindOfClass:[NSSet class]] || [instance isKindOfClass:[NSMutableSet class]] || [instance isKindOfClass:[NSDictionary class]] || [instance isKindOfClass:[NSMutableDictionary class]]) {
        return YES;
    }
    return NO;
}


//判断是否含有某个属性
- (BOOL)isContainProperty:(NSString*)property {
    BOOL ret = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", property];
    NSArray *results = [[self getSelfPropArray] filteredArrayUsingPredicate:predicate];
    if (results && results.count > 0) {
        ret = YES;
    }
    return ret;
}


//获取属性列表
- (NSArray*)getSelfPropArray {
    unsigned int propsCount;
    //获取对象的属性列表
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    NSMutableArray *propArray = [NSMutableArray array];
    for(int i = 0;i < propsCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        [propArray addObject:propName];
    }
    free(props);
    return propArray;
}


//把对象转成字典
- (NSDictionary*)getDictionaryFromObject_Ext:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    //获取对象的属性列表
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    NSDictionary *mapDict = [self getMapDict];
    for(int i = 0;i < propsCount; i++) {
        objc_property_t prop = props[i];
        id value = nil;
        @try {
            //获取对象的属性名称
            NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
            //获取属性对应的值
            value = [self getObjectInternal_Ext:[obj valueForKey:propName]];
            if(value != nil) {
                if (mapDict != nil) {
                    //获取映射的名称
                    NSString *key = [mapDict objectForKey:propName];
                    if (key) {
                        [dic setObject:value forKey:key];
                    }else{
                        [dic setObject:value forKey:propName];
                    }
                }else {
                    [dic setObject:value forKey:propName];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        
    }
    free(props);
    return dic;
}


//获取每个属性的值
- (id)getObjectInternal_Ext:(id)obj
{
    //判断是否为空，或者是string，或者null，或者nsnumber
    if(!obj
       || [obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    //判断是不是数组
    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++) {
            [arr setObject:[self getObjectInternal_Ext:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    //判断是不是字典
    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys) {
            [dic setObject:[self getObjectInternal_Ext:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    //默认递归
    return [self getDictionaryFromObject_Ext:obj];
}

@end
