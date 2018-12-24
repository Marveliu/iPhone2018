//
//  PDGridInfoViewController.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/22.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDGridInfoViewController.h"
#import "PDTopBarView.h"
#import "PDGridInfoCell.h"
#import "PDGridInfoSectionData.h"
#import "PDDataManager.h"

#define GridInfoReuseIdentifier @"GridInfoReuseIdentifier"

@interface PDGridInfoViewController () <PDTopBarViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet PDTopBarView *topBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *sectionDataArray;

@end

const CGFloat GridTableHeaderHeight = 30;
const CGFloat GridTableHeightForRow = 100;

@implementation PDGridInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.topBar.delegate = self;
    [self.topBar setTitleWithText:@"记录"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        PDDataManager *dataManager = [PDDataManager defaultManager];
        self.sectionDataArray = [dataManager getGridInfoData];

        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
    });
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PDGridInfoCell" bundle:nil] forCellReuseIdentifier:GridInfoReuseIdentifier];
    
    self.tableView.backgroundColor = BackgroudGrayColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - PDTopBarViewDelegate

- (void)infoTableViewReturn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDGridInfoSectionData *sectionData = self.sectionDataArray[indexPath.section];
    PDGridInfoCellData *cellData = sectionData.cellDatas[indexPath.row];
    
    [self.baseVCDelegate baseInfoViewController:self dismissAndEnterPieceViewWithDate:cellData.date];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GridTableHeightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return GridTableHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 显示年月的标签
    CGFloat labelWidth = 120;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, GridTableHeaderHeight)];
    label.backgroundColor = MainBlueColor;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    PDGridInfoSectionData *sectionData = self.sectionDataArray[section];
    NSInteger year = sectionData.year;
    NSInteger month = sectionData.month;
    label.text = [NSString stringWithFormat:@"%@年%@月", @(year), @(month)];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = BackgroudGrayColor;
    [headerView addSubview:label];
    
    return headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PDGridInfoSectionData *sectionData = self.sectionDataArray[section];
    return [sectionData.cellDatas count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionDataArray count];
}

- (PDGridInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDGridInfoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:GridInfoReuseIdentifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PDGridInfoCell" owner:self options:nil] firstObject];
    }
    
    PDGridInfoSectionData *sectionData = self.sectionDataArray[indexPath.section];
    PDGridInfoCellData *cellData = sectionData.cellDatas[indexPath.row];
    
    NSDate *date = cellData.date;
    NSInteger day = [date dayValue];
    NSInteger weekday = [date weekdayValue];
    
    UIImage *image = [cellData.images firstObject]; // 只显示第一张照片
    [cell setupWithDay:day weekday:weekday question:cellData.question answer:cellData.answer photo:image];
    
    return cell;
}

@end
