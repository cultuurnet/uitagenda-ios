#import "UiTFavorite.h"
#import "UitagendaDataModel.h"

@interface UiTFavorite ()

@end

@implementation UiTFavorite

+(UiTFavorite *)favoriteWithEventId:(NSString *)eventId usingManagedObjectContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[UiTFavorite entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"eventID = %@", eventId]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    if (error) {
        exit(1);
    }
    
    if ([results count] == 0) {
        return nil;
    }
    
    return [results objectAtIndex:0];
}

@end