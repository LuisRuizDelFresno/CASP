//
//  GlosarioMenuViewController.m
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

#import "GlosarioMenuViewController.h"
#import "ModelGlosario.h"
#import "GlosarioDetalleViewController.h"

@implementation GlosarioMenuViewController

@synthesize glosarioArray, glosarioFiltradoArray, searchWasActive, titulosSeccion;

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //***************** TITULO
    self.title = NSLocalizedString(@"TituloGlosarioVC", nil);
    
    //***************** CARGA LOS DATOS DEL PLIST Y LE DA LA ESTRUCTURA MULTINIVEL, ORDENADOS, ...
    //CARGA LOS DATOS DEL PLIST EN UN ARRAY (cargaPlistArray), SACA EL DIC QUE TIENE EN SEGUNDO NIVEL (dicDelCargaPlistArray),
	//CREA INSTANCES DEL MODELGLOSARIO (unaGlosa) PARA ESOS DATOS, los va pasando por las claves del dic objetos Model (unaGlosa)
	//que se van sumando en un Array: glosarioBrutoArray (es plano, sólo tiene un nivel: las glosas, sin secciones)
    
    //Obtiene el path al plist de inglés,
    NSString *glosarioPath = [[NSBundle mainBundle] pathForResource:@"Glossary" ofType:@"plist"];
   
    //************* PARA SOLVENTAR EL PROBLEM CON LAS LANGUAGE IDS + REGION IDS DE IOS9
    NSArray<NSString *> *availableLanguages = @[@"en", @"es"];
    NSString *codigoIdioma = [[[NSBundle preferredLocalizationsFromArray:availableLanguages] firstObject] mutableCopy];
    
    //LA LINEA SIGUIENTE FUNCIONABA ANTES DE IOS9
    //NSString *codigoIdioma = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"Códgigo idioma %@", codigoIdioma);
    //********************
    
    //Si el codigo de idioma es "es" (español), cambia el path al del plist en español
    if ([codigoIdioma isEqualToString:@"es"]) {
        glosarioPath = [[NSBundle mainBundle] pathForResource:@"Glosario" ofType:@"plist"];
	}
        
	NSArray *cargaPlistArray;                                                       //especifica un Array para cargalos
	NSMutableArray *glosarioBrutoArray;                                             //especifica un MutableArray para contener las glosas
	if (glosarioPath && (cargaPlistArray = [NSArray arrayWithContentsOfFile:glosarioPath])) { //incializa el Array carga con el contenido del plist
		glosarioBrutoArray =[NSMutableArray arrayWithCapacity:1];                   //inicailiza el MutArray asig memo inicial para 1 item
		for (NSDictionary *dicDelCargaPlistArray in cargaPlistArray) {              //para cada dic del Array de carga...
			ModelGlosario *unaGlosa = [[ModelGlosario alloc] init];                  //...crea uan glosa según modelo del ModelGlosario...
			unaGlosa.termino = [dicDelCargaPlistArray objectForKey:@"Termino"];               //...
			unaGlosa.definicion = [dicDelCargaPlistArray objectForKey:@"Definicion"];
            unaGlosa.grupo = [dicDelCargaPlistArray objectForKey:@"Grupo"];                   //...
			[glosarioBrutoArray addObject:unaGlosa];                                          //...y añadela al MutArray
        }
	} else {
		return;
	}
    
    //AHORA YA TENEMOS UN ARRAY DE DIC EN FORMATO Q NECESITABAMOS (el de las glosas de ModelGlosario).
    //Falta ordenarlas alfabéticamente por término, ver cuantas secciones tendrá la tabla, numerarlas y empaquetarlas por sección (en un Array por cada sección o interior), y luego todas las secciones a su vez en un sólo paquete (array de secciones o exterior).
    
    //Crea una instancia compartida de UILocalizedIndexedCollation.
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //INCIALIZA UN MUTABLEARRAY QUE CONTENDRÁ LOS ARRAYS DE SECCIón
	self.glosarioArray = [NSMutableArray arrayWithCapacity:1];
    
    //Bucle para numerar cada glosa del glosarioBrutoArray, con el número de sección que le corresponda.
    //Crea otra instancia de ModelGlosario (glosaNumerada) con datos del glosarioBrutoArray;
    //para cada entrada collation la ordena según el campo termino y le asigna un número de sección (serán grupos de A-Z),
    //que luego se copia en el campo numeroSeccion de la entrada.
    for (ModelGlosario *glosaNumerada in glosarioBrutoArray) {
        NSInteger sect = [collation sectionForObject:glosaNumerada collationStringSelector:@selector(termino)];
        glosaNumerada.numeroSeccion = sect;
    }
    
    //Cuenta las secciones que hay numeradas y hace un arrayExterior temporal de la misma capacidad, al que le va añadiendo los arrays interiores (de momento vacios)
    NSInteger ultimaSeccion = [[collation sectionTitles] count];
    NSMutableArray *arrayExterior = [NSMutableArray arrayWithCapacity:ultimaSeccion];
    //Bucle para nueva sección numerada.
    //para cada nueva sección crea una arrayInterno (que esta vacio) y lo añade al externo.
    for (int i=0; i<=ultimaSeccion; i++) {
        NSMutableArray *arrayInterior = [NSMutableArray arrayWithCapacity:1];
        [arrayExterior addObject:arrayInterior];
    }
    
    //Bucle rellenar los arrayInteriores con sus respectivas glosaNumeradas.
    //Va rellenando los arrayInteriores ([arrayExterior objectAtIndex:glosaNumerada.numeroSeccion]) con las glosas numeradas.
    for (ModelGlosario *glosaNumerada in glosarioBrutoArray) {
        [(NSMutableArray *)[arrayExterior objectAtIndex:glosaNumerada.numeroSeccion] addObject:glosaNumerada];
    }
    
    //Bucle para ordenar las glosas dentro de cada array Interior.
    //Las ordena constituyendo un array interior final (seccionOrdenada) que va añadiendo al array exterior final (glosarioArray).
    for (NSMutableArray *arrayInterior in arrayExterior) {
        NSArray *seccionOrdenada = [collation sortedArrayFromArray:arrayInterior collationStringSelector:@selector(termino)];
        [self.glosarioArray addObject:seccionOrdenada];
    }
    
    //***************** OTRO ASUNTO: FILTRAR LAS GLOSAS HACIENDO UNA BÚSQUEDA
    //Crea el glosarioFiltradoArray con capacidad igual a la del glosario completo
    self.glosarioFiltradoArray = [NSMutableArray arrayWithCapacity:[self.glosarioArray count]];
    
    
    //*************** QUITO el código de restore search settings Y LA IVAR savedSearchTerm, lo puedes ver en la versión previa de CASP, pero parece que está incompleto porque no incluye la parte de guardar el término cuando se reciba un didReceivedMemoryWarning, ... Si quieres implementarlo podrias seguir el "Sample Code": Simple UISearchBar with State Restoration de Apple.

    //?*?*?*?*?*?*   ¿HACE FALTA ACTIVAR EL SCROLL? SE H DESACTIVADO EN OTRO SITIO.
    [self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
    
} // end of viewDidLoad

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //self.glosarioFiltradoArray = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

/*
 #pragma mark -
 #pragma mark Relacionado con la vista Flip
 
 - (void)info:(id)sender {
 InfoCASPeViewController *infoCASPeViewController =[[InfoCASPeViewController alloc] initWithNibName:@"InfoCASPeViewController" bundle:nil];
 infoCASPeViewController.delegate = self;    //establece que el delegado de la instancia que acabamos de crear es self: el VC actualmente al cargo en este punto, que es RootViewController
 infoCASPeViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
 [self presentModalViewController:infoCASPeViewController animated:YES];
 [infoCASPeViewController release];
 }
 
 - (void)infoCASPeViewControllerDidFinish:(InfoCASPeViewController *)infoCASPeViewController {
 [self dismissModalViewControllerAnimated:YES];
 }
 */

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [self.glosarioArray count];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {//Le quita el índice a la tabla de búsquedas.
        return nil;
    } else {
        
        //PARA EVITAR QUE CUANDO LOCALIZA EN ESPAÑOL, ponga una "CH" y la "LL" en el índice.
        //Si no existen no da error, pero para hacerlo más fino habría que condicionar esto a localización española.
        //Originalment lo que hacía era: return [collation sectionTitles]; pero collation es read-only y no se deja modificar directamente, por lo que hay que pasarlo lo que nos interesa de él a un array nuestro y retorna este modificado.
        //************* PARA SOLVENTAR EL PROBLEM CON LAS LANGUAGE IDS + REGION IDS DE IOS9
        NSArray<NSString *> *availableLanguages = @[@"en", @"es"];
        NSString *codigoIdioma = [[[NSBundle preferredLocalizationsFromArray:availableLanguages] firstObject] mutableCopy];
        
        //LA LINEA SIGUIENTE FUNCIONABA ANTES DE IOS9
        //NSString *codigoIdioma = [[NSLocale preferredLanguages] objectAtIndex:0];
        //NSLog(@"Códgigo idioma %@", codigoIdioma);
        //********************
        if ([codigoIdioma isEqualToString:@"es"]) {
            
            NSMutableArray *nuevosSectionTitles = [[NSMutableArray alloc] initWithArray:[[UILocalizedIndexedCollation currentCollation] sectionTitles]];
            [nuevosSectionTitles removeObject:@"CH"];
            [nuevosSectionTitles removeObject:@"LL"];
            return nuevosSectionTitles;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
            
        }
        
        //Cambio el return directo desde currentLocation por estas lineas para añadirle al array de los titulos @"{search}" en la posición 0, para que muestre la lupita, y adpatar el indice a mi espacio, intentando que entre entre las 2 barras sin abreviarse con puntos, ...
        /*
         //NSMutableArray *index = [[[NSMutableArray alloc] initWithArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]] autorelease]; // le pongo autorelease para solucionar un aviso de posible leak de memoria al analizar
         
         NSMutableArray *index = [[[NSMutableArray alloc] initWithObjects:@"{search}", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"Ñ", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil] autorelease];
         [index removeLastObject]; //insertObject:@"{search}" atIndex:0]; //index;  @"{search}"
         //titulosSeccion = [[NSMutableArray alloc] initWithArray:index];
         return index;
         */
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil; //Le quita los titulos de sección en la tabla de búsquedas
    } else if ([[self.glosarioArray objectAtIndex:section] count] > 0) {
        
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /*
     if (tableView == self.searchDisplayController.searchResultsTableView)
     {
     return [self.searchResults count];
     }
     else
     {
     return [self.products count];
     }
     */
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.glosarioFiltradoArray count];
        
    } else {
        return [[self.glosarioArray objectAtIndex:section] count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     //PARA PERSONALIZAR EL INDICE, EN ESTE CASO TAMAÑO DE FUENTE, TAMBIÉN SE PUEDE COLOR DE FONDO, ETC.
     for(UIView *view in [tableView subviews]) {
     if([[[view class] description] isEqualToString:@"UITableViewIndex"]) {
     [view performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:10]];
     }
     }
     */
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        static NSString *kCellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        ModelGlosario *glosaObj = [self.glosarioFiltradoArray objectAtIndex:indexPath.row];
        cell.textLabel.text = glosaObj.termino;
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell.
        ModelGlosario *glosaObj = [[self.glosarioArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = glosaObj.termino;
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     GlosarioDetalleViewController *glosarioDetalleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GlosarioDetalleVC"];
    
    ModelGlosario *glosaObj = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        glosaObj = [self.glosarioFiltradoArray objectAtIndex:indexPath.row];
    } else {
        glosaObj = [[self.glosarioArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
	glosarioDetalleViewController.terminoDetalle = glosaObj.termino;
	glosarioDetalleViewController.definicionDetalle = glosaObj.definicion;
    //NO ESTAMOS PASANDO EL GRUPO AL QUE PERTENECE, PENDIENTE DE DECISIÓN SOBRE SI VA A HABER ALGÚN LOGOTIPO, ...
    //EN LA VISTA DEFINICIONES QUE HAGA REFERENCIA AL TIPO DE ARTÍCULO AL QUE ES APLICABLE.
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:glosarioDetalleViewController animated:YES];
    
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText {
    
	[self.glosarioFiltradoArray removeAllObjects]; // First clear the filtered array.
    
    int i;
    NSMutableArray *glosarioArrayPlano = [[NSMutableArray alloc] initWithCapacity:1];
    for (i=0; i< glosarioArray.count; i++) {
        NSMutableArray *arrayInterno = [NSMutableArray arrayWithArray:[glosarioArray objectAtIndex:i]];
        [glosarioArrayPlano addObjectsFromArray:arrayInterno];
    }
    
    for (ModelGlosario *glosaObj in glosarioArrayPlano) {
        NSComparisonResult result = [glosaObj.termino compare:searchText
                                                      options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                        range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame) {
            [self.glosarioFiltradoArray addObject:glosaObj];
        }
    }
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
