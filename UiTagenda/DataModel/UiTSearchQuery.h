#import "_UiTSearchQuery.h"

@interface UiTSearchQuery : _UiTSearchQuery {}

+(UiTSearchQuery *)saveWithTitle:(NSString *)title usingManagedObjectContext:(NSManagedObjectContext *)moc;

@end