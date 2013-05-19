//
//  TransmitViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "TransmitViewController.h"

#import "CBFileUtils.h"

@interface TransmitViewController ()

@end

@implementation TransmitViewController

@synthesize addressLabel = _addressLabel;
@synthesize statusLabel = _statusLabel;
@synthesize consoleView = _consoleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = NSLocalizedString(@"Stop", nil);
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    [self updateLabels];
    
    NSArray* last3Days = [CBDateUtils lastThreeDays];
    NSString* documentsPath = [CBPathUtils documentsDirectoryPath];
    for (NSDate* day in last3Days)
    {
        NSString* dayStr = [CBDateUtils dateStringInLocalTimeZone:SEEDLIST_LINK_DATE_FORMAT andDate:day];
        NSString* dayFolderPath = [documentsPath stringByAppendingPathComponent:dayStr];
        NSArray* files = [CBFileUtils filesInDirectory:dayFolderPath fileExtendName:@"torrent"];
        NSMutableString* zipName = [NSMutableString stringWithString:dayStr];
        [zipName appendString:@".zip"];
        NSString* zipFilePath = [dayFolderPath stringByAppendingPathComponent:zipName];
        zipFilePath = [CBFileUtils newZipFileWithFiles:zipFilePath zipFiles:files];
        DLog(@"New zip file created:%@", zipFilePath);
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TransmissionModule* transmitModule = [TransmissionModule sharedInstance];
    [transmitModule stopHTTPServer];
}

- (void)updateLabels
{
    TransmissionModule* transmitModule = [TransmissionModule sharedInstance];
    [transmitModule startHTTPServer];

    NSString* name = [transmitModule httpServerName];
    NSInteger port = [transmitModule httpServerPort];

    if (nil != name && 0 < name.length)
    {
        NSMutableString* addrStr = [NSMutableString string];
        
        [addrStr appendString:@"http://"];
        [addrStr appendString:name];
        [addrStr appendString:@":"];
        [addrStr appendString:[NSString stringWithFormat:@"%d", port]];
        
        [_addressLabel setText:addrStr];        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setAddressLabel:nil];
    [self setStatusLabel:nil];
    [self setConsoleView:nil];
    [super viewDidUnload];
}
@end
