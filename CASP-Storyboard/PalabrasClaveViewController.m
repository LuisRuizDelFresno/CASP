//
//  PalabrasClaveViewController.m
//
//  Created by Luis Ruiz del Fresno on 19/10/12.
//
//

#import "PalabrasClaveViewController.h"
#import "Etiquetas.h"
#import "AppDelegate.h"

@interface PalabrasClaveViewController ()

@end

@implementation PalabrasClaveViewController

@synthesize tableView, saveBoton, cancelButton;//, palabrasClaveArray;
@synthesize fetchedResultsController, context, lecturaCritica, pickedTags, etiquetasGeneralesUnicasOrdenadas, editBoton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
        
    [super viewDidLoad];
    
    //intentando que se ajuste a pantallas de 3,5 y 4 inches
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //Obtiene TODAS las etiquetas que tenga CUALQUIER LECTURA del context) y si falla que comunique el error y aborte la app.
    etiquetasGeneralesUnicasOrdenadas = [[NSMutableArray alloc] initWithCapacity:1];
    etiquetasGeneralesUnicasOrdenadas = [self copyEtiquetasGeneralesArrayOrdenado];
    
    //Obtiene las etiquetas del objeto lectura recibido
    pickedTags = [[NSMutableSet alloc] initWithCapacity:1];
    pickedTags = [self copyObtieneEtiquetasLectura];
    
    saveBoton.enabled = 0;
    cancelButton.enabled = 1;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated {

    //A diferencia de lo que pasa con los VC del stack de un navigation controller, los modalviewcontroller cuando aparece por segunda vez se recargan desde cero (pasando por viewDidLoad). Por lo tanto, un array cargado en primera instancia en viewDidLoad, debe ser guardado en disco cada vez que se modifica para que la próxima vez que se carge la página se lea del disco y contenga las modificaciones. Lo guardaría en viewWillDisappear y lo carga en viewDidLoad. Pero lo he pasado a saveAndPop y quitAndPop porque en uno guarda los cambios y en otro no, y son las dos unicas formas de salir de la view.

    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - NSFetchedResultsController Delegate

- (NSFetchedResultsController *)fetchedResultsController {
    
    //Si NO creamos etiquetas al inicializar una lectura (las crearía/seleccionaria el usuario de la lista, editando la lectura); cuando ejecute la búsqueda tendremos una colección de objetos únicos ordenados. Si creamos las etiquetas al inicializar vamos aumentando el número de objetos etiquetas duplicados.
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    // Set up the fetched results controller. (1) Create the fetch request for the entity. (2) Edit the entity name as appropriate. (3) Edit the sort key as appropriate. (4) Edit the section name key path and cache name if appropriate. nil for section name key path means "no sections".
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //(2)
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Etiquetas" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // (3)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"etiquetaNombre" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // (4)
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:context
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    fetchedResultsController = aFetchedResultsController;
    
    
    return fetchedResultsController;
}

-(NSMutableArray *)copyEtiquetasGeneralesArrayOrdenado {
    
    //Ejecuta la consulta definida en fetchResCon (si hay un error lo comunica y aborta), y luego pasa los objetos obtenidos a un array que usará para el resto de las tareas con la tabla, ... No hace falta eliminar duplicidades, ni ordenar porque las etiquetas ya están ordenadas y si están duplicadas es porque el usuario lo ha querido así.
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Core data error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];    
    NSMutableArray *etiquetasGeneralesArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i < [sectionInfo numberOfObjects]; i++) {
        NSIndexPath *indiceAdaptado = [NSIndexPath indexPathForRow:i inSection:0];
        Etiquetas *managedEtiquetasObject = [fetchedResultsController objectAtIndexPath:indiceAdaptado];
        [etiquetasGeneralesArray addObject:managedEtiquetasObject];
        
    }
    //Aquí hay un "potential leak" en el análysis que se corrige con autorelease al inicializar el array pero entonces se libera antes de ser usado en otros métodos y se cierra la aplicación por zombie. Soluciones: la mejor esperar a cuando pase el proyecto a ARC que se corregirá sólo, o hacer del mutable array una ivar que libero yo en dealloc. No funcionó lo del autorelease, se cerraba la app por que se deallocaba demasiado pronto, siguiendo las intrucciones de la alrma azul de potential leak (cuando volviá a ejarlo sin autorelease), dice que el meétodo debe emepzar por copy, mutablecopy alloc or new. por eso empieza por copy y parece que funcionó
    return etiquetasGeneralesArray;//[etiquetasGeneralesArray autorelease];
    
}

-(NSMutableSet *)copyObtieneEtiquetasLectura {
    
    //Obtiene las etiquetas SOLO DE ESTA LECTURA
    NSSet *tags = self.lecturaCritica.relacionEtiquetas;
    NSMutableSet *tagsMutableSet = [[NSMutableSet alloc] initWithSet:tags];
    
    //Aquí hay un "potential leak" en el análysis que se corrige con autorelease al inicializar el Set pero entonces se libera antes de ser usado en otros métodos y se cierra la palicación por zombie. Soluciones: la mejor esperar a cuando pase el proyecto a ARC que se corregirá sólo, o hacer del set una ivar que libero yo en dealloc.
    return tagsMutableSet;//[tagsMutableSet autorelease];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)        return 1;
    
    else {
        //if ([etiquetasGeneralesUnicasOrdenadas count] > 0) return etiquetasGeneralesUnicasOrdenadas.count;
        //return 1;
        
        return etiquetasGeneralesUnicasOrdenadas.count;
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) return NSLocalizedString(@"Escriba una etiqueta nueva", nil);
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 35;
    return 45;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0)   return nil;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, super.view.bounds.size.width, 44)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 230, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.text = NSLocalizedString(@"Seleccione las que desee", nil);
    [headerView addSubview:headerLabel];
    
    editBoton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editBoton.frame = CGRectMake(260.0, 10, 50.0, 25.0);
    [editBoton setTitle:NSLocalizedString(@"Editar", nil) forState:UIControlStateNormal];
    [editBoton addTarget:self
                  action:@selector(editButtonSelected:)//@selector(tableView:canEditRowAtIndexPath:)
        forControlEvents:UIControlEventTouchDown];
    
    [headerView addSubview:editBoton];
    
    return headerView;
    
}

- (void) editButtonSelected: (id) sender {
    if (tableView.editing) {
        [editBoton setTitle:NSLocalizedString(@"Editar", nil) forState:UIControlStateNormal];

        [self.tableView setEditing:NO animated:YES];
        
    } else {
        [editBoton setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
        
        [self.tableView setEditing:YES animated:YES];
        
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Inicializa una celda, (1) Si la sección es la uno la puebla (2) si la sección es 0 le asigna la configurada en PalabrasClaveViewController.xib
    static NSString *Cell1Identifier = @"celdaSeccion1";
    static NSString *Cell0Identifier = @"celdaSeccion0";

    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:Cell0Identifier forIndexPath:indexPath];
        /*
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell0Identifier];
            
        }
        */
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:Cell1Identifier forIndexPath:indexPath];
        /*
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell1Identifier];
            
        }
        */
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([etiquetasGeneralesUnicasOrdenadas count] > 0) {
            Etiquetas *etiqueta = (Etiquetas *)[etiquetasGeneralesUnicasOrdenadas objectAtIndex:indexPath.row];
            cell.textLabel.text = etiqueta.etiquetaNombre;
            if ([pickedTags containsObject:etiqueta])   cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else {
            cell.textLabel.text = nil;
            
        }

    }

    //Puebla las celdas de la sección 1
    if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([etiquetasGeneralesUnicasOrdenadas count] > 0) {
            Etiquetas *etiqueta = (Etiquetas *)[etiquetasGeneralesUnicasOrdenadas objectAtIndex:indexPath.row];
            cell.textLabel.text = etiqueta.etiquetaNombre;
            if ([pickedTags containsObject:etiqueta])   cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else {
            cell.textLabel.text = nil;
            
        }

    }
    
    return cell;
    
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (etiquetasGeneralesUnicasOrdenadas.count > 0) {
        
        //(1) Hay que comparar la etiqueta seleccionada con las de la lectura crítica para saber si hay que añadirla o eliminar (2) y al tiempo poner o quitar la checkmark
        UITableViewCell * cell = [self.tableView  cellForRowAtIndexPath:indexPath];                                     //Para (2)
        Etiquetas *etiquetaSeleccionada = (Etiquetas *)[etiquetasGeneralesUnicasOrdenadas objectAtIndex:indexPath.row];
    
        if ([pickedTags containsObject:etiquetaSeleccionada]) {
            [pickedTags removeObject:etiquetaSeleccionada];
            cell.accessoryType = UITableViewCellAccessoryNone;

        } else {
            [pickedTags addObject:etiquetaSeleccionada];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        }
    
        [cell setSelected:NO animated:YES];
        
    } 
    
    [saveBoton setEnabled:YES];
    
}

#pragma mark -
#pragma mark UITableView Editar, reordenar

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Así no se edita ni la primera sección que sólo tiene una row ni la sección 1 cuando queda una sóla row (porque si la eliminamos la appp se cierra por lainconsistencia de que deben quedar 0 ros y en numbreOfRow decimos 1 al menos.
    //if ([self.tableView numberOfRowsInSection:indexPath.section] == 1 )     return NO;
    
    if (indexPath.section == 0) return NO;
    
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        //if ([self.tableView numberOfRowsInSection:indexPath.section] > 0 ) { //decidií permitir que se borrase la última etiqueta, para ello permití 0 rows en la seciion 1 en numberOfRows, permitir editar la row 0 en la sección 1 en ccanEdit y puse "0" en vez de "1" en esta condición.
            
            
            //obtine una referencia al objeto a borrar, (1) lo elimina del context, (2) actualiza el array que puebla numbreOfRows... (3) actualiza pickedTags si procede, (4) borra la row animadamente
            NSManagedObject *objetoABorrar = [etiquetasGeneralesUnicasOrdenadas objectAtIndex:indexPath.row];
        
            //1
            [context deleteObject:objetoABorrar];
        
            //2 y 3
            [etiquetasGeneralesUnicasOrdenadas removeObject:objetoABorrar];
            if ([pickedTags containsObject:objetoABorrar]) [pickedTags removeObject:objetoABorrar];
        
            //4
            NSIndexPath *indexPathAdaptadoSec1 = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathAdaptadoSec1] withRowAnimation:UITableViewRowAnimationFade];
            
        //} else {
            [self editButtonSelected:self];
        //}
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view. CREO QUE LO HACEMOS EN TEXTFIELD SHOULD RETURN
    }
}

#pragma mark -
#pragma mark Guadar lo Introducido/seleccionado y salir
- (void)sumaEtiqueta:(NSString *)etiqueta {
    
    [self.tableView beginUpdates];
    
    //Crea el objeto etiqueta en el context y lo puebla,
    Etiquetas *nuevaEtiqueta = [NSEntityDescription insertNewObjectForEntityForName:@"Etiquetas" inManagedObjectContext:context];
    nuevaEtiqueta.etiquetaNombre = etiqueta;
    
    //Refresca el array de TODAS las etiquetas que tenga CUALQUIER LECTURA del context (ahí ya va la etiqueta nueva), para cuando forme numberOfRows,...
    etiquetasGeneralesUnicasOrdenadas = [self copyEtiquetasGeneralesArrayOrdenado];
    
    //la añade a la etiquetas del la lectura
    [pickedTags addObject:nuevaEtiqueta];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

- (IBAction)saveAndPop:(id)sender {
    
    self.lecturaCritica.relacionEtiquetas = pickedTags;
    [self saveContext];

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction) quitAndPop:(id)sender {
    
    [context refreshObject:lecturaCritica mergeChanges:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)saveContext {
    
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    cancelButton.enabled = 1;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length > 0) {
        [self sumaEtiqueta:textField.text];
    }
    
    textField.text = nil;
    [textField resignFirstResponder];
    
    saveBoton.enabled = 1;
    cancelButton.enabled = 1;

    return YES;
}

@end
