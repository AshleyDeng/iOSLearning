//
//  ASItem.h
//  BNRItem
//
//  Created by Ashley on 2013-03-22.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASItem : NSObject
//{
//    NSString *itemName;
//    NSString *serialNumber;
//    int valueInDollars;
//    NSDate *dateCreated;
//    
//    ASItem *containedItem;
//    __weak ASItem *container;
//}

// class methods
+(id) randomItem;

// initializers
-(id) initWithItemName:(NSString *) name
        valueInDollars:(int) value
          serialNumber:(NSString *) sNumber;

-(id) initWithItemName:(NSString *) name;
-(id) initWithValueInDollars:(int) value;
-(id) initWithSerialNumber:(NSString *) sNumber;

//// deallocation of objects
//-(void) dealloc;
//
//-(void)setContainedItem:(ASItem *)i;
//-(ASItem *)containedItem;
//
//-(void)setContainer:(ASItem *)i;
//-(ASItem *)container;
//
//// Instance methods
//-(void) setItemName:(NSString *)str;
//-(NSString *) itemName;
//
//-(void) setSerialNumber:(NSString *)str;
//-(NSString *) serialNumber;
//
//-(void) setValueInDollars:(int)i;
//-(int) valueInDollars;
//
//-(NSDate *) dateCreated;

// using property directive to declare the instance variables &
// their setters and getters 
@property (nonatomic) NSString *itemName;
@property (nonatomic) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly) NSDate *dateCreated;

@property (nonatomic) ASItem *containedItem;
@property (nonatomic, weak) ASItem *container;


@end
