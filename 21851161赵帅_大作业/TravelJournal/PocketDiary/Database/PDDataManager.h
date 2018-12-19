//
//  PDDataManager.h
//  PocketDiary
//
//  Created by 赵帅 on 2018/11/20.
//  Copyright © 2018 赵帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface PDDataManager : NSObject

+ (instancetype)defaultManager;

- (NSArray *)getPieceViewCellDatasWithDate:(NSDate *)date;
- (void)setAnswerContentWithText:(NSString *)text questionID:(NSInteger)questionID date:(NSDate *)date;
- (void)setQuetionContentWithNewContent:(NSString *)newContent oldContent:(NSString *)oldContent inDate:(NSDate *)date;

- (BOOL)exsistQuestionContent:(NSString *)content;  // 是否已存在这个问题
- (NSInteger)getQuestionIDWithQuestionContent:(NSString *)content;  // 通过问题内容获取问题ID
- (BOOL)exsistQuestionID:(NSInteger)questionID inDate:(NSDate *)date;   // date对应的日期中是否已存在该questionID
- (void)insertPhotosWithPhotoDatas:(NSArray *)photoDatas;
- (NSArray *)getPhotoDatasWithDate:(NSDate *)date questionID:(NSInteger)questionID;
- (void)deletePhotoWithPhotoID:(NSInteger)photoID;

- (NSInteger)getDiaryQuantity;
- (NSInteger)getEditedGridQuantity;
- (NSInteger)getQuestionQuantity;
- (NSInteger)getPhotoQuantity;

- (NSArray *)getDiaryInfoData;
- (NSArray *)getGridInfoData;
- (NSArray *)getPhotoInfoData;
- (NSArray *)getQuestionInfoData;

- (NSString *)getWeahterStringWithDate:(NSDate *)date;
- (NSString *)getMoodStringWithDate:(NSDate *)date;

- (void)setupWeatherWithDate:(NSDate *)date weather:(NSString *)weather;
- (void)setupMoodWithDate:(NSDate *)date mood:(NSString *)mood;
- (UIImage *)getWeatherImageWithDate:(NSDate *)date;
- (UIImage *)getMoodImageWithDate:(NSDate *)date;

@end
