#import "ParseStarterProjectViewController.h"
#import <Parse/Parse.h>

@implementation ParseStarterProjectViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    [testObject setObject:@"12" forKey:@"foo"];
//    [testObject setObject:[NSNumber numberWithInt:nil] forKey:@"foo2"];
//    [testObject setObject:[NSNumber numberWithInt:1337] forKey:@"value"];
//    [testObject save];
    
    PFQuery *query = [PFQuery queryWithClassName:@"TestObject"];
    PFObject *gameScore = [query getObjectWithId:@"RTVy1ZmZim"];
    
    int value = [[gameScore objectForKey:@"value"] intValue];
    NSString *foo = [gameScore objectForKey:@"foo"];
    
    NSString *objectId = gameScore.objectId;
    NSDate *updatedAt = gameScore.updatedAt;
    NSDate *createdAt = gameScore.createdAt;
    
    NSLog(@"%@ %d %@ %@ %@", foo, value, objectId, updatedAt, createdAt);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
