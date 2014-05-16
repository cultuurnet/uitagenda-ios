// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UiTSearchQuery.m instead.

#import "_UiTSearchQuery.h"

const struct UiTSearchQueryAttributes UiTSearchQueryAttributes = {
	.free = @"free",
	.kids = @"kids",
	.nocoursesandworkshops = @"nocoursesandworkshops",
	.radius = @"radius",
	.searchTerm = @"searchTerm",
	.title = @"title",
	.what = @"what",
	.when = @"when",
	.where = @"where",
};

const struct UiTSearchQueryRelationships UiTSearchQueryRelationships = {
};

const struct UiTSearchQueryFetchedProperties UiTSearchQueryFetchedProperties = {
};

@implementation UiTSearchQueryID
@end

@implementation _UiTSearchQuery

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UiTSearchQuery" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UiTSearchQuery";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UiTSearchQuery" inManagedObjectContext:moc_];
}

- (UiTSearchQueryID*)objectID {
	return (UiTSearchQueryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"freeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"free"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kidsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kids"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"nocoursesandworkshopsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nocoursesandworkshops"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic free;



- (BOOL)freeValue {
	NSNumber *result = [self free];
	return [result boolValue];
}

- (void)setFreeValue:(BOOL)value_ {
	[self setFree:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFreeValue {
	NSNumber *result = [self primitiveFree];
	return [result boolValue];
}

- (void)setPrimitiveFreeValue:(BOOL)value_ {
	[self setPrimitiveFree:[NSNumber numberWithBool:value_]];
}





@dynamic kids;



- (BOOL)kidsValue {
	NSNumber *result = [self kids];
	return [result boolValue];
}

- (void)setKidsValue:(BOOL)value_ {
	[self setKids:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveKidsValue {
	NSNumber *result = [self primitiveKids];
	return [result boolValue];
}

- (void)setPrimitiveKidsValue:(BOOL)value_ {
	[self setPrimitiveKids:[NSNumber numberWithBool:value_]];
}





@dynamic nocoursesandworkshops;



- (BOOL)nocoursesandworkshopsValue {
	NSNumber *result = [self nocoursesandworkshops];
	return [result boolValue];
}

- (void)setNocoursesandworkshopsValue:(BOOL)value_ {
	[self setNocoursesandworkshops:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNocoursesandworkshopsValue {
	NSNumber *result = [self primitiveNocoursesandworkshops];
	return [result boolValue];
}

- (void)setPrimitiveNocoursesandworkshopsValue:(BOOL)value_ {
	[self setPrimitiveNocoursesandworkshops:[NSNumber numberWithBool:value_]];
}





@dynamic radius;






@dynamic searchTerm;






@dynamic title;






@dynamic what;






@dynamic when;






@dynamic where;











@end
