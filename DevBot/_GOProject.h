// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GOProject.h instead.

#import <CoreData/CoreData.h>


extern const struct GOProjectAttributes {
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *revision;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *title;
} GOProjectAttributes;

extern const struct GOProjectRelationships {
} GOProjectRelationships;

extern const struct GOProjectFetchedProperties {
} GOProjectFetchedProperties;







@interface GOProjectID : NSManagedObjectID {}
@end

@interface _GOProject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GOProjectID*)objectID;





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

@interface _GOProject (CoreDataGeneratedAccessors)

@end

@interface _GOProject (CoreDataGeneratedPrimitiveAccessors)


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
