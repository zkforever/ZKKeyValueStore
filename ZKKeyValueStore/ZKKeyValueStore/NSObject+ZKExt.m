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
    return [self zkModelToKeyValue];
}

- (NSDictionary*)getMapDict {
    //key为属性名称，value为映射的键
    return nil;
}

//用NSDictionary设置属性
- (void)setPropertyWithDict:(NSDictionary*)dict {
    for (NSString *key in [dict allKeys]) {
        NSString *tKey = [self zkIsExistKey:key];
        if(tKey.length != 0){
            // 存在key
            [self zkSetKey:tKey withValue:dict[key]];
        }else{
            // 不存在key
            NSLog(@"不存在该‘%@’字段",key);
        }
    }
}

#pragma mark - 公用方法

/**
 是否存在key,如果有则返回key名(映射名)
 
 @param key 字典key
 @return 模型属性名
 */
- (NSString *)zkIsExistKey:(NSString *)key
{
    const char *aKey;
    unsigned int count;
    NSDictionary *mapDic;
    
    // Model属性有映射
    if([self respondsToSelector:@selector(getMapDict)]){
        mapDic = [self getMapDict];
        if(mapDic){
            for (NSString *tKey in mapDic) {
                if([key isEqualToString:mapDic[tKey]]){
                    return tKey;
                }
            }
        }
    }
    
    // Model属性无映射
    aKey = [key UTF8String];
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        if(strcmp(propertyName, aKey) == 0){
            free(propertyList);
            return [NSString stringWithUTF8String:aKey];
        }
    }
    free(propertyList);
    
    return nil;
}

// key是否是系统的类
- (BOOL)zkIsSystemClass:(NSString *)key
{
    Class aClass = [self zkGetAttributeClass:key];
    
    if(aClass){
        // 判断key的类型是否是系统类
        NSBundle *aBundle = [NSBundle bundleForClass:aClass];
        if(aBundle == [NSBundle mainBundle]){
            // 自定义的类
            return NO;
        }else{
            // 系统类
            return YES;
        }
    }else{
        // 基本类型
        return YES;
    }
}

/**
 
 获取Model属性的类名
 
 eg: T@"zkCourse",&,N,V_course 获取字符串中的'zkCourse'
 
 @param key Model属性对应的
 @return Model属性的类名
 */
- (Class)zkGetAttributeClass:(NSString *)key
{
    Class aClass;
    unsigned int count;
    NSRange objRange;
    NSRange dotRange;
    NSString *aClassStr;
    NSMutableString *aAttribute;
    const char *att = "";
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *tStr = [NSString stringWithUTF8String:propertyName];
        if([key isEqualToString:tStr]){
            att = property_getAttributes(propertyList[i]);
            break;
        }
    }
    free(propertyList);
    
    aAttribute  = [[NSMutableString alloc] initWithUTF8String:att];
    objRange = [aAttribute rangeOfString:@"@"];
    if(objRange.location != NSNotFound){
        // key是对象，不是基本类型
        dotRange = [aAttribute rangeOfString:@","];
        aClassStr = [aAttribute substringWithRange:NSMakeRange(3, dotRange.location-1-3)];
        aClass = NSClassFromString(aClassStr);
    }else{
        return nil;
    }
    
    return aClass;
}

#pragma mark - 字典->模型

+ (instancetype)zkModelWithKeyValue:(NSDictionary *)dic
{
    return [[self alloc] zkInitWithKeyValue:dic];
}

+ (instancetype)zkModelWithKeyValueString:(NSString *)dicString
{
    NSData *data;
    NSError *error;
    NSDictionary *dic;
    data = [dicString dataUsingEncoding:NSUTF8StringEncoding];
    dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error){
        NSLog(@"error_>字符串为非Json字符串,无法解析");
        return nil;
    }else{
        return [self zkModelWithKeyValue:dic];
    }
}

- (instancetype)zkInitWithKeyValue:(NSDictionary *)dic
{
    NSAssert([dic isKindOfClass:[NSDictionary class]], @"此数据为非字典，无法解析");
    
    for (NSString *key in [dic allKeys]) {
        NSString *tKey = [self zkIsExistKey:key];
        if(tKey.length != 0){
            // 存在key
            [self zkSetKey:tKey withValue:dic[key]];
        }else{
            // 不存在key
            NSLog(@"不存在该‘%@’字段",key);
        }
    }
    
    return self;
}

- (void)zkSetKey:(NSString *)key withValue:(id)value
{
    id aValue;
    
    if([self zkIsSystemClass:key]){
        // 系统类
        aValue = value;
    }else{
        // 自定义类（model嵌套model）
        Class aClass = [self zkGetAttributeClass:key];
        if([value isKindOfClass:[NSArray class]]){
            // 嵌套的model数据是数组
            aValue = [aClass zkModelsWithKeyValues:value];
        }else{
            // 嵌套的model数据是字典
            aValue = [aClass zkModelWithKeyValue:value];
        }
    }
    
    [self setValue:aValue forKey:key];
}

#pragma mark - 字典(数组)->模型(数组)

+ (NSArray *)zkModelsWithKeyValues:(NSArray<__kindof NSDictionary*> *)arr
{
    NSAssert([arr isKindOfClass:[NSArray class]], @"error_>对象为非数组");
    
    return [[self alloc] zkInitWithKeyValues:arr];
}

- (NSArray *)zkInitWithKeyValues:(NSArray<__kindof NSDictionary*> *)arr
{
    NSMutableArray *aArr = [NSMutableArray new];
    for (NSDictionary *dic in arr) {
        if([dic isKindOfClass:[NSDictionary class]]){
            Class tClass = [self class];
            typeof(self) tSelf = [tClass zkModelWithKeyValue:dic];
            [aArr addObject:tSelf];
        }else{
            NSLog(@"warning_>数组中的'%@'不是字典，可能导致数据转换不完整",dic);
            break;
        }
    }
    return aArr;
}

#pragma mark - 模型->字典

- (NSDictionary *)zkModelToKeyValue
{
    unsigned int count;
    id value;
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *tPropertyName = [NSString stringWithUTF8String:propertyName];
        id propertyValue = [self valueForKey:tPropertyName];
        
        if([self zkIsSystemClass:tPropertyName]){
            // 系统类
            value = propertyValue;
            [dic setValue:value forKey:[NSString stringWithUTF8String:propertyName]];
        }else{
            // 自定义类,递归
            value =  [propertyValue zkModelToKeyValue];
            [dic setValue:value forKey:[NSString stringWithUTF8String:propertyName]];
        }
    }
    return dic;
}

- (NSArray *)zkModelsToKeyValues
{
    NSAssert([self isKindOfClass:[NSArray class]], @"error_>对象为非数组");
    
    NSMutableArray *dics = [NSMutableArray new];
    NSArray *arr = (NSArray *)self;
    
    for (id obj in arr) {
        NSDictionary *tDic = [obj zkModelToKeyValue];
        [dics addObject:tDic];
    }
    
    return dics;
}


@end
