//
//  LeftTableView.h
//  AirWave
//
//  Created by Macmini on 2017/11/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    KMyInformation = 1,
    KQRCode,
    KPersonalSignature,
    KMyQQVip,
    KQQWalte,
    KPersonalDressing,
    KMyLike,
    KMyAlbum,
    KMyFile,
    //    KMyBusinessCards,
    KAppSeting,
    KNightStyle,
    KWeather,
} ELeftClickType;

@protocol LeftTableViewClickDelegate <NSObject>
-(void)tableView:(UITableView *) tableView clickedType:(ELeftClickType) clickType;
@end

@interface LeftTableView : UITableView
@property(nonatomic,assign)id<LeftTableViewClickDelegate>clickDelegate;
@end

