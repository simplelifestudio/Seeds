//
//  TableViewSegmentCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TableViewSegmentCell.h"

@implementation TableViewSegmentCell
@synthesize segmentControl = _segmentControl;
@synthesize segmentLabel = _segmentLabel;

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
