//
//  ASContainer.m
//  BNRItem
//
//  Created by Ashley on 2013-03-22.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import "ASContainer.h"
#import "ASItem.h"

@implementation ASContainer:ASItem

-(id) initWithContainerName:(NSString *) cName
{
    self = [super initWithItemName:@"" valueInDollars:0 serialNumber:@""];
    
    totalPrice = 0;
    containerName = cName;
    
    arrayItem = [[NSMutableArray alloc] init];
    for (int i=0; i<10; i++){
        ASItem *p = [ASItem randomItem];
        [arrayItem addObject:p];
    }
    
    return self;
}

-(void) description
{
    NSLog(@"Container Name: %@", containerName);
    for (int i=0; i<[arrayItem count]; i++){
        NSLog(@"ItemName: %@ (%@) Price: %d",  [[arrayItem objectAtIndex:i] itemName],
                                                [[arrayItem objectAtIndex:i] serialNumber],
                                                [[arrayItem objectAtIndex:i] valueInDollars]);
    }
    NSLog(@"Total Price: %d", [self totalPrice]);
    
}

-(int) totalPrice
{
    int p=0;
    for (int i=0; i<[arrayItem count]; i++){
        p += [[arrayItem objectAtIndex:i] valueInDollars];
    }
    
    return p;
     
}


@end