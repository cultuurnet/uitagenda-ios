// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UiTFavorite.m instead.

#import "_UiTFavorite.h"

const struct UiTFavoriteAttributes UiTFavoriteAttributes = {
	.eventID = @"eventID",
};

const struct UiTFavoriteRelationships UiTFavoriteRelationships = {
};

const struct UiTFavoriteFetchedProperties UiTFavoriteFetchedProperties = {
};

@implementation UiTFavoriteID
@end

@implementation _UiTFavorite

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UiTFavorite" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UiTFavorite";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UiTFavorite" inManagedObjectContext:moc_];
}

- (UiTFavoriteID*)objectID {
	return (UiTFavoriteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic eventID;











@end
