//
//  SplashViewController.m
//  Seeds
//
//  Created by Patrick Deng on 13-4-20.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@property (nonatomic, strong) NSThread *loadStuffThread;

@end

@implementation SplashViewController

@synthesize progressLabel;
@synthesize progressView;
@synthesize loadStuffThread = _loadStuffThread;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _loadStuffThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadAnyNecessaryStuff)  object:nil];
    [_loadStuffThread start];
}

- (void)viewDidUnload
{
    [self setLoadStuffThread:nil];
    [self setProgressLabel:nil];
    [self setProgressView:nil];
    
    [super viewDidUnload];
}

- (void)startFadingSplashScreen
{
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.75];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishFadingSplashScreen)];   // calls the finishFadingSplashScreen method when the animation is done (or done fading out)
	self.view.alpha = 0.0;       // Fades the alpha channel of this view to "0.0" over the animationDuration of "0.75" seconds
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
}

- (void) finishFadingSplashScreen
{
    [self performSegueWithIdentifier:@"splash2navigation" sender:self];
}

- (void) loadAnyNecessaryStuff
{
    // All CBModules should start here
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // UserDefaults Module
    appDelegate.userDefaultsModule = [UserDefaultsModule sharedInstance];
    [appDelegate.userDefaultsModule initModule];
    [self updateProgress:appDelegate.userDefaultsModule.moduleIdentity andPercents:0.2];
    [appDelegate.userDefaultsModule startService];
    
    // Communication Module
    appDelegate.communicationModule = [[CommunicationModule alloc] initWithIsIndividualThreadNecessary:NO];
    [appDelegate.communicationModule initModule];
    [self updateProgress:appDelegate.communicationModule.moduleIdentity andPercents:0.5];
    [appDelegate.communicationModule startService];

    // Spider Module
    appDelegate.spiderModule = [[SpiderModule alloc] initWithIsIndividualThreadNecessary:NO];
    [appDelegate.spiderModule initModule];
    [self updateProgress:appDelegate.spiderModule.moduleIdentity andPercents:0.7];
    [appDelegate.spiderModule startService];
    
    // Database Module
    appDelegate.databaseModule = [[DatabaseModule alloc] initWithIsIndividualThreadNecessary:NO];
    [appDelegate.databaseModule initModule];
    [self updateProgress:appDelegate.databaseModule.moduleIdentity andPercents:1.0];    
    [appDelegate.databaseModule startService];
    
    // Switch back to Splash UI
    [self performSelectorOnMainThread:@selector(startFadingSplashScreen) withObject:self waitUntilDone:YES];
}

-(void) updateProgress:(NSString*) text andPercents:(float) percents
{
    [[NSRunLoop currentRunLoop]runUntilDate:[NSDate distantPast]];
    [self performSelectorOnMainThread:@selector(updateProgressText:) withObject:text waitUntilDone:NO];
    NSNumber *percentsVal = [NSNumber numberWithFloat:percents];
    [self performSelectorOnMainThread:@selector(updateProgressPercents:) withObject:percentsVal waitUntilDone:NO];
}

-(void) updateProgressText:(NSString*) text
{
    if ([self.progressLabel isHidden])
    {
        [self.progressLabel setHidden:FALSE];
    }
    
    NSMutableString* str = [NSMutableString stringWithString:NSLocalizedString(@"Loading: ", nil)];
    text = (nil != text) ? text : @"";
    [str appendString:text];
    
    [self.progressLabel setText:str];
}

-(void) updateProgressPercents:(NSNumber*) percentsVal
{
    if ([self.progressView isHidden])
    {
        [self.progressView setHidden:FALSE];
    }
    
    [self.progressView setProgress:percentsVal.floatValue animated:TRUE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
