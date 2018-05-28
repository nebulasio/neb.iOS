//
//  ViewController.m
//  demo
//
//  Created by 斌李 on 2018/5/28.
//  Copyright © 2018年 斌李. All rights reserved.
//

#import "ViewController.h"
#import "NASSmartContracts.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *sn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pay:(id)sender {
    self.sn = [NASSmartContracts randomCodeWithLength:32];
    [NASSmartContracts payNas:@(0.01)
                    toAddress:@"imaddress"
             withSerialNumber:self.sn
                 forGoodsName:@"test1"
                      andDesc:@"desc"];
}

- (IBAction)call:(id)sender {
    self.sn = [NASSmartContracts randomCodeWithLength:32];
    [NASSmartContracts callWithMethod:@"get"
                              andArgs:@[@"a", @"b"]
                               payNas:@(0)
                            toAddress:@"imaddress"
                     withSerialNumber:self.sn
                         forGoodsName:@"test2"
                              andDesc:@"desc2"];
}

- (IBAction)check:(id)sender {
    [NASSmartContracts checkStatusWithSerialNumber:self.sn withCompletionHandler:^(NSString *data) {
        NSLog(@"%@", data);
    }];
}


@end
