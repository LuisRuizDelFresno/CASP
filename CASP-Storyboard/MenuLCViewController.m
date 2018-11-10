//
//  MenuLCViewController.m
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 03/04/13.
//
//

#import "MenuLCViewController.h"
#import "LectCritViewController.h"
#import "LectCrit.h"
#import "Revisor.h"
#import "AppDelegate.h"
#import "InfoCASPeViewController.h"

@implementation MenuLCViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize nuevaLC;

- (void)viewDidLoad {
    [super viewDidLoad];

    //Título en NavBar
    self.navigationItem.title = NSLocalizedString(@"Lecturas", nil);

    //Botón añadir
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    //Botón info.
    UIImage *infoIcon = [UIImage imageNamed:@"info"];
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:infoIcon
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                  action:@selector(info:)];
    self.navigationItem.leftBarButtonItem = infoButton;
   // Inicialmente estaba inicializado aquí y en viewWillAppear, pero creo que aquí no hace falta, y en viewWillAppear me pareció mejor porque lo actualiza la búsqueda cada vez que muestra el Menu, mientras que viewDidLoad sólo la primera vez que muestra la View. Ya no es válido la recomendación de optimizar el uso de memoria asignando nil en viewDidUnload y reinciializando en viewDidLoad, porque viewDidUnload quedo deprecado en iOS6
    /*
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        //Comunica el error en consola
        NSLog(@"Error en incialización-ejecución primera búsqueda fetResultsController %@, %@", error, [error userInfo]);
        
        //Sal de la aplicación
        abort();
    }
   */
    
    //PAra evita el error de que no encuentra un NSManagedObjetModel Etiquetas, tomado de stackoverflow.com/questions/1074539/passing-a-managedobjectcontext-to-a-second-view
     if (_managedObjectContext == nil) {
         _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
         NSLog(@"NO HABIA MANAGEDOBJECT CONTEXT DONDE DEBIA HABERLO: %s", __FUNCTION__);
     }
     
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error! %@", error);
        //causes the application to generate a crash log and
        // terminate. You should not use this function in a shipping
        // application, although it may be useful during development.
    }
    
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        
    return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
      
    }
    
    [self configureCell:cell atIndexPath:indexPath];
        
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell.
    LectCrit *managedLCObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = managedLCObject.titulo;
    cell.detailTextLabel.text = managedLCObject.tipoArt;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"MenuALect" sender:self];

}

#pragma mark - Info

- (IBAction)info:(id)sender {
    
    [self performSegueWithIdentifier:@"MenuAInfo" sender:self];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"MenuAInfo"]) {
        InfoCASPeViewController *infoViewController = segue.destinationViewController;
        infoViewController.delegate = self;
        
    } else if ([[segue identifier] isEqualToString:@"MenuALect"]) {
        LectCritViewController *lectCritVC = segue.destinationViewController;
        
        //Para pasarle al nuevo VC la Lectura que interesa: nuevaLC o una del menú.
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        if (indexpath)  lectCritVC.lecturaCritica = (LectCrit *)[self.fetchedResultsController objectAtIndexPath:indexpath];
        else            lectCritVC.lecturaCritica = nuevaLC;
        
        lectCritVC.context = self.managedObjectContext;
        
        nuevaLC = nil;

    }
}

- (void)infoCASPeViewControllerDidFinish:(InfoCASPeViewController *)infoCASPeViewController {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Add un objeto

- (void)handleOpenURL:(NSURL *)url {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //CREA un objeto nuevo, obtiene el diccionario del mensaje y puebal los atributos y relaciones
    nuevaLC = [NSEntityDescription insertNewObjectForEntityForName:@"LectCrit" inManagedObjectContext:self.managedObjectContext];
    
    NSDictionary *objetoDict = [self dictFromURL:url];
    if (objetoDict) {
        [nuevaLC populateFromDictionary:objetoDict];
    }

}

-(NSDictionary *)dictFromURL:(NSURL *)importURL {
    
    //Des-serializar un JSON
    //URL que trae datos JSON -> NSData [NSData dataWithContentOfURL] -> NSDict o NSArray [NSJSONSerialization JSONObjectWithData:options:error:]
    NSData *dataJson = [NSData dataWithContentsOfURL:importURL];
    
    NSError *error = nil;
    NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:dataJson
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    
    if(!myDictionary)   NSLog(@"Error: %@",error);
    
    return myDictionary;
    
}

- (void)add:(id)sender {
    
    //Obtenemos el Contexto y creamos un ModelObject en él, de acuerdo a la entidad LectCrit
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    nuevaLC = [NSEntityDescription insertNewObjectForEntityForName:@"LectCrit" inManagedObjectContext:context];

    //VALORES POR DEFECTO A TODAS LOS ATRIBUTOSVamos dándole valores a sus atributos, y relación con revisor
    //Atributos directos de nuevaLect
    nuevaLC.titulo = NSLocalizedString(@"Escriba aquí el Título", nil);
    nuevaLC.revista =  NSLocalizedString(@"Escriba aquí la Revista", nil);
    nuevaLC.pubmedID =  NSLocalizedString(@"Escriba aquí el PubMedID", nil);
    nuevaLC.tipoArt =  NSLocalizedString(@"Pendiente de Lectura", nil);
    nuevaLC.comentario =  NSLocalizedString(@"Escriba aquí sus comentarios", nil);
    nuevaLC.fecha = [NSDate date];

    nuevaLC.etiquetaIndice = NSLocalizedString(@"EtiquetaIndicePorDefecto", nil);
    
    //REVISORTomar al revisor por defecto desde la configuración en "Ajustes". Para no duplicarlo sigue un esquema find-or-create.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSEntityDescription *revisorEntity = [NSEntityDescription entityForName:@"Revisor" inManagedObjectContext:context];
    NSFetchRequest *solicitud = [[NSFetchRequest alloc] init];    
    [solicitud setEntity:revisorEntity];
    NSPredicate *criterioBusqueda = [NSPredicate predicateWithFormat:@"revisorNombre LIKE %@", [defaults stringForKey:@"nombre_preferences"]];
    [solicitud setPredicate:criterioBusqueda];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:solicitud error:&error];
    
    if (array.count == 0) {
        Revisor *revisor = [NSEntityDescription insertNewObjectForEntityForName:@"Revisor" inManagedObjectContext:context];
        revisor.revisorNombre = [defaults stringForKey:@"nombre_preferences"];
        revisor.revisorEmail = [defaults stringForKey:@"correo_preferences"];
        array = [NSArray arrayWithObject:revisor];

    }
    
    nuevaLC.relacionRevisor = [array objectAtIndex:0];
    
    [self saveContext];
    
    [self performSegueWithIdentifier:@"MenuALect" sender:self];
    
}

- (void)saveContext {
    
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LectCrit"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    //Primero el desciptor que ordene las secciones, usando como clave el atributo que interese; si el atributo está en un objeto relacionado con la entidad: @"nombreDeLaRelacion.atributo"
    //Luego el descriptor que ordene las rows
    NSSortDescriptor *sortDescriptorSecciones = [[NSSortDescriptor alloc] initWithKey:@"etiquetaIndice" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titulo" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptorSecciones, sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    // Si es un atributo de la entity @"atributo", si es un atributo de otro managedObject relacionado: @"nombreDeLaRelacion.atributo". cacheName creo que puede ser @"LectCrit" o @"Master" (sin saber muy bien que significa @"Master") o nil. el cache parece qu acelera la ejecución cuando hay que cargar bastantes objetos (stackoverflow 3035791) Le puse @"MenuFRC", lo quité por el problema de actualizar menu después de duplicar un objeto en lectVc
    //Si una lectura no tiene valor en etiquetaIndice, da problemas porque el fetchedResultsController no recibe las notificaciones de que el context ha cambiado,... Añado algo de código para crear las lecturas con un valor por defecto (EN MenuVC) y asignarle uno si el usuario las deja sin valor (LectCritViewController).
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"etiquetaIndice"
                                                                                                           cacheName:@"ProbandoCache"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    //+++++++++++++++++++
    //Para contar el numero de objetos que hay en el Context
    /*
    NSError *error;
    NSArray *objetosEnContextArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objetosEnContextArray == nil) {
        NSLog(@"No hay ningún objeto en el context");
        
    } else {
        NSLog(@"HAy %lu objetos en el context", (unsigned long)objetosEnContextArray.count);
        LectCrit *lectura;
        for (lectura in objetosEnContextArray) {
            NSLog(@"OBJETO ID %@ \nTipoArt %@, \nRelacionRespuestas %@", [lectura objectID], lectura.tipoArt, lectura.relacionRespuestas);

        }
    }
    */
    //+++++++++++++++++++

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];

    } else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];

    }
    
    /* DA UN WARNING
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    */
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
        
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
}

 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
/*
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller  {
 // In the simplest, most efficient, case, reload the table view.
     NSLog(@"%s", __FUNCTION__);

     [self.tableView reloadData];
}
*/

@end
