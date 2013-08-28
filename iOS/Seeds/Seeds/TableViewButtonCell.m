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
    [GUIStyle formatFlatUIButton:_button buttonColor:FLATUI_COLOR_BUTTON shadowColor:FLATUI_COLOR_BUTTON_SHADOW shadowHeight:0 cornerRadius:3 titleColor:FLATUI_COLOR_LABEL highlightedTitleColor:FLATUI_COLOR_BUTTON_TEXT_HIGHLIGHTED];
    
    [GUIStyle formatFlatUILabel:_label textColor:COLOR_TEXT_INFO];
}

@end
