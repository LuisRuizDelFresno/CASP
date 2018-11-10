//
//  MenuLCViewController.h
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 03/04/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "InfoCASPeViewController.h"
#import "LectCrit.h"

@interface MenuLCViewController : UITableViewController  <NSFetchedResultsControllerDelegate, InfoCASPeViewControllerDelegate> {
    LectCrit *nuevaLC;
    
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) LectCrit *nuevaLC;

- (void)handleOpenURL:(NSURL *)url;
- (NSDictionary *)dictFromURL:(NSURL *)importURL;

@end
