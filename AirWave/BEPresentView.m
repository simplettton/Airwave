//
//  BEPresentView.m
//  AirWave
//
//  Created by Macmini on 2017/11/16.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BEPresentView.h"
#define UI_navBar_Height 64.0
#define UI_View_Height 731
#define UI_View_Width 375.0
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
@interface BEPresentView()
{
//    UIView *_contentView;
}
@end
@implementation BEPresentView

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        [self setupContent];
    }
    return self;
}

- (void)setupContent
{
    self.frame = CGRectMake(0, 0, UI_View_Width, BEPresentViewHight);
    
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)]];
    
    if (_contentView == nil)
    {
        
        CGFloat margin = 15;
        
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0,  UI_View_Height - BEPresentViewHight, UI_View_Width,  BEPresentViewHight)];
        NSLog(@"%f",_contentView.bounds.size.height);
        NSLog(@"%f",_contentView.frame.origin.y);
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        // 右上角关闭按钮
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(_contentView.bounds.size.width - 20 - margin, margin, 20, 20);
        [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(disMissView) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:closeBtn];
        
        
        UIButton *redrawButton = [[UIButton alloc]initWithFrame:CGRectMake(margin, 10, 50, 30)];
        [redrawButton setTitle:@"清除" forState:UIControlStateNormal];
        [redrawButton setTitleColor:UIColorFromHex(0x85abe4) forState:UIControlStateNormal];
        redrawButton.titleLabel.font= [UIFont systemFontOfSize:17.0];
        [redrawButton setTag:5555];
        [_contentView addSubview:redrawButton];
        
        
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(50 + margin*2, 10, 50, 30)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor:UIColorFromHex(0x85abe4) forState:UIControlStateNormal];
        saveButton.titleLabel.font= [UIFont systemFontOfSize:17.0];
        [saveButton setTag:6666];
        [_contentView addSubview:saveButton];
    }
}
//展示从底部向上弹出的UIView（包含遮罩）
- (void)showInView:(UIView *)view
{
    if (!view)
    {
        return;
    }
    
    [view addSubview:self];
    [view addSubview:_contentView];
    
    [_contentView setFrame:CGRectMake(0, UI_View_Height, UI_View_Width, BEPresentViewHight)];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
        
        [_contentView setFrame:CGRectMake(0, UI_View_Height - BEPresentViewHight - UI_navBar_Height, UI_View_Width, BEPresentViewHight)];
        
    } completion:nil];
}

//移除从上向底部弹下去的UIView（包含遮罩）
- (void)disMissView
{
    [_contentView setFrame:CGRectMake(0, UI_View_Height - BEPresentViewHight, UI_View_Width, BEPresentViewHight)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.alpha = 0.0;
                         
                         [_contentView setFrame:CGRectMake(0, UI_View_Height, UI_View_Width, BEPresentViewHight)];
                     }
                     completion:^(BOOL finished){
                         
                         [self removeFromSuperview];
                         [_contentView removeFromSuperview];
                         
                     }];
}

@end
