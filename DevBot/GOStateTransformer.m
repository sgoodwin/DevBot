//
//  GOStateTransformer.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//  Copyright (c) 2013 Roundwall Software. All rights reserved.
//

#import "GOStateTransformer.h"
#import "GOProject.h"

@implementation GOStateTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    GOProjectState state = [(NSNumber*)value unsignedIntegerValue];
    switch(state){
        case GOProjectStateIdle:
            return nil;
            break;
        case GOProjectStateBuilding:
            return @"Building...";
            break;
        case GOProjectStateWaiting:
            return @"Waiting...";
            break;
    }
    return nil;
}

@end
