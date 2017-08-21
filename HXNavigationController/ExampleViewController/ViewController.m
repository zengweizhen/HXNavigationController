//
//  ViewController.m
//  HXNavigationController
//
//  Created by Jney on 2017/8/21.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+HXCategory.h"
#import "MineViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *pushButton = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100)/2.0, ([UIScreen mainScreen].bounds.size.height - 50)/2.0, 100, 50)];
    [pushButton setTitle:@"Push" forState:UIControlStateNormal];
    [pushButton setBackgroundColor:[UIColor cyanColor]];
    [pushButton addTarget:self action:@selector(hx_pushNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
}

- (void)hx_pushNext{
    
    [self.navigationController pushViewController:[MineViewController new] animated:YES];
}

@end
