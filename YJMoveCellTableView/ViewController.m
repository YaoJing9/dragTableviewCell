//
//  ViewController.m
//  YJMoveCellTableView
//
//  Created by cherry on 2017/9/18.
//  Copyright © 2017年 YaoJing. All rights reserved.
//

#import "ViewController.h"
#import "YJMoveCellTableview.h"
@interface ViewController ()<yjMoveCellTableViewDelegate, yjMoveCellTableViewDataSource>

@property(nonatomic, strong)NSMutableArray *dataAry;
@property(nonatomic, strong)YJMoveCellTableview *tableview;

@end

@implementation ViewController

//数据源
- (NSMutableArray *)dataAry{

    if (_dataAry == nil) {
        _dataAry = [NSMutableArray array];
        for (NSInteger section = 0; section < 6; section ++) {
            NSMutableArray *sectionArray = [NSMutableArray new];
            for (NSInteger row = 0; row < 5; row ++) {
                [sectionArray addObject:[NSString stringWithFormat:@"section -- %ld row -- %ld", section, row]];
            }
            [_dataAry addObject:sectionArray];
        }

    }
    return _dataAry;
}

- (YJMoveCellTableview *)tableview
{
    if (_tableview == nil) {
        _tableview = [[YJMoveCellTableview alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

    }
    return _tableview;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataAry[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor grayColor];
    cell.textLabel.text = self.dataAry[indexPath.section][indexPath.row];
    return cell;
}

- (NSArray *)dataSourceArrayInTableView:(YJMoveCellTableview *)tableView
{
    return _dataAry.copy;
}

- (void)tableView:(YJMoveCellTableview *)tableView newDataSourceArrayAfterMove:(NSArray *)newDataSourceArray
{
    _dataAry = newDataSourceArray.mutableCopy;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
