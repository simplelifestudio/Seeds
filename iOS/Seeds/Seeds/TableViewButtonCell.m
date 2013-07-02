//
//  TableViewButtonCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TableViewButtonCell.h"

@implementation TableViewButtonCell

@synthesize label = _label;
@synthesize button = _button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
