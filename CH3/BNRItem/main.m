//
//  main.m
//  BNRItem
//
//  Created by Ashley on 2013-03-22.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASItem.h"
#import "ASContainer.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        // insert code here...
//        NSLog(@"Hello, World!");
//        for (int i = 0; i<3; i++){
//            ASItem *p = [ASItem randomItem];
//            
//            [items addObject:p];
//        }
//        
//        for (ASItem *item in items){
//            NSLog(@"ItemName: %@ (%@) Price: %d", [item itemName], [item serialNumber], [item valueInDollars]);
//        }

        
        // bronze
//      NSLog(@"ItemName: %@ (%@) Price: %d", [[items objectAtIndex:3] itemName], [[items objectAtIndex:3] serialNumber], [[items objectAtIndex:3] valueInDollars]);
        
//        ASItem *nn = [[ASItem alloc] initWithItemName:@"ASHLEY"];
//        NSLog(@"ItemName: %@ (%@) Price: %d", [nn itemName], [nn serialNumber], [nn valueInDollars]);
//        
//        
//        ASContainer *c = [[ASContainer alloc] initWithContainerName:@"Samiul"];
//        
//        [c description];
        
        
        /*
         
         Code for the strong and weak reference checking
         
         */
        
        ASItem *backPack = [[ASItem alloc] init];
        [backPack setItemName:@"BackPack"];
        [items addObject:backPack];
        
        ASItem *calculator = [[ASItem alloc] initWithItemName:@"Calculator"];
        [items addObject:calculator];
        
        [backPack setContainedItem:calculator];

//        [calculator setContainedItem:nil];
//        [calculator setContainer:nil];
//        
//        [backPack setContainedItem:nil];
//        [backPack setContainer:nil];
        backPack = nil;
        
        NSLog(@"Setting items to nil...");
        items = nil;
        

        
        
    }
    return 0;
}