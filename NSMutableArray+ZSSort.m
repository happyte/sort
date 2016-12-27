//
//  NSMutableArray+ZSSort.m
//  Sort
//
//  Created by 张树 on 16/11/28.
//  Copyright © 2016年 com.zs. All rights reserved.
//

#import "NSMutableArray+ZSSort.h"

@implementation NSMutableArray (ZSSort)

- (void)zs_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB Change:(ZSExchange)exchange {
    id temp = self[indexA];
    self[indexA] = self[indexB];
    self[indexB] = temp;
    if (exchange) {
        exchange(self[indexA],self[indexB]);
    }
}

#pragma mark - 选择排序
- (void)zs_selectSort:(ZSCompare)compare withCallback:(ZSExchange)exchange{
    if (self.count == 0) {
        return;
    }
    for (int i = 0; i < self.count; i++) {
        for (int j = i+1; j < self.count; j++) {
            if (compare(self[i],self[j])==NSOrderedDescending) {
                [self zs_exchangeWithIndexA:i indexB:j Change:exchange];
            }
        }
    }
}

#pragma mark - 冒泡排序
- (void)zs_bubbleSort:(ZSCompare)compare withCallback:(ZSExchange)exchange{
    if (self.count == 0) {
        return;
    }
    for (NSInteger i = self.count-1; i > 0; i --) {
        for (NSInteger j = 0; j < i; j++) {
            if (compare(self[j],self[j+1])==NSOrderedDescending) {
                [self zs_exchangeWithIndexA:j indexB:j+1 Change:exchange];
            }
        }
    }
}

#pragma mark - 插入排序
- (void)zs_insertSort:(ZSCompare)compare withCallback:(ZSExchange)exchange{
    if (self.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.count-1; i++) {
        for (NSInteger j = i+1; j > 0; j--) {
            if (compare(self[j],self[j-1])==NSOrderedAscending) {
                [self zs_exchangeWithIndexA:j indexB:j-1 Change:exchange];
            }
            else{
                break;
            }
        }
    }
}

#pragma mark - 原始快速排序
- (void)zs_quickSort:(ZSCompare)compare withCallback:(ZSExchange)exchange{
    if (self.count == 0) {
        return;
    }
    [self zs_quickSortWithLow:0 High:self.count-1 Compare:compare Callback:exchange];
}

//递归函数,必须有返回
- (void)zs_quickSortWithLow:(NSInteger)low High:(NSInteger)high Compare:(ZSCompare)compare Callback:(ZSExchange)exchange{
    if (low >= high) {
        return;
    }
    NSInteger pivotIndex = [self zs_pivotIndexWithLeft:low Right:high Compare:compare Callback:exchange];
    [self zs_quickSortWithLow:low High:pivotIndex-1 Compare:compare Callback:exchange];
    [self zs_quickSortWithLow:pivotIndex+1 High:high Compare:compare Callback:exchange];
}

- (NSInteger)zs_pivotIndexWithLeft:(NSInteger)left Right:(NSInteger)right Compare:(ZSCompare)compare Callback:(ZSExchange)exchange{
    NSInteger i = left;
    NSInteger j = right;
    id pivot = self[left];
    while (i < j) {
        //从右边找小的,如果右边大于等于pivot，则右游标向左移动
        while (i < j && compare(pivot,self[j])!= NSOrderedDescending) {
            j--;
        }
        //右边的值小于pivot
        if (i < j) {
            [self zs_exchangeWithIndexA:i indexB:j Change:exchange];
            i++;
        }
        //从左边找大的，如果左边小于等于pivot,则左游标向右移动
        while (i < j && compare(self[i],pivot)!=NSOrderedDescending) {
            i++;
        }
        //左边的值大于pivot
        if (i < j) {
            [self zs_exchangeWithIndexA:i indexB:j Change:exchange];
            j--;
        }
    
    }
    return i;
}

#pragma mark - 堆排序
- (void)zs_heapSort:(ZSCompare)compare withCallback:(ZSExchange)exchange{
    if (self.count == 0) {
        return;
    }
    [self insertObject:[[NSNull alloc]init] atIndex:0];
    //初始化最大堆排序
    for (NSInteger index = (self.count-1)/2; index > 0; index--) {
        [self sinkIndex:index bottomIndex:self.count-1 compare:compare Callback:exchange];
    }
    //第一次交换根结点与最后一个元素,然后不断沉底第一个元素
    for (NSInteger index = self.count-1; index > 1; index--) {
        [self zs_exchangeWithIndexA:1 indexB:index Change:exchange];
        [self sinkIndex:1 bottomIndex:index-1 compare:compare Callback:exchange];
    }
    [self removeObjectAtIndex:0];
}

//第一个参数是需要沉底的元素索引值，第二个元素是能允许沉底的最大索引值
- (void)sinkIndex:(NSInteger)currentIndex bottomIndex:(NSInteger)bottomIndex compare:(ZSCompare)compare Callback:(ZSExchange)exchange{
    //数组第一个数为空，就是为了子左结点刚好是2倍，子右节点是2倍+1
    for (NSInteger maxIndex = 2*currentIndex; maxIndex <= bottomIndex ; maxIndex *= 2) {
        //找到子左右节点的最大值，父节点与这个值比较,首先必须保证右节点要存在
        if ((maxIndex+1)<=bottomIndex && compare(self[maxIndex],self[maxIndex+1])==NSOrderedAscending) {
            ++ maxIndex;
        }
        //比较父结点与子左右节点的最大值，如果小于，则交换，否则break跳出
        if (compare(self[currentIndex],self[maxIndex])==NSOrderedAscending) {
            [self zs_exchangeWithIndexA:currentIndex indexB:maxIndex Change:exchange];
        }
        else{
            break;
        }
        //将当前需要改变的节点位置currentIndex变成maxIndex,这样就可以继续沉底
        currentIndex = maxIndex;
    }
}
@end
