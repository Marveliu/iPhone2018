//
//  PDPhotoInfoViewController.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/24.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDPhotoInfoViewController.h"
#import "PDTopBarView.h"
#import "PDDataManager.h"
#import "PDPhotoInfoCell.h"
#import "PDPhotoData.h"

#define PhotoInfoCollectionIdentifier  @"PhotoInfoCollectionIdentifier"

@interface PDPhotoInfoViewController () <PDTopBarViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet PDTopBarView *topBar;
@property (nonatomic, retain) NSArray *photoDataArray;
@property (nonatomic, weak) IBOutlet UICollectionView *collection;

@end

@implementation PDPhotoInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.topBar.delegate = self;
    [self.topBar setTitleWithText:@"照片"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        PDDataManager *dataManager = [PDDataManager defaultManager];
        self.photoDataArray = [dataManager getPhotoInfoData];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.collection reloadData];
        });
    });
    
    [self.collection registerNib:[UINib nibWithNibName:@"PDPhotoInfoCell" bundle:nil] forCellWithReuseIdentifier:PhotoInfoCollectionIdentifier];
    
    self.collection.layer.borderWidth = 1;
    self.collection.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // 横竖屏切换刷新下尺寸
    [self.collection reloadData];
}


#pragma mark - PDTopBarViewDelegate

- (void)infoTableViewReturn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDPhotoData *data = self.photoDataArray[indexPath.row];
    [self.baseVCDelegate baseInfoViewController:self dismissAndEnterPieceViewWithDate:data.date];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photoDataArray count];
}

- (PDPhotoInfoCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDPhotoInfoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoInfoCollectionIdentifier forIndexPath:indexPath];
    
    PDPhotoData *data = self.photoDataArray[indexPath.row];
    UIImage *image = data.image;
    NSDate *date = data.date;
    
    NSInteger year = [date yearValue];
    NSInteger month = [date monthValue];
    NSInteger day = [date dayValue];
    
    [cell setupWithYear:year month:month day:day photo:image];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger spacing = 1;  // collectionView的minispacing为1
    NSInteger count = 4;    // 每行4张照片
    
    CGFloat w = (CGRectGetWidth(collectionView.frame) - (count - 1) * spacing) / count;
    
    return CGSizeMake(w, w);
}

@end
