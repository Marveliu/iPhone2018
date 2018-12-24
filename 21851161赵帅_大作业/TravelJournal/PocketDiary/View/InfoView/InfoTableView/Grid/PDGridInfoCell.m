//
//  PDGridInfoCell.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/22.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDGridInfoCell.h"

@interface PDGridInfoCell ()

@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *weekdayLabel;
@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photo;

@end

@implementation PDGridInfoCell

- (void)awakeFromNib {
    // Initialization code
    
    // 临时处理。
    [super awakeFromNib];
    CGFloat photoW = 100 - 20 * 2;
    self.photo.clipsToBounds = YES;
    self.photo.layer.cornerRadius = photoW / 2;
    self.photo.layer.borderWidth = 1;
    self.photo.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.dayLabel.textColor = TitleTextBlackColor;
    self.weekdayLabel.textColor = TitleTextGrayColor;
    self.questionLabel.textColor = TitleTextBlackColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithDay:(NSInteger)day weekday:(NSInteger)weekday question:(NSString *)question answer:(NSString *)answer photo:(UIImage *)photo
{
    self.dayLabel.text = [NSString stringWithFormat:@"%@", @(day)];
    
    NSArray *weekdayArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    self.weekdayLabel.text = [NSString stringWithFormat:@"周%@", weekdayArray[weekday - 1]];
    
    self.questionLabel.text = question;
    
    // 没有答案时显示“无内容”，并把字体颜色改为灰色
    if (answer && [answer length] > 0)
    {
        self.answerLabel.text = answer;
        self.answerLabel.textColor = ContentTextColor;
    }
    else
    {
        self.answerLabel.text = @"无内容";
        self.answerLabel.textColor = TitleTextGrayColor;
    }
    
    if (photo)
    {
        self.photo.image = photo;
        self.photo.hidden = NO;
    }
    else
    {
        self.photo.hidden = YES;
    }
    
}

@end
