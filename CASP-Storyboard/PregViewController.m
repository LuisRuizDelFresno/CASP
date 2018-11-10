//
//  PregViewController.m
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PregViewController.h"
#import "AppDelegate.h"
#import "NNTViewController.h"
#import "DiagViewController.h"
#import "LectCrit.h"

@implementation PregViewController

@synthesize notaColor, delegate;
@synthesize preguntaString, pistaString, celdaSeleccionadaP;
@synthesize labelPregunta, botonRespuesta, textViewComentario, constraintToAdjust, labelPista, labelCalcula;
@synthesize plantillaID;
@synthesize laLectCrit, context;
@synthesize alturaTextViewNumber, placeholder, numeroComentario;

//CONSTAMNTES DEFINIDAS PARA CALCULAR EL TAMAÑO DEL TEXTO ... ALTURA DE LA CELDA
#define FONT_PLAIN [UIFont systemFontOfSize:14.0f]
#define FONT_BOLD [UIFont boldSystemFontOfSize:16.0f]
#define FONT_COMENTARIO [UIFont boldSystemFontOfSize:14.0f]
#define VERDE_TEXTO [UIColor colorWithRed: 27.0/255.0 green: 100.0/255.0 blue: 23.0/255.0 alpha: 1.0]
#define CELL_CONTENT_WIDTH_PORTRAIT 300.0f //EL ANCHO DE LA CELDA vertical
#define CELL_TV_CONTENT_MARGIN 2.0f //MARGENES INTERIORES DE LA CELDA A SU CONTENIDO si TextView, que lleva otros márgenes interno hasta el texto
#define MargenInternoTextView 8.0f
#define CELL_Label_CONTENT_MARGIN 8.0f //MARGENES INTERIORES DE LA CELDA A SU CONTENIDO si label que no tiene margen interno hasta el texto.

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Pistas", nil);
    plantillaID = laLectCrit.relacionRespuestas.plantillaID;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //PAra evita el error de que no encuentra un NSManagedObjetModel Etiquetas, tomado de stackoverflow.com/questions/1074539/passing-a-managedobjectcontext-to-a-second-view
    if (context == nil) {
        context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"NO HABIA MANAGEDOBJECT CONTEXT DONDE DEBIA HABERLO: %s", __FUNCTION__);
    }
    
    //[self.tableView reloadData] NO actualizaba el contenido de la celdas porque el método configiuraCelda no se llmama desde celForRow, porque no hay cellForRow (es una tabla estática configurada en Storyboard
    [self configurarCelda];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    // observe keyboard hide and show notifications to resize the text view appropriately .APPLE 1/8
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self saveContext];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    //Quiero anular el valor que tenga alturaTextView, y no sirve asignarle nil, ... por que no es un objeto de Objective-C sino un escalar.
    //En alturaTextView = nanf(NULL); nan significa "not a number" que es la forma en StackOverflow de anular (9402348), pero tampoco a funcionado, por lo que lo almaceno como un objeto NSNumber y así poder asignarle nil.
    //El objeto de anularlo es como al anular alturasArray en lectura, el forzar que reclacule tamaño de row cuando el texto ha cambiado en pregVC
    alturaTextViewNumber = nil;
    
    //APPLE 2/8
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

#pragma mark - Save Context
- (void)saveContext {
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } 
    
}

#pragma mark - Table view data source

//Hace el juego de 2 ó 3 secciones según sea diag-rct o no
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSRange diaRango = [plantillaID rangeOfString:@"dia"];
    NSRange rctRango = [plantillaID rangeOfString:@"rct"];
    
    if (((diaRango.length > 0) || (rctRango.length > 0)) && (celdaSeleccionadaP.section == 1)) return 4;

    return 3;
}

//ASIGNA TEXTOS, COLORES Y AJUSTA TAMAÑOS
- (void) configurarCelda {
    
    //LABELPREGUNTA---------------------------------------------------------------------------------------
    CGFloat alturaLabelPregunta = [self calculaAlturaLabelParaTexto:preguntaString conFont:FONT_BOLD];

    [labelPregunta setFrame:CGRectMake(CELL_Label_CONTENT_MARGIN,
                               CELL_Label_CONTENT_MARGIN,
                               (CELL_CONTENT_WIDTH_PORTRAIT - CELL_Label_CONTENT_MARGIN * 2),
                               alturaLabelPregunta)];

    labelPregunta.text = preguntaString;
    
    //BOTONERARESPUESTA-----------------------------------------------------------------------------------
    [botonRespuesta setTitle:NSLocalizedString(@"SíEnRespuestas", nil) forSegmentAtIndex:0];
    [botonRespuesta setTitle:NSLocalizedString(@"NoEnRespuestas", nil) forSegmentAtIndex:1];
    [botonRespuesta setTitle:NSLocalizedString(@"No sé", nil) forSegmentAtIndex:2];

    NSString *colorRespuesta = [laLectCrit.relacionRespuestas valueForKey:[NSString stringWithFormat:@"r%i", numeroComentario]];
    if ([colorRespuesta isEqualToString:@"greenColor"])         botonRespuesta.selectedSegmentIndex = 0;
    else if ([colorRespuesta isEqualToString:@"redColor"])      botonRespuesta.selectedSegmentIndex = 1;
    else if ([colorRespuesta isEqualToString:@"yellowColor"])   botonRespuesta.selectedSegmentIndex = 2;
    else                                                        botonRespuesta.selectedSegmentIndex = -1;
    
    //TEXTVIEWCOMENTARIO ---------------------------------------------------------------------------------
    //Textos a manejar
    placeholder = NSLocalizedString(@"Escriba aquí sus comentarios", nil);
    NSString *comentarioKey = [laLectCrit.relacionRespuestas valueForKey:[NSString stringWithFormat:@"c%i", numeroComentario]];
    if (comentarioKey.length == 0) comentarioKey = placeholder;

    //create a rect for the text view so it's the right size coming out of IB. Size it to something that is form fitting to the string in the model.
    float height = [self calculaAlturaTextViewParaTexto:comentarioKey conFont:FONT_COMENTARIO];
    
    CGRect textViewRect = CGRectMake(textViewComentario.frame.origin.x,
                                     textViewComentario.frame.origin.y,
                                     CELL_CONTENT_WIDTH_PORTRAIT - (CELL_TV_CONTENT_MARGIN * 2) - (MargenInternoTextView * 2),
                                     height);
    
    self.textViewComentario.frame = textViewRect;
    
    // now that we've resized the frame properly, let's run this through again to get proper dimensions for the contentSize.
    self.textViewComentario.contentSize = CGSizeMake(CELL_CONTENT_WIDTH_PORTRAIT - (CELL_TV_CONTENT_MARGIN * 2) - (MargenInternoTextView * 2),
                                                     [self calculaAlturaTextViewParaTexto:comentarioKey conFont:FONT_COMENTARIO]);

    //Color de texto
    if (comentarioKey.length != 0) {
        if ([comentarioKey isEqual:placeholder])      textViewComentario.textColor = VERDE_TEXTO;           //Tiene contenido: el placeholder
        else                                          textViewComentario.textColor = [UIColor blackColor];  //Tiene contenido que no es placeholder
        
    } else {
        //Esta vacio
        [laLectCrit.relacionRespuestas setValue:placeholder forKey:[NSString stringWithFormat:@"c%i", numeroComentario]];
        textViewComentario.textColor = VERDE_TEXTO;
        
    }
    
    //Le ponemos el texto
    textViewComentario.text = comentarioKey;
    
    //LABELPISTA-----------------------------------------------------------------------------------------
    CGFloat alturaLabelPista = [self calculaAlturaLabelParaTexto:pistaString conFont:FONT_PLAIN];
    [labelPista setFrame:CGRectMake(CELL_Label_CONTENT_MARGIN,
                                    CELL_Label_CONTENT_MARGIN,
                                    (CELL_CONTENT_WIDTH_PORTRAIT - CELL_Label_CONTENT_MARGIN * 2),
                                    alturaLabelPista)];
    labelPista.text = pistaString;
    
    //LABELCALCULA NNT O PROB POSTTEST
    NSRange diaRango = [plantillaID rangeOfString:@"dia"];
    NSRange rctRango = [plantillaID rangeOfString:@"rct"];
        
    if (diaRango.length > 0) labelCalcula.text = NSLocalizedString(@"EnlaceACalcDiag", nil);
    else if (rctRango.length > 0) labelCalcula.text = NSLocalizedString(@"EnlaceACalcNNT", nil);
    
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Para que alinee verticalmente el texto arriba, que se sale en la primera carga por el borde superior (porque parece que inicialmente centra verticlmente el texto, y cuando sobra desborda por encima y debajo)
    if (indexPath.section == 1) {
        //SOLUCIONA QUE AL CARGAR UN TEXTO SUPERIRO A L ALTURA DEL TEXTVIEW DESBORDE LAS PRIMERAS LÍNEAS PARA DA REL TEXTO CENTRADO
        textViewComentario.contentOffset = CGPointMake(0.0f, 0.0f);
        
        //SOLUCIONA EL QUE SE OCULTE LA LINEA QUE SE ESCRIBE http://stackoverflow.com/a/22469770/2848364
        textViewComentario.layoutManager.allowsNonContiguousLayout = NO;

    }

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1)           return NSLocalizedString(@"comentarios", nil);
    else if (section == 2)      return NSLocalizedString(@"pista", nil);
    else                        return nil;
    
}


//PARA que se calcule la altura que tiene que tener cada celda usamos el método -heightForRowAtIndexPath: We calculate the height of the cell by determining the size of the text based on the length of the text and the font we intend to use. The NSString class provides a method called -sizeWithFont that enables us to obtain this size.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //PARA CALCULAR LA ALTURA DE LA CELDA, CALCULAMOS LA ALTURA DE LA LABEL Y LE SUMAMOS LOS MÁRGENES INTERIORES.
    //LA ALTURA DE LA LABEL DEPENDE DEL TEXTO CONCRETO, SU FUENTE, COMO CORTE LAS LINEAS Y EL ANCHO.
    //EL ANCHO ES UN FIJO SEGÚN LA OIRIENTACIÓN, FUENTE Y FORMA DE CORTAR TAMBIÉN LO SON.
    //LA ALTURA la calcula en dos parte sprimero una reducto genérico de ancho fijo adecuado y altura mucho mayor de la necesaria en cualquier fila. 
    //luego calcula la altura calculando el size necesario para ese ancho, texto, ... la altura es la propiedad height de ese size, y establece la condición de que como mínimo será 40.0 (l aaltura estandar de una celda).
    float alturaRow = 0.0;
    
    //CALCULA EL TAMAÑO DEL TEXTO TENIENDO EN CUENTA EL TAMAÑO DE FUENTE, EL ANCHO DISPONIBLE Y EL MÉTODO DE DIVIDIR LAS LINEAS.
    if (indexPath.section ==0) {
        //PREGUNTA + BOTONERA
        CGFloat heightLabel = [self calculaAlturaLabelParaTexto:preguntaString conFont:FONT_COMENTARIO];
        alturaRow = MAX(heightLabel + (CELL_Label_CONTENT_MARGIN * 3) + 30, 44); //5 de separación label-segmented; 30 de altura de segmented
        
    } else if (indexPath.section == 1) {
        //COMENTARIO
        NSString *comentario = [laLectCrit.relacionRespuestas valueForKey:[NSString stringWithFormat:@"c%i", numeroComentario]];
        if (!alturaTextViewNumber) {
            //Si no se está editando, no hay alturaTextView y calcula con el contenido que tenga el ojeto en comentario
            
            alturaRow = [self calculaAlturaTextViewParaTexto:comentario conFont:FONT_COMENTARIO] + (CELL_TV_CONTENT_MARGIN * 2);

        } else {
            //Si existe alturaTextView (porque se está escribiendo ahora en el textview), toma ese valor que se está calculando letra a letra en textViewDidChange
            float alturaTextView = [alturaTextViewNumber floatValue];
            alturaRow = MAX(44, alturaTextView + (CELL_TV_CONTENT_MARGIN * 2));

        }

    } else if (indexPath.section == 2) {
        //PISTA
        CGFloat alturaLabel = [self calculaAlturaLabelParaTexto:pistaString conFont:FONT_PLAIN];
        alturaRow = alturaLabel + (CELL_Label_CONTENT_MARGIN * 4); //A veces no llega a mostrar la última línea si le doy solo 2 veces el CELL_Label_CONTENT_MARGIN
        
    } else {
        //CALCULADORA SI PROCEDE
        alturaRow = 44;

    }
    
    return alturaRow;
    
}

- (CGFloat)calculaAlturaLabelParaTexto:(NSString *)texto conFont:(UIFont *)tipoLetra {
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH_PORTRAIT - (CELL_Label_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size;
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributes = @{NSFontAttributeName : tipoLetra,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
    size = [texto boundingRectWithSize:constraint
                                   options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                attributes:attributes
                                    context:nil].size;
        
    CGFloat heightLabel = MAX(size.height, 24.0f);
    
    return heightLabel;
    
}


- (CGFloat)calculaAlturaTextViewParaTexto:(NSString *)texto conFont:(UIFont *)tipoLetra {
    
    //Si no se está editando, no hay alturaTextView y calcula con el contenido que tenga el ojeto en comentario
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH_PORTRAIT - (CELL_TV_CONTENT_MARGIN * 2) - (MargenInternoTextView * 2), 20000.0f);
    
    CGSize size;

    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributes = @{NSFontAttributeName : tipoLetra,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
    size = [texto boundingRectWithSize:constraint
                               options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                            attributes:attributes
                               context:nil].size;
    //Limita el tamaño del textview, permitiendo su scroll es lo que hace la aplicación oficial contactos con sus notas.
    CGFloat heightTextView = MIN(MAX(size.height + (MargenInternoTextView * 2), 44 - (CELL_TV_CONTENT_MARGIN *2)), 120);
    
    alturaTextViewNumber = [NSNumber numberWithFloat:heightTextView];
    
    return heightTextView;
    
}

#pragma mark - TABLEView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([plantillaID rangeOfString:@"dia"].length > 0) {
        if (indexPath.section == 3) {
            
            [self performSegueWithIdentifier:@"PregADiag" sender:self];
            
        }
    } else if ([plantillaID rangeOfString:@"rct"].length > 0) {
        if (indexPath.section == 3) {
            [self performSegueWithIdentifier:@"PregANNT" sender:self];
            
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PregADiag"]) {
        DiagViewController *diagVC = segue.destinationViewController;
        diagVC.lectCrit = laLectCrit;
        diagVC.comentarioNumero = [NSString stringWithFormat:@"c%i", numeroComentario];
        diagVC.context = context;
        
    } else if ([segue.identifier isEqualToString:@"PregANNT"]) {
        NNTViewController *nntVC = segue.destinationViewController;
        nntVC.lectCrit = laLectCrit;
        nntVC.comentarioNumero = [NSString stringWithFormat:@"c%i", numeroComentario];
        nntVC.context = context;

    }
    
}

-(IBAction)botonRespuestaPulsado:(id)sender {
    if ([sender selectedSegmentIndex] == 0)         notaColor = @"greenColor";
    else if ([sender selectedSegmentIndex] == 1)    notaColor = @"redColor";
    else if ([sender selectedSegmentIndex] ==2)     notaColor = @"yellowColor";
    
    //Actualizar el modelo
    [laLectCrit.relacionRespuestas setValue:notaColor forKey:[NSString stringWithFormat:@"r%i", numeroComentario]];
    
    //Pasar la información al delelgado
    NSDictionary * dicRespuesta = [[NSDictionary alloc] initWithObjectsAndKeys:celdaSeleccionadaP, @"celda", notaColor, @"color", nil];
    /*
    // Xcode will complain if we access a weak property more than
    // once here, since it could in theory be nilled between accesses
    // leading to unpredictable results. So we'll start by taking
    // a local, strong reference to the delegate.
    //id<PregViewControllerDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    */
    if ([delegate respondsToSelector:@selector(respuestaEnDelegante:)]) {
        [delegate respuestaEnDelegante:dicRespuesta];
    }
    
}

#pragma mark - TextView Delegate y relacionados

- (void) textViewDidBeginEditing:(UITextView *)textView {
    
    NSLog(@"%s", __FUNCTION__);

    if ([textView.text isEqual:placeholder])    textView.text = @"";
    
    //APPLE 3/8
    [self adjustSelection:textView];

    [self gestosEnFondoDeTabla:YES];
    
}

//APPLE 4/8
- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    [self adjustSelection:textView];
}

//APPLE 5/8
- (void)adjustSelection:(UITextView *)textView {
    
    // workaround to UITextView bug, text at the very bottom is slightly cropped by the keyboard
    if ([textView respondsToSelector:@selector(textContainerInset)]) {
        [textView layoutIfNeeded];
        CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        caretRect.size.height += textView.textContainerInset.bottom;
        [textView scrollRectToVisible:caretRect animated:NO];
    }
}

//APPLE 6/8
- (void)adjustTextViewByKeyboardState:(BOOL)showKeyboard keyboardInfo:(NSDictionary *)info {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    // transform the UIViewAnimationCurve to a UIViewAnimationOptions mask
    UIViewAnimationCurve animationCurve = [info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState;
    if (animationCurve == UIViewAnimationCurveEaseIn)           animationOptions |= UIViewAnimationOptionCurveEaseIn;
    else if (animationCurve == UIViewAnimationCurveEaseInOut)   animationOptions |= UIViewAnimationOptionCurveEaseInOut;
    else if (animationCurve == UIViewAnimationCurveEaseOut)     animationOptions |= UIViewAnimationOptionCurveEaseOut;
    else if (animationCurve == UIViewAnimationCurveLinear)      animationOptions |= UIViewAnimationOptionCurveLinear;
    
    [self.textViewComentario setNeedsUpdateConstraints];                                              // NO APLICABLE A MI
    //[self.tableView setNeedsUpdateConstraints];                                              // NO APLICABLE A MI

    if (showKeyboard) {

        NSValue *keyboardFrameVal = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
        CGFloat height = keyboardFrame.size.height; // NO APLICABLE A MI
        
        // adjust the constraint constant to include the keyboard's height
        self.constraintToAdjust.constant += height;                                         // ADAPTAR AL FRAME? DE LA TABLEVIEW?
        
    }
    else {
        self.constraintToAdjust.constant = 0;                                               // ADAPTAR AL FRAME DE LA TABLEVIEW?
 
    }
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {

    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:YES keyboardInfo:userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:NO keyboardInfo:userInfo];
    
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

- (void) esconderTeclado {
    [[self view] endEditing:YES];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text isEqual:placeholder])    textView.textColor = VERDE_TEXTO;//[UIColor lightGrayColor];
    else                                        textView.textColor = [UIColor blackColor];
    
    //Prepara la tabla para añadir, quitar o mover filas, ... You should not call reloadData within the group; if you call this method within the group, you will need to perform any animations yourself.
    
    //Si obtengo el indexCeldaActiva en textViewDidBeginEditing (que es lo que me pareció más normal, justo detrás de obtener la celdaActiva), no sé que pasa que intentar hacer referencia a indexCeldaActiva en didChange o en heightForRow hace crash; en cambio obtener aquí el indexCeldaActiva no da problemas ¿por qué?

    [self.tableView beginUpdates];
    
    CGRect frame = textView.frame;
        
    float alturaTextView = [self calculaAlturaTextViewParaTexto:textView.text conFont:FONT_COMENTARIO];
    
    frame.size.height = alturaTextView;
    textView.frame = frame;
    
    alturaTextViewNumber = [NSNumber numberWithFloat:alturaTextView];

    //Para que siga al cursor
    //[self performSelector:@selector(scrollToCursorForTextView:) withObject:textView afterDelay:0];
    [self adjustSelection:textView];
    
    [self.tableView endUpdates];
        
}

- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    NSLog(@"%s NOOO DEBERIA LLAMARSE", __FUNCTION__);
    /*
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 20; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
        
    }
    */
}

- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    NSLog(@"%s NO DEBERIA LLAMARSE", __FUNCTION__);

    return CGRectContainsRect(visibleRect, rect);
    
}

- (void) textViewDidEndEditing:(UITextView *)textView {

    //SI TIENE TEXTO le da un color u otr dependiendo de sui es el placeholder u otro. SI NO TIENE TEXTO le pone el placeholder y le da color
    if (textView.text.length) {
        if ([textView.text isEqual:placeholder])    textView.textColor = VERDE_TEXTO;
        else textView.textColor = [UIColor blackColor];
        
    } else {
        textView.text = placeholder;
        textView.textColor = VERDE_TEXTO;
    }
    
    //COPIA EL TEXTO EN EL ATRIBUTO
    [laLectCrit.relacionRespuestas setValue:textView.text forKey:[NSString stringWithFormat:@"c%i", numeroComentario]];
    
    [self gestosEnFondoDeTabla:NO];

}

/*
- (void)quitaScrollTextView:(UITextView *)unTextView {
    unTextView.scrollEnabled = NO;
    
}
*/
@end
