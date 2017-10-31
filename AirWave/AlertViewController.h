//
//  AlertViewController.h
//  
//
//  Created by Macmini on 2017/10/27.
//
//

#import <UIKit/UIKit.h>
@protocol AlertViewControllerDelegate<NSObject>
//声明协议
//在接收方调用
@end
@interface AlertViewController : UIViewController
@property (nonatomic,copy)void(^returnBlock)(BOOL,BOOL);
@property (assign ,nonatomic) BOOL firstSelected;
@property (assign ,nonatomic) BOOL secondSelected;
@property (assign ,nonatomic) BOOL thirdSelected;
@end
