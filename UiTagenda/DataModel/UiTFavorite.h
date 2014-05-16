#import "_UiTFavorite.h"

@interface UiTFavorite : _UiTFavorite {}

+(UiTFavorite *)favoriteWithEventId:(NSString *)eventId usingManagedObjectContext:(NSManagedObjectContext *)moc;

@end