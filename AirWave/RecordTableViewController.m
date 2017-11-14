//
//  RecordTableViewController.m
//  AirWave
//
//  Created by Macmini on 2017/10/10.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordTableViewController.h"
#import "RecordTableViewCell.h"
#import "UIImage+Rotate.h"
#import "DetailViewController.h"
#import "TreatRecord.h"
#import "ServerRecordTableViewController.h"
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
static NSString *AIRWAVETYPE = @"7681";
static NSString *BLOODDEVTYPE = @"8888";
typedef NS_ENUM(NSUInteger,cellViewTag)
{
    timeLabelTag = 55,imageTag = 555,treatWayLableTag = 666,numberLabelTag = 222
};
@interface RecordTableViewController ()
{
    NSMutableArray *records;
    NSMutableArray *mResult;
}
- (IBAction)returnButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)upload:(id)sender;
@end

@implementation RecordTableViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //文件名
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *documentPath = [documents stringByAppendingPathComponent:@"record.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:documentPath])
        {
            [fileManager createFileAtPath:documentPath contents:nil attributes:nil];
        }
        //取出以前保存的record数组
        if ([fileManager fileExistsAtPath:documentPath])
        {
            NSData * resultdata = [[NSData alloc] initWithContentsOfFile:documentPath];
            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:resultdata];
            NSArray *savedArray = [unArchiver decodeObjectForKey:@"recordArray"];
            NSMutableArray *array = [NSMutableArray arrayWithArray:savedArray];

            //倒序
            records = [NSMutableArray arrayWithArray:[[array reverseObjectEnumerator] allObjects]];
            mResult = [[NSMutableArray alloc]init];
            for(TreatRecord *record in records)
            {
                if ([record.type isEqualToString:self.type])
                {
                    [mResult addObject:record];
                }
            }
//            mResult = records;
            if (!records)
            {
                records = [NSMutableArray array];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];} );
        }
    });
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.type isEqualToString:BLOODDEVTYPE])
    {
        self.title = @"血瘘治疗记录";
    }else if ([self.type isEqualToString:AIRWAVETYPE])
    {
        self.title = @"空气波治疗记录";
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc]init];
    //加载数据
    //导航栏
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65BBA9);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem.tintColor = UIColorFromHex(0xffffff);
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0xffffff);
    
    //右上角按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30 , 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"list-2"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rightBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barButton;
    [self.tableView reloadData];

}
-(void)rightBarButtonClicked:(UIButton *)button
{
    [self performSegueWithIdentifier:@"ShowServerRecords" sender:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mResult count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[RecordTableViewCell init]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //序号
    cell.numberLabel.text = [NSString stringWithFormat:@"%d",(int)indexPath.row +1];
    //取出record
    TreatRecord *record = (TreatRecord *)[mResult objectAtIndex:indexPath.row];
    //时间
    cell.timeLabel.text = record.dateString;
    
    //治疗方式
    if ([self.type isEqualToString:AIRWAVETYPE])
    {
        cell.treatWayLabel.text = record.treatWayString;
    }else if([self.type isEqualToString:BLOODDEVTYPE]){
        cell.treatWayLabel.text = [NSString stringWithFormat:@"治疗强度：%d",record.treatWay];
    }

    //治疗时长
//    cell.durationLabel.text = record.durationString;
    return cell;
}
#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//  NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    TreatRecord *record = mResult[indexPath.row];
    [self performSegueWithIdentifier:@"ShowDetail" sender:record];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *searchResult = self.searchBar.text;
    if ([searchResult length]>0)
    {
        //搜索结果
        NSString *searchString = self.searchBar.text;
        
        
        //tmpt保存搜索结果数组
        NSMutableArray *tmpt = [NSMutableArray array];
        //便利records
        for (TreatRecord *record in records )
        {
            NSDate *date = record.dateTime;
            NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
            fmt.dateFormat = @"yyyy-MM-dd";
            NSString *dateString = [fmt stringFromDate:date];
            
            if ([dateString isEqualToString:searchString])
            {
                
                [tmpt addObject:record];
            }
        }
        if ([tmpt count]>0)
        {
            mResult = tmpt;
        }
        else
        {
            mResult = records;
        }
    }
    else
    {
        mResult = records;
    }
    [self.tableView reloadData];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetail"])
    {
        DetailViewController *controller = (DetailViewController* )segue.destinationViewController;
        controller.record = sender;
    }else if ([segue.identifier isEqualToString:@"ShowServerRecords"]){
        ServerRecordTableViewController *controller = (ServerRecordTableViewController *)segue.destinationViewController;
        controller.type = self.type;
    }
}
#pragma mark - picture
//等比例压缩
-(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

#pragma mark - private method
-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *)scaleImage:(UIImage *)image maxSize:(CGFloat)maxSize {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if(data.length < 200 * 1024)
    {//0.25M-0.5M(当图片小于此范围不压缩)
        return image;
    }
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat targetWidth = imageWidth;
    CGFloat targetHeight = imageHeight;
    CGFloat imageMaxSize = MAX(imageWidth, imageHeight);
    if (imageMaxSize > maxSize)
    {
        CGFloat scale = 0;
        if (imageWidth >= imageHeight) {// 宽长
            scale = maxSize / imageWidth;
            targetWidth = maxSize;
            targetHeight = imageHeight * scale;
        } else { // 高长
            scale = maxSize / imageHeight;
            targetHeight = maxSize;
            targetWidth = imageWidth * scale;
        }
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [image drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    }
    return image;
}

- (IBAction)returnButtonClicked:(id)sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}
@end
