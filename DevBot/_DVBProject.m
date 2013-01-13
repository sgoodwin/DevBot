// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DVBProject.m instead.

#import "_DVBProject.h"

const struct DVBProjectAttributes DVBProjectAttributes = {
	.appPath = @"appPath",
	.folderPath = @"folderPath",
	.ipaPath = @"ipaPath",
	.revision = @"revision",
	.state = @"state",
	.title = @"title",
};

const struct DVBProjectRelationships DVBProjectRelationships = {
};

const struct DVBProjectFetchedProperties DVBProjectFetchedProperties = {
};

@implementation DVBProjectID
@end

@implementation _DVBProject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Project";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Project" inManagedObjectContext:moc_];
}

- (DVBProjectID*)objectID {
	return (DVBProjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"stateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"state"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic appPath;






@dynamic folderPath;






@dynamic ipaPath;






@dynamic revision;






@dynamic state;



- (int16_t)stateValue {
	NSNumber *result = [self state];
	return [result shortValue];
}

- (void)setStateValue:(int16_t)value_ {
	[self setState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStateValue {
	NSNumber *result = [self primitiveState];
	return [result shortValue];
}

- (void)setPrimitiveStateValue:(int16_t)value_ {
	[self setPrimitiveState:[NSNumber numberWithShort:value_]];
}





@dynamic title;











#if TARGET_OS_IPHONE

#endif

@end
