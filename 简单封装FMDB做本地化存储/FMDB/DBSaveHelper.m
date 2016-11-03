//
//  DBSaveHelper.m
//  简单封装FMDB做本地化存储
//
//  Created by aaa on 16/1/22.
//  Copyright © 2016年 pengPL. All rights reserved.
//

#import "DBSaveHelper.h"
#import "ShaHeSave.h"


@implementation DBSaveHelper

+ (instancetype)sharedHelper
{
    static DBSaveHelper *_saveHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _saveHelper = [[DBSaveHelper alloc]init];
    });
    return _saveHelper;
}
+ (NSString *)contentStrWith:(NSString *)dbStr And:(NSString *)type{
    return [NSString stringWithFormat:@"%@ %@",dbStr,type];
}


#pragma mark - 打开sqlite 文件  打开db 如果不存在则创建 --
- (void)openDB:(NSString *)pathName
{
    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingString:[NSString stringWithFormat:@"/%@",pathName]];
    NSLog( @"path====%@", path );
    
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
}

//在sqlite下面创建表，tableName为表名 array 为所要创建的表字段
- (void)createTableWithName:(NSString *)tableName AndArray:(NSArray *)array
{
    NSMutableString * mutStr = [NSMutableString string];
    NSString * string1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer PRIMARY KEY AUTOINCREMENT",tableName];
    [mutStr appendString:string1];
    for (int i = 0; i < array.count; i ++) {
        [mutStr appendString:[NSString stringWithFormat:@",%@",array[i]]];
    }
    [mutStr appendString:@")"];
    [_db executeUpdate:mutStr];
}

#pragma mark - 插入数据 --
- (void)insertIntoDBWithTableName:(NSString *)name AndModel:(NSObject *)model
{
    NSDictionary * dict = model.keyValues;
    NSArray * array = [dict allKeys];
    [ShaHeSave saveQuestionArray:array withName:name];
    //KeyStr 为所有的键
    NSMutableString * keyStr = [NSMutableString string];
    for (int i = 0; i < array.count-1; i ++) {
        [keyStr appendString:[NSString stringWithFormat:@"%@,",array[i]]];
    }
    [keyStr appendString:[NSString stringWithFormat:@"%@",[array lastObject]]];
    //ValueStr 为所有的值
    NSArray * array1 = [dict allValues];
    NSMutableString * valueStr = [NSMutableString string];
    for (int i = 0; i < array1.count-1; i ++) {
        [valueStr appendString:@"?,"];
    }
    [valueStr appendString:@"?"];
    NSString * sql = [NSString stringWithFormat:@"insert into %@ (%@)values(%@)",name,keyStr,valueStr];
    [_db executeUpdate:sql withArgumentsInArray:array1];
    
}

//传入sql 拿到字典数组
- (NSArray *)searchDBWithSql:(NSString *)sql AndArray:(NSArray *)array AndTableName:(NSString *)name{
    FMResultSet * res = [_db executeQuery:sql withArgumentsInArray:array];
    NSMutableArray * mutArray = [NSMutableArray array];
    while ([res next]) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        NSString * string = [res stringForColumn:@"ID"];
        NSArray * array = [ShaHeSave getArrayFromDBWithName:name];
        dict[@"ID"] = string;
        for (int i = 0; i < array.count; i ++) {
            dict[array[i]] = [res stringForColumn:array[i]];
        }
        [mutArray addObject:dict];
    }
    return mutArray;
}



- (NSArray *)searchDBAllContentWithTableName:(NSString *)tableName{
    NSString * sql = [NSString stringWithFormat:@"select * from %@",tableName];
    FMResultSet * res = [_db executeQuery:sql];
    NSArray * array = [ShaHeSave getArrayFromDBWithName:tableName];
    NSMutableArray * array1 = [NSMutableArray array];
   
    while ([res next]) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        NSString * string = [res stringForColumn:@"ID"] ;
        dict[@"ID"] = string;
        for (int i = 0; i < array.count; i ++) {
            dict[array[i]] = [res stringForColumn:array[i]];
        }
        [array1 addObject:dict];
    }
    return array1;
}

- (void)DeleteTableWithTableName:(NSString *)name ID:(NSString *)ID
{
    NSString * sql = [NSString stringWithFormat:@"delete from %@ where ID = %@",name,ID];
    [_db executeUpdate:sql];
}

- (void)DeleteAllFromTableWithName:(NSString *)name{
    NSString * sql = [NSString stringWithFormat:@"delete from %@",name];
    [_db executeUpdate:sql];
}

- (void)UpdataDBWithTableName:(NSString *)name AndID:(NSString *)ID AndModel:(NSObject *)model
{
    NSDictionary * dict = model.keyValues;
    NSArray * array = [dict allKeys];
    NSArray * array1 = [dict allValues];
    NSMutableString * updataStr = [NSMutableString string];
    [updataStr appendString:[NSString stringWithFormat:@"update %@ set ",name]];
    
    for (int i = 0; i < array.count-1; i ++) {
        [updataStr appendString:[NSString stringWithFormat:@"%@=?,",array[i]]];
    }
    [updataStr appendString:[NSString stringWithFormat:@"%@=?",[array lastObject]]];
    [updataStr appendString:@" where ID =?"];
    NSMutableArray * mutArray = [NSMutableArray arrayWithArray:array1];
    [mutArray addObject:ID];
    [_db executeUpdate:updataStr withArgumentsInArray:mutArray];
}


//#pragma mark - 检查 表名 是否存在数据库中 --
//-(BOOL)checkTableIsHasWithTableName:(NSString *)tableName
//{
//    BOOL isHas = NO;
//    
//    /**
//     *  select count(*) from sqlite_master where type='table' and name='TaskRewardCategoryTable';
//     */
//    
////    NSString * sqlDropTable = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name='%@';", tableName ];
//    
//    NSString * sqlDropTable = [NSString stringWithFormat:@"select count(*) from sqlite_master where and name='%@'", tableName ];
//    
//    NSLog( @"sqlDropTable====%@", sqlDropTable );
//    
//    
//    isHas = [_db executeQuery: sqlDropTable ];
//    
//    return isHas;
//}

#pragma mark - 检查 表名 是否存在数据库中 --
-(BOOL)checkTableIsHasWithTableName:(NSString *)tableName
{
    BOOL isHas = NO;
    
    /**
     *  select count(*) from sqlite_master where type='table' and name='TaskRewardCategoryTable';
     */
    
    //    NSString * sqlDropTable = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name='%@';", tableName ];
    
    NSString * sqlDropTable = [NSString stringWithFormat:@"select count(*) from sqlite_master where name='%@'", tableName ];
    
    FMResultSet * getSqlResult = [_db executeQuery: sqlDropTable ];
    while ( [getSqlResult next] ) {
        NSString * getObj = [NSString stringWithFormat:@"%@", [getSqlResult stringForColumnIndex: 0 ]];
        if ( [getObj isEqualToString:@"0"] ) {
            isHas = NO;
        }else if ( [getObj isEqualToString:@"1"] ){
            isHas = YES;
        }
        break;
    }
    return isHas;
}

#pragma mark - 删除 表名 --
-(void)DropTableWithTableName:(NSString *)tableName
{
    NSString * sqlDropTable = [NSString stringWithFormat:@"drop table %@", tableName ];
    [_db executeQuery: sqlDropTable ];
}

#pragma mark - 升级 数据库 表里添加传入的属性 --
-(void)UpgradeTableWithTableName:(NSString *)tableName andAttribute:(NSString *)attribute andType:(NSString *)type
{
    /**
     *   从数据库中删除表。删除后，表结构不在存在，无法再对该表进行任何操作
     */
    NSString * sqlGetCreateTable = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName ];
    
    FMResultSet * getSqlResult = [_db executeQuery: sqlGetCreateTable ];
    
    BOOL isUpgradeAddLevelIndexAttribute = NO;
    while ( [getSqlResult next] ) {
        NSString * getCreateTableSql = [getSqlResult stringForColumnIndex: 0 ];
        NSLog( @"getCreateTableSql====%@", getCreateTableSql );
        
        NSRange range = [getCreateTableSql rangeOfString: attribute ];
        if( range.location == NSNotFound ){
            isUpgradeAddLevelIndexAttribute = YES;
        }
        break;
    }
    
    if ( isUpgradeAddLevelIndexAttribute ) {
        /*
         找不到levelIndex, 数据库里没有该属性，可以插入了。
         */
        
        /**
         *  alter table 'TaskRewardCategoryTable' add levelIndex TEXT
         */
        NSString * getAddLevelIndexSql = [NSString stringWithFormat:@"alter table '%@' add %@ %@", tableName, attribute, type ];
        FMResultSet * getAddLevelIndexSqlResult = [_db executeQuery: getAddLevelIndexSql ];
        NSLog( @"getAddLevelIndexSqlResult====%@", getAddLevelIndexSqlResult );
        
        while ( [getAddLevelIndexSqlResult next] ) {
            
        }
    }
}



#pragma mark - 执行 获取字符串的 sql 语句 --
-(NSString *)getStringWithSql:(NSString *)sql
{
    FMResultSet * sqlGetNameByCodeResult = [_db executeQuery: sql ];
    NSString * returnString = @"";
    while ( [sqlGetNameByCodeResult next] ) {
        returnString = [sqlGetNameByCodeResult stringForColumn:@"name"];
    }
    return returnString;
}


#pragma mark - 执行 获取 数组 查找表中所有数据  的 sql 语句 --
-(NSArray *)getArrayAllObjectWithSql:(NSString *)sql andTableName:(NSString *)tableName
{
    /**
     *  获取 表中的 属性 --
     */
    NSString * sqlGetCreateTable = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName ];
    NSLog( @"sqlGetCreateTable===%@", sqlGetCreateTable );
    FMResultSet * getSqlResult = [_db executeQuery: sqlGetCreateTable ];
    
    NSMutableArray * getTableAttributeArr = [NSMutableArray array];
    while ( [getSqlResult next] ) {
        NSString * getCreateTableSql = [getSqlResult stringForColumnIndex: 0 ];
        NSLog( @"getCreateTableSql====%@", getCreateTableSql );
        
        NSRange range1 = [getCreateTableSql rangeOfString:@"("];
        if ( range1.location != NSNotFound ) {
            NSString * getRange1 = [getCreateTableSql substringFromIndex: range1.location ];
            getTableAttributeArr = [NSMutableArray arrayWithArray: [getRange1 componentsSeparatedByString:@","] ];
            for ( NSInteger i = 0; i < getTableAttributeArr.count; i++ ) {
                if ( i == 0 ) {
                    [getTableAttributeArr replaceObjectAtIndex: i withObject: @"ID" ];
                    
                }else{
                    NSString * getStr = [NSString stringWithFormat:@"%@", [getTableAttributeArr objectAtIndex: i ]];
                    NSArray * getNamrArr = [getStr componentsSeparatedByString:@" "];
                    NSString * getName = [NSString stringWithFormat:@"%@", [getNamrArr objectAtIndex: 0 ]];
                    if ( [getName isEqualToString:@""] ) {
                        getName = [NSString stringWithFormat:@"%@", [getNamrArr objectAtIndex: 1 ]];
                    }
                    [getTableAttributeArr replaceObjectAtIndex: i withObject: getName ];
                }
            }
        }
        
        break;
    }
    NSLog( @"getTableAttributeArr====%@", getTableAttributeArr );
    
    FMResultSet * sqlResult = [_db executeQuery: sql ];
    NSMutableArray * getSqlResultArr = [NSMutableArray array];
    
    while ( [sqlResult next] ) {
        NSMutableDictionary * getSqlResultDict = [NSMutableDictionary dictionary];
        for ( NSInteger i = 0; i < getTableAttributeArr.count; i ++) {
            getSqlResultDict[getTableAttributeArr[i]] = [sqlResult stringForColumn:getTableAttributeArr[i]];
        }
        [getSqlResultArr addObject: getSqlResultDict ];
    }
    
    return getSqlResultArr;
}



- (void)CloseDB
{
    [_db close];
}

@end
