//
//  NSMutableArray+ZSSort.h
//  Sort
//
//  Created by 张树 on 16/11/28.
//  Copyright © 2016年 com.zs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (ZSSort)
 //block块作为参数传给函数
typedef NSComparisonResult(^ZSCompare)(id obj1,id obj2);  //比较函数
typedef void(^ZSExchange)(id obj1,id obj2);               //交换函数

- (void)zs_selectSort:(ZSCompare)compare withCallback:(ZSExchange)exchange;   //选择排序
- (void)zs_bubbleSort:(ZSCompare)compare withCallback:(ZSExchange)exchange;
- (void)zs_insertSort:(ZSCompare)compare withCallback:(ZSExchange)exchange;
- (void)zs_quickSort:(ZSCompare)compare withCallback:(ZSExchange)exchange;
- (void)zs_heapSort:(ZSCompare)compare withCallback:(ZSExchange)exchange;
@end
