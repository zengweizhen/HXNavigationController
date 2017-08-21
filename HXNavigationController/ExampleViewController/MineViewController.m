//
//  MineViewController.m
//  HXNavigationController
//
//  Created by Jney on 2017/8/21.
//  Copyright © 2017年 Jney. All rights reserved.
//

#import "MineViewController.h"
#import "UIViewController+HXCategory.h"
#import "SettingViewController.h"

static NSString *HXMineCellReuseIdentifier = @"HXMineCellReuseIdentifier";
static CGFloat  HeaderImage_Height = 200;
static CGFloat  Nav_Height = 64;

@interface MineViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic)UITableView *tableView;
@property(strong, nonatomic)UIImageView *headerImageView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self hx_createTableView];
    
    ///设置rightBarButtonItem
    [self hx_setRightBarItemIcon:@"unselected_set" action:@selector(hx_pushNext)];
   
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self hx_setNavigationBarAlpha:0];
    ///设置navigationBar透明
    self.navigationController.navigationBar.translucent = YES;//Bar的模糊效果，默认为YES
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hx_resumeNavigationBar];
}



#pragma mark - 私有方法

///创建tableView
- (void)hx_createTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HXMineCellReuseIdentifier];
    [self hx_setHeaderView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

///设置tableView的headerView
- (void)hx_setHeaderView{
    
    UIView *bgHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HeaderImage_Height)];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HeaderImage_Height)];
    headerImageView.image = [UIImage imageNamed:@"bgImage"];
    self.headerImageView = headerImageView;
    [bgHeadView addSubview:self.headerImageView];
    self.tableView.tableHeaderView = bgHeadView;
}

///点击set按钮push下一个页面
- (void)hx_pushNext{
    
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}


#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HXMineCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HXMineCellReuseIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"这里是第%ld个cell",(long)indexPath.row];
    return cell;
}

#pragma mark - scrollerViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"tableView滚动的距离:%f",scrollView.contentOffset.y);
    CGFloat offSetY = scrollView.contentOffset.y;
    CGFloat alpha = 1 - (HeaderImage_Height - offSetY - Nav_Height) / HeaderImage_Height;
    
    if (offSetY < 0) {
        ///放大headerImageView
        CGFloat scale = 1 + (fabs(offSetY) / HeaderImage_Height);
        self.headerImageView.transform = CGAffineTransformMakeScale(scale, scale);
        self.headerImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, (HeaderImage_Height + offSetY)/2.0 );
    }
    
    if (alpha > 0.6) {
        ///这里恢复系统之前默认的颜色(包括title的颜色)
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:251/255.0 alpha:1];
        [self hx_setRightBarItemIcon:@"selected_set" action:@selector(hx_pushNext)];
        ///设置navigationTitle的样式为默认样式
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor blackColor]}];
        [[self.navigationController.navigationBar subviews] objectAtIndex:0].alpha = alpha;
    }else{
        ///设置navigationTitle的样式为白色
        [self hx_setRightBarItemIcon:@"unselected_set" action:@selector(hx_pushNext)];
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor whiteColor]}];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [[self.navigationController.navigationBar subviews] objectAtIndex:0].alpha = 0;
    }
    
    
    
}

@end
