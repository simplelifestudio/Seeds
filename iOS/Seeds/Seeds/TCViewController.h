//
//  TCViewController.h
//  Seeds
//
//  Created by Patrick Deng on 13-08-06.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCViewController : UITableViewController

@property (nonatomic, retain) IBOutlet UITextView *inputView;

- (IBAction)reconnect:(id)sender;

@end
