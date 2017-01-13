//
//  ViewController.m
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "ViewController.h"
#import "UserObj.h"
#import "ZKKeyValueStore.h"


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //生成对象
    UserObj *userObj = [[UserObj alloc] init];
    userObj.userId = 1;
    userObj.name = @"abc";
    userObj.age = 12;
    userObj.testAccount = 1.2334f;
    userObj.account = 121212.42342342f;
    userObj.testArray = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3"]];
    
    NSLog(@"name==%@,userId = %d,age=%d,account==%f,testAcount=%f,testArray==%@",userObj.name,userObj.userId,userObj.age,userObj.account,userObj.testAccount,userObj.testArray);
    
    
    //存对象
    [[ZKKeyValueStore sharedInstance] storeObject:userObj andKey:@"user"];
    
    //取真实对象
    UserObj *newObj = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"user"];
    NSLog(@"name==%@,userId = %d,age=%d,account==%f,testAcount=%f,testArray==%@",newObj.name,newObj.userId,newObj.age,newObj.account,newObj.testAccount,newObj.testArray);

    
    
    //存字典
    NSDictionary *testDict = @{@"abc":@"a",@"b":@2};
    [[ZKKeyValueStore sharedInstance] storeObject:testDict andKey:@"testDict"];
    
    //取字典
    NSDictionary *dict = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testDict"];
    NSLog(@"dict == %@",dict);
    
    
    //存可变字典
    NSMutableDictionary *testMuDict = [NSMutableDictionary dictionaryWithDictionary:@{@"abc":@"a",@"b":@2}];
    [[ZKKeyValueStore sharedInstance] storeObject:testMuDict andKey:@"testMuDict"];
    
    //取字典
    NSDictionary *muDict = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testMuDict"];
    NSLog(@"dict == %@",muDict);
    
    
    //存Array
    NSArray *array = @[@"123",@"456"];
    [[ZKKeyValueStore sharedInstance] storeObject:array andKey:@"testArray"];

    //取Array
    NSArray *testArray = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testArray"];
    NSLog(@"testArray == %@",testArray);
    
    
    //存String
    NSString *str = @"testStr";
    [[ZKKeyValueStore sharedInstance] storeObject:str andKey:@"testStr"];
    // 取String
    NSString *testStr = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testStr"];
    NSLog(@"str == %@",testStr);
    
    //存NSSet
    NSSet *set = [NSSet setWithArray:array];
    [[ZKKeyValueStore sharedInstance] storeObject:set andKey:@"testSet"];
    
    //取NSSet
    NSSet *testSet = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testSet"];
    NSLog(@"testSet == %@",testSet);
    
    //存可变NSSet
    NSMutableSet *muSet = [NSMutableSet set];
    [muSet addObject:@"222"];
    [muSet addObject:@"333"];
    [[ZKKeyValueStore sharedInstance] storeObject:muSet andKey:@"testMuSet"];

    //取可变NSSet
    NSSet *testMuSet = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testMuSet"];
    NSLog(@"testMuSet == %@",testMuSet);
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
