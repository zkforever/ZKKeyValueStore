//
//  ViewController.m
//  ZKKeyValueStore
//
//  Created by zk on 2017/1/7.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "ViewController.h"
#import "UserObj.h"
#import "ClassObj.h"
#import "ZKKeyValueStore.h"
#import <YYModel.h>

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict = @{@"nick_name":@"112",@"userId":@"22",@"aClass":@{@"name":@"className",@"aStr":@"aStraa"}};
    UserObj *user = [[UserObj alloc]init];
    [user setPropertyWithDict:dict];
    NSLog(@"user==%@",user);
    
    //存对象
    [[ZKKeyValueStore sharedInstance] storeObject:user andKey:@"testUser"];
    //取对象
    UserObj *aUser = [[ZKKeyValueStore sharedInstance] getObjectForKey:@"testUser"];
    NSLog(@"aUser=%@",aUser);
    
    NSMutableArray *userArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        UserObj *testUser = [UserObj yy_modelWithDictionary:dict];
        testUser.userId = i;
        [userArray addObject:testUser];
    }
    
    //存一层Array
     [[ZKKeyValueStore sharedInstance] storeObject:userArray andKey:@"aArray"];
    //取一层Array
    NSMutableArray *getUserArray =  [[ZKKeyValueStore sharedInstance] getObjectForKey:@"aArray"];
    
    NSLog(@"aArray==%@",getUserArray);
    
    //存两层Array
    NSArray *twoArr = @[userArray];
    [[ZKKeyValueStore sharedInstance] storeObject:twoArr andKey:@"twoArray"];
    //取两层Array
    NSMutableArray *twoUserArray =  [[ZKKeyValueStore sharedInstance] getObjectForKey:@"twoArray"];
    
    NSLog(@"twoArray==%@",twoUserArray);
    
    
    //存三层Array
    NSArray *threeArr = @[twoArr,userArray,twoUserArray];
    [[ZKKeyValueStore sharedInstance] storeObject:threeArr andKey:@"threeArray"];
    //取三层Array
    NSMutableArray *threeUserArr =  [[ZKKeyValueStore sharedInstance] getObjectForKey:@"threeArray"];
    
    NSLog(@"threeArr==%@",threeUserArr);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
