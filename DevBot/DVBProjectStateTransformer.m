//
//  GOStateTransformer.m
//  DevBot
//
//  Created by Samuel Goodwin on 1/10/13.
//

#import "DVBProjectStateTransformer.h"
#import "DVBConstants.h"

@implementation DVBProjectStateTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    DVBProjectState state = [(NSNumber*)value unsignedIntegerValue];
    switch(state){
        case DVBProjectStateIdle:
            return nil;
            break;
        case DVBProjectStateBuilding:
            return @"Building...";
            break;
        case DVBProjectStateWaiting:
            return @"Waiting...";
            break;
        case DVBProjectStatePackaging:
            return @"Packaging...";
            break;
        case DVBProjectStateFailed:
            return @"FAILED!";
            break;
    }
    return nil;
}

@end
