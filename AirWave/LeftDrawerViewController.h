//
//  LeftDrawerViewController.h
//  
//
//  Created by Macmini on 2017/11/7.
//
//

#import <UIKit/UIKit.h>
#import "LeftHeaderView.h"

@interface LeftDrawerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet LeftHeaderView *headerView;
@end
