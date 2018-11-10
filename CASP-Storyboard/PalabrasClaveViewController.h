//
//  PalabrasClaveViewController.h
//
//  Created by Luis Ruiz del Fresno on 19/10/12.
//
//

#import <UIKit/UIKit.h>
#import "LectCrit.h"

@interface PalabrasClaveViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate> {
    
    UIButton            *editBoton;
    UIBarButtonItem            *saveBoton;
    UIBarButtonItem            *cancelButton;
    
    UITableView         *tableView;
    
    NSManagedObjectContext      *context;
    NSFetchedResultsController  *fetchedResultsController;

    LectCrit                    *lecturaCritica;
    
    NSMutableSet                *pickedTags;
    NSMutableArray              *etiquetasGeneralesUnicasOrdenadas;

}

@property (nonatomic, strong) IBOutlet UITableView      *tableView;
@property (nonatomic, strong) UIButton                  *editBoton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem            *saveBoton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem            *cancelButton;
@property (nonatomic, strong) NSManagedObjectContext      *context;
@property (nonatomic, strong) LectCrit                    *lecturaCritica;
@property (nonatomic, strong) NSMutableSet                *pickedTags;
@property (nonatomic, strong) NSMutableArray              *etiquetasGeneralesUnicasOrdenadas;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController; //Para mostrar una entidad relacionada con la que le pasan

@end
