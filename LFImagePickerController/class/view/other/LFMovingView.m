//
//  LFMovingView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/24.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFMovingView.h"

#define margin 22

@interface LFMovingView ()
{
    UIView *_contentView;
    UIButton *_deleteButton;
    UIImageView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

@property (nonatomic, weak) UIView *customView;

@end

@implementation LFMovingView

+ (void)setActiveEmoticonView:(LFMovingView *)view
{
    static LFMovingView *activeView = nil;
    /** 停止取消激活 */
    [activeView cancelDeactivated];
    if(view != activeView){
        [activeView setActive:NO];
        activeView = view;
        [activeView setActive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
    }
    [activeView autoDeactivated];
}

- (void)dealloc
{
    [self cancelDeactivated];
}

#pragma mark - 自动取消激活
- (void)cancelDeactivated
{
    [LFMovingView cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDeactivated
{
    [self performSelector:@selector(setActiveEmoticonView:) withObject:nil afterDelay:4.f];
}

- (void)setActiveEmoticonView:(LFMovingView *)view
{
    [LFMovingView setActiveEmoticonView:view];
}

- (UIView *)view
{
    return self.customView;
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width+margin, view.frame.size.height+margin)];
    if(self){
        _customView = view;
        _contentView = [[UIView alloc] initWithFrame:view.bounds];
        _contentView.layer.borderColor = [[UIColor colorWithWhite:1.f alpha:0.8] CGColor];
        _contentView.layer.cornerRadius = 3;
        _contentView.center = self.center;
        [_contentView addSubview:view];
        view.frame = _contentView.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_contentView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, margin, margin);
        _deleteButton.center = _contentView.frame.origin;
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.backgroundColor = [UIColor redColor];
        [self addSubview:_deleteButton];
        
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, margin, margin)];
        _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _circleView.backgroundColor = [UIColor redColor];
        [self addSubview:_circleView];
        
        _scale = 1;
        _arg = 0;
        _minScale = .2f;
        _maxScale = 3.f;
        
        [self initGestures];
        [self setActive:NO];
    }
    return self;
}

- (void)initGestures
{
    self.userInteractionEnabled = YES;
    _contentView.userInteractionEnabled = YES;
    _circleView.userInteractionEnabled = YES;
    [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_contentView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        return nil;
    }
    if (view == nil) {
        [LFMovingView setActiveEmoticonView:nil];
    }
    return view;
}

- (void)setActive:(BOOL)active
{
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
    _contentView.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (void)setScale:(CGFloat)scale
{
    _scale = MIN(MAX(scale, _minScale), _maxScale);
    
    self.transform = CGAffineTransformIdentity;
    
    _contentView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_contentView.frame.size.width + margin)) / 2;
    rct.origin.y += (rct.size.height - (_contentView.frame.size.height + margin)) / 2;
    rct.size.width  = _contentView.frame.size.width + margin;
    rct.size.height = _contentView.frame.size.height + margin;
    self.frame = rct;
    
    _contentView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _contentView.layer.borderWidth = 1/_scale;
    _contentView.layer.cornerRadius = 3/_scale;
}

#pragma mark - Touch Event

- (void)pushedDeleteBtn:(id)sender
{
    LFMovingView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[LFMovingView class]]){
            nextTarget = (LFMovingView *)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[LFMovingView class]]){
                nextTarget = (LFMovingView *)view;
                break;
            }
        }
    }
    
    [[self class] setActiveEmoticonView:nextTarget];
    [self removeFromSuperview];
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if (self.tapEnded) self.tapEnded(self.customView);
    [[self class] setActiveEmoticonView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveEmoticonView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
        [self cancelDeactivated];
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!CGRectContainsPoint(self.superview.frame, self.center)) {
            /** 超出边界线 重置会中间 */
            [UIView animateWithDuration:0.25f animations:^{
                self.center = self.superview.center;
            }];
        }
        [self autoDeactivated];
    }
}

- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        [self cancelDeactivated];
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg = _initialArg + arg - tmpA;
    [self setScale:(_initialScale * R / tmpR)];
}
@end
