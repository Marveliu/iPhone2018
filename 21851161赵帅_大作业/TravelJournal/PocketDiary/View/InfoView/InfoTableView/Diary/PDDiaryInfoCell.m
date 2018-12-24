//
//  PDDiaryInfoCell.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/22.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDDiaryInfoCell.h"

@interface PDDiaryInfoCell ()

@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *weekdayLabel;
@property (nonatomic, weak) IBOutlet UIImageView *weatherImageView;
@property (nonatomic, weak) IBOutlet UIImageView *moodImageView;

@end

@implementation PDDiaryInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.dayLabel.textColor = TitleTextBlackColor;
    self.weekdayLabel.textColor = TitleTextGrayColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithDay:(NSInteger)day weekday:(NSInteger)weekday weatherImage:(UIImage *)weatherImage moodImage:(UIImage *)moodImage
{
    self.dayLabel.text = [NSString stringWithFormat:@"%@", @(day)];
    
    NSArray *weekdayArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    self.weekdayLabel.text = [NSString stringWithFormat:@"周%@", weekdayArray[weekday - 1]];
    
    self.weatherImageView.image = weatherImage;
    self.moodImageView.image = moodImage;
}

@end
