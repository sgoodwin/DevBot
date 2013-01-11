// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DVBProject.h instead.

#import <CoreData/CoreData.h>


extern const struct DVBProjectAttributes {
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *revision;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *title;
} DVBProjectAttributes;

extern const struct DVBProjectRelationships {
} DVBProjectRelationships;

extern const struct DVBProjectFetchedProperties {
} DVBProjectFetchedProperties;







@interface DVBProjectID : NSManagedObjectID {}
@end

@interface _DVBProject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DVBProjectID*)objectID;





@property (nonatomic, strong) NSString* path;



//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* revision;



//- (BOOL)validateRevision:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* state;



@property int16_t stateValue;
- (int16_t)stateValue;
- (void)setStateValue:(int16_t)value_;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






#if TARGET_OS_IPHONE

#endif

@end

@interface _DVBProject (CoreDataGeneratedAccessors)

@end

@interface _DVBProject (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSString*)primitiveRevision;
- (void)setPrimitiveRevision:(NSString*)value;




- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (int16_t)primitiveStateValue;
- (void)setPrimitiveStateValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
