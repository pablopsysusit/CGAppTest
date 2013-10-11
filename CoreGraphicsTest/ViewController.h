//
//  ViewController.h
//  CoreGraphicsTest
//
//  Created by Pablo Padilla on 10/10/13.
//  Copyright (c) 2013 Pablo Padilla. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

// tableView to select the type of shape to add
@property (retain, nonatomic) IBOutlet UITableView *shapesTableView;
// a list of available shapes 
@property (retain, nonatomic) NSArray* shapeTypes;
@property (retain, nonatomic) NSString* selectedShapeType;
// gesture recognizer for dragging views
@property (retain, nonatomic) UIPanGestureRecognizer* dragGR;
// gesture recognizer for resizing the selection view
@property (retain, nonatomic) UIPanGestureRecognizer* selectionGR;
// location of origin for the selection view
@property (nonatomic) CGPoint selectionOrigin;
// view that represents the selected area in the canvas
@property (nonatomic,retain) UIView* selectionView;

// Saves the current state of the view to the Camera roll
-(IBAction)saveToCameraRoll:(id)sender;

@end
