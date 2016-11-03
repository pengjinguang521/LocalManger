//
//  TestModel.m
//  简单封装FMDB做本地化存储
//
//  Created by aaa on 16/1/22.
//  Copyright © 2016年 pengPL. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel

- (instancetype)initWithName:(NSString *)name Age:(NSString *)age ColorStr:(NSString *)colorStr{
    if (self = [super init]) {
        _name = name;
        _age = age;
        _color = colorStr;
    }
    return self;
}

@end
