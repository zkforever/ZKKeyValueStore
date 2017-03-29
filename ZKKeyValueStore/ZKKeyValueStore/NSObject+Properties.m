//
//  NSObject+Properties.m
//  ZKKeyValueStore
//
//  Created by Louis on 2017/3/27.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "NSObject+Properties.h"

#import "NSObject+Properties.h"
#import <objc/runtime.h>

@implementation NSObject (Properties)

#pragma runtime - 动态添加了一个属性，map属性
static char mapDictionaryFlag;
- (void)setMapDictionary:(NSDictionary *)mapDictionary
{
    objc_setAssociatedObject(self, &mapDictionaryFlag, mapDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSDictionary *)mapDictionary
{
    return objc_getAssociatedObject(self, &mapDictionaryFlag);
}

#pragma public - 公开方法

- (void)setDataDictionary:(NSDictionary*)dataDictionary
{
    [self setAttributes:[self mapDictionary:self.mapDictionary dataDictionary:dataDictionary]
                    obj:self];
}

- (NSDictionary *)dataDictionary
{
    // 获取属性列表
    NSArray *properties = [self propertyNames:[self class]];
    
    // 根据属性列表获取属性值
    return [self propertiesAndValuesDictionary:self properties:properties];
}

#pragma private - 私有方法

// 通过属性名字拼凑setter方法
- (SEL)getSetterSelWithAttibuteName:(NSString*)attributeName
{
    NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
    NSString *setterSelStr = \
    [NSString stringWithFormat:@"set%@%@:", capital, [attributeName substringFromIndex:1]];
    return NSSelectorFromString(setterSelStr);
}

// 通过字典设置属性值
- (void)setAttributes:(NSDictionary*)dataDic obj:(id)obj
{
    // 获取所有的key值
    NSEnumerator *keyEnum = [dataDic keyEnumerator];
    
    // 字典的key值(与Model的属性值一一对应)
    id attributeName = nil;
    while ((attributeName = [keyEnum nextObject]))
    {
        // 获取拼凑的setter方法
        SEL sel = [obj getSetterSelWithAttibuteName:attributeName];
        
        // 验证setter方法是否能回应
        if ([obj respondsToSelector:sel])
        {
            id value      = nil;
            id tmpValue   = dataDic[attributeName];
            
            if([tmpValue isKindOfClass:[NSNull class]])
            {
                // 如果是NSNull类型，则value值为空
                value = nil;
            }
            else
            {
                value = tmpValue;
            }
            
            // 执行setter方法
            [obj performSelectorOnMainThread:sel
                                  withObject:value
                               waitUntilDone:[NSThread isMainThread]];
        }
    }
}


// 获取一个类的属性名字列表
- (NSArray*)propertyNames:(Class)class
{
    NSMutableArray  *propertyNames = [[NSMutableArray alloc] init];
    unsigned int     propertyCount = 0;
    objc_property_t *properties    = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i)
    {
        objc_property_t  property = properties[i];
        const char      *name     = property_getName(property);
        
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    
    free(properties);
    
    return propertyNames;
}

// 根据属性数组获取该属性的值
- (NSDictionary*)propertiesAndValuesDictionary:(id)obj properties:(NSArray *)properties
{
    NSMutableDictionary *propertiesValuesDic = [NSMutableDictionary dictionary];
    
    for (NSString *property in properties)
    {
        SEL getSel = NSSelectorFromString(property);
        
        if ([obj respondsToSelector:getSel])
        {
            NSMethodSignature  *signature  = nil;
            signature                      = [obj methodSignatureForSelector:getSel];
            NSInvocation       *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:obj];
            [invocation setSelector:getSel];
            NSObject * __unsafe_unretained valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            
            //assign to @"" string
            if (valueObj == nil)
            {
                valueObj = @"";
            }
            [propertiesValuesDic setObject:valueObj forKey:property];
        }
    }
    
    return propertiesValuesDic;
}

// 根据map值替换掉键值
- (NSDictionary *)mapDictionary:(NSDictionary *)map dataDictionary:(NSDictionary *)data
{
    if (map && data)
    {
        // 拷贝字典
        NSMutableDictionary *newDataDic = [NSMutableDictionary dictionaryWithDictionary:data];
        
        // 获取所有map键值
        NSArray *allKeys                = [map allKeys];
        
        for (NSString *oldKey in allKeys)
        {
            // 获取到value
            id value = [newDataDic objectForKey:oldKey];
            
            // 如果有这个value
            if (value)
            {
                NSString *newKey = [map objectForKey:oldKey];
                [newDataDic removeObjectForKey:oldKey];
                [newDataDic setObject:value forKey:newKey];
            }
        }
        
        return newDataDic;
    }
    else
    {
        return data;
    }
}

@end
