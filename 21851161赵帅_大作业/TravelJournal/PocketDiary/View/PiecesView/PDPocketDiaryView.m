//
//  PDPocketDiaryView.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/30.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDPocketDiaryView.h"
#import "PDPieceCell.h"
#import "PDDateCell.h"
#import "PDDataManager.h"
#import "PDPhotoData.h"
#import "PDPieceCellData.h"

#define PiecesCollectionIdentifier  @"PiecesCollectionIdentifier"
#define PDPieceCellIdentifier       @"PDPieceCellIdentifier"
#define PDDateCellIdentifier   @"PDDateCellIdentifier"

#define kDateCellHeight     156
#define kToolBarHeight      44

#define kMinimumInteritemSpacing    1
#define kMinimumLineSpacing  1

typedef NS_ENUM(NSInteger, CollectionSlideDirection) {
    CollectionSlideDirectionLeft,   // 左滑
    CollectionSlideDirectionRight   // 右滑
};

@interface PDPocketDiaryView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIButton *toInfoBtn;
@property (nonatomic, weak) IBOutlet UIButton *leftSlideBtn;
@property (nonatomic, weak) IBOutlet UIButton *rightSlideBtn;
@property (nonatomic, weak) IBOutlet UIButton *toolBtn;

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) UICollectionView *slideOutCollectionView;
@property (nonatomic, retain) NSArray *oldCellDataArray;
@property (nonatomic, retain) NSDate *oldDate;

//@property (nonatomic, copy) NSArray *yesterdayCellDataArray;
//@property (nonatomic, copy) NSArray *tomorrowCellDataArray;

@end

@implementation PDPocketDiaryView

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    [self initPiecesCollectionView];
}

- (void)initPiecesCollectionView
{
    [self.pieceCollectionView registerNib:[UINib nibWithNibName:@"PDPieceCell" bundle:nil] forCellWithReuseIdentifier:PDPieceCellIdentifier];
    [self.pieceCollectionView registerNib:[UINib nibWithNibName:@"PDDateCell" bundle:nil] forCellWithReuseIdentifier:PDDateCellIdentifier];
    
    self.pieceCollectionView.backgroundColor = BackgroudGrayColor;
    self.pieceCollectionView.layer.borderWidth = 1;
    self.pieceCollectionView.layer.borderColor = BackgroudGrayColor.CGColor;

    
    [self addSubview:self.pieceCollectionView];
}

- (BOOL)isLandscape
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return NO;
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft ||
             orientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    
    NSLog(@"判断横竖屏有误。");
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self resetLayout];
}

- (void)resetLayout
{
    [self.pieceCollectionView setCollectionViewLayout:[self getCollectionViewFlowLayout] animated:NO];  // 这个地方设为NO会导致reloadData刷新无效。
//    [self.pieceCollectionView reloadData];
}

- (UICollectionViewFlowLayout *)getCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.minimumInteritemSpacing = kMinimumInteritemSpacing;
    flowLayout.minimumLineSpacing = kMinimumLineSpacing;
    
    return flowLayout;
}

- (PDPieceCellData *)getCellDataWithIndexPath:(NSIndexPath *)indexPath inDataArray:(NSArray *)dataArry
{
    // 通过indexPath获取data，考虑到日期cell的存在，要根据横竖屏情况来通过正确的索引获取到data
    
    if (!dataArry || [dataArry count] < 8)
    {
        PDLog(@"self.cellDataArray不存在或数据个数有误！");
        return nil;
    }
    
    PDPieceCellData *data = dataArry[[self getDataActualIndexWithIndexPatn:indexPath]];
    return data;
}

- (NSInteger)getDataActualIndexWithIndexPatn:(NSIndexPath *)indexPath
{
    // 获得cell数据对应在数组中的索引，因为需要除去日期cell
    NSInteger row = indexPath.row;
    NSInteger index = -1;
    if ([self isLandscape])
    {
        // 横屏的时候日期cell的索引为4
        if (row < 4)
        {
            index = row;
        }
        else if (row > 4)
        {
            index = row - 1;
        }
    }
    else
    {
        // 竖屏的时候日期cell的索引为0
        index = row - 1;
    }
    
    return index;
}

- (void)resetPocketDiaryViewWithDate:(NSDate *)date
{
    [self setCurrentDate:date];
    [self reloadAllCell];
}

- (void)setCurrentDateWithDate:(NSDate *)date
{
    self.currentDate = date;
}

- (void)reloadAllCell
{
    // 刷新数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        PDDataManager *dataManager = [PDDataManager defaultManager];
        NSArray *dataArray = [dataManager getPieceViewCellDatasWithDate:self.currentDate];
        
        self.cellDataArray = dataArray;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.pieceCollectionView reloadData];
        });
    });
}

- (IBAction)leftSlideTouched:(id)sender
{
    [self collectionViewSlideToDirection:CollectionSlideDirectionLeft];
}

- (IBAction)rightSlideTouched:(id)sender
{
    [self collectionViewSlideToDirection:CollectionSlideDirectionRight];
}

- (IBAction)infoButtonTouched:(id)sender
{
    [self.delegate enterInfoViewWithDate:self.currentDate];
}

- (IBAction)toolButtonTouched:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设置功能暂未开放：)" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)readButtonTouched:(id)sender
{
     [self.delegate enterReadViewWithDate:self.currentDate];
}

- (void)collectionViewSlideToDirection:(CollectionSlideDirection)direction
{
    // 添加两个临时的collectionView视图来展现滑动换页的效果
    
    // 设置旧的数据
    self.oldCellDataArray = [self.cellDataArray copy];
    self.oldDate = [self.currentDate copy];
    
    self.slideOutCollectionView = [self getSlideOutCollectionView];
    [self addSubview:self.slideOutCollectionView];
    [self insertSubview:self.slideOutCollectionView aboveSubview:self.pieceCollectionView];
    
    // 设置新的数据
    NSDate *newDate = (direction == CollectionSlideDirectionLeft) ? [self.currentDate yesterday] : [self.currentDate tomorrow];
    self.currentDate = newDate;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        PDDataManager *dataManager = [PDDataManager defaultManager];
        self.cellDataArray = [dataManager getPieceViewCellDatasWithDate:newDate];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.pieceCollectionView reloadData];
        });
    });
    
    UICollectionView *slideInCollectionView = [self getSlideInCollectionViewWithDirection:direction];
    [self addSubview:slideInCollectionView];
    [self insertSubview:slideInCollectionView aboveSubview:self.pieceCollectionView];
    
    [UIView animateWithDuration:0.5 animations:^(){
        self.slideOutCollectionView.frame = [self getSlideOutCollectionViewToFrameWithDirection:direction];
        slideInCollectionView.frame = self.pieceCollectionView.frame;
    }completion:^(BOOL finished)
     {
         [self.slideOutCollectionView removeFromSuperview];
         [slideInCollectionView removeFromSuperview];
     }];
}

- (CGRect)getSlideOutCollectionViewToFrameWithDirection:(CollectionSlideDirection)direction
{
    CGRect frame = (direction == CollectionSlideDirectionLeft) ? [self getRightCollectionViewFrame] : [self getLeftCollectionViewFrame];
    return frame;
}

- (UICollectionView *)getSlideOutCollectionView
{
    // 滑出的collectionView
    return [self createSlideCollectionViewWithFrame:self.pieceCollectionView.frame];
}

- (UICollectionView *)getSlideInCollectionViewWithDirection:(CollectionSlideDirection)direcion
{
    // 滑入的collectionView
    CGRect frame = (direcion == CollectionSlideDirectionLeft) ? [self getLeftCollectionViewFrame] : [self getRightCollectionViewFrame];
    return [self createSlideCollectionViewWithFrame:frame];
}

- (UICollectionView *)createSlideCollectionViewWithFrame:(CGRect)frame
{
    // 创建滑动切换页面时用来展现动画效果的collectionView
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[self getCollectionViewFlowLayout]];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = BackgroudGrayColor;
    
    [collectionView registerNib:[UINib nibWithNibName:@"PDPieceCell" bundle:nil] forCellWithReuseIdentifier:PDPieceCellIdentifier];
    [collectionView registerNib:[UINib nibWithNibName:@"PDDateCell" bundle:nil] forCellWithReuseIdentifier:PDDateCellIdentifier];
    
    return collectionView;
}

- (CGRect)getLeftCollectionViewFrame
{
    CGRect frame = self.pieceCollectionView.frame;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGRect leftFrame = CGRectMake(-width, frame.origin.y, width, height);
    return leftFrame;
}

- (CGRect)getRightCollectionViewFrame
{
    CGRect frame = self.pieceCollectionView.frame;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGRect rightFrame = CGRectMake(width, frame.origin.y, width, height);
    return rightFrame;
}

- (BOOL)isDateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (([self isLandscape] && (indexPath.row == 4)) ||
        (![self isLandscape] && (indexPath.row == 0)))
    {
        return YES;
    }
    return NO;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isDateCellWithIndexPath:indexPath])
    {
        [self.delegate enterRecordViewWithDate:[self getCurrentDate]];
    }
    else
    {
        [self.delegate enterEditFromCell:[collectionView cellForItemAtIndexPath:indexPath] dataArrayIndex:[self getDataActualIndexWithIndexPatn:indexPath]];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    BOOL isSlideCollectionView = (collectionView == self.slideOutCollectionView) ? YES : NO;
    
    if ([self isDateCellWithIndexPath:indexPath])
    {
        // 横竖屏时显示日期的cell
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:PDDateCellIdentifier forIndexPath:indexPath];
        
        NSDate *date = isSlideCollectionView ? self.oldDate : [self getCurrentDate];
        PDDataManager *dataManager = [PDDataManager defaultManager];
        
        UIImage *weatherImage = [dataManager getWeatherImageWithDate:date];
        UIImage *moodImage = [dataManager getMoodImageWithDate:date];
        
        [(PDDateCell *)cell setupWithDate:date weatherIcon:weatherImage moodIcon:moodImage];
    }
    else
    {
        // 显示问题cell
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:PDPieceCellIdentifier forIndexPath:indexPath];
        
        NSArray *dataArray = isSlideCollectionView ? self.oldCellDataArray : self.cellDataArray;
        PDPieceCellData *data = [self getCellDataWithIndexPath:indexPath inDataArray:dataArray];
        
        NSArray *photoDatas = data.photoDatas;
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger i = 0; i < [photoDatas count]; i++)
        {
            PDPhotoData *d = photoDatas[i];
            [photos addObject:d.image];
        }
        
        [(PDPieceCell *)cell setupWithQuestion:data.question answer:data.answer photos:photos];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (NSDate *)getCurrentDate
{
    if (!self.currentDate)
    {
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
        
        self.currentDate = localeDate;
    }
    
    return self.currentDate;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 横屏时为3行3列，日期在正中间方格；竖屏时为4行2列，日期显示在顶端独占一行
    CGSize size = CGSizeZero;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    if ([self isLandscape])
    {
        size = CGSizeMake((width - kMinimumInteritemSpacing * 2) / 3, ((height - kMinimumLineSpacing * 2) - kToolBarHeight) / 3);
    }
    else
    {
        if (indexPath.row == 0)
        {
            size = CGSizeMake(width, kDateCellHeight);
        }
        else
        {
            size = CGSizeMake((width - kMinimumInteritemSpacing) / 2, (height - kToolBarHeight - kDateCellHeight - kMinimumLineSpacing * 4) / 4);
        }
    }
    
    return size;
}

@end
