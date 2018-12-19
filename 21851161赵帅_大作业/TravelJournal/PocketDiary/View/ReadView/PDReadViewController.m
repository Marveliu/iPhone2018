//
//  PDReadViewController.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/12/1.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDReadViewController.h"
#import "PDReadViewToolbar.h"
#import "PDReadTitleView.h"
#import "PDPieceCellData.h"
#import "PDPhotoData.h"

@interface PDReadViewController () <PDReadViewToolbarDelegate>

@property (nonatomic, weak) IBOutlet PDReadViewToolbar *toolbar;
@property (nonatomic, weak) IBOutlet PDReadTitleView *readTitleView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, assign) CGFloat originY;

@end

const CGFloat originX = 25;     // 问题和标签的偏移量

@implementation PDReadViewController

- (id)initWithDataArray:(NSArray *)dataArray
{
    self = [super init];
    if (self)
    {
        self.dataArray = dataArray;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.toolbar.delegate = self;
    self.toolbar.layer.borderWidth = 1;
    self.toolbar.layer.borderColor = BackgroudGrayColor.CGColor;
    
    self.readTitleView.backgroundColor = MainBlueColor;
    [self.readTitleView setupLabelWithDate:[self getDate]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setupScrollViewContent];
}

- (void)setupScrollViewContent
{
    // 将日记内容加到scrollView上
    
    self.originY = 40;
    
    for (NSInteger i = 0; i < [self.dataArray count]; i++)
    {
        PDPieceCellData *cellData = self.dataArray[i];
        if (![self judgePieceCellHasEditedWithCellData:cellData])
        {
            continue;
        }
        
        NSString *question = cellData.question;
        [self addQuestionWithText:question];
        
        NSString *answer = cellData.answer;
        if ([answer length] > 0)
        {
            self.originY += 40;     // 问题和答案的间隔
            [self addAnswerWithText:answer];
        }
        
        NSArray *photoDatas = cellData.photoDatas;
        if ([photoDatas count] > 0)
        {
            self.originY += 40;     // 答案和图片的间隔
            for (NSInteger j = 0; j < [photoDatas count]; j++)
            {
                PDPhotoData *photoData = photoDatas[j];
                [self addPhotoWithImage:photoData.image];
                self.originY += 20;     // 图片和图片的间隔
            }
        }
        
        self.originY += 56;     // 和下一个问题的间隔
    }
    
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    CGFloat height = self.originY;
    self.scrollView.contentSize = CGSizeMake(width, height);
}

- (BOOL)judgePieceCellHasEditedWithCellData:(PDPieceCellData *)data
{
    // 判断格子是否被编辑过，若无则不加到scrollview上
    
    if (([data.answer length] < 1) && ([data.photoDatas count] < 1))
    {
        return NO;
    }
    
    return YES;
}

- (void)addQuestionWithText:(NSString *)text
{
    // 将问题添加到scrollView上
    [self addLabelWithText:text font:[self getQuestionLabelFont] textColor:[self getQuestionLabelColor]];
}

- (void)addAnswerWithText:(NSString *)text
{
    // 将答案添加到scrollView上
    [self addLabelWithText:text font:[self getAnswerLabelFont] textColor:[self getAnswerLabelColor]];
}

- (void)addLabelWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize labelSize = [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.scrollView.bounds), 2000) options: NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    
    label.frame = CGRectMake(originX, self.originY, labelSize.width, labelSize.height);
    label.text = text;
    label.textColor = color;
    label.font = font;
    
    self.originY += labelSize.height;
    [self.scrollView addSubview:label];
}

- (UIFont *)getQuestionLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:28];
    return font;
}

- (UIFont *)getAnswerLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:24];
    return font;
}

- (UIColor *)getQuestionLabelColor
{
    return TitleTextBlackColor;
}

- (UIColor *)getAnswerLabelColor
{
    return ContentTextColor;
}

- (void)addPhotoWithImage:(UIImage *)image
{
    // 将图片添加到scrollView上
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    CGFloat imageViewWidth = CGRectGetWidth(imageView.frame);
    CGFloat imageViewHeight = CGRectGetHeight(imageView.frame);
    CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.bounds);
    
    if (imageViewWidth > scrollViewWidth)
    {
        CGFloat scale = scrollViewWidth / imageViewWidth;
        imageViewWidth *= scale;
        imageViewHeight *= scale;
    }
    
    imageView.frame = CGRectMake(0, self.originY, imageViewWidth, imageViewHeight);
    [self.scrollView addSubview:imageView];
    
    self.originY += imageViewHeight;
}

- (NSDate *)getDate
{
    PDPieceCellData *cellData = [self.dataArray firstObject];
    return cellData.date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PDReadViewToolbarDelegate

- (void)readViewReturn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
