#import "UiTSearchQuery.h"
#import "UitagendaDataModel.h"

@interface UiTSearchQuery ()

@end

@implementation UiTSearchQuery

+(UiTSearchQuery *)saveWithTitle:(NSString *)title usingManagedObjectContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[UiTSearchQuery entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title = %@", title]];
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