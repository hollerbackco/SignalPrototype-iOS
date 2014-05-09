//
//  CGUtils.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

@interface CGUtils : NSObject

CG_INLINE CGRect CGRectSetX(CGRect rect, CGFloat x);
CG_INLINE CGRect CGRectSetY(CGRect rect, CGFloat y);
CG_INLINE CGRect CGRectSetXY(CGRect rect, CGFloat x, CGFloat y);
CG_INLINE CGRect CGRectSetOrigin(CGRect rect, CGPoint point);
CG_INLINE CGRect CGRectSetWidth(CGRect rect, CGFloat width);
CG_INLINE CGRect CGRectSetHeight(CGRect rect, CGFloat height);
CG_INLINE CGRect CGRectSetWidthHeight(CGRect rect, CGFloat width, CGFloat height);
CG_INLINE CGRect CGRectSetSize(CGRect rect, CGSize size);
CG_INLINE CGRect CGRectSetSizeOffset(CGRect rect, CGFloat widthOffset, CGFloat heightOffset);

CG_INLINE CGRect
CGRectSetX(CGRect rect, CGFloat x)
{
    CGRect rect_ = rect;
    rect_.origin.x = x;
    return rect_;
}

CG_INLINE CGRect
CGRectSetY(CGRect rect, CGFloat y)
{
    CGRect rect_ = rect;
    rect_.origin.y = y;
    return rect_;
}

CG_INLINE CGRect
CGRectSetXY(CGRect rect, CGFloat x, CGFloat y)
{
    CGRect rect_ = rect;
    rect_.origin.x = x;
    rect_.origin.y = y;
    return rect_;
}

CG_INLINE CGRect
CGRectSetOrigin(CGRect rect, CGPoint point)
{
    CGRect rect_ = rect;
    rect_.origin = point;
    return rect_;
}

CG_INLINE CGRect
CGRectSetWidth(CGRect rect, CGFloat width)
{
    CGRect rect_ = rect;
    rect_.size.width = width;
    return rect_;
}

CG_INLINE CGRect
CGRectSetHeight(CGRect rect, CGFloat height)
{
    CGRect rect_ = rect;
    rect_.size.height = height;
    return rect_;
}

CG_INLINE CGRect
CGRectSetWidthHeight(CGRect rect, CGFloat width, CGFloat height)
{
    CGRect rect_ = rect;
    rect_.size.width = width;
    rect_.size.height = height;
    return rect_;
}

CG_INLINE CGRect
CGRectSetSize(CGRect rect, CGSize size)
{
    CGRect rect_ = rect;
    rect_.size = size;
    return rect_;
}

CG_INLINE CGRect
CGRectSetSizeOffset(CGRect rect, CGFloat widthOffset, CGFloat heightOffset)
{
    CGRect rect_ = rect;
    rect_.size.width += widthOffset;
    rect_.size.height += heightOffset;
    return rect_;
}

CG_INLINE CGPoint
CGPointGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

@end
