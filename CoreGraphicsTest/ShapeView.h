//
//  ShapeView.h
//  CoreGraphicsTest
//
//  Created by Pablo Padilla on 10/10/13.
//  Copyright (c) 2013 Pablo Padilla. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const STCircle;
extern NSString* const STSquare;
extern NSString* const STTriangle;
extern NSString* const STStar;

@interface ShapeView : UIView

@property (nonatomic, copy) NSString* const shapeType;

@end
