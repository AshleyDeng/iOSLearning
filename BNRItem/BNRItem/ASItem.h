//
//  ASItem.h
//  BNRItem
//
//  Created by Ashley on 2013-03-22.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASItem : NSObject
{
    NSString *itemName;
    NSString *serialNumber;
    int valueInDollars;
    NSDate *dateCreated;

}
// class methods
+(id) randomItem;

// initializers
-(id) initWithItemName:(NSString *) name
        valueInDollars:(int) value
          serialNumber:(NSString *) sNumber;

-(id) initWithItemName:(NSString *) name;
-(id) initWithValueInDollars:(int) value;
-(id) initWithSerialNumber:(NSString *) sNumber;

// Instance methods
-(void) setItemName:(NSString *)str;
-(NSString *) itemName;

-(void) setSerialNumber:(NSString *)str;
-(NSString *) serialNumber;

-(void) setValueInDollars:(int)i;
-(int) valueInDollars;

-(NSDate *) dateCreated;


@end
