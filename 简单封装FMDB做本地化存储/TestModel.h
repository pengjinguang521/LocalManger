//
//  TestModel.h
//  简单封装FMDB做本地化存储
//
//  Created by aaa on 16/1/22.
//  Copyright © 2016年 pengPL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject

@property (nonatomic,strong)NSString * name;
@property (nonatomic,strong)NSString * age;
@property (nonatomic,strong)NSString * color;
@property (nonatomic,strong)NSString * ID;

- (instancetype)initWithName:(NSString *)name Age:(NSString *)age ColorStr:(NSString *)colorStr;

@end
