//
//  ShapeView.m
//  CoreGraphicsTest
//
//  Created by Pablo Padilla on 10/10/13.
//  Copyright (c) 2013 Pablo Padilla. All rights reserved.
//

#import "ShapeView.h"
#import <QuartzCore/QuartzCore.h>
#import "ShapeConstants.h"

NSString* const STCircle= @"Circle";
NSString* const STTriangle= @"Triangle";
NSString* const STSquare= @"Square";
NSString* const STStar= @"Star";

@implementation ShapeView

@synthesize shapeType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // set white background
        self.backgroundColor= [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];

    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx,2);
    CGContextSetRGBStrokeColor(ctx,0.8,0.8,0.8,1.0);
    
    if ([shapeType isEqualToString:STCircle]) { // Draws a Circle
        
        CGContextAddArc(ctx, bounds.size.width/2.0, bounds.size.height/2.0, 15, 0.0, 2*M_PI, YES);
        
    }else if ([shapeType isEqualToString:STTriangle]){// Draws a Triangle
        
        UIBezierPath *path = [[UIBezierPath bezierPath] retain];
        [path moveToPoint:CGPointMake(33.0/2.0, 1.0)];
        [path addLineToPoint:CGPointMake(32.0, 32.0)];
        [path addLineToPoint:CGPointMake(1, 32)];
        [path closePath];
        
        CGContextAddPath(ctx, path.CGPath);
        [path release];
        
    }else if ([shapeType isEqualToString:STSquare]){ // Draws a Square
        
        CGContextAddRect(ctx, CGRectMake(bounds.origin.x+5, bounds.origin.y+5, bounds.size.width-10, bounds.size.height-10));
        
    }else if ([shapeType isEqualToString:STStar]){ // Draws the 5-point Star
    
        UIBezierPath *path = [[UIBezierPath bezierPath] retain];
        NSArray* points= [self createStarPoints];
        [path moveToPoint: [points[0] CGPointValue]];

        for(int i=0; i< [points count]; ++i){
            NSValue* pointValue= points[i];
            [path addLineToPoint: [pointValue CGPointValue]];
        }
    
        [path closePath];
        CGContextAddPath(ctx, path.CGPath);
        [path release];

    }
    
    CGContextStrokePath(ctx); 
}


/*
 * Creates the array of points for the 5-point star.
 */
-(NSArray*)createStarPoints{
    
    NSMutableArray* points= [[[NSMutableArray alloc] init] retain];
    float outerRadius= 15, innerRadius= 7.5;
    
    // for each vertex, 5 in the outter radius and 5 in the inner radius
    for (int i=0; i<2*5; ++i) {
        
        // the angle is given by half the number of points
        // in this case 10 points, 5 in the inner radius
        // and 5 in the outter radius, starting with the point at
        // ( outter radius, M_PI/2 ) in polar coordinates
        float angle= i*M_PI/5.0 - M_PI/2;
        
        // alternate between the inner and outter radius,
        // starting with the outter radius.
        float radius= i%2 == 0 ? outerRadius: innerRadius;
        
        // add the rectangular coordinates for each point
        // calculating it's x & y components
        NSValue* pointVal= [NSValue valueWithCGPoint:
                           CGPointMake( self.bounds.size.width/2.0+ radius*cos(angle),
                                        self.bounds.size.height/2.0+ radius*sin(angle))];
        [points addObject: pointVal];
    }
    
    return [points autorelease];
}

@end
