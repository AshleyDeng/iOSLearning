//
//  ASItem.m
//  BNRItem
//
//  Created by Ashley on 2013-03-22.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import "ASItem.h"

@implementation ASItem
@synthesize itemName, container, containedItem, serialNumber, valueInDollars, dateCreated;

//NSString *itemName;
//NSString *serialNumber;
//int valueInDollars;
//NSDate *dateCreated

// class methods
+(id) randomItem
{
    NSArray *randomAdjectiveList = [NSArray arrayWithObjects:@"Fluffy",
                                                             @"Rusty",
                                                             @"Shiny",nil];
    NSArray *randomNounList = [NSArray arrayWithObjects:@"Bear",
                                                        @"Spork",
                                                        @"Mac",nil];
    
    NSInteger adjectiveIndex = rand() % [randomAdjectiveList count];
    NSInteger nounIndex = rand() % [randomNounList count];
    
    
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]];
    int randomValue = rand() % 100;
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10];
    
    ASItem *newItem = [[self alloc] initWithItemName:randomName
                                        valueInDollars:randomValue
                                          serialNumber: randomSerialNumber];
    return newItem;
    
}

// initializers
-(id) initWithItemName:(NSString *) name
        valueInDollars:(int) value
          serialNumber:(NSString *) sNumber
{

    self = [super init];
    
    [self setItemName:name];
    [self setSerialNumber:sNumber];
    [self setValueInDollars:value];
    
    dateCreated = [[NSDate alloc] init];
    
    return self;

}

-(id) initWithItemName:(NSString *) name
{
    return [self initWithItemName: name
                   valueInDollars:0
                     serialNumber:@""];
}
-(id) initWithValueInDollars:(int) value
{
    return [self initWithItemName: @""
                   valueInDollars:value
                     serialNumber:@""];
}
-(id) initWithSerialNumber:(NSString *) sNumber
{
    return [self initWithItemName: @""
                   valueInDollars:0
                     serialNumber:sNumber];

}

// deallocation
-(void) dealloc
{
    NSLog(@"Destroyed: %@", self);
}

-(void)setContainedItem:(ASItem *)i
{
    containedItem = i;
    
    [i setContainer:self];
}
//
//-(ASItem *)containedItem
//{
//    return containedItem;
//}
//
//-(void)setContainer:(ASItem *)i
//{
//    container = i;
//}
//
//-(ASItem *)container
//{
//    return container;
//}
//
//// Instance methods
//-(void) setItemName:(NSString *) str{
//    itemName = str;
//}
//
//-(NSString *) itemName{
//    return itemName;
//}
//
//-(void) setSerialNumber:(NSString *)str{
//    serialNumber = str;
//
//}
//-(NSString *) serialNumber{
//    return serialNumber;
//}
//
//
//-(void) setValueInDollars:(int)i{
//    valueInDollars = i;
//}
//-(int) valueInDollars{
//    return valueInDollars;
//}
//
//-(NSDate *) dateCreated{
//    return dateCreated;
//}

@end