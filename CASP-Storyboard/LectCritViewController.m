//
//  LectCritViewController.m
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 02/04/13.
//
//[self.tableView beginUpdates] ... [self.tableView endUpdates]; No da lo mismo que reloadData
//ESCONDER TECLADO:
//Funcion tocando en el botón escogido o en el fondo de la tabla si se asocia a un reconocedor de gestos, ... como pone en viewDidLoad.
//Creo que funciona tanto con textView como con textFields.
// Tomado de http://stackoverflow.com/questions/703754/how-to-dismiss-keyboard-for-uitextview-with-return-key, que a su vez cita a Source: Big Nerd Ranch
//Otra solución universales: tomada de nevyn en http://stackoverflow.com/questions/1823317/get-the-current-first-responder-without-using-a-private-api
//CÁLCULO DE ALTURAS, ...
/*
 1. LLama a heightForRowAtIndexPath lo primero y para cada row, por eso ahí se llama al texto de cada row y se llama al cálculo del tamaño del texto para un constrain que tiene un ancho (según tipo de celda - el margen externo que le demos) y una altura exagerada para que ajuste la altura. Si fuesemos a mostrar el texto en una UILabel ese altura del texto sería el la altura de la label, pero los UItextView tiene  un margen interno que hay que sumarle la altura del texto para que quede bien, luego altura final de la textview como mínimo tiene que ser la del texto + 2 x margen interno (además limitamos por debajo a 44 - márgenes externos para que las celdas no salgan inferiores a lo estandar. Esa altura de row (altura de la textview + márgenes externos), es la que devuelve heightForRowAtIndexPath, y además se almacena en alturasArray.
 2. La celda se tiene que configurar en cellForRow, tanto su contenido como las dimensiones de sus subviews (la Uitextview en este caso). Pero cellForRow es llamado después de height, aprovechando las alturas devuletas en height. Para ello cellForRow llama a asignaTextos:atIndexPath y este es el que le devuelve contenido para todas las rows y dimensiones de textview para las que tienen esa subview. El array de alturas de row que calculó height se utiliza en asignaTextos:atIndexPath para dimensionar los textviews.
 3. Cómo hacemos para que vaya ampliando el textview y la row al ir escribiendo en él: cuando escribe en un textview que ha delegado en este viewcontroller el viewcontroller va recibiendo notificaciones vía textViewDidChange; desde allí se recoge la row que se esta editando y se llama a height... mediante beginUpDate - endUpdate, en heigh se reclacula la altura a cada cambio y se actualia el alturasArray ...
 
*/


//!!!!!!!!!!!!!!!!!!!!!!!       CONVERTIR MANAGEDOBJECT -> DIC
//NSLog(@"EL DICCIONARIO de la subCLASE %@", [lecturaCritica toDictionary]);
//este diccionario probablemente ya podemos someterlo a compresión y envio en email
//y a la vuleta descomprimirlo y reconstituir un diccionario del que podemos formar un nuevo objeto con el siguiente método:

//!!!!!!!!!!!!!!!!!!!!!!!!      CONVERTIR DIC -> MANAGED OBJECT
//SManagedObjectContext* context = ... // your managed object context reference
//Person *anotherPerson = [ExtendedManagedObject createManagedObjectFromDictionary:personDict inContext:context];

//!!!!!!!!!!!!!!!!!!!!!!!      ACTUALIZAR LOS VALORES DE UN OBJETO YA EXISTENTE
//NSDictionary* personDict = ... // Your updated person dictionary (fetched from a web service, for example)
//NSManagedObject* person = ... // Fetch your Person managed object from a context

// Update the person managed object using data from the dicitonary
//[person populateFromDictionary:personDict];


#import "LectCritViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Revisor.h"
#import "Respuestas.h"
#import "Etiquetas.h"
#import "PalabrasClaveViewController.h"
#import "PlantillaDetalleViewController.h"
#import "ComentarioViewController.h"
#import "PDFDesdeLectura.h"
#import "TFHpple.h"
#import "SVProgressHUD.h"

@implementation LectCritViewController

@synthesize lecturaCritica, lecturaDuplicada, context, barraTeclado, miSegmentedControl, celdaActiva, alturasArray, textView100, textView101, textView102, plantillasMenuArray, indexNuevo, actionSheetFecha, fechaPicker, botonCancelar, pubMedBoton, indicadorActividad, documentController;

#define IS_WIDESCREEN               (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define CELL_MARGIN                 2.0f
#define MargenInternoTextView       8.0f
#define CELL_WIDTH_Grouped          295.0f
#define CELL_WIDTH_Grouped_Value2   215.0f
#define FONT_SIZE                   [UIFont boldSystemFontOfSize:17.0f]
#define VERDE_TEXTO                 [UIColor colorWithRed: 27.0/255.0 green: 100.0/255.0 blue: 23.0/255.0 alpha: 0.8]
#define kAlertViewBorrarLect        3
#define kAlertViewPubMed            5
#define kAlertViewSMS               6
#define kEscribeTag                 4
#define kActionSheetParaInicializarRespuestas 1
#define kActionSheetParaAcciones    2

#pragma mark - Inicialización y Memory Management

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //------------------------------------------------------------------------------------------
    // TITULO NAV BAR
    self.title = NSLocalizedString(@"Cita", nil);

    //------------------------------------------------------------------------------------------
    // PARA MOSTRAR U OCULTAR LA CELDA DE IMPORTAR LA CITA O ESCOGER FECHA
    rowDatePicker = FALSE;
    rowImportacion = FALSE;
    
    //------------------------------------------------------------------------------------------
    // PLANTILLAS ARRAY
    //1. Obtiene el path al plist de inglés, 2. Si el codigo de idioma es "es" (español), cambia el path al del plist en español. 3. Carga el plist que corresponda en plantillasMenuArray. 4. Las ordena según valor de la clave "corto"
    
    //1.
    NSString *plantillasPath = [[NSBundle mainBundle] pathForResource:@"PlantillasEn" ofType:@"plist"];
    //2.
    //************* PARA SOLVENTAR EL PROBLEM CON LAS LANGUAGE IDS + REGION IDS DE IOS9
    NSArray<NSString *> *availableLanguages = @[@"en", @"es"];
    NSString *codigoIdioma = [[[NSBundle preferredLocalizationsFromArray:availableLanguages] firstObject] mutableCopy];
    
    //LA LINEA SIGUIENTE FUNCIONABA ANTES DE IOS9
    //NSString *codigoIdioma = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"Códgigo idioma %@", codigoIdioma);
    //********************
    
    if ([codigoIdioma isEqualToString:@"es"]) plantillasPath = [[NSBundle mainBundle] pathForResource:@"Plantillas" ofType:@"plist"];
    //3.
    NSMutableArray *plantillasDesordenadoArray = [[NSMutableArray alloc] initWithContentsOfFile:plantillasPath];
    //4.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"corto" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *plantillasOrdenadasArray = [plantillasDesordenadoArray sortedArrayUsingDescriptors:sortDescriptors];
    plantillasMenuArray = [[NSArray alloc] initWithArray:plantillasOrdenadasArray];
    
    //------------------------------------------------------------------------------------------
    // PAra evita el error de que no encuentra un NSManagedObjetModel Etiquetas, tomado de stackoverflow.com/questions/1074539/passing-a-managedobjectcontext-to-a-second-view. Debe ir emparejado con la descarga del context de la memoria en viewDidUnload. viewDidUnload está deprecado desde iOS6
    if (context == nil) {
        context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"NO HABIA MANAGEDOBJECT CONTEXT DONDE DEBIA HABERLO: %s", __FUNCTION__);
    }
    
    //------------------------------------------------------------------------------------------
    //Botones derechos
    UIBarButtonItem *actionBotton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionSheetAcciones)];
    botonCancelar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [botonCancelar setEnabled:NO];
    self.navigationItem.rightBarButtonItems = @[botonCancelar, actionBotton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //------------------------------------------------------------------------------------------
    //PAra evita el error de que no encuentra un NSManagedObjetModel Etiquetas, tomado de stackoverflow.com/questions/1074539/passing-a-managedobjectcontext-to-a-second-view
    if (context == nil) {
        context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"SE REGENERA CONTEXT EN: %s", __FUNCTION__);
    }

    //------------------------------------------------------------------------------------------
    // Para actualizar la tabla Cuando vuelve de las etiquetas
    [self.tableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    // sirve para forzar que reclacule tamaños y se adapte a los cambios de la propiedad "comentario", que ocurren sin teclear directamente en su row. Ocurría cuando volvía de la calculadora incorporando texto en ella.
    alturasArray = nil;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    //------------------------------------------------------------------------------------------
    [self saveContext];
    
    //Esto debe ser una medida de ahorro de memoria, implica que en viewWillAppear se regenera el context
    self.context = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource & asigna textos y calcula tamaños a mostrar

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //Uso de switch como en listing 4-13 de la TableView Programming Guide (excepto que allí envuelve las instrucciones de cada case en llaves {}
    NSString *title;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"Referencia", nil);
            break;
        case 1:
            title = NSLocalizedString(@"Lectura Crítica", nil);
            break;
        case 2:
            title = NSLocalizedString(@"Comentarios", nil);
            break;
        case 3:
            title = NSLocalizedString(@"Revisor", nil);
            break;
        case 4:
            title = NSLocalizedString(@"Fecha", nil);
            break;
        case 5:
            title = NSLocalizedString(@"Etiquetas", nil);
            break;
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger numerorows = 1;
    switch (section) {
        case 0:            //Articulo: titulo, revista, PMID
            if (rowImportacion)  numerorows = 3;
            else                 numerorows = 2;
            break;
        case 1:             //Respuestas
            numerorows = 1;
            break;
        case 2:             //Comentario
            numerorows = 1;
            break;
        case 3:             //Revisor: nombre, e-mail
            numerorows = 2;
            break;
        case 4:             //Fecha
            if (rowDatePicker)  numerorows = 2;
            else                numerorows = 1;
            break;
        case 5:             //Eiquetas
            if ([lecturaCritica.relacionEtiquetas count] == 0)  numerorows = 1;
            else                                                numerorows = [lecturaCritica.relacionEtiquetas count] + 1;
            break;
    }
    
    return numerorows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //------------------------------------------------------------------------------------------
    // REUTILIZACIÓN O CREACIÓN DE LAS CELDAS.
    //para no tener problemas con la reutilización defino cellIdentificadores dsitintos para cada celda que tenga algo distinto de las demás que no va a cambiar al reutilizarla (el estilo base, una imagen, el centrado, ...), las propiedades que van a cambiar hay que cambiarlas al poblar la celda, ya sea para adjuducar un valor nuevo, o para sólamente eliminar el que pudiese existir de un uso anterior, y que ahora no interese.
    static NSString *celda100 = @"celdaLabelTextView100";
    static NSString *celda101 = @"celdaLabelTextView101";
    static NSString *celda102 = @"celdaLabelTextView102";
    static NSString *celda110 = @"celdaBasica110";
    static NSString *celda120 = @"celdaBasica120";
    static NSString *celda130 = @"celdaRightDet130";
    static NSString *celda140 = @"celdaBasica140";
    static NSString *celda141 = @"celdaDatePicker141";
    static NSString *celda150 = @"celdaEtiqueta150";
    static NSString *celda151 = @"celdaPieEtiqueta151";

    UITableViewCell *cell = nil;
    
    if (indexPath.row == lecturaCritica.relacionEtiquetas.count)   cell = [tableView dequeueReusableCellWithIdentifier:celda151];
    else                                                           cell = [tableView dequeueReusableCellWithIdentifier:celda150];

    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:celda100];
            
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:celda101];
            
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:celda102];
            
        }
        
    }     //Poner titulo propio y referencia bibliográfica
    
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:celda110];
        
        
    } //Asociarle una Plantilla lectura crítica
    else if (indexPath.section == 2){ //Comentario
        cell = [tableView dequeueReusableCellWithIdentifier:celda120];
        
    }
    else if (indexPath.section == 3) {    //Revisor
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:celda130];
        //Lo siguiente da el error que describe http://stackoverflow.com/questions/26895201/single-row-uitableview-doesnt-show-detailtextlabel-until-scroll No sé por qué, pero se soluciona así.
        //cell = [tableView dequeueReusableCellWithIdentifier:celda130];
        
        
    }
    else if (indexPath.section == 4){  //Fecha.
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:celda140];
            
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:celda141];
            
        }
        
    }
    else {        //Etiquetas
        if (indexPath.row == lecturaCritica.relacionEtiquetas.count)   cell = [tableView dequeueReusableCellWithIdentifier:celda151];
        else                                                           cell = [tableView dequeueReusableCellWithIdentifier:celda150];
        
    }
    
    /*
     - Al reutilizar Resetear los valores de texto, ... el contenido, no el alfa ni la selección, ...
     En este caso no hace falta salvo en las etiquetas, por que todas las demas celdas son únicas, realmente no se generan dos iguales excepto en etiquetas.
     - En prepareForReuse resetear otras características que no tengan que ver con los valores a mostrar: alfa, editing and selection state
     */
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //------------------------------------------------------------------------------------------
    //POBLAR LAS CELDAS: DARLE VALORES A SUS OBJETOS
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat heightResultado;
    
    //------------------------------------------------------------------------------------------
    //1. Si no existe alturasArray lo inicializa. Esto ocurre cuando va a formar la pantalla, y sólo al querer calcular la primera row (que curiosamente no es la (0,0))
    if (!alturasArray) {
        alturasArray = [[NSMutableArray alloc] initWithCapacity:1];
        NSInteger numeroSecciones = [self.tableView numberOfSections];
        for (int i = 0; i < numeroSecciones ; i++) {
            NSMutableArray *arraySeccion = [[NSMutableArray alloc] initWithCapacity:1];
            [alturasArray addObject:arraySeccion];
        }
    }
    
    //------------------------------------------------------------------------------------------
    //2. Busca el dic con los datos de la row concreta que está calculando.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(indice ==  %@)", indexPath];
    NSArray *filteredArray = [[alturasArray objectAtIndex:indexPath.section] filteredArrayUsingPredicate:predicate];
    
    if (filteredArray.count == 0)  {
        //3. Si no existía ese dic lo crea, y puebla u añade a alturasArray donde corresponda. Si es seccion de textView busca el texto, calcula alturaTetView y calcula la de la row añadiendo márgenes, como mínimo 44 (altura estándar de una row).
        
        NSMutableDictionary *unDic = [[NSMutableDictionary alloc] initWithCapacity:1];
        NSIndexPath *indiceNuevo;
        
        if (indexPath.section == 0 ) {
            NSString *elTexto = [self textoParaTextViewAtIndexPath:indexPath];
            CGFloat heightCalculada = [self calculaSoloAlturaTextView:elTexto atIndexPath:indexPath];
            
            indiceNuevo = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            heightResultado = heightCalculada + (CELL_MARGIN * 2);
            
        } else if (indexPath.section == 4 && indexPath.row == 1) {
            indiceNuevo = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            heightResultado = 216;
            
        } else {
        
            indiceNuevo = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            heightResultado = 44;
            
        }
        
        [unDic setObject:indiceNuevo forKey:@"indice"];
        [unDic setObject:[NSNumber numberWithFloat:heightResultado] forKey:@"altura"]; //EL ARRAY GUARDA ALTURAS DE LA ROW, no del textView
        
        [[alturasArray objectAtIndex:indexPath.section] addObject:unDic];
        
        NSSortDescriptor *ordenIntraSeccion = [[NSSortDescriptor alloc] initWithKey: @"indice" ascending: YES];
        [[alturasArray objectAtIndex:indexPath.section] sortedArrayUsingDescriptors:[NSArray arrayWithObject:ordenIntraSeccion]];
        
    } else {
        //Si ya existía: toma el valor
        
        CGFloat alturaAlmacenada = [[[filteredArray objectAtIndex:0] objectForKey:@"altura"] floatValue];
        heightResultado = alturaAlmacenada;
    
    }
    
    return heightResultado;
    
}

#pragma mark - Configuración de las celdas

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    /*
    //Sobre la conveniencia de este método http://stackoverflow.com/questions/5467831/why-do-programmers-use-configurecellatindexpath-method-to-config-the-tableview
    //Los textos que requieren calculo de tamaño (los de los textView), los obtiene por método aparte (porque habrá que obtenerlos de nuevo para heightForRow), y calcula su tamaño de textView necesario por método aparte (porque habrá que obtenerlo de nuevo para heightForRow)
    //Las únicas Label con valor son las de celdas-label-textview, las demás son de secciones de una sola row y el título de sección las define.
    */
    
    //------------------------------------------------------------------------------------------
    //REPARTE IDENTIFICACIONES EN LA SECCIÓN 0
    UILabel *laTextLabel;
    UITextView *elTextView;

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                elTextView = (UITextView *)[cell viewWithTag:100];
                laTextLabel = (UILabel *)[cell viewWithTag:1000];
                break;
            case 1:
                elTextView = (UITextView *)[cell viewWithTag:101];
                laTextLabel = (UILabel *)[cell viewWithTag:1010];
                [self dibujaTrianguloEnCelda:cell];
                break;
            case 2:
                elTextView = (UITextView *)[cell viewWithTag:102];
                break;
            default:
                break;
        }
    }
    
    //------------------------------------------------------------------------------------------
    //LABELS: ASIGNA VALORES
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            laTextLabel.text = NSLocalizedString(@"Título", nil);

        } else if (indexPath.row == 1) {
            laTextLabel.text = NSLocalizedString(@"Revista", nil);

        }

    }
    else if (indexPath.section == 1) {
        //No uso tags en esta celda porque es una celda básica que lleva su textlabel por defecto, creo que no le puedo cambiar la aunque parezca en el StoryBoard que sí.
        if (lecturaCritica.relacionRespuestas) {
            NSArray *filteredArray = [self obtienePlantillaUsada];
            if (filteredArray.count > 0) cell.textLabel.text = [[filteredArray objectAtIndex:0] objectForKey:@"corto"];
        } else  cell.textLabel.text = NSLocalizedString(@"Pulse aquí para crear una lectura crítica", nil);
        
        
    }
    else if (indexPath.section == 2) {
        if (!lecturaCritica.comentario.length)  cell.textLabel.text = NSLocalizedString(@"Escriba aquí sus comentarios", nil);
        else                                    cell.textLabel.text = lecturaCritica.comentario;

    }
    else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Nombre", nil);
                cell.detailTextLabel.text = lecturaCritica.relacionRevisor.revisorNombre;
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Correo", nil);
                cell.detailTextLabel.text = lecturaCritica.relacionRevisor.revisorEmail;
                break;
            default:
                break;
        }

    }
    else if (indexPath.section == 4 && indexPath.row == 0) {
            cell.textLabel.text = [self fechaFormateada:lecturaCritica.fecha];
        
    }
    else if (indexPath.section == 5) {
        //Queremos mostrar las etiquetas ordenadas alfabéticamente y marcar la etiqueta especificada en la lecCrit como índice para ordenar en secciones. Que la última row no tenga nada en la label detailtextlabel.
        NSSet *etiquetasSet = lecturaCritica.relacionEtiquetas;
        NSArray *etiquetasOrdenadas = [self ordenaPickedTags:etiquetasSet];

        if (indexPath.row < etiquetasSet.count) {
            Etiquetas *unaEtiqueta = [etiquetasOrdenadas objectAtIndex:indexPath.row];
            cell.textLabel.text = unaEtiqueta.etiquetaNombre;
            if ([[[etiquetasOrdenadas objectAtIndex:indexPath.row] etiquetaNombre] isEqual:lecturaCritica.etiquetaIndice]) {
                cell.detailTextLabel.text = NSLocalizedString(@"Índice", nil);
                
            } else {
                cell.detailTextLabel.text = @" ";
                
            }

        } else {
            cell.textLabel.text = NSLocalizedString(@"Modificar Etiquetas", nil);

        }

    }
 
    //------------------------------------------------------------------------------------------
    //TEXTVIEW: ASIGNA VALORES, LES DA ALTURA, CENTRA EL TEXTO Y LE DA COLOR
    elTextView.text = [self textoParaTextViewAtIndexPath:indexPath];

    CGRect frameNuevo = elTextView.frame;
    frameNuevo.size.height = [[[[alturasArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"altura"] floatValue];
    elTextView.frame = frameNuevo;
    
    //PARECE QUE NO HACE NADA
    [self centradoVerticalTextView:elTextView];

    [self colorDelTextoDeLaCelda:cell];

}

- (NSString *) textoParaTextViewAtIndexPath:(NSIndexPath *)indexPath {
    //Para alimentar de texto de textView en configuraCell y heightForRow ---------------------------------------------
    NSString *textoTextView = nil;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                if (!lecturaCritica.titulo.length)  textoTextView = NSLocalizedString(@"Escriba aquí el Título", nil);
                else                                textoTextView = lecturaCritica.titulo;
                break;
            case 1:
                if (!lecturaCritica.revista.length)  textoTextView = NSLocalizedString(@"Escriba aquí la Revista", nil);
                else                                textoTextView = lecturaCritica.revista;
                break;
            case 2:
                if (!lecturaCritica.pubmedID.length)  textoTextView = NSLocalizedString(@"Escriba aquí el PubMedID", nil);
                else                                textoTextView = lecturaCritica.pubmedID;
            default:
                break;
        }
        
    } /*else if (indexPath.section == 2) {
        if (!lecturaCritica.comentario.length)   textoTextView = NSLocalizedString(@"Escriba aquí sus comentarios", nil);
        else                                    textoTextView = lecturaCritica.comentario;

    }
    */
    return textoTextView;
}

- (void) dibujaTrianguloEnCelda:(UITableViewCell *)cell {

    UIImageView *anguloImagen = (UIImageView *)[cell viewWithTag:1011];
    
    //Sólo hace falta un triiángulo
    if (!rowImportacion) {
        [UIView animateWithDuration:0.25 animations:^{
            anguloImagen.transform = CGAffineTransformMakeRotation( 0 * M_PI  / 180);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            anguloImagen.transform = CGAffineTransformMakeRotation( 90 * M_PI  / 180);
        }];

    }
    
    /* //Sin animación, usando los dos set de imagenes
    if (!rowImportacion)    anguloImagen.image = [UIImage imageNamed:@"trianguloUp"];
    else                    anguloImagen.image = [UIImage imageNamed:@"trianguloDown"];
    */

}

- (NSString *) fechaFormateada:(NSDate *)date {
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMMYYYY"
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    
    NSString *stringDesdeDate = [dateFormatter stringFromDate:date];
    
    return stringDesdeDate;
    
}

- (void) colorDelTextoDeLaCelda:(UITableViewCell *)cell {
    //Creo que esto de tomar el valor de la View para darle color no debe estar conforme al MVC
    textView100 = (UITextView *)[cell viewWithTag:100];
    NSString *textoEstaRow = textView100.text;
    if ([textoEstaRow isEqual:NSLocalizedString(@"Escriba aquí el Título", nil)])   textView100.textColor = VERDE_TEXTO;
    else                                                                            textView100.textColor = [UIColor blackColor];

    textView101 = (UITextView *)[cell viewWithTag:101];
    NSString *textoEstaRoww = textView101.text;
    if ([textoEstaRoww isEqual:NSLocalizedString(@"Escriba aquí la Revista", nil)]) textView101.textColor = VERDE_TEXTO;
    else                                                                            textView101.textColor = [UIColor blackColor];

    textView102 = (UITextView *)[cell viewWithTag:102];
    NSString *textoEstaRowww = textView102.text;
    if ([textoEstaRowww isEqual:NSLocalizedString(@"Escriba aquí el PubMedID", nil)]) textView102.textColor = VERDE_TEXTO;
    else                                                                              textView102.textColor = [UIColor blackColor];
   
    if (cell.tag == 120) {
        NSString *textoCeldaComent = cell.textLabel.text;
        if ([textoCeldaComent isEqual:NSLocalizedString(@"Escriba aquí sus comentarios", nil)]) cell.textLabel.textColor = VERDE_TEXTO;
        else                                                                                    cell.textLabel.textColor = [UIColor blackColor];

    }

    if (cell.tag == 44) { // en esta celda le pongo una tag para facilitar el hacer referencia a ella en este punto (Antes hacía referencia a la tag de su Label (110) ¿mejora algo el referenciar la celda en vez de la label?
        NSString *textoTipoLectura = cell.textLabel.text;
        if ([textoTipoLectura isEqual:NSLocalizedString(@"Pulse aquí para crear una lectura crítica", nil)])    cell.textLabel.textColor = VERDE_TEXTO;
        else                                                                                                 cell.textLabel.textColor = [UIColor blackColor];

    }

}

//PARECE QUE NO HACE NADA
- (void) centradoVerticalTextView:(UITextView *)elTextView {
 
    if (elTextView.tag == 100) {
        elTextView.contentOffset = CGPointMake(0, -10);
    }

    //------------------------------------------------------------------------------------------
    //Tomado de imagineric.ericd.net/2011/03/10/ios-vertical-aligning-text-in-a-uitextview
    CGFloat topCorrect = (elTextView.bounds.size.height - elTextView.contentSize.height * elTextView.zoomScale)/2.0;
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    elTextView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
}

- (void) actualizaAlturaRowParaTexto:(NSString *)elTexto atIndexPath:(NSIndexPath *)elIndexPath {
    
    //5. Calcula las alturas de row
    CGFloat nuevaAlturaRow = [self calculaSoloAlturaTextView:elTexto atIndexPath:elIndexPath] + (CELL_MARGIN * 2);

    //6. Para actualizar alturasArray. Busca el dic con los datos de la row concreta que está calculando. Y le actualiza el valor
    NSNumber * alturaNumber = [NSNumber numberWithFloat:nuevaAlturaRow];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(indice ==  %@)", elIndexPath];
    NSArray *filteredArray = [[alturasArray objectAtIndex:elIndexPath.section] filteredArrayUsingPredicate:predicate];
    [[filteredArray objectAtIndex:0] setValue:alturaNumber forKey:@"altura"];
    
}

- (CGFloat) calculaSoloAlturaTextView:(NSString *)unTexto atIndexPath:(NSIndexPath *)unIndexPath {
    
    /*
    //Calcula la altura TEXTO por el método de constraint y compone el size de la TEXTVIEW con el ancho predefinido porque si no los anchos van cambiando según el cálculo por constraint
    =================================================================================================================
    =                                           CELL_MARGIN                                                         =
    =               |--------------------------------------------------------------------------------|              =
    =               |                           MargenInternoTextView                                |              =
    =               |                       .................................                        |              =
    = Storyboard    |                      .   Texto que ve el usuario     .                         | Storyboard   =
    =               | MargenInternoTextView .   Texto que ve el usuario     . MargenInternoTextView  |              =
    =               |                       .................................                        |              =
    =               |                           MargenInternoTextView                                |              =
    =               |--------------------------------------------------------------------------------|              =
    =                                           CELL_MARGIN                                                         =
    =================================================================================================================
    |                                           CELL_WIDTH_Grouped_...                                              |
    */

    CGFloat anchuraContenidoRow;
    if (unIndexPath.section == 0)   anchuraContenidoRow = 205;//CELL_WIDTH_Grouped_Value2;
    else                            anchuraContenidoRow = 271;//CELL_WIDTH_Grouped;
    CGSize constraint = CGSizeMake(anchuraContenidoRow - (MargenInternoTextView *2), 20000.0f); //- (CELL_MARGIN * 2)
    
    CGSize sizeTextoCalculado;
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributes = @{NSFontAttributeName : FONT_SIZE,
                                      NSParagraphStyleAttributeName : paragraphStyle};
    
    sizeTextoCalculado = [unTexto boundingRectWithSize:constraint
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes
                                                context:nil].size;
    
    CGFloat heightTextViewCalculado = MIN(MAX(sizeTextoCalculado.height + (MargenInternoTextView * 3), 44 - (CELL_MARGIN *2)), 135);

    //Debería ser MargenInternoTextView * 2. Pero es que parece que se queda corto para la última línea
    return heightTextViewCalculado;
    
}

- (NSArray *)ordenaPickedTags:(NSSet *)pickedTags{
    //Ordeno las etiquetas antes de mostrarlas, porque no las puedo guardar ordenadas en un set que es como van en el model object. Tiene la lógica de que el orden es una cuestión de la view no del model.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"etiquetaNombre" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; //criterio bien definido
    
    NSArray *pickedTagsOrdenadasArray = [pickedTags sortedArrayUsingDescriptors:sortDescriptors]; // Lo ordena bien siempre.
    
    return pickedTagsOrdenadasArray;
}

- (NSArray *)obtienePlantillaUsada {
    //Obtiene el dic con los datos de la plantilla con la que se hizo previamente la Lectura, sea en el idioma que sea; para ello reune todos los menus de plantillas posibles en un array y busca en él el que se usó cuando se hizo la lectura
    NSString *plantillasEnPath = [[NSBundle mainBundle] pathForResource:@"PlantillasEn" ofType:@"plist"];
    NSString *plantillasEsPath = [[NSBundle mainBundle] pathForResource:@"Plantillas" ofType:@"plist"];
    NSMutableArray *plantillasTotal = [NSMutableArray arrayWithContentsOfFile:plantillasEnPath];
    [plantillasTotal addObjectsFromArray:[NSArray arrayWithContentsOfFile:plantillasEsPath]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID ==  %@", lecturaCritica.relacionRespuestas.plantillaID];
    NSArray *filteredArray = [plantillasTotal filteredArrayUsingPredicate:predicate];
    
    return filteredArray;
}

#pragma mark - TableView Delegate & ActionSheet y AlertView desencadenados por la row seleccionada

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        
        //DESPLIEGA O PLIEGA LA ROW OCULTAS
        //Hacer 2 cosas: desplegar_recoger la row 2 de la seccion 0 + invertir el triangulito de la row 1.
        //Para cada una de esa acciones aisladas no hace falta el bloque de beginUpdates ... endUpdates. Pero para hacerlo conjuntamente sí:
        [self.tableView beginUpdates];
        
        if (!rowImportacion ) {
            rowImportacion = TRUE;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

        } else {
            rowImportacion = FALSE;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

        }
        
        NSIndexPath *indexPath01 = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *celdaRow01 = [self.tableView cellForRowAtIndexPath:indexPath01];
        [self configureCell:celdaRow01 atIndexPath:indexPath01];
        
        [self.tableView endUpdates];
        
    }
    else if (indexPath.section == 1) {
        
        //************ INICIALIZAR PLANTILLAS
        //Si no tenía respuestas: nos lleva a AlertViwew para conforma creación. O si ya tenía plantilla asignada: nos lleva a ella, seleccionando el plsit de preguntas correcto en base al valor de tipoArt: con el valor de tipArt busca en el menú de plantillas (plantillasMenuArray) el nombre corto, largo ... de la plantilla de interés, y en le siguiente ViewController (plantillasDetalleVC) con el nombre largo se busca el plist de preguntas que interesa
        //1.
        
        if (!lecturaCritica.relacionRespuestas) {
            [self actionSheetParaInicializarRespuestas];
            
        } else {
            //Quiere leer / modificar la lectura previa
            [self performSegueWithIdentifier:@"LectAPlantilla" sender:self];
            
        }
    }
    
    else if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"LectAComentario" sender:self];

    }
    
    else if (indexPath.section == 3) {
        NSLog(@"Que traes en Revisor mail %@", lecturaCritica.relacionRevisor.revisorEmail); //"No especificado"  "Not specified"
        if ([lecturaCritica.relacionRevisor.revisorEmail isEqualToString:NSLocalizedString(@"No especificado", nil)]) {
            UIAlertView *unaAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Revisor por Defecto", nil)
                                                                   message:NSLocalizedString(@"Si quiere modificar sus datos, puede hacerlo en Ajustes", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"De acuerdo", nil)
                                                         otherButtonTitles:nil, nil];
            [unaAlertView show];
            
        } else {
            if ((indexPath.row == 1) && (lecturaCritica.relacionRevisor.revisorEmail)) {
                MFMailComposeViewController *mensajeMail = [[MFMailComposeViewController alloc] init];
                [mensajeMail setSubject:NSLocalizedString(@"Una Lectura Crítica", nil)];
                [mensajeMail setToRecipients:[NSArray arrayWithObject:lecturaCritica.relacionRevisor.revisorEmail]];
                [mensajeMail setMailComposeDelegate:self];
                [self presentViewController:mensajeMail animated:YES completion:nil];
                
            } else {
                UIAlertView *unaAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Revisor por Defecto", nil)
                                                                       message:NSLocalizedString(@"Si quiere modificar sus datos, puede hacerlo en Ajustes", nil)
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"De acuerdo", nil)
                                                             otherButtonTitles:nil, nil];
                [unaAlertView show];

            }
        }
        
    } else if (indexPath.section == 4 && indexPath.row == 0) {
        
        NSArray *datePickerIndexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:4]];
                                                 
        [self.tableView beginUpdates];

        if (!rowDatePicker) {
            rowDatePicker = TRUE;
            [self.tableView insertRowsAtIndexPaths:datePickerIndexPathArray withRowAnimation:UITableViewRowAnimationFade];

        } else {
            rowDatePicker = FALSE;
            [self.tableView deleteRowsAtIndexPaths:datePickerIndexPathArray withRowAnimation:UITableViewRowAnimationFade];
                
        }
        
        [self.tableView endUpdates];
        
        //Hay que esperar a que termine de actualizar la tabla para poder desplazarla en función de la fila nueva.
        if ([self.tableView numberOfRowsInSection:4] == 2) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] animated:YES scrollPosition:UITableViewScrollPositionMiddle];

        }

    }
    else if (indexPath.section == 5) {
        
        if (indexPath.row == lecturaCritica.relacionEtiquetas.count) {
            [self performSegueWithIdentifier:@"LectAPalabra" sender:self];
            
        }
        else {
            //Hay que comparar la etiqueta seleccionada con el valor en etiquetaIndice de la lectura crítica
            //Si son la misma: poner UnIndexed en el valor del atributo etiquetaIndice.
            //Si son distintas: poner Index en  el valor del atributo etiquetaIndice
            //Reload la sección y eso actualiza la detailLabel
            
            NSSet *etiquetasSet = lecturaCritica.relacionEtiquetas;
            NSArray *etiquetasOrdenadas = [self ordenaPickedTags:etiquetasSet];
            
            Etiquetas *etiquetaSeleccionada = (Etiquetas *)[etiquetasOrdenadas objectAtIndex:indexPath.row];
            if ([etiquetaSeleccionada.etiquetaNombre isEqual:lecturaCritica.etiquetaIndice]) {
                lecturaCritica.etiquetaIndice = NSLocalizedString(@"EtiquetaIndicePorDefecto", nil);
                
            }
            else {
                lecturaCritica.etiquetaIndice = etiquetaSeleccionada.etiquetaNombre;
                
            }
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];

        }
        
    } 
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"LectAPlantilla"]) {
        PlantillaDetalleViewController *plantillaDetalleViewController = segue.destinationViewController;
        
        NSArray *plantillaSeleccionada = [self obtienePlantillaUsada];
        
        plantillaDetalleViewController.nombrePlantillaCorto     = [[plantillaSeleccionada objectAtIndex:0] objectForKey:@"corto"];
        plantillaDetalleViewController.plantillaID              = [[plantillaSeleccionada objectAtIndex:0] objectForKey:@"ID"];
        plantillaDetalleViewController.context                  = self.context;
        plantillaDetalleViewController.laLectCrit               = lecturaCritica;
        
    } else if ([segue.identifier isEqualToString:@"LectAPalabra"]) {
        PalabrasClaveViewController *palabrasClaveVC = segue.destinationViewController;
        palabrasClaveVC.context = self.context;
        palabrasClaveVC.lecturaCritica = self.lecturaCritica;
        
    } else if ([segue.identifier isEqualToString:@"LectAComentario"]) {
        ComentarioViewController *comenarioVC = segue.destinationViewController;
        comenarioVC.context = self.context;
        comenarioVC.lecturaCritica = self.lecturaCritica;
    }
}

-(void)actionSheetParaInicializarRespuestas {
    //Hace los mismo que la pulsa en mod edición: inicia el proceso de escoger un plantilla y rellenarla
    //Configurar la ActionSheet usando un array para los botones (para faciliatr la abstracción, localización)
    UIActionSheet *myActionSheet;
    myActionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Creando una L Crítica Nueva", nil)
                                               delegate:self
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    
    myActionSheet.tag = kActionSheetParaInicializarRespuestas;
    //Extrae un array de strings para darle nombre a los botones de la actionSheet
    for (NSDictionary *unDic in plantillasMenuArray) {
        [myActionSheet addButtonWithTitle:[unDic objectForKey:@"corto"]];
    }
    
    [myActionSheet addButtonWithTitle:NSLocalizedString(@"Cancelar", nil)];
    myActionSheet.cancelButtonIndex = plantillasMenuArray.count;
    
    myActionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [myActionSheet showFromTabBar:self.tabBarController.tabBar];

}

-(IBAction)fechaEscogida:(UIDatePicker *)sender {
    lecturaCritica.fecha = sender.date;
        
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
    
}

-(IBAction)guardaFecha:(id)sender {
    [self saveContext];
    [self dismissActionSheetFecha];
    
}

-(IBAction)cancelaFecha:(id)sender {
    [context refreshObject:lecturaCritica mergeChanges:NO];
    [self dismissActionSheetFecha];
    
}

-(void)dismissActionSheetFecha {
    [actionSheetFecha dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)gestosEnFondoDeTabla:(BOOL)gestosSiNo {
    
    //********************** RELATIVO A TEXTFIELD Y TECLADO
    //Para que si está editando un textview, si toca en la tabla, desaparezca el telado. La 3ª linea es para que respete los toques que se produzcan en celdas sin textviews
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(esconderTeclado)];
    tapGestureRecognizer.cancelsTouchesInView = NO;

    if (gestosSiNo){
        [self.tableView addGestureRecognizer:tapGestureRecognizer];
        
    } else {
        [self.tableView removeGestureRecognizer:[self.tableView.gestureRecognizers lastObject]];
        //Elimina el último reconocedor de gestos que es que añadió, (tiene otros 4 reconocedores más)
    }
    
}

#pragma mark -
#pragma mark TextView Delegate & scroll cuando sube el KeyBoard

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    //¿ HACE FALTA ? para el juego de pasar de una celda a la siguiente o la anterior -------------------
    celdaActiva = (UITableViewCell *)[[textView superview] superview];

    [self.tableView beginUpdates];
    
    //PARA SIMULAR PLACEHOLDER. Si tiene el texto-por-defecto lo elimina --------------------------------
    NSIndexPath *indexPath;
    if (textView.tag == 100) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if ([textView.text isEqual:NSLocalizedString(@"Escriba aquí el Título", nil)]) {
            textView.text = @"";
        }
        
    } else if (textView.tag == 101) {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        if ([textView.text isEqual:NSLocalizedString(@"Escriba aquí la Revista", nil)]) {
            textView.text = @"";
        }
        
    } else if (textView.tag == 102) {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        if ([textView.text isEqual:NSLocalizedString(@"Escriba aquí el PubMedID", nil)]) {
            textView.text = @"";
        }
        
    } 
    
    //Para dar color verde a lo que queremos que sea placeholder y negro a otros textos. -------------------
    UITableViewCell *cell = (UITableViewCell *)[[textView superview] superview];
    [self colorDelTextoDeLaCelda:cell];
    
    //DA La altura del textView hay que dársela aquí, y MODIF el ARRAy de alturas de row -------------------
    CGFloat heightTextViewCalculado = [self calculaSoloAlturaTextView:textView.text atIndexPath:indexPath];
    
    //3.Le asigna al textview el valor calculado
    CGRect frame = textView.frame;
    frame.size.height = heightTextViewCalculado;
    textView.frame = frame;
    
    //5. Actualiza alturasArray
    [self actualizaAlturaRowParaTexto:textView.text atIndexPath:indexPath];
    
    //4. Centrar el texto en el textview ------------------------------------------------------------------
    //PARECE QUE NO HACE NADA
    //[self centradoVerticalTextView:textView];
    
    // =========
    //ESTO FUNCIONA BIEN LA SEGUNDA VEZ QUE ENTRA NE LE TEXTVIEW LARGO Y SIGUIENTES. PERO NO LA PRIMERA ¿?

    //[self performSelector:@selector(scrollToCursorForTextView:) withObject:textView afterDelay:0]; //-------

    [self gestosEnFondoDeTabla:YES]; // --------------------------------------------------------------------
    
    [self.tableView endUpdates];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    //Prepara la tabla para añadir, quitar o mover filas, ... You should not call reloadData within the group; if you call this method within the group, you will need to perform any animations yourself.
    //En cada cambio del contenido del textview llamará a heightForRow,...
    [self.tableView beginUpdates];
    
    NSIndexPath *indexPath = nil;
    if (textView.tag == 100)        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    else if (textView.tag == 101)   indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    else if (textView.tag == 102)   indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    else if (textView.tag == 120)   indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    
    CGFloat heightTextViewCalculado = [self calculaSoloAlturaTextView:textView.text atIndexPath:indexPath];
    
    //3.Le asigna al textview el valor calculado
    CGRect frame = textView.frame;
    frame.size.height = heightTextViewCalculado;
    textView.frame = frame;

    //4. Centrar el texto en el textview
    //PARECE QUE NO HACE NADA
    //[self centradoVerticalTextView:textView];
    
    //Actualiza alturasArray
    [self actualizaAlturaRowParaTexto:textView.text atIndexPath:indexPath];

    UITableViewCell *cell = (UITableViewCell *)[[textView superview] superview];
    //Llamo a los métodos de recolocar triángulo y botón de esta forma para ofrzar que se ponen en la cola de métodos a ejecutar y no son canibalizados por la ejecución de otros más prioritarios, aunque el retraso de 0 parece inutil, asegura que se ejecutaa detras de lo prioritario. debe haber otra forma mejor de poner en queue
    if ([[self.tableView indexPathForCell:cell] isEqual:[NSIndexPath indexPathForRow:1 inSection:0]]) {
        [self performSelector:@selector(dibujaTrianguloEnCelda:) withObject:cell afterDelay:1];
        
    }
    
    //Para activar el botón cancel en textviewDidEndEditing
    textoCambio = 1;
    
    //Para que siga al cursor
    //[self performSelector:@selector(scrollToCursorForTextView:) withObject:textView afterDelay:0];

    //Para que heightForRow se dispare y use las alturas de row actualizadas
    [self.tableView endUpdates];
    
}

- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    /*
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        //NSLog(@"NOOO ES VISIBLE");
        cursorRect.size.height += 20; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
        
    } //else NSLog(@"IT'S VISIBLE");
     */
}

- (BOOL)rectVisible: (CGRect)rect {
    
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    //NSLog(@"ContetOffset %@\n Rango de Alturas visibles %0.0f a %0.0f", NSStringFromCGPoint(self.tableView.contentOffset), visibleRect.origin.y, visibleRect.size.height + visibleRect.origin.y);
    
    return CGRectContainsRect(visibleRect, rect);

}

- (void)textViewDidEndEditing:(UITextView *)textView {

    //JUEGO PLACEHOLDERS En cada textview: ---------------------------------------------------------------
        //si está vacio le coloca el texto placeholder pero no copia ese contenido en el objeto de coredata.
        //Si no está vacio y es distitnto al placeholder entonces lo guarda en el objeto
    [self.tableView beginUpdates];
    
    NSIndexPath *indexPath;
    if (textView.tag == 100) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (textView.text.length == 0) {
            textView.text = NSLocalizedString(@"Escriba aquí el Título", nil);
            
        } else {
            if (![textView.text isEqual:NSLocalizedString(@"Escriba aquí el Título", nil)]) lecturaCritica.titulo = textView.text;

        }

    } else if (textView.tag == 101) {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        if (textView.text.length == 0) {
            textView.text = NSLocalizedString(@"Escriba aquí la Revista", nil);
            lecturaCritica.revista = nil;

        } else {
            if (![textView.text isEqual:NSLocalizedString(@"Escriba aquí la Revista", nil)]) {
                lecturaCritica.revista = textView.text;
                
            }
            
        }
        
    } else if (textView.tag == 102) {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        if (textView.text.length == 0) {
            textView.text = NSLocalizedString(@"Escriba aquí el PubMedID", nil);
            lecturaCritica.pubmedID = nil;
            
        } else {
            if (![textView.text isEqual:NSLocalizedString(@"Escriba aquí el PubMedID", nil)]) {
                lecturaCritica.pubmedID = textView.text;

            }
        }

    } 
    
    //  ---------------------------------------------------------------------------------------------
    //DA La altura del textView hay que dársela aquí, y MODIF el ARRAy de alturas de row
    CGFloat heightTextViewCalculado = [self calculaSoloAlturaTextView:textView.text atIndexPath:indexPath];
    
    //3.Le asigna al textview el valor calculado
    CGRect frame = textView.frame;
    frame.size.height = heightTextViewCalculado;
    textView.frame = frame;
    
    //4. Centrar el texto en el textview
    //PARECE QUE NO HACE NADA
    [self centradoVerticalTextView:textView];
    
    //5. Actualiza alturasArray
    [self actualizaAlturaRowParaTexto:textView.text atIndexPath:indexPath];

    //Para que coloree los textos
    [self colorDelTextoDeLaCelda:celdaActiva];
    
    //para evitar que la tabla pueda hacer un scroll exagerado hacia arriba después de editar, volvemos a dimensionar el contentInset a lo estándar. QUITAR junto con la instrucción de modificar el inset en textViewDidBeginEditing
    //self.tableView.contentInset = UIEdgeInsetsZero;
    
    [self gestosEnFondoDeTabla:NO];
    
    if (textoCambio)     [botonCancelar setEnabled:YES];

    [self.tableView endUpdates];

}

- (void)esconderTeclado {
    
    [[self view] endEditing:YES];
    
}

#pragma mark - Botones y Acciones desencadenadas

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

- (void)cancel {
    
    [botonCancelar setEnabled:NO];
    [context refreshObject:lecturaCritica mergeChanges:NO];
    [self.tableView reloadData];
    
}

- (void)actionSheetAcciones {
    
    UIActionSheet *myActionSheet;
    myActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"TituloActionSheetAcciones", nil)
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Cancelar", nil)
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:NSLocalizedString(@"Duplicar", nil), NSLocalizedString(@"Enviar por correo", nil), NSLocalizedString(@"Guardar como PDF", nil), NSLocalizedString(@"Borrar esta Lectura", nil), nil];
    
    myActionSheet.tag = kActionSheetParaAcciones;
    myActionSheet.destructiveButtonIndex = 3;

    myActionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [myActionSheet showFromTabBar:self.tabBarController.tabBar];
    
}

- (void)duplicarObjeto {
    
    //Para mostrar un objeto copia parcial (quitando el tipo de artículo, las respuestas, comentarios y etiquetas; dejando los datos de la referencia; y actualizando fecha y revisor)
    //1. Crear un objeto raiz nuevo.
    //2. Poblar la copia como deseamos: pasarle los valores que queremos mantener dle original, poblar nuevos los que queremos que sean nuevos y dejando el resto en por defecto.
    //3. Asignar a la ivar lecturaCrítica el duplicado y guardar
    
    //1.
    lecturaDuplicada = [NSEntityDescription insertNewObjectForEntityForName:@"LectCrit" inManagedObjectContext:context];
    
    if (lecturaCritica.titulo)   lecturaDuplicada.titulo = [NSString stringWithFormat:@"%@", lecturaCritica.titulo];
    if (lecturaCritica.revista)   lecturaDuplicada.revista = lecturaCritica.revista;
    if (lecturaCritica.pubmedID)   lecturaDuplicada.pubmedID = lecturaCritica.pubmedID;

    lecturaDuplicada.tipoArt = NSLocalizedString(@"Pendiente de Lectura", nil); //NO le damos valores a relacionRespuesta

    lecturaDuplicada.comentario = NSLocalizedString(@"Escriba aquí sus comentarios", nil);

    lecturaDuplicada.etiquetaIndice = NSLocalizedString(@"EtiquetaIndicePorDefecto", nil);

    //Revisor No crear un nuevo objeto y darle mis valores o los que sean, porque iriamos creando objetos duplicados con los datos de un mismo revisor, ... sino pasarle el revisor del original a la copia (que es la que se queda guardada como si fuera el original), y asignarle a al original el revisor por defecto del dispositivo. o más perfecto terminar de configurar una revisorID y usar esa ID en vez del nombfre.
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
    
    lecturaDuplicada.relacionRevisor = [array objectAtIndex:0];
    
    //Fecha: lo mismo del revisor, pasar a la copia la fecha del original (porque quedará como original) y asignarle al original la actual (porque quedará como copia)
    lecturaDuplicada.fecha = [NSDate date];

    lecturaDuplicada.etiquetaIndice = NSLocalizedString(@"EtiquetaIndicePorDefecto", nil);

    lecturaCritica = lecturaDuplicada;
    
    [self saveContext];
    
    [self.tableView reloadData];
    
}

-(void)enviarViaEmailLecturaCritica:(LectCrit *)laLecturaCritica {
    
    //Para enviar como un objeto de CASP lo pasamos a JSON antes.
    
    NSData *dataJson = [laLecturaCritica exportToNSData];
    NSString *objetoAdjuntoNombre = [NSString stringWithFormat:@"%@.casp", laLecturaCritica.titulo];
    
    MFMailComposeViewController *mensajeMail = [[MFMailComposeViewController alloc] init];
    [mensajeMail setMailComposeDelegate:self];
    [mensajeMail setSubject:NSLocalizedString(@"Una Lectura Crítica", nil)];
    [mensajeMail setToRecipients:[NSArray array]];
    [mensajeMail setMessageBody:NSLocalizedString(@"¡Revise esta Lectura Crítica! Necesitará tener instalada CASP, luego pulse en el icono para abrirla.", nil) isHTML:NO];

    if (dataJson != nil) {
        [mensajeMail addAttachmentData:dataJson mimeType:@"application/casp" fileName:objetoAdjuntoNombre];
    }
    
    //Para adjuntarlo también en pdf. Lo convierte en texto aquí y le pasa el texto a otra clase para que haga la conversión y lo guarde en Documents: desde allí lo puedo adjuntar al mail o pasar al iBooks, ...
    NSData *dataPDF = [self generaPdfLecturaCritica:laLecturaCritica];
        
    [mensajeMail addAttachmentData:dataPDF
                          mimeType:@"application/pdf"
                          fileName:[NSString stringWithFormat:@"%@.pdf", laLecturaCritica.titulo]];
    
    
    [self presentViewController:mensajeMail animated:YES completion:nil];
    
}

- (NSData *)generaPdfLecturaCritica:(LectCrit *)laLecturaCritica {
    
    PDFDesdeLectura *pdfCreador = [[PDFDesdeLectura alloc] initConLectura:laLecturaCritica];
    
    NSData *dataPDF = [pdfCreador formaDataPDFDesdeDiccionario];
    
    return dataPDF;
}

- (void)enviarPdfOtrasApp:(LectCrit *)laLecturaCritica {
    NSData * dataPDF = [self generaPdfLecturaCritica:laLecturaCritica];
    NSString * titulo = [NSString stringWithFormat:@"%@.pdf", laLecturaCritica.titulo];
    
    //El Path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:titulo];
    
    if(dataPDF) {
        [dataPDF writeToFile:pdfFileName atomically:NO];
    }
    else            NSLog(@"No hay dataPDF");
    
    NSURL *url = [NSURL fileURLWithPath:pdfFileName];
    
    //use the UIDocInteractionController API to get list of devices that support the file type
    documentController = [UIDocumentInteractionController interactionControllerWithURL:url]; //OK
    
    documentController.delegate = self;                                                                                       //OK
    documentController.UTI = @"com.adobe.pdf";
    //present a drop down list of the apps that support the file type, click an item in the list will open that app while passing in the file.
    [documentController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];

}

- (void)botonBorrar {
    
    UIAlertView *alertViewBorrar = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"¿Quiere borrar está lectura?", nil)
                                                              message:NSLocalizedString(@"Pulsando Sí la borrará de forma definitiva", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                    otherButtonTitles:NSLocalizedString(@"Sí", nil), nil];
    alertViewBorrar.tag = kAlertViewBorrarLect;
    [alertViewBorrar show];
    
}

#pragma mark  - Importar un PubMed
- (IBAction)importarUnPubMed:(id)sender {
    
    /*
     Descarga en segundo plano utilizando una queue de Grand Central Dispatch, siguiendo el ejemplo de ScaryBugs http://www.raywenderlich.com/es/18135/como-crear-una-aplicacion-simple-para-iphone-en-ios-5-parte-33. 
     Del mismo ejemplo tomo el indicador de actividad SVProgressHUD, que a su vez lo descarga de https://github.com/samvermette/SVProgressHUD
     Dentro de la cola concurrente abierta con GrandCentralDispatch ejecuta el parseo de HTML de PubMed, lo hace en un block of code.
     //1. Inicializa el objeto que va a formar
     //2. Envuelve la página web cargada en un objeto NSData para pasárselo al parseador que formará un array multinivel con él
     //3. Le decimos que busque el nodo donde está el título (que es la única cosa en la página que tiene estilo h2). Aunque es un nodo terminal, lo que devuelve el parser es un array  de elemntos TFHplle (tantos como objetos haya en la página web con estilo h2, en nuestro caso el título es lo único, lueog hay un sólo elemento TFHpple).
     
     //4. Ese elemento TFHpple, aunque cuando se ve lo que representa en formato html, parece que es un punto terminal, en estructura TFHpple es un array que tiene 2 elementos: su tagName (h2 en este caso), y lo que contiene que tiene estructura de objeto TFHpple con 2 propiedades: tagName y content (lo que nos interesa), parecen un diccionario al sacarlo por consola, pero no se recuperan con métodos de diccionario sino como las propiedades de un objeto.
     
     //5. Vamos a buscar los autores. construimos una string con el path a la etiqueta que los marca, que forme el array de todos los que haya (solo hay uno en nuestro caso), forma un elemento TFHpple y si efectivamente estamos al final de esa rama, en el primer hijo el content será lo que queremos.
     
     //6. Vamos a por titulo y por Revista
     //7. Vamos por la PubMedID. Aquí hay dos elementos en la webpage con la etiqueta div class="ids". El que nos interesa es el primero, pero este a su vez se compone de varias cosas (hijos). El que no interesa tiene la etiqueta span. Dentro de la cadena que contiene viene primero el numero de PubMedID seguido de un espacio y una frase entre corchetes, la dividimos esa cadena mediante los espacios y escogemos sólo el primer elemento.
     //8. Le da valor  de Favoritos y de perteneciente a misPubMed
     //9. Muestra modalemnte edit pasándole este objeto, para que el usuario ponga palabra clave y comentario, guarde o no.
     */
    
    //0
    NSURL *pubMedURL;
    if ([lecturaCritica.pubmedID rangeOfString:@"/"].location == NSNotFound) {
        pubMedURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/m/pubmed/%@", lecturaCritica.pubmedID]];

    } else {
        NSString *doiCodificadoParaURL = [lecturaCritica.pubmedID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        pubMedURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/m/pubmed/?term=%@", doiCodificadoParaURL]];

    }
    
    NSMutableString *referenciaFinalString = [NSMutableString string];

    // 1) Muestra el estado 
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Descargando", nil) maskType:SVProgressHUDMaskTypeBlack];
    
    // 2) Obtiene una cola concurrente del sistema
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // 3) Carga el selector en segundo plano
    dispatch_async(concurrentQueue, ^{

        //2
        NSData *pubMedData = [NSData dataWithContentsOfURL:pubMedURL];
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:pubMedData];
        
        //NSString *dataString = [[NSString alloc] initWithData:pubMedData encoding:NSUTF8StringEncoding];
        //NSLog(@"NSDATA %@", dataString);
        //3.         //4.
    
        //5
        NSString *autoresXpathQueryString = @"//div[@class='auths']";
        NSArray *autoresArray = [tutorialsParser searchWithXPathQuery:autoresXpathQueryString];
        if (autoresArray.count > 0) {
            TFHppleElement *autoresElemento = [autoresArray objectAtIndex:0];
            [referenciaFinalString appendFormat:@"%@. ", [[[autoresElemento firstChild] firstChild] content]];
            //NSLog(@"autores %@", autoresElemento);
            //NSLog(@"autores %@", [[[autoresElemento firstChild] firstChild] content]);

        } else {
            [referenciaFinalString appendFormat:@"%@ ", NSLocalizedString(@"Autor no detectado", nil)];

        }

        //6.
        NSString *tituloXpathQueryString = @"//div[@class='a']/h2";
        NSArray *tituloArray = [tutorialsParser searchWithXPathQuery:tituloXpathQueryString];
        if(tituloArray.count > 0) {
            TFHppleElement *tituloElemento = [tituloArray objectAtIndex:0];
            [referenciaFinalString appendFormat:@"%@ ", [[tituloElemento firstChild] content]];

        } else {
            [referenciaFinalString appendFormat:@"%@ ", NSLocalizedString(@"Titulo no detectado", nil)];

        }
    
        //6.
        NSString *referenciaXpathQueryString = @"//p[@class='j']";
        NSArray *referenciaArray = [tutorialsParser searchWithXPathQuery:referenciaXpathQueryString];
        if (referenciaArray.count > 0) {
            TFHppleElement *referenciaElemento = [referenciaArray objectAtIndex:0];
            [referenciaFinalString appendFormat:@"%@ ", [[referenciaElemento firstChild] content]];

        } else {
            [referenciaFinalString appendFormat:@"%@ ", NSLocalizedString(@"Revista no detectada", nil)];

        }
        
        // 4) Presenta el resultado en el hilo principal
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.tableView beginUpdates];
            
            rowImportacion = FALSE;
            
            lecturaCritica.revista = referenciaFinalString;
            celdaActiva = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UITextView *eltextView = (UITextView *)[celdaActiva viewWithTag:101];
            eltextView.text = lecturaCritica.revista;
            [self textViewDidChange:eltextView];
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView endUpdates];

            [SVProgressHUD dismiss];

        });
    
    });
    
    //Hacer 2 cosas: desplegar_recoger la row 2 de la seccion 0 + invertir el triangulito de la row 1.
    //Para cada una de esa acciones aisladas no hace falta el bloque de beginUpdates ... endUpdates. Pero para hacerlo conjuntamente sí, de lo contrario la celda se desplaa hacia arriba por delante de la suerior ...
    //Meto en el mismo bloque: los cambios de texto, tirángulo y desplazamiento hacia abajo de la tabla para que las celdas superiores estén formadas cuando les llegue la orden de cambiar el texto. Empiezo por esto último para evitar el problema de enviar mensajes a textview/celdas que aún no se hayan formado.

}

#pragma mark  - Mail, Message, DocumentInteractionController
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    
    //Borra el documento del directorio en el que se escribió cuando lo cargo el UIDocumentInteractionController
    NSURL *url = controller.URL;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr removeItemAtURL:url error:NULL]  == YES)       NSLog (@"Remove successful");
    else                                                        NSLog (@"Remove failed");
    
}

#pragma mark - ActionSheet & AlertView Delagaciones:
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)botonIndex {
    
    if (actionSheet.tag == kActionSheetParaInicializarRespuestas) {
        
        //Cuando pulsa un botón de los de artículos, utiliza ese index para seleccionar la plantilla de interés en el array de plantillas, y saca varios datos de ella:
        //- los nombres corto y largo para pasarlo a plantillaDetalleVC
        //- una ID de 3 cifras para darle valor al atributo tipoArt de las respuestas. Con ella se sabe a qué preguntas corresponden estas respuestas (ya que ne la preguntasDetalleVC las respuestas viene de CoreData pero las preguntas vienen de un plist estático, un plist u otro dependiendo de la ID que señala que tipo de plantilla se escogió).
        
        if (botonIndex < plantillasMenuArray.count) {
            
            PlantillaDetalleViewController *plantillaDetalleViewController = [[PlantillaDetalleViewController alloc] initWithStyle:UITableViewStyleGrouped];
            NSString *plantillaID = [[plantillasMenuArray objectAtIndex:botonIndex] objectForKey:@"ID"];
            NSString *nombrePlantillaCorto = [[plantillasMenuArray objectAtIndex:botonIndex] objectForKey:@"corto"];
            
            lecturaCritica.tipoArt = nombrePlantillaCorto;
            
            Respuestas *respuestas = [NSEntityDescription insertNewObjectForEntityForName:@"Respuestas" inManagedObjectContext:self.context];
            respuestas.plantillaID = plantillaID;
            respuestas.r0  = @"whiteColor";
            respuestas.r1   = @"whiteColor";
            respuestas.r2   = @"whiteColor";
            respuestas.r3   = @"whiteColor";
            respuestas.r4   = @"whiteColor";
            respuestas.r5   = @"whiteColor";
            respuestas.r6  = @"whiteColor";
            respuestas.r7   = @"whiteColor";
            respuestas.r8   = @"whiteColor";
            respuestas.r9   = @"whiteColor";
            respuestas.r10  = @"whiteColor";
            respuestas.r11  = @"whiteColor";
            respuestas.r12  = @"whiteColor";
            lecturaCritica.relacionRespuestas = respuestas;
            
            plantillaDetalleViewController.nombrePlantillaCorto     = nombrePlantillaCorto;
            plantillaDetalleViewController.plantillaID              = plantillaID;
            plantillaDetalleViewController.context                  = self.context;
            plantillaDetalleViewController.laLectCrit               = lecturaCritica;
            
            [self performSegueWithIdentifier:@"LectAPlantilla" sender:self];
            
        }
        
    } else if (actionSheet.tag == kActionSheetParaAcciones) {
        
        if (botonIndex == 0) {
            [self duplicarObjeto];
            
        } else if (botonIndex == 1) {
            [self enviarViaEmailLecturaCritica:lecturaCritica];
            
        } else if (botonIndex == 2) {
            [self enviarPdfOtrasApp:lecturaCritica];
            
        } else if (botonIndex == 3) {
            [self botonBorrar];
            
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewBorrarLect) {
        if (buttonIndex == 0)   NSLog(@"Pulsó NO");
        else {
            //Borra el objeto. Consolida ese cambio y pasa al view controller anterior.
            if (!lecturaCritica)    NSLog(@"No hay Lect Crit");
            else                    [context deleteObject:lecturaCritica];
            
            [self saveContext];

            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
