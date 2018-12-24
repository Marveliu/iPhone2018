//
//  PDPhotoInfoCell.m
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/24.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import "PDPhotoInfoCell.h"

@interface PDPhotoInfoCell ()

@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearMonthLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photo;

@end

@implementation PDPhotoInfoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.contentView bringSubviewToFront:self.dayLabel];
    [self.contentView bringSubviewToFront:self.yearMonthLabel];
}

- (void)setupWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day photo:(UIImage *)photo
{
    self.dayLabel.text = [NSString stringWithFormat:@"%@", @(day)];
    self.yearMonthLabel.text = [NSString stringWithFormat:@"%@年%@月", @(year), @(month)];
    
    self.photo.image = photo;
}





@end
