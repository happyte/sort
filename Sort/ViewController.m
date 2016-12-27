//
//  ViewController.m
//  Sort
//
//  Created by 张树 on 16/11/28.
//  Copyright © 2016年 com.zs. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableArray+ZSSort.h"

static int num = 50;

@interface ViewController ()

@property(nonatomic,strong)UISegmentedControl *segment;
@property(nonatomic,strong)NSMutableArray *barViewArray;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)UILabel *timeLabel;
@property (nonatomic, strong) dispatch_semaphore_t sema;
@end

@implementation ViewController

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (NSMutableArray *)barViewArray{
    if (_barViewArray == nil) {
        _barViewArray = [NSMutableArray arrayWithCapacity:num];
        for (int i = 0; i < num; i++) {
            UIView *barView = [[UIView alloc]init];
            barView.backgroundColor = [UIColor blueColor];
            [_barViewArray addObject:barView];
            [self.view addSubview:barView];
        }
    }
    return _barViewArray;
}

- (UISegmentedControl *)segment{
    if (_segment == nil) {
        _segment = [[UISegmentedControl alloc]initWithItems:@[@"选择",@"冒泡",@"插入",@"快速",@"堆排"]];
        [_segment addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_segment];
    }
    return _segment;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"重置" style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(sort)];
    self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.view.bounds)*0.5-40, 560, 80, 30);
    self.segment.frame = CGRectMake(40, 64+10, CGRectGetWidth(self.view.frame)*0.8, 30);
    self.segment.selectedSegmentIndex = 0;
    [self reset];
}

- (void)segmentChanged{
    [self reset];
}

- (void)reset{
    CGFloat barMargin = 1;
    self.timeLabel.text = @"";
    CGFloat barWidth = (0.8*CGRectGetWidth(self.view.bounds) - (num-1)*barMargin)/num;
    [self.barViewArray enumerateObjectsUsingBlock:^(UIView  *_Nonnull bar, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat barHeight = 10+arc4random_uniform(CGRectGetHeight(self.view.bounds)*0.6);
        bar.frame = CGRectMake(40+idx*(barWidth+barMargin), 550, barWidth, -barHeight);
    }];
}

- (void)sort{
    [self timerInvalid];
    NSTimeInterval currentTime = [[NSDate date]timeIntervalSince1970];
    self.sema = dispatch_semaphore_create(0);    //创建请求
     __weak typeof(self) weakSelf = self;
    // 定时器信号
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.005 repeats:YES block:^(NSTimer * _Nonnull timer) {
        //发出信号量
        dispatch_semaphore_signal(self.sema);
        NSTimeInterval delta = [[NSDate date]timeIntervalSince1970]-currentTime;
        self.timeLabel.text = [NSString stringWithFormat:@"耗时%.2f",delta];
    }];
    //下面这条线程不是主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        switch (self.segment.selectedSegmentIndex) {
            case 0:
                [self selectSort];
                break;
            case 1:
                [self bubbleSort];
                break;
            case 2:
                [self insertSort];
                break;
            case 3:
                [self quickSort];
                break;
            case 4:
                [self heapSort];
                break;
            default:
                break;
        }
        [self timerInvalid];
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self timerInvalid];
}

- (void)timerInvalid{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.sema = nil;
}

- (void)selectSort{
    [self.barViewArray zs_selectSort:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithOne:obj1 Two:obj2];
    } withCallback:^(id obj1, id obj2) {
        [self exchangeWithOne:obj1 Two:obj2];
    }];
}

- (void)bubbleSort{
    [self.barViewArray zs_bubbleSort:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithOne:obj1 Two:obj2];
    } withCallback:^(id obj1, id obj2) {
        [self exchangeWithOne:obj1 Two:obj2];
    }];
}

- (void)insertSort{
    [self.barViewArray zs_insertSort:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithOne:obj1 Two:obj2];
    } withCallback:^(id obj1, id obj2) {
         [self exchangeWithOne:obj1 Two:obj2];
    }];
}

- (void)quickSort{
    [self.barViewArray zs_quickSort:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithOne:obj1 Two:obj2];
    } withCallback:^(id obj1, id obj2) {
        [self exchangeWithOne:obj1 Two:obj2];
    }];
}

- (void)heapSort{
    [self.barViewArray zs_heapSort:^NSComparisonResult(id obj1, id obj2) {
        return [self compareWithOne:obj1 Two:obj2];
    } withCallback:^(id obj1, id obj2) {
        [self exchangeWithOne:obj1 Two:obj2];
    }];
}

- (NSComparisonResult)compareWithOne:(UIView *)one Two:(UIView *)two{
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    CGFloat oneHeight = one.frame.size.height;
    CGFloat twoHeight = two.frame.size.height;
    if (oneHeight == twoHeight) {
        return NSOrderedSame;
    }
    return oneHeight < twoHeight? NSOrderedAscending:NSOrderedDescending;
}

- (void)exchangeWithOne:(UIView *)one Two:(UIView *)two{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect oneFrame = one.frame;
        CGRect twoFrame = two.frame;
        oneFrame.origin.x = two.frame.origin.x;
        twoFrame.origin.x = one.frame.origin.x;
        one.frame = oneFrame;
        two.frame = twoFrame;
    });
}

@end
