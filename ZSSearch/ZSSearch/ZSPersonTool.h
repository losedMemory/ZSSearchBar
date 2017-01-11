//
//  ZSPersonTool.h
//  ZSSearch
//
//  Created by 周松 on 16/11/25.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZSPerson;
@interface ZSPersonTool : NSObject

//保存一个联系人
+(void)save:(ZSPerson *)person;

//查询所有联系人
+(NSArray *)query;
+(NSArray *)queryWithCondition:(NSString *)condition;

@end
