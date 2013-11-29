//
//  TableViewSwitcherCell.m
//  Seeds
//
//  Created by Patrick Deng on 13-7-1.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TableViewSwitcherCell.h"

@implementation TableViewSwitcherCell

@synthesize switcher = _switcher;
@synthesize switcherLabel = _switcherLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self _formatFlatUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)awakeFromNib
{
    [self _formatFlatUI];
    
    [super awakeFromNib];
}

- (void)_formatFlatUI
{  
    _switcher.onColor = FLATUI_COLOR_BUTTON;
    _switcher.offColor = FLATUI_COLOR_LABEL;
    _switcher.onBackgroundColor = FLATUI_COLOR_BUTTON_SHADOW;
    _switcher.offBackgroundColor = FLATUI_COLOR_LABEL_SHADOW;

//    _switcher.offLabel.font = [UIFont boldFlatFontOfSize:14];
//    _switcher.onLabel.font = [UIFont boldFlatFontOfSize:14];
    
    [GUIStyle formatFlatUILabel:_switcherLabel textColor:COLOR_TEXT_INFO];
}

@end
