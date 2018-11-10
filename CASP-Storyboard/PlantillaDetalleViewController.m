//
//  PlantillaDetalleViewController.m
//  TableSearch
//
//  Created by Luis Ruiz del Fresno on 27/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlantillaDetalleViewController.h"
#import "AppDelegate.h"
#import "PregViewController.h"
#import "Respuestas.h"

@implementation PlantillaDetalleViewController

@synthesize recibeColor, nombrePlantillaCorto, plantillaID, tipoArtiPregArray, muestraColor, celdaSeleccionadaD, context, laLectCrit; //idPlantilla,

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = nombrePlantillaCorto;

    //Prepara por el path al plist con el plantillaID: si viene de un menu de plantillas en inglés, los plantillaID son de plist en inglés, y lo correspondiente si viene de menu en español.
    //Para poder cambiar los valores de los dic de preguntas el dic debe ser mutable. EN las colecciones multiniveles, si la colección tronco es mutable sus subdivisiones se comportan como mutables, por eso plantillaPlistDic deb ser mutable
    NSString *tipoArticuloPath = [[NSBundle mainBundle] pathForResource:plantillaID ofType:@"plist"];
    NSMutableDictionary *plantillaPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:tipoArticuloPath];
    
    tipoArtiPregArray = [[NSMutableArray alloc] initWithArray:[plantillaPlistDic objectForKey:@"preguntas"]];

    //Código para ampliar el plist inicial de cada plantilla
    /*
    NSString *logo = [NSString stringWithFormat:@"logo"];
    NSString *logo2 = [NSString stringWithFormat:@"logo"];
    NSString *programa = [NSString stringWithFormat:@""];
    NSString *entender = [NSString stringWithFormat:@"10 questions to help you make sense of a review"];
    NSString *comentariosGenerales = [NSString stringWithFormat:@"How to use this appraisal tool\nThree broad issues need to be considered when appraising the report of a randomised controlled trial:\n- Are the results of the review valid?      (Section A)\n- What are the results?      (Section B)\n- Will the results help locally?      (Section C)\nThe 10 questions on the following pages are designed to help you think about these issues systematically.\nThe first two questions are screening questions and can be answered quickly. If the answer to both is “yes”, it is worth proceeding with the remainig questions.\n\nThere is some degree of overlap between the questions, you are asked to record a “yes”, “no” or “can’t tell” to most of the questions. A number of italicised prompts are given after each question. These are designed to remind you why the question is important. Record your reasons for your answers in the spaces provided.\n\nThere will not be time in the small groups to answer them all in detail!"];
    NSString *registrada = [NSString stringWithFormat:@"©CASP This work is licensed under the Creative Commons Attribution - NonCommercial-ShareAlike 3.0 Unported Lic1ense. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ www.casp-uk.net"];
    NSString *citameAsi = [NSString stringWithFormat:@"©Critical Appraisal Skills Programme (CASP) Systematic Review Checklist 31.05.13"];
    
    NSDictionary *tipoArticuloDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     logo, @"logo1",
                                     logo2, @"logo2",
                                     programa, @"pagina1Programa",
                                     entender, @"pagina1TipoArt",
                                     comentariosGenerales, @"pagina1ComentariosGenerales",
                                     registrada, @"pagina1Marca",
                                     citameAsi, @"pagina1CitameAsi",
                                     tipoArtiPregArray, @"preguntas", nil];
    //El Path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *docName = [documentsDirectory stringByAppendingPathComponent:@"rev_2_en.plist"];

    [tipoArticuloDic writeToFile:docName atomically:YES];
    
    NSLog(@"PATH %@", docName);
    */
    
    [self coreDataRespuestas];
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    //PAra evita el error de que no encuentra un NSManagedObjetModel Etiquetas, tomado de stackoverflow.com/questions/1074539/passing-a-managedobjectcontext-to-a-second-view
    if (context == nil) {
        context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"NO HABIA MANAGEDOBJECT CONTEXT DONDE DEBIA HABERLO: %s", __FUNCTION__);
    }

    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //Cuando va a desaparecer la view pasa las respuestas al objeto respuestas y le pega este al objeto lecturacCritica, y guarda.
    [self respuestasCoreData];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];

    //[[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark - Modificar Respuestas

-(IBAction)customActionPressed:(id)sender {
    
    //Obtener el indexPath de la celda donde se ha pulsado el botón. 
    //Botón (sender) está dentro de contentView (contenteView es su superview: [sender supreview]), que a su vex está dentro de una UItableViewCellScrollView, que a su vez esta dentro de la que es la que se identifica por el indexPath. OJO que antes de Storyboard sólo había que retrotraerse 2 superviews para llegar a la cell.
    
    UITableViewCell *celdaBotonPulsado = nil;
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))    celdaBotonPulsado = (UITableViewCell*)[[[sender superview] superview] superview];
    else                                    celdaBotonPulsado = (UITableViewCell*)[[sender superview] superview];
    
    NSIndexPath *pathToCell = [self.tableView indexPathForCell:celdaBotonPulsado];
    
    //No se por qué no compara bien el whiteColor especificando @"whiteColor", por eso empiezo la cadena por otro color y dejo el whiteColor como última opción sin citarlo; sin embargo lee whiteColor, etc.
    if ([[[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] objectForKey:@"color"] isEqualToString:@"greenColor"]) {
                
        [[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] setValue:@"yellowColor" forKey:@"color"];
        
    } else if ([[[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] objectForKey:@"color"] isEqualToString:@"yellowColor"]) {
        
        [[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] setValue:@"redColor" forKey:@"color"];
        
    } else if ([[[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] objectForKey:@"color"] isEqualToString:@"redColor" ]) {
        
        [[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] setValue:@"whiteColor" forKey:@"color"];

    } else {
        [[[[tipoArtiPregArray objectAtIndex:pathToCell.section] objectForKey:@"preguntas"] objectAtIndex:pathToCell.row] setValue:@"greenColor" forKey:@"color"];
    }
    
    [self.tableView reloadData];
    
    [self respuestasCoreData];
    
}

-(void)coreDataRespuestas {
        
    //Queremos pasar los valores de los atributos r0, r1, ... de Respuestas al array tipoArtiPregArray
    //Para ello defino un integer (i) que empieza valiendo 0, luego voy iterando por cada sección y pregunta, al pasar por cada pregunta hago referencia a la r que corresponda, le voy pasando su color a tipoArtiPregArray, y subo 1 el valor de i para que me sirva para la siguiente r.
    //Ojo: NSMutableDictionary *preguntaDic = [arrayPregSecc objectAtIndex:z] es un puntero al dic que hay en tipoArtiPregArray en última instancia. Pero: NSMutableDictionary *preguntaDic = [NSMutableDictionary dictionaryWithDictionary:[arrayPregSecc objectAtIndex:z]]; es crear un nuevo dic con el contenido del otro, los cambios que hiciesemos en este nuevo no cambiarían el contenido final de tipoArtiPregArray

    int i = 0;
    for (NSDictionary *dicSeccion in tipoArtiPregArray) {
        NSArray *arrayPregSecc = [dicSeccion objectForKey:@"preguntas"];
        for (int z = 0; z < arrayPregSecc.count; z++) {
            NSMutableDictionary *preguntaDic = [arrayPregSecc objectAtIndex:z];
            [preguntaDic setValue:[laLectCrit.relacionRespuestas valueForKey:[NSString stringWithFormat:@"r%i", i]] forKey:@"color"];
            i++;
        }
    }
}

-(void)respuestasCoreData {
    
    //Pasa las respuestas que viene en ultima instancia del plist de una plantilla concreta, a los valores del objeto respuestas, asociado a la lectura actual.
    //para ello saca los "colores" a un array plano y luego los asigna a los atributos r0, r1, ... del objeto Respuestas
    NSMutableArray *coloresArrayPlano = [[NSMutableArray alloc] initWithCapacity:12];
    for (NSDictionary *dicSeccion in tipoArtiPregArray) {
        NSArray *arrayIntePreg = [dicSeccion objectForKey:@"preguntas"];
        for (int i = 0; i < arrayIntePreg.count; i++) {
            NSMutableDictionary *preguntaDic = [NSMutableDictionary dictionaryWithDictionary:[arrayIntePreg objectAtIndex:i]];
            [coloresArrayPlano addObject:[preguntaDic objectForKey:@"color"]];
        }
    }
    
    for (int i = 0 ; i < coloresArrayPlano.count ; i++) {
        [laLectCrit.relacionRespuestas setValue:[coloresArrayPlano objectAtIndex:i] forKey:[NSString stringWithFormat:@"r%i", i]];

    }
    
    [self saveContext];
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

#pragma mark - Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return tipoArtiPregArray.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	//Cogemos el diccionario que corresponda a la sección que queremos representar
	NSDictionary *dicEnTipoArticuloArray = [tipoArtiPregArray objectAtIndex:section];
	
	//y ahora recuperamos la NSString asociada a la clave "bloque"
	NSString *bloqueLecCri = [dicEnTipoArticuloArray objectForKey:@"bloque"];
	
	//Devolvemos el valor anterior, que será el título de nuestra sección
	return bloqueLecCri;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	NSDictionary *dicSeccionesEnTipoArticulo = [tipoArtiPregArray objectAtIndex:section];
	NSArray *arrayPregDeLaSeccion = [dicSeccionesEnTipoArticulo objectForKey:@"preguntas"];
    	
	return [arrayPregDeLaSeccion count];
}

//INTENTO RESOLVER DEFINIENDO un solo TIPO DE CELDA.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSArray *arrayPregDeLaSeccion = [[tipoArtiPregArray objectAtIndex:indexPath.section] objectForKey:@"preguntas"];
    NSString * color = [[arrayPregDeLaSeccion objectAtIndex:indexPath.row] objectForKey:@"color"];

    // Each subview in the cell will be identified by a unique tag.
    static NSUInteger const kVistoBuenoTag = 5;
        
    // Declare references to the subviews which will display the earthquake data.
    UIImageView *vistoBueno = nil;
        
    static NSString *cellIdentifier2 = @"CellConVB";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    
    //Las limpia para reutilizar (si siempre se pueblan con datos nuevos no haría falta limpiar, pero los subtitulos por ejemplo hay celdas que los pueblan y optras que no, si reutilizamos una con subtitulo viejo y no lo limpiamos ni lo poblamos saldría el subtitulo viejo)
    cell.detailTextLabel.text = nil;
    vistoBueno = (UIImageView *)[cell.contentView viewWithTag:kVistoBuenoTag];
    
    // Ahora las rellena, ya sea celdas nuevas o reutilizadas
    NSString * literalC = [[arrayPregDeLaSeccion objectAtIndex:indexPath.row] objectForKey:@"literalC"];    
    NSString * caracter = [[arrayPregDeLaSeccion objectAtIndex:indexPath.row] objectForKey:@"caracter"];

    cell.textLabel.text = literalC;
    cell.detailTextLabel.text = caracter;
    
    if ([color isEqual:@"redColor"])            [vistoBueno setImage:[UIImage imageNamed:@"red"]];
    else if ([color isEqual:@"greenColor"])     [vistoBueno setImage:[UIImage imageNamed:@"green"]];
    else if ([color isEqual:@"yellowColor"])    [vistoBueno setImage:[UIImage imageNamed:@"yellow"]];
    else                                        [vistoBueno setImage:[UIImage imageNamed:@"white"]];
    
    //Ya la devuelve
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"PlantillaAPreg" sender:self];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PregViewController *pregVC = segue.destinationViewController;
    pregVC.delegate = self;

    /*Para poder pasar el numero de pregunta que sirva para apuntar al comentario concreto de esa pregunta, independientemente del "modelo": antes me basaba en capturar el número con el que empieza la pregunta (model) para identificar el comentario que le correspondía, esto exigía que las preguntas empezasen por "unNúmero.", que no hubiese dos con el mismo número (por ejmplo 6.A y 6.B), y en cualquier caso no respetaba el principio de MVC. 
     Para evitar estos inconvenientes: hacemos los siguientes cálculos que devuelven el número de orden de la pregunta pulsada:
        - siendo el menor 0, para que cumpla con los usos generales de numeración de las colecciones
        - siendo la numeración independiente del modelo, para respetar MVC y así ser más robusta ...
        - siendo la numeración contínua desde la primera preg a la última independientemente de las secciones que tenga, de rows por sección, ...
     Definicmos un múmero acumulativo (numeroPreg) que incrementa su valor de la siguiente manera: para las secciones inferiores a la de la row pulsada suma sus números de rows, y luego para la sección de la row pulsada suma las rows anteriores y la pulsada
     */
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    int numeroPreg = -1;
    int s;
    for (s = 0; s < indexPath.section; s++) {
        numeroPreg += [self.tableView numberOfRowsInSection:s];
    }
    
    if (s == indexPath.section) {
        for (int r = 0; r <= indexPath.row ; r++)   numeroPreg++;
    }

    NSArray *arrayPregDeLaSeccion = [[tipoArtiPregArray objectAtIndex:indexPath.section] objectForKey:@"preguntas"];
    NSString *literal = [[arrayPregDeLaSeccion objectAtIndex:indexPath.row] objectForKey:@"literal"];
    NSString *pista = [[arrayPregDeLaSeccion objectAtIndex:indexPath.row] objectForKey:@"pista"];
    
    pregVC.preguntaString = literal;
    pregVC.pistaString = pista;
    pregVC.celdaSeleccionadaP = indexPath;// Envía el indexPath de la celda pulsada para la notificación de vuelta con el color elegido por el usuario, y para identificar las celdas de la sección B que llevan textView
    pregVC.numeroComentario = numeroPreg;

    pregVC.laLectCrit = laLectCrit;
    pregVC.context = context;

    if (indexPath.section == 1) pregVC.plantillaID = laLectCrit.relacionRespuestas.plantillaID;

}

#pragma mark - Delegación de PregVC

- (void) respuestaEnDelegante:(NSDictionary *)dicRespuesta {
    NSIndexPath *celdaColoreada = [dicRespuesta objectForKey:@"celda"];
    NSString *colorEscogido = [dicRespuesta objectForKey:@"color"];
    
    //Condición if para que si está vacio recibeColor (se volvió de la pregunat sin marcar nada) no se aplique la instrucción siguiente porque da error.
    if (colorEscogido.length != 0) {//para meter en bucle sólo cuando colorEscogido no está vacio, un espacio ya es un valor
        [[[[tipoArtiPregArray objectAtIndex:celdaColoreada.section] objectForKey:@"preguntas"] objectAtIndex:celdaColoreada.row] setObject:colorEscogido forKey:@"color"];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

@end
