//
//  ViewController.m
//  ZSSearch
//
//  Created by 周松 on 16/11/25.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ViewController.h"
#import "ZSPerson.h"
#import "ZSPersonTool.h"
#import "ZSSearchResultViewController.h"

@interface ViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
//显示搜索记录的
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *person;

@property (nonatomic,strong) UISearchBar *searchBar;
//显示搜索结果的控制器
@property (nonatomic,strong) ZSSearchResultViewController *searchResultVC;

//搜索历史的缓存路径
@property (nonatomic,copy) NSString *searchHistoryCache;

//存放搜索历史的数组
@property (nonatomic,strong) NSMutableArray *searchHistroyArray;
@end

@implementation ViewController

-(NSArray *)person{
    if (_person == nil) {
        _person = [NSArray array];
    }
    return _person;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(20, 5, [UIScreen mainScreen].bounds.size.width-35, 30)];
    //设置搜索框
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.frame = titleView.bounds;
    [titleView addSubview:searchBar];
    searchBar.delegate = self;
    //设置占位文字
    [searchBar setPlaceholder:@"搜索吧,骚年"];
    searchBar.layer.cornerRadius = 15;
    searchBar.layer.masksToBounds = YES;
    searchBar.backgroundColor = self.navigationController.navigationBar.tintColor;
    [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];
    [searchBar.layer setBorderWidth:5];
    [searchBar setSearchResultsButtonSelected:NO];
    self.navigationItem.titleView = titleView;
    self.searchBar = searchBar;
    
    //设置状态栏的背景颜色
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    [self.view addSubview:backView];
    backView.backgroundColor = [UIColor whiteColor];
    
    self.searchResultVC.view.hidden = YES;
    self.tableView.hidden = YES;
    
    //footerView 清空历史记录
    UIView *footerView = [[UIView alloc]init];
    footerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30);
    UILabel *emptyAllHistoryLabel = [[UILabel alloc]init];
    emptyAllHistoryLabel.frame = footerView.bounds;
    emptyAllHistoryLabel.textColor = [UIColor darkGrayColor];
    emptyAllHistoryLabel.textAlignment = NSTextAlignmentCenter;
    emptyAllHistoryLabel.font = [UIFont systemFontOfSize:14];
    emptyAllHistoryLabel.text = @"清空搜索历史";
    emptyAllHistoryLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emptyAllHistoryClick)];
    [emptyAllHistoryLabel addGestureRecognizer:tap];
    [footerView addSubview:emptyAllHistoryLabel];
    self.tableView.tableFooterView = footerView;
    //初始化数据
    [self initData];
    
}

#pragma mark --懒加载
//搜索结果显示
- (ZSSearchResultViewController *)searchResultVC{
    if (_searchResultVC == nil) {
        _searchResultVC = [[ZSSearchResultViewController alloc]initWithStyle:UITableViewStylePlain];
        [self.view addSubview:self.searchResultVC.view];
        [self addChildViewController:self.searchResultVC];
        //点击cell的block
        __weak typeof(self) _weakSelf = self;
        self.searchResultVC.didselectedCellBlock = ^(UITableViewCell *didSelectedCell){
            //将cell中的内容赋值给searchBar
            _weakSelf.searchBar.text = didSelectedCell.textLabel.text;
            //保存信息
            [_weakSelf saveSearchHistory];
        };
    }
    return _searchResultVC;
}
//显示搜索历史
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.tableView];

    }
    return _tableView;
}
//存放搜索历史的数组
- (NSMutableArray *)searchHistroyArray{
    if (_searchHistroyArray == nil) {
        _searchHistroyArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoryCache]];
    }
    return _searchHistroyArray;
}
//在获取路径时将数组设置成nil,因为在后面调用的时候如果不设置成nil,在数组的get方法中会直接返回,不会从沙盒中读取数据
- (void)setSearchHistoryCache:(NSString *)searchHistoryCache{
    _searchHistoryCache = [searchHistoryCache copy];
  
    self.searchHistroyArray = nil;
    
}

- (void)initData{
    //初始化数据
    NSArray *names = @[@"西门抽血", @"西门抽筋", @"西门抽风", @"西门吹雪", @"东门抽血", @"东门抽筋", @"东门抽风", @"东门吹雪", @"北门抽血", @"北门抽筋", @"南门抽风", @"南门吹雪"];
    
    for (int i = 0; i < 20; i ++) {
        ZSPerson *p = [[ZSPerson alloc]init];
        p.name = [NSString stringWithFormat:@"%@-%d",names[arc4random_uniform(names.count)],arc4random_uniform(100)];
        p.age = arc4random_uniform(20) + 20;
        [ZSPersonTool save:p];
    }
    
    //搜索历史的缓存路径
    self.searchHistoryCache = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"SearchHistory.plist"];
}

#pragma mark -- 代理数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  self.searchHistroyArray ? self.searchHistroyArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuserID = @"id";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserID];
    }
    cell.textLabel.text = self.searchHistroyArray[indexPath.row];
    //添加关闭按钮
    UIButton *closeButton = [[UIButton alloc]init];
    closeButton.frame = CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.height);
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = closeButton;
    cell.imageView.image = [UIImage imageNamed:@"search_history"];
    return cell;
}

//组头文字
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return  @"搜索历史";
}
//组头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取当前的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchBar.text = cell.textLabel.text;
    //存储搜索历史
    [self saveSearchHistory];
}

//关闭按钮的点击事件
- (void)closeButtonClick:(UIButton *)sender{
    //获取当前的cell
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    //删除信息
    [self.searchHistroyArray removeObject:cell.textLabel.text];
    //保存
    [NSKeyedArchiver archiveRootObject:self.searchHistroyArray toFile:self.searchHistoryCache];
    //刷新
    [self.tableView reloadData];
    //如果数组为空,就隐藏搜索历史视图
    if (self.searchHistroyArray.count == 0) {
        self.tableView.hidden = YES;
    }
}
///清空历史记录
- (void)emptyAllHistoryClick{
    //移除
    [self.searchHistroyArray removeAllObjects];
    //沙盒中也保存
    [NSKeyedArchiver archiveRootObject:self.searchHistroyArray toFile:self.searchHistoryCache];
    //刷新
    [self.tableView reloadData];
    self.tableView.hidden = YES;
}

#pragma  mark --UISearchDelegate
//要开始进行编辑
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [UIView animateWithDuration:0.5 animations:^{
        
        //显示取消按钮
        searchBar.showsCancelButton = YES;
        
        [self setupCancelButton];
        if (self.searchHistroyArray.count == 0) {
            self.tableView.hidden = YES;
        }else{
            self.tableView.hidden = NO;
        }
        
        self.searchResultVC.view.hidden = YES;
    }];
    
}
//搜索框的代理方法,正在进行编辑时
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    //当内容为空,将搜索结果设置隐藏,判断 == @""或者 == nil,都是不行的
    if (searchText.length == 0) {
        self.searchResultVC.infoArray = nil;
        self.searchResultVC.view.hidden = YES;
        self.tableView.hidden = NO;
    }else{
        self.searchResultVC.view.hidden = NO;
        self.searchResultVC.infoArray = [ZSPersonTool queryWithCondition:searchText];
        self.tableView.hidden = YES;
    }
    
};

//点击键盘上的搜索按钮时调用的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self.searchBar resignFirstResponder];
    
    [self saveSearchHistory];
}

///保存搜索历史并刷新
- (void)saveSearchHistory{
    UISearchBar *searchBar = self.searchBar;
    //先清除,在插入到第一个
    [self.searchHistroyArray removeObject:searchBar.text];
    [self.searchHistroyArray insertObject:searchBar.text atIndex:0];
    
    //如果多于20条就删除最后一个
    if (self.searchHistroyArray.count > 20) {
        [self.searchHistroyArray removeLastObject];
    }
    
    //保存信息  注意:不能直接将字符串存入文件中
    [NSKeyedArchiver archiveRootObject:self.searchHistroyArray toFile:self.searchHistoryCache];
    
    [self.tableView reloadData];

}

//取消按钮
- (void)setupCancelButton{
    UIButton *cancelButton = [self.searchBar valueForKey:@"_cancelButton"];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
}
//取消按钮的点击事件
- (void)cancelButtonClick{
    [UIView animateWithDuration:0.5 animations:^{
       //回到原来的位置
        self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
        self.searchBar.transform = CGAffineTransformIdentity;
        self.searchBar.showsCancelButton = NO;
        //结束编辑,不再成为第一响应者
        [self.searchBar endEditing:YES];
        //点击取消按钮,让searchBar不再显示刚才搜索的内容
        self.searchBar.text = @"";
        //点击取消让tableView透明
        self.searchResultVC.view.hidden = YES;
        self.tableView.hidden = YES;
    }];
}
//滚动时让searchBar失去第一响应者
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
