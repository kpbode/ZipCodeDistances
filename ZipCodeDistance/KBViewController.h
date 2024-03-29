//
//  KBViewController.h
//  ZipCodeDistance
//
//  Created by Karl Bode on 14.09.12.
//  Copyright (c) 2012 Karl Bode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak, readwrite) IBOutlet UILabel *currentLocationLabel;
@property (nonatomic, weak, readwrite) IBOutlet UITableView *zipCodeTableView;

@end
