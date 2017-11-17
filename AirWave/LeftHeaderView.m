//
//  LeftHeaderView.m
//  AirWave
//
//  Created by Macmini on 2017/11/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LeftHeaderView.h"
#import "UIImage+ImageWithColor.h"
#import "BaseHeader.h"

#define tableViewWidth  KScreenWidth - KMainPageDistance

@interface LeftHeaderView()

@end

@implementation LeftHeaderView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame] ;
    if (self) {
        [self addView];
        self.backgroundColor = UIColorFromHex(0X65BBA9);
    }
    return self;
}

-(void)addView
{
    //加载头像
    UIImageView * headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 * KScreenUnit, 130 * KScreenUnit, 100 * KScreenUnit, 100 * KScreenUnit)];
//    headerImageView.layer.cornerRadius = 50 * KScreenUnit;
    headerImageView.clipsToBounds  = YES;
    headerImageView.image = [UIImage imageNamed:@"bear"];
    [self addSubview:headerImageView];
    //加载昵称
    UILabel * nickNameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headerImageView.frame)+ 20 * KScreenUnit , 150 * KScreenUnit, 300 * KScreenUnit,40 * KScreenUnit)];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"name"]) {
        nickNameLabel.text = [NSString stringWithFormat:@"    %@",[userDefault objectForKey:@"name"]];
    }else{
            nickNameLabel.text = @"    jasper";
    }
    nickNameLabel.textColor = [UIColor whiteColor];
//    nickNameLabel.font   = [UIFont systemFontOfSize:28 * KScreenUnit];
    nickNameLabel.font = [UIFont systemFontOfSize:35*KScreenUnit];
    [self addSubview:nickNameLabel];
    
    //添加点击button
    self.myInformationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, tableViewWidth, 230 * KScreenUnit)];
    self.myInformationButton.tag = 1;
    self.myInformationButton.backgroundColor = [UIColor clearColor];
    [self.myInformationButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBAndAlpha(0Xffffff, 0.3)] forState:UIControlStateHighlighted];
    [self addSubview:self.myInformationButton];
    
    
    //添加二维码button
    self.QRCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(520 * KScreenUnit, 135 * KScreenUnit, 44 * KScreenUnit, 44 * KScreenUnit)];
    [self.QRCodeButton setBackgroundImage:[UIImage imageNamed:@"sidebar_ QRcode_normal"] forState:UIControlStateNormal];
    self.QRCodeButton.tag = 2;
    [self.QRCodeButton setBackgroundImage:[UIImage imageNamed:@"sidebar_ QRcode_press"] forState:UIControlStateHighlighted  ];
    [self addSubview:self.QRCodeButton];
    
    //添加个性签名-图片，文字
    UIImageView * symbolImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 * KScreenUnit,240 * KScreenUnit , 30 * KScreenUnit, 30 * KScreenUnit)];
    
    symbolImageView.image = [UIImage imageNamed:@"sidebar_signature_nor"];
    [self addSubview:symbolImageView];
    
    UILabel * personalSignature = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(symbolImageView.frame) + 15 * KScreenUnit, 230  * KScreenUnit, 500 * KScreenUnit, 50 * KScreenUnit)];
    personalSignature.font = [UIFont systemFontOfSize:22 * KScreenUnit];
    personalSignature.text =  @"                    🐑";
    personalSignature.textColor = UIColorFromRGBAndAlpha(0x000000, 0.54);
    [self addSubview:personalSignature];
    
    //添加个性签名的button
    self.personalSignatureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 230 * KScreenUnit, tableViewWidth, 50 * KScreenUnit)];
    self.personalSignatureButton.tag = 3;
    self.personalSignatureButton.backgroundColor = [UIColor clearColor];
    [self.personalSignatureButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBAndAlpha(0xffffff, 0.3)] forState:UIControlStateHighlighted];
    [self addSubview:self.personalSignatureButton];
    
}


@end
