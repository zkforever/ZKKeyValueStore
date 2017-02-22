//
//  FMDatabase+FMDatabase_Addition.m
//  ZKKeyValueStore
//
//  Created by zk on 2017/2/22.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "FMDatabase_ZKAddition.h"
#import <objc/message.h>

#import "unistd.h"
#import <objc/runtime.h>

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

#define DBSECURETKEY @"justabc123"

@implementation FMDatabase (FMDatabase_Addition)

+ (void)load {
    Method openMethod = class_getInstanceMethod([self class], @selector(open));
    // 获取自定义方法openNew
    Method openMethodNew = class_getInstanceMethod([self class], @selector(openNew));
    // 交换方法实现
    method_exchangeImplementations(openMethod, openMethodNew);
    
    
    Method openWithFlagMethod = class_getInstanceMethod([self class], @selector(openWithFlags:vfs:));
    // 获取自定义方法openWithFlagsNew
    Method openWithFlagMethodNew = class_getInstanceMethod([self class], @selector(openWithFlagsNew:vfs:));
    // 交换方法实现
    method_exchangeImplementations(openWithFlagMethod, openWithFlagMethodNew);
}

- (BOOL)openNew {
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open([self mySqlitePath], (sqlite3**)&_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }
    const char* key = [DBSECURETKEY UTF8String];
    
    sqlite3_key(_db, key, (int)strlen(key));//注意此行
    
    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }
    
    
    return YES;
}


- (BOOL)openWithFlagsNew:(int)flags vfs:(NSString *)vfsName {
#if SQLITE_VERSION_NUMBER >= 3005000
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open_v2([self mySqlitePath], (sqlite3**)&_db, flags, [vfsName UTF8String]);
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    }
    const char* key = [DBSECURETKEY UTF8String];
    
    sqlite3_key(_db, key, (int)strlen(key));//注意此行
    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }
    
    return YES;
#else
    NSLog(@"openWithFlags requires SQLite 3.5");
    return NO;
#endif
}


- (const char*)mySqlitePath {
    
    if (!_databasePath) {
        return ":memory:";
    }
    
    if ([_databasePath length] == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    
    return [_databasePath fileSystemRepresentation];
    
}


@end
