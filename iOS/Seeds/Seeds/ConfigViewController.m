//
//  ConfigViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "ConfigViewController.h"

#import "TableViewSwitcherCell.h"
#import "TableViewSegmentCell.h"

#define HEIGHT_CELL_COMPONENT 27

#define CELL_ID_SWITCHER @"CellType_Switcher"
#define NIB_TABLECELL_SWITCHER @"TableViewSwitcherCell"

#define CELL_ID_SEGMENTER @"CellType_Segmenter"
#define NIB_TABLECELL_SEGMENTER @"TableViewSegmentCell"

#define SECTION_ITEMCOUNT_CONFIG 2

#define SECTION_INDEX_MODE 0
#define SECTION_ITEMCOUNT_MODE 1
#define SECTION_INDEX_MODE_ITEM_INDEX_MODE 0
#define SEGMENT_INDEX_MODE_STANDALONE 0
#define SEGMENT_INDEX_MODE_SERVER 1

#define SECTION_INDEX_IMAGE 1
#define SECTION_ITEMCOUNT_IMAGE 1
#define SECTION_INDEX_IMAGE_ITEM_INDEX_3GDOWNLOAD 0

#define SECTION_INDEX_DATA 2
#define SECTION_ITEMCOUNT_DATA 2

#define SECTION_INDEX_PASSCODE 3
#define SECTION_ITEMCOUNT_PASSCODE 2

#define SECTION_INDEX_SNS 4
#define SECTION_ITEMCOUNT_SNS 1

#define SECTION_INDEX_ABOUT 5
#define SECTION_ITEMCOUNT_ABOUT 1

@interface ConfigViewController ()
{
    UserDefaultsModule* _usersDefaults;
}

@end

@implementation ConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [self _setupViewController];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_ITEMCOUNT_CONFIG;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_INDEX_MODE:
        {
            return SECTION_ITEMCOUNT_MODE;
        }
        case SECTION_INDEX_IMAGE:
        {
            return SECTION_ITEMCOUNT_IMAGE;
        }
        case SECTION_INDEX_DATA:
        {
            return SECTION_ITEMCOUNT_DATA;
        }
        case SECTION_INDEX_PASSCODE:
        {
            return SECTION_ITEMCOUNT_PASSCODE;
        }
        case SECTION_INDEX_SNS:
        {
            return SECTION_ITEMCOUNT_SNS;
        }
        case SECTION_INDEX_ABOUT:
        {
            return SECTION_ITEMCOUNT_ABOUT;
        }
        default:
        {
            break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSInteger section = indexPath.section;
    NSInteger rowInSection = indexPath.row;
    
    switch (section)
    {
        case SECTION_INDEX_MODE:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_MODE_ITEM_INDEX_MODE:
                {
                    TableViewSegmentCell* customCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SEGMENTER];
                    if (nil == customCell)
                    {
                        customCell = [CBUIUtils componentFromNib:NIB_TABLECELL_SEGMENTER owner:self options:nil];

                        [customCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        customCell.segmentLabel.text = NSLocalizedString(@"Running Mode", nil);
                        [customCell.segmentControl setTitle:NSLocalizedString(@"Standalone", nil) forSegmentAtIndex:SEGMENT_INDEX_MODE_STANDALONE];
                        [customCell.segmentControl setTitle:NSLocalizedString(@"Server", nil) forSegmentAtIndex:1];
                        [customCell.segmentControl addTarget:self action:@selector(_onRunningModeChanged:) forControlEvents:UIControlEventValueChanged];
                        CGRect oldFrame = customCell.segmentControl.frame;
                        CGFloat offsetY = (oldFrame.size.height - HEIGHT_CELL_COMPONENT) / 2;
                        CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y + offsetY, oldFrame.size.width, HEIGHT_CELL_COMPONENT);
                        [customCell.segmentControl setFrame:newFrame];
                        
                        BOOL flag = [_usersDefaults isServerMode];
                        if (flag)
                        {
                            [customCell.segmentControl setSelectedSegmentIndex:SEGMENT_INDEX_MODE_SERVER];
                        }
                        else
                        {
                            [customCell.segmentControl setSelectedSegmentIndex:SEGMENT_INDEX_MODE_STANDALONE];
                        }
                        [customCell.segmentControl setEnabled:NO];
                    }
                    cell = customCell;
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case SECTION_INDEX_IMAGE:
        {
            switch (rowInSection)
            {
                case SECTION_INDEX_IMAGE_ITEM_INDEX_3GDOWNLOAD:
                {
                    TableViewSwitcherCell* customCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_SWITCHER];
                    if (nil == customCell)
                    {
                        customCell = [CBUIUtils componentFromNib:NIB_TABLECELL_SWITCHER owner:self options:nil];
                        
                        [customCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        customCell.switcherLabel.text = NSLocalizedString(@"Download Images Through 3G/GPRS", nil);
                        [customCell.switcher addTarget:self action:@selector(_on3GDownloadImagesSwitched:) forControlEvents:UIControlEventValueChanged];
                        
                        BOOL flag = [_usersDefaults isDownloadImagesThrough3GEnabled];
                        [customCell.switcher setOn:flag];
                    }
                    cell = customCell;
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case SECTION_INDEX_MODE:
        {
            sectionName = NSLocalizedString(@"Mode", nil);
            break;
        }
        case SECTION_INDEX_IMAGE:
        {
            sectionName = NSLocalizedString(@"Images", nil);
            break;
        }
        default:
        {
            sectionName = @"";
            break;
        }
    }
    return sectionName;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Private Methods

-(void) _setupViewController
{
    [self _setupTableView];
    [self _registerGestureRecognizers];
}

-(void) _setupTableView
{
    _usersDefaults = [UserDefaultsModule sharedInstance];
}

- (void) _registerGestureRecognizers
{
    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeRight:)];
    [swipeRightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:swipeRightRecognizer];
}

- (void) _handleSwipeRight:(UISwipeGestureRecognizer*) gestureRecognizer
{    
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void) _onRunningModeChanged:(UIControl*) control
{
    if (nil != control)
    {
        UISegmentedControl* segment = (UISegmentedControl*) control;
        if (SEGMENT_INDEX_MODE_SERVER == segment.selectedSegmentIndex)
        {
            [self _enableServerMode];
        }
        else if (SEGMENT_INDEX_MODE_STANDALONE == segment.selectedSegmentIndex)
        {
            [self _enableStandaloneMode];
        }
    }
}

- (void) _enableStandaloneMode
{
    
}

- (void) _enableServerMode
{
    
}

- (void) _on3GDownloadImagesSwitched:(UIControl*) control
{
    if (nil != control)
    {
        UISwitch* switcher = (UISwitch*) control;
        [self _set3GDownloadImages:switcher.isOn];
    }
}

- (void) _set3GDownloadImages:(BOOL) flag
{
    UserDefaultsModule* defaults = [UserDefaultsModule sharedInstance];
    [defaults enableDownloadImagesThrough3G:flag];
}

@end
