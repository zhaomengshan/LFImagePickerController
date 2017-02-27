//
//  LFDrawView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFDrawView : UIView <NSCopying>

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, copy) void(^drawBegan)();
@property (nonatomic, copy) void(^drawEnded)();

/** 是否可撤销 */
- (BOOL)canUndo;
//撤销
- (void)undo;

@end
