//
//  ZSPersonTool.m
//  ZSSearch
//
//  Created by 周松 on 16/11/25.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPersonTool.h"
#import "ZSPerson.h"
#import <sqlite3.h>

static sqlite3 *_db;
@implementation ZSPersonTool
//首先要创建数据库
+(void)initialize{
    //获取数据库文件的路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *fileName = [doc stringByAppendingString:@"person.sqlite"];
    //将OC字符串转换成c语言的字符串
    const char *cfileName = fileName.UTF8String;
    //1.打开数据库文件(如果数据库文件不存在,那么就会创建数据库)
    int result = sqlite3_open(cfileName, &_db);
    if (result == SQLITE_OK) {
        //2.创建表
        const char *sql = "CREATE TABLE IF NOT EXISTS t_person (id integer PRIMARY KEY AUTOINCREMENT,name text NOT NULL,age integer NOT NULL);";
        char *errmsg = NULL;
        result = sqlite3_exec(_db, sql, NULL, NULL, &errmsg);
        //创建表成功
        if (result == SQLITE_OK) {
            NSLog(@"创建表成功");
        }else{
            NSLog(@"创建表失败");
        }
    }else{
        NSLog(@"打开数据库失败");
    }
}

+ (void)save:(ZSPerson *)person{
    //1.拼接SQL语句
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_person(name,age) VALUES ('%@',%d);",person.name,person.age];
    //2.执行SQL语句
    char *errmsg = NULL;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"插入数据有误  %s",errmsg);
    }else{
//        NSLog(@"插入数据成功");
    }
}

+(NSArray *)query{
    return  [self queryWithCondition:@""];
    
}

+(NSArray *)queryWithCondition:(NSString *)condition{
    //用来保存查询到的联系人
    NSMutableArray *personArray = nil;
    
    NSString *NSsql = [NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;",condition];
    //SELECT id,name,age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;"
    const char *sql = NSsql.UTF8String;
    
    sqlite3_stmt *stmt = NULL;
    
    //进行查询前的准备工作 -1代表系统会自动计算SQL语句的长度
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, nil) == SQLITE_OK) {
//        NSLog(@"查询语句没有问题");
        
        personArray = [NSMutableArray array];
        
        //每调用一次sqlite3_step函数,stmt就会指向下一条记录
        while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
            //取出数据
            //(1)取出第0列字段的值
            int ID = sqlite3_column_int(stmt, 0);
            //(2)取出第1列字段的值
            const unsigned char *name = sqlite3_column_text(stmt, 1);
            //(3取出第2列字段的值
            int age = sqlite3_column_int(stmt, 2);
            
            ZSPerson *person = [[ZSPerson alloc]init];
            person.ID = ID;
            person.name = [NSString stringWithUTF8String:(const char *)name];
            person.age = age;
            [personArray addObject:person];
        }
    }else{
        NSLog(@"查询语句有问题");
    }
    return personArray;
}

@end













