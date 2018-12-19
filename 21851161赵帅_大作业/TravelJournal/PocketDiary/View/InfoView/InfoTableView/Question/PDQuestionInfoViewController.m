//
//  PDQuestionInfoViewController.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/27.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDQuestionInfoViewController.h"
#import "PDTopBarView.h"
#import "PDQuestionInfoCellData.h"
#import "PDDataManager.h"
#import "PDQuestionInfoCell.h"
#import "PDQuestionDetailViewController.h"

#define QuestionInfoReuseIdentifier @"QuestionInfoReuseIdentifier"

@interface PDQuestionInfoViewController () <PDTopBarViewDelegate, UITableViewDataSource, UITableViewDelegate, PDQuestionDetailViewController>

@property (nonatomic, weak) IBOutlet PDTopBarView *topBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *questionInfoDataArray;

@end

@implementation PDQuestionInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.topBar.delegate = self;
    [self.topBar setTitleWithText:@"问题"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        PDDataManager *dataManager = [PDDataManager defaultManager];
        self.questionInfoDataArray = [dataManager getQuestionInfoData];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
    });
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PDQuestionInfoCell" bundle:nil] forCellReuseIdentifier:QuestionInfoReuseIdentifier];
    self.tableView.backgroundColor = BackgroudGrayColor;
    
    self.navigationController.navigationBarHidden = YES;
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

#pragma mark - PDQuestionDetailViewController

- (void)detailViewControllerReturn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectedWithDate:(NSDate *)date
{
    [self.baseVCDelegate baseInfoViewController:self dismissAndEnterPieceViewWithDate:date];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDQuestionInfoCellData *data = self.questionInfoDataArray[indexPath.row];
    PDQuestionDetailViewController *detailViewController = [[PDQuestionDetailViewController alloc] initWithDataArray:data.sectionDataArray titleText:data.questionContent];
    detailViewController.delegate = self;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = BackgroudGrayColor;
    
    return headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.questionInfoDataArray count];
}

- (PDQuestionInfoCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDQuestionInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:QuestionInfoReuseIdentifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PDQuestionInfoCell" owner:self options:nil] firstObject];
    }
    
    PDQuestionInfoCellData *data = self.questionInfoDataArray[indexPath.row];
    [cell setupWithQuestionContent:data.questionContent quantity:data.quatity];
    
    return cell;
}

@end
