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
typedef NS_ENUM(NSUInteger,cellViewTag)
{
    timeLabelTag = 55,imageTag = 555,treatWayLableTag = 666,numberLabelTag = 222
};
@interface RecordTableViewController ()
{
    NSMutableArray *records;
    NSMutableArray *mResult;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation RecordTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
        mResult = records;
        if (!records)
        {
            records = [NSMutableArray array];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //然后再新开一个线程去加载图片
//    [NSThread detachNewThreadSelector:@selector(updateImageForCellAtIndexPath:) toTarget:self withObject:indexPath];
//}
//- (void)updateImageForCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    //取出record
//    TreatRecord *record = (TreatRecord *)[records objectAtIndex:indexPath.row];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    UIImageView *imageView = [cell viewWithTag:imageTag];
//    NSData *imageData =record.imgData;
////  UIImage *image = [self imageCompressForSize:[UIImage imageWithData:imageData] targetSize:imageView.frame.size];
//
////    UIImage *image = [UIImage imageWithData:imageData];
//    UIImage *image = [self fixOrientation:[UIImage imageWithData:imageData]];
//    [imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[RecordTableViewCell init]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //序号
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row +1];
    //取出record
    TreatRecord *record = (TreatRecord *)[mResult objectAtIndex:indexPath.row];
    //时间
    cell.timeLabel.text = record.dateString;
    
    //治疗方式
    
    cell.treatWayLabel.text = record.treatWayString;
    //治疗时长
//    cell.durationLabel.text = record.durationString;
    
    //图片
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData =record.imgData;
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.resultImageView.image = [[self imageCompressForSize:image targetSize:cell.resultImageView.frame.size]rotate:UIImageOrientationRight];
        });
    });
    return cell;
}
#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//  NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    TreatRecord *record = mResult[indexPath.row];
    if ([record.imgData length]>0)
    {
        [self performSegueWithIdentifier:@"ShowDetail" sender:record];
    }
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
    if(CGSizeEqualToSize(imageSize, size) == NO){
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
    if(CGSizeEqualToSize(imageSize, size) == NO){
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
@end
