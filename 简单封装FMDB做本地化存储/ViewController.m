//
//  ViewController.m
//  简单封装FMDB做本地化存储
//
//  Created by aaa on 16/1/22.
//  Copyright © 2016年 pengPL. All rights reserved.
//

#import "ViewController.h"
#import "DBSaveHelper.h"
#import "TestModel.h"
#define TYPEINT @"int"
#define TYPETEXT @"text"
#define TableOne @"province"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //打开数据库procityarea.sqlite 如果不存在，则创建
    [[DBSaveHelper sharedHelper]openDB:@"procityarea.sqlite"];
    //构造数据库中一个表的字段和类型 这边要注意字段必须与你模型的字段一致
    //ID不用传 自增。
    /**
     *  @property (nonatomic,strong)NSString * name;
        @property (nonatomic,strong)NSString * age;
        @property (nonatomic,strong)NSString * color;
        @property (nonatomic,strong)NSString * ID;
     */
    NSMutableArray * tableTest = [NSMutableArray array];
    [tableTest addObject:[DBSaveHelper contentStrWith:@"name" And:TYPETEXT]];
    [tableTest addObject:[DBSaveHelper contentStrWith:@"age" And:TYPETEXT]];
    [tableTest addObject:[DBSaveHelper contentStrWith:@"color" And:TYPETEXT]];
    //创建表，和表字段
    [[DBSaveHelper sharedHelper]createTableWithName:TableOne AndArray:tableTest];
    
    //拿到一个任意模型（必须是model）
    TestModel * model = [[TestModel alloc]initWithName:@"wang" Age:@"121" ColorStr:@"红色"];
    //将模型存入数据库中
   [[DBSaveHelper sharedHelper]insertIntoDBWithTableName:TableOne AndModel:model];
    //拿到表中的全部信息
    NSArray * array = [[DBSaveHelper sharedHelper] searchDBAllContentWithTableName:TableOne];
    //这里直接拿到模型数组
    NSLog(@"%@",array);
    //将字典数组，直接转成模型数组，ID字段不用赋值
   NSArray * modelArray = [TestModel objectArrayWithKeyValuesArray:array];
    TestModel * model1 = [modelArray lastObject];
    NSLog(@"%@",model1.ID);
    
//    //删除第十三条记录
    [[DBSaveHelper sharedHelper] DeleteTableWithTableName:TableOne ID:@"1"];
//    TestModel * model = [[TestModel alloc]initWithName:@"guang" Age:@"11" ColorStr:@"红色23"];
    //替换id ＝2 的数据库信息
    [[DBSaveHelper sharedHelper]UpdataDBWithTableName:TableOne AndID:@"2" AndModel:model];
//  //传入sql进去直接查询语句
//    NSString * sql = [NSString stringWithFormat:@"select * from %@ where ID > 3",TableOne];
//    NSArray * arrayS = [[DBSaveHelper sharedHelper]searchDBWithSql:sql AndArray:nil AndTableName:TableOne];
//    NSLog(@"%@",arrayS);
//    //传入 sql 和 数组，数组中的内容为 sql中的？
//    NSString * sql1 = [NSString stringWithFormat:@"select * from %@ where name = ?",TableOne];
//    NSArray * arraytest = @[@"guang"];
//    NSArray * arraySs = [[DBSaveHelper sharedHelper]searchDBWithSql:sql1 AndArray:arraytest AndTableName:TableOne];
//    NSLog(@"%@",arraySs);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
