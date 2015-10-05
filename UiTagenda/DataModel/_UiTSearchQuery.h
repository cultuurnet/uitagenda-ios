// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UiTSearchQuery.h instead.

#import <CoreData/CoreData.h>


extern const struct UiTSearchQueryAttributes {
	__unsafe_unretained NSString *free;
	__unsafe_unretained NSString *kids;
	__unsafe_unretained NSString *nocoursesandworkshops;
	__unsafe_unretained NSString *radius;
	__unsafe_unretained NSString *searchTerm;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *what;
	__unsafe_unretained NSString *when;
	__unsafe_unretained NSString *where;
} UiTSearchQueryAttributes;

extern const struct UiTSearchQueryRelationships {
} UiTSearchQueryRelationships;

extern const struct UiTSearchQueryFetchedProperties {
} UiTSearchQueryFetchedProperties;












@interface UiTSearchQueryID : NSManagedObjectID {}
@end

@interface _UiTSearchQuery : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UiTSearchQueryID*)objectID;





@property (nonatomic, strong) NSNumber* free;



@property BOOL freeValue;
- (BOOL)freeValue;
- (void)setFreeValue:(BOOL)value_;

//- (BOOL)validateFree:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* kids;



@property BOOL kidsValue;
- (BOOL)kidsValue;
- (void)setKidsValue:(BOOL)value_;

//- (BOOL)validateKids:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* nocoursesandworkshops;



@property BOOL nocoursesandworkshopsValue;
- (BOOL)nocoursesandworkshopsValue;
- (void)setNocoursesandworkshopsValue:(BOOL)value_;

//- (BOOL)validateNocoursesandworkshops:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* radius;



//- (BOOL)validateRadius:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* searchTerm;



//- (BOOL)validateSearchTerm:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* what;



//- (BOOL)validateWhat:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* when;



//- (BOOL)validateWhen:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* where;



//- (BOOL)validateWhere:(id*)value_ error:(NSError**)error_;






@end

@interface _UiTSearchQuery (CoreDataGeneratedAccessors)

@end

@interface _UiTSearchQuery (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFree;
- (void)setPrimitiveFree:(NSNumber*)value;

- (BOOL)primitiveFreeValue;
- (void)setPrimitiveFreeValue:(BOOL)value_;




- (NSNumber*)primitiveKids;
- (void)setPrimitiveKids:(NSNumber*)value;

- (BOOL)primitiveKidsValue;
- (void)setPrimitiveKidsValue:(BOOL)value_;




- (NSNumber*)primitiveNocoursesandworkshops;
- (void)setPrimitiveNocoursesandworkshops:(NSNumber*)value;

- (BOOL)primitiveNocoursesandworkshopsValue;
- (void)setPrimitiveNocoursesandworkshopsValue:(BOOL)value_;




- (NSString*)primitiveRadius;
- (void)setPrimitiveRadius:(NSString*)value;




- (NSString*)primitiveSearchTerm;
- (void)setPrimitiveSearchTerm:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWhat;
- (void)setPrimitiveWhat:(NSString*)value;




- (NSString*)primitiveWhen;
- (void)setPrimitiveWhen:(NSString*)value;




- (NSString*)primitiveWhere;
- (void)setPrimitiveWhere:(NSString*)value;




@end
