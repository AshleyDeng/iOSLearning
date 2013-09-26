//
//  ViewController.m
//  FakeNotifier
//
//  Created by Craig Siemens on 2013-02-21.
//  Copyright (c) 2013 Craig Siemens. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeSegmentedControl;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Fake Push Notifications

- (IBAction)scheduleNotificationButtonPressed:(id)sender
{
    NSInteger delay = self.timeSegmentedControl.selectedSegmentIndex * 15;
    delay = (delay == 0 ? 5 : delay);
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    [notification setTimeZone:[NSTimeZone localTimeZone]];
    [notification setAlertBody:@"Your Shaw Technician will be arriving in 30 minutes."];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
        
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [self showStatus:[NSString stringWithFormat:@"Notification in %d sec", delay]];
}

- (void)showStatus:(NSString *)status
{
	[self.statusLabel setText:status];
	
	[UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[self.statusLabel setAlpha:1.0];
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5f delay:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
			[self.statusLabel setAlpha:0.0];
		} completion:nil];
	}];
    
    
    
}

@end
