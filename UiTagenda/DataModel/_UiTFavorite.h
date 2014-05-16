// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UiTFavorite.h instead.

#import <CoreData/CoreData.h>


extern const struct UiTFavoriteAttributes {
	__unsafe_unretained NSString *eventID;
} UiTFavoriteAttributes;

extern const struct UiTFavoriteRelationships {
} UiTFavoriteRelationships;

extern const struct UiTFavoriteFetchedProperties {
} UiTFavoriteFetchedProperties;




@interface UiTFavoriteID : NSManagedObjectID {}
@end

@interface _UiTFavorite : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UiTFavoriteID*)objectID;





@property (nonatomic, strong) NSString* eventID;



//- (BOOL)validateEventID:(id*)value_ error:(NSError**)error_;






@end

@interface _UiTFavorite (CoreDataGeneratedAccessors)

@end

@interface _UiTFavorite (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEventID;
- (void)setPrimitiveEventID:(NSString*)value;




@end
