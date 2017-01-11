//
//  ZSSearchResultViewController.h
//  ZSSearch
//
//  Created by 周松 on 17/1/10.
//  Copyright © 2017年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ResultDidSelectedCellBlock) (UITableViewCell *selectedCell);

@interface ZSSearchResultViewController : UITableViewController

@property (nonatomic,copy) NSArray<NSString *> *infoArray;

//点击cell的block,将内容传递到searchBar中
@property (nonatomic,copy) ResultDidSelectedCellBlock didselectedCellBlock;

@end
