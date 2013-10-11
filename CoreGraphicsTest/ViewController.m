//
//  ViewController.m
//  CoreGraphicsTest
//
//  Created by Pablo Padilla on 10/10/13.
//  Copyright (c) 2013 Pablo Padilla. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ShapeView.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize shapesTableView;
@synthesize shapeTypes;
@synthesize selectedShapeType;
@synthesize dragGR;
@synthesize selectionGR;
@synthesize selectionOrigin;
@synthesize selectionView;


#pragma mark - Initialization & De-allocation
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // add the available shape types
    shapeTypes= [@[ STCircle, STTriangle, STSquare, STStar] retain];
    
    // assign the tableView and DataSource delegates
    self.shapesTableView.delegate = self;
    self.shapesTableView.dataSource= self;
    
    // set a border for the table view
    shapesTableView.layer.borderWidth= 1.0;
    shapesTableView.layer.borderColor= [UIColor grayColor].CGColor;
    
    // set default selected row
    selectedShapeType= STCircle;
    NSIndexPath* ip= [NSIndexPath indexPathForRow:0 inSection:0];
    [shapesTableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    // add double-tap gesture recognizer
    UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc]
                                          initWithTarget: self
                                          action:@selector(handleDoubleTap:)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    // setup selection gesture recognizer
    self.view.userInteractionEnabled= YES;
    selectionGR= [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(handleSelection:)];
    selectionGR.minimumNumberOfTouches= 1;
    selectionGR.maximumNumberOfTouches=1;
    [self.view addGestureRecognizer:selectionGR];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [shapesTableView release];
    [shapeTypes release];
    [selectedShapeType release];
    [selectionGR release];
    
    [super dealloc];
}



-(void)addShape:(NSString*)shapeType withCenter:(CGPoint)center{
    
    // each shape is 40x40
    ShapeView* sv= [[ShapeView alloc] initWithFrame:CGRectMake(center.x-20, center.y-20, 40, 40)];
    sv.shapeType= shapeType;
    sv.userInteractionEnabled= YES;
    [self.view addSubview:sv];
    
    [self setupDragGesture:sv];
    
    [sv release];    
}

#pragma mark - Handle Gestures

/*
 * Updates the selected region
 */
-(void)handleSelection:(UIPanGestureRecognizer*)sender{
    
    
    // on gesture start ...
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        // save the original location where the gesture begins
        selectionOrigin= [sender locationOfTouch:0 inView:sender.view];
        
        // calculate the initial frame of the selection view
        CGRect frame= CGRectMake(selectionOrigin.x, selectionOrigin.y, 0, 0);
        
        // create the selection view if it doesn't exist
        if (!selectionView) {
            selectionView= [[UIView alloc] initWithFrame:
                            frame];
            [self.view addSubview:selectionView];
            selectionView.backgroundColor= [UIColor blueColor];
            selectionView.alpha= 0.1;
            
            // add the drag gesture, so we can drag the selection
            [self setupDragGesture:selectionView];
            
        }else{// if it exists, reset the frame each time the gesture starts
            selectionView.frame= frame;
        }
    }
    
    // update the frame of the selection view
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation= [sender translationInView:sender.view.superview];
        CGRect frame= CGRectMake(selectionOrigin.x,
                                 selectionOrigin.y,
                                 selectionView.frame.size.width+translation.x,
                                 selectionView.frame.size.height+translation.y);
        selectionView.frame= frame;
        [sender setTranslation:CGPointZero inView:sender.view];
        
    }
    
    
    // when the gesture is finished
    if (sender.state == UIGestureRecognizerStateEnded) {
        // check collision with other views to indicate selection
        for (UIView* sv in self.view.subviews) {
            
            if ([sv isKindOfClass:[ShapeView class]]) {
                // add alpha to views contained in selection
                if ( CGRectIntersectsRect(sv.frame, selectionView.frame)) {
                    sv.alpha= 0.5;
                }
            }
        }
        
    }
    
}



/*
 * Updates the position of the view that's being dragged
 */
-(void)handleDrag:(UIPanGestureRecognizer*)sender{
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        // move the view to the current location of the gesture
        CGPoint point= [sender locationInView:self.view];
        sender.view.center= point;
        
        // if this is the selectionView, move all views contained
        // in the selection
        if (selectionView && sender.view==selectionView) {
            
            CGPoint translation= [sender translationInView:sender.view.superview];
            
            // for each subview contained in the selected region
            for (UIView* sv in self.view.subviews) {
                if ([sv isKindOfClass:[ShapeView class]]
                    && CGRectIntersectsRect(sv.frame, selectionView.frame)) {
                    // update it's position acording to the selection translation
                    sv.center= CGPointMake(sv.center.x+translation.x,
                                           sv.center.y+translation.y);
                    [sender setTranslation:CGPointZero inView:sender.view.superview];
                }
            }
        }
    }
}

/*
 * Receives double tap events.
 */
-(void)handleDoubleTap:(id)sender{
    
    UIGestureRecognizer* doubleTap= sender;
    CGPoint location= [doubleTap locationOfTouch:0 inView:self.view];
    
    NSLog(@"Touching in %@", NSStringFromCGPoint(location));
    
    // adds a shape of the selected type at location
    [self addShape:selectedShapeType withCenter:location];
}

/*
 * Remove selection view with single tap anywhere
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // remove selection view
    if (selectionView) {
        
        // remove opacity from selected subviews
        for (UIView* sv in self.view.subviews) {
            if ([sv isKindOfClass:[ShapeView class]]) {
                sv.alpha= 1;
            }
        }
        
        [selectionView removeFromSuperview];
        [selectionView release];
        selectionView= nil;
    }
    
}

/*
 * Adds a pan gesture recognizer to the indicated view.
 * This enables the view to be dragged.
 */
- (void)setupDragGesture:(UIView *)sv {
    // add gesture recognizer for panning
    // setup the pan gesture recognizer
    dragGR= [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                   action:@selector(handleDrag:)];
    dragGR.minimumNumberOfTouches= 1;
    dragGR.maximumNumberOfTouches= 1;
    [sv addGestureRecognizer:dragGR];
    
    [dragGR release];
}



#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.shapeTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell= [shapesTableView dequeueReusableCellWithIdentifier:@"shapeTypeCell"];
    
    cell.textLabel.font= [UIFont systemFontOfSize:10];
    cell.textLabel.text= (self.shapeTypes)[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSIndexPath* ip= [self.shapesTableView indexPathForSelectedRow];
    
    selectedShapeType= (self.shapeTypes)[ip.row];
    
    NSLog(@"Selecting shape type= %@", selectedShapeType);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 33;
}


#pragma mark - Save to Camera roll
-(void)saveToCameraRoll:(id)sender{
    
    // get the image from the current view
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* imageToSave= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //save to camera roll
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
        
        UIAlertView* alertView= [[UIAlertView alloc] initWithTitle:@"Success!"
                                                           message:@"Image saved."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });

}

@end
