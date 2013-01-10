//
//  GOStateTransformer.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "GOProjectStateTransformer.h"
#import "GOConstants.h"

@implementation GOProjectStateTransformer

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
