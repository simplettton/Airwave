//
//  EnumValue.h
//  AirWave
//
//  Created by Macmini on 2017/12/6.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#ifndef EnumValue_h
#define EnumValue_h
typedef NS_ENUM(NSUInteger,BodyButtonIndexs)
{
    leftup1index,leftup2index,leftup3index,lefthandindex,leftdown1index,leftdown2index,leftdown3index,leftfootindex,
    rightup1index,rightup2index,rightup3index,righthandindex,rightdown1index,rightdown2index,rightdown3index,rightfootindex,
    middle1index,middle2index,middle3index,middle4index
};
typedef NS_ENUM(NSUInteger,LegButtonIndexs)
{
    leftleg1index,leftleg2index,leftleg3index,leftleg4index,leftleg5index,leftleg6index,leftleg7index
};
typedef NS_ENUM(NSUInteger,TreatState)
{   Running,Stop,Pause,Unconnecte   };
typedef NS_ENUM(NSUInteger,CellState)
{
    UnWorking,Working,KeepingAir
};
typedef NS_ENUM(NSUInteger,TreatWay)
{
    Standart = 1,Gradient,Parameter,Solution
};
typedef NS_ENUM(NSUInteger,BodyTags)
{
    leftup1tag   =17,leftup2tag   =16,leftup3tag   =15,lefthandtag  =14,leftdown1tag =13,leftdown2tag =12,leftdown3tag =11,
    leftfoottag  =10,rightup1tag  =27,rightup2tag  =26,rightup3tag  =25,righthandtag =24,rightdown1tag=23,rightdown2tag=22,
    rightdown3tag=21,rightfoottag =20,middle1tag   =33,middle2tag   =32,middle3tag   =31,middle4tag   =30,
    
    rightleg1tag =47,rightleg2tag =46,rightleg3tag =45,rightleg4tag =44,rightleg5tag =43,rightleg6tag =42,rightleg7tag =41,
    leftleg1tag  =57,leftleg2tag  =56,leftleg3tag  =55,leftleg4tag  =54,leftleg5tag  =53,leftleg6tag  =52,leftleg7tag  =51, disconnectViewtag = 999
    
};
static int bodyPartTags[] = {   leftup1tag , leftup2tag , leftup3tag , lefthandtag , leftdown1tag , leftdown2tag , leftdown3tag , leftfoottag ,
    rightup1tag, rightup2tag, rightup3tag, righthandtag, rightdown1tag, rightdown2tag, rightdown3tag, rightfoottag,
    middle1tag, middle2tag , middle3tag , middle4tag    };

static int legTags[] = {    leftleg1tag , leftleg2tag , leftleg3tag , leftleg4tag , leftleg5tag , leftleg6tag , leftleg7tag , leftfoottag,
    rightleg1tag, rightleg2tag, rightleg3tag, rightleg4tag, rightleg5tag, rightleg6tag, rightleg7tag, rightfoottag    };


#endif /* EnumValue_h */
