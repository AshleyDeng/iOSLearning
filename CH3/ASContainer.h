//
//  ASContainer.h
//  BNRItem
//
//  Created by Ashley on 2013-03-22.
//  Copyright (c) 2013 Ashley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASItem.h"

@interface ASContainer : ASItem
{
    NSString * containerName;
    int totalPrice;
    NSMutableArray *arrayItem;
}

-(id) initWithContainerName:(NSString *) cName;
-(void) description;
-(int) totalPrice;


@end
