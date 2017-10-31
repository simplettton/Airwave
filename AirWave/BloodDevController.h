//
//  ViewController.h
//  LifotronicFamily
//
//  Created by simplettton on 2017/7/31.
//  Copyright © 2017年 Simplettton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
@interface BloodDevController : UIViewController{
    @public
    BabyBluetooth *baby;
}
@property __block NSMutableArray *services;
@property(strong,nonatomic)CBPeripheral *currPeripheral;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)pause:(id)sender;

@end

