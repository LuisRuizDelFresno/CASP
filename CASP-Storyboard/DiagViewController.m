//
//  DiagViewController.m
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiagViewController.h"

@interface DiagViewController ()

@end

@implementation DiagViewController

@synthesize rvseControl, preLabel, postLabel, rvCalcLabel, senIC95Label, espeIC95Label, rvIC95Label, footerBoton;

@synthesize preSlider, rvTextField, posnegControl, sensTextField, espeTextField, posnegControlRaw, testNegGSNeg, testNegGSPos, testPosGSNeg, testPosGSPos, dicResultados;
@synthesize lectCrit, context, comentarioNumero;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"titleDiagVC", nil);
    
    //FooterView
    [self componeTableFooter];
    
    //Para que se muestre con unos valores desde formación de pantalla. Y calcule si es posible.
    [rvTextField addTarget:self action:@selector(calcula:) forControlEvents:UIControlEventEditingChanged];
    [self calcula:self];
    
    dicResultados = [[NSMutableDictionary alloc] initWithCapacity:1];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Save Context
- (void)saveContext {
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } 

}

#pragma mark - Table view 
- (void)componeTableFooter {
    //FooterView
    [footerBoton setTitle:NSLocalizedString(@"Copiar los Resultados en Comentarios", nil) forState:UIControlStateNormal];
    [footerBoton addTarget:self action:@selector(copiaResultados:) forControlEvents:UIControlEventTouchUpInside];
    
    footerBoton.enabled = NO;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        
        //HeaderView para la section 2
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 70)];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, 295, 21)];
        headerLabel.text = NSLocalizedString(@"HeaderLabelText", nil);
        [headerView addSubview:headerLabel];
        
        NSArray *itemsArray = [NSArray arrayWithObjects:NSLocalizedString(@"Uno", nil), NSLocalizedString(@"Dos", nil), NSLocalizedString(@"Tres", nil), nil];
        rvseControl = [[UISegmentedControl alloc] initWithItems:itemsArray ];//
        rvseControl.frame = CGRectMake(20, 35, 280, 30);
        rvseControl.selectedSegmentIndex = 0;
        [rvseControl addTarget:self action:@selector(rvOse:) forControlEvents:UIControlEventValueChanged];
        
        [headerView addSubview:rvseControl];
        
        return headerView;
        
    }
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat altura = 10;
    if (section == 2)   altura = 70;
    return altura;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat alturaRow = 44;
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (rvseControl.selectedSegmentIndex != 0)  alturaRow = 0;
        } else if (indexPath.row == 1) {
            if (rvseControl.selectedSegmentIndex != 1)  alturaRow = 0;
            else                                        alturaRow = 100;
        } else if (indexPath.row == 2) {
            if (rvseControl.selectedSegmentIndex != 2)  alturaRow = 0;
            else                                        alturaRow = 147;
        }
    }
    
    return alturaRow;
}

#pragma mark - Cálculos

-(IBAction)rvOse:(UISegmentedControl *)segmentado {
    
    //Que recalcule
    [self calcula:self];
    
    //Que actualice el layout de la tabla animadamnete, según el segmento seleccionado
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
}

//Calcula la ProbPost desde la celda de pr y la de rv tecleado.
-(IBAction)calcula:(id)sender {
    
    //Toma el valor del slider, lo almacena en el dic de resultados y Prepara la odds Pre
    preLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PreTestLabel", nil), preSlider.value];
    [dicResultados setObject:[NSNumber numberWithFloat:preSlider.value] forKey:@"preProb"];
    
    float oddsPreFloat = preSlider.value/(100 - preSlider.value);
    
    //ASIGNAR A COCPROBFLOAT EL VALOR DEL RV TECLEADO O CALCULADO, SEGÚN SE ESTÉ MOSTRANDO UNA CELDA U OTRA.
    float cocProbFloat = 1;
    NSString *rvString;
    if (rvseControl.selectedSegmentIndex == 0) {
        rvString = rvTextField.text;
        [dicResultados setObject:[NSNumber numberWithFloat:rvString.floatValue] forKey:@"rv"];

        NSNumberFormatter * formateador = [[NSNumberFormatter alloc] init];
        [formateador setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *numeroFormateado = [formateador numberFromString:rvString];
        cocProbFloat = [numeroFormateado floatValue];
        
    } else if (rvseControl.selectedSegmentIndex == 1) {
        //No funciona con el formateador, probablemente porque no es un valor tecleado sino resultado de un cálculo.
        cocProbFloat = rvCalculado;
        [dicResultados setObject:[NSNumber numberWithFloat:rvCalculado] forKey:@"rv"];
 
    } else if (rvseControl.selectedSegmentIndex == 2) {
        cocProbFloat = rvCalcRaw;
        [dicResultados setObject:[NSNumber numberWithFloat:rvCalcRaw] forKey:@"rv"];

    }
    
    //CALCULAR LA PR POST Y MOSTRARLA
    float oddsPostFloat = oddsPreFloat*cocProbFloat;
    probPostFloat = 100*oddsPostFloat / (1+oddsPostFloat);
    [dicResultados setObject:[NSNumber numberWithFloat:probPostFloat] forKey:@"postProb"];
    
    if (probPostFloat > 0) postLabel.text = [NSString stringWithFormat:NSLocalizedString(@"postLabel", nil), probPostFloat];
    else postLabel.text = [NSString stringWithFormat:NSLocalizedString(@"postLabelVacia", nil)];
    
    //Para que hbilite o inhabolite el botón de copiar en resultados en función de que haya un valor en Pr Postest o no.
    if (probPostFloat && lectCrit)  footerBoton.enabled = YES;
    
}

//CALCULA LA RVCALCULADO A PARTIR DE S, E, TEST+/-. Todo ello en la misma celda
-(IBAction)calculaDesdeSE:(id)sender {
    
    //Formatea las entradas en los TextField para convertirlos en float.
    NSNumberFormatter * formateador = [[NSNumberFormatter alloc] init];
    [formateador setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *sensiNumero = [formateador numberFromString:sensTextField.text];
    float sensiFloat = [sensiNumero floatValue];
    NSNumber *espeNumero = [formateador numberFromString:espeTextField.text];
    float espeFloat = [espeNumero floatValue];
    
    //SI SE METE UN VALOR QUE EXCEDA DE 0-100 BORRA ESE CAMPO Y SACA UNA ALERTA EXPLICÁNDOLO
    if (sensTextField.text.length > 0 && espeTextField.text.length > 0 && (sensiFloat >=100 || espeFloat >= 100 || sensiFloat < 0 || espeFloat < 0)) {
        
        if (sender == sensTextField) {
            sensTextField.text = nil;
        } else {
            espeTextField.text = nil;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ValorNoValido", nil) message:NSLocalizedString(@"SenEspValidValues", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"De acuerdo", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    //CALCULA CUANDO SE HAN RELLENADO S Y E (con valores válidos)
    if (sensTextField.text.length > 0 && espeTextField.text.length > 0) {
        [dicResultados setObject:[NSNumber numberWithFloat:sensiFloat] forKey:@"sen"];
        [dicResultados setObject:[NSNumber numberWithFloat:espeFloat] forKey:@"esp"];

        if (posnegControl.selectedSegmentIndex == 0) {
            rvCalculado = sensiFloat/(100 - espeFloat);
            //Rellena aquí la label para que sólo le de números si han rellenado S y E
            rvCalcLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rvCalcLabel+", nil), rvCalculado];
            [dicResultados setObject:@"Test(+)" forKey:@"testPosNeg"];

        } else if (posnegControl.selectedSegmentIndex == 1) {
            rvCalculado = (100 - sensiFloat)/espeFloat;
            //Rellena aquí la label para que sólo le de números si han rellenado S y E
            rvCalcLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rvCalcLabel-", nil), rvCalculado];
            [dicResultados setObject:@"Test(-)" forKey:@"testPosNeg"];

        }
        
    } else {
        //Si no han rellenado S y E ponrá este texto en vez de el número calculado antes, ...
        rvCalcLabel.text = NSLocalizedString(@"rvCalcLabel", nil);
    }
    
    //termina llamando a calcula para que termine los cálculos hasta pr Post
    [self calcula:self];
}

- (IBAction)calculaDiagDesdeRaw:(id)sender {
        
    //CALCULA CUANDO SE HAN RELLENADO los 4 campos de Raw
    if (testNegGSNeg.text.length > 0 && testNegGSPos.text.length > 0 && testPosGSNeg.text.length > 0 && testPosGSPos.text.length > 0) {
        float sensiFloat = 100*testPosGSPos.text.floatValue / (testPosGSPos.text.floatValue + testNegGSPos.text.floatValue);
        float sensiEstandarError = sqrtf(sensiFloat*(100-sensiFloat)/(testPosGSPos.text.floatValue + testNegGSPos.text.floatValue));
        float sensiIC95Inf = sensiFloat - 1.96*sensiEstandarError;
        float sensiIC95Sup = sensiFloat + 1.96*sensiEstandarError;
        
        float espeFloat = 100*testNegGSNeg.text.floatValue / (testPosGSNeg.text.floatValue + testNegGSNeg.text.floatValue);
        float espeEstandarError = sqrtf(espeFloat*(100-espeFloat)/(testPosGSNeg.text.floatValue + testNegGSNeg.text.floatValue));
        float espeIC95Inf = espeFloat - 1.96*espeEstandarError;
        float espeIC95Sup = espeFloat + 1.96*espeEstandarError;
        
        [dicResultados setObject:[NSNumber numberWithFloat:testPosGSPos.text.floatValue] forKey:@"truePos"];
        [dicResultados setObject:[NSNumber numberWithFloat:testNegGSNeg.text.floatValue] forKey:@"trueNeg"];
        [dicResultados setObject:[NSNumber numberWithFloat:(testPosGSPos.text.floatValue + testNegGSPos.text.floatValue)] forKey:@"allEnf"];
        [dicResultados setObject:[NSNumber numberWithFloat:(testPosGSNeg.text.floatValue + testNegGSNeg.text.floatValue)] forKey:@"allSanos"];
        
        if (posnegControlRaw.selectedSegmentIndex == 0) {
            rvCalcRaw = sensiFloat/(100 - espeFloat);
            float rvPosIC95EstandrError = sqrtf((1-sensiFloat/100)/testPosGSPos.text.floatValue + espeFloat/100/testPosGSNeg.text.floatValue);
            float rvPosIC95Inf = exp(logf(rvCalcRaw)-1.96*rvPosIC95EstandrError);
            float rvPosIC95Sup = exp(logf(rvCalcRaw)+1.96*rvPosIC95EstandrError);
            
            rvIC95Label.text = [NSString stringWithFormat:NSLocalizedString(@"rv95LabelT+", nil), rvCalcRaw, rvPosIC95Inf, rvPosIC95Sup];
            
            [dicResultados setObject:@"Test(+)" forKey:@"testPosNeg"];
            [dicResultados setObject:[NSNumber numberWithFloat:rvPosIC95Inf] forKey:@"rvIC95Inf"];
            [dicResultados setObject:[NSNumber numberWithFloat:rvPosIC95Sup] forKey:@"rvIC95Sup"];

            
        } else if (posnegControlRaw.selectedSegmentIndex == 1) {
            rvCalcRaw = (100 - sensiFloat)/espeFloat;
            float rvNegIC95EstandrError = sqrtf((1-(testPosGSPos.text.floatValue/(testPosGSPos.text.floatValue+testPosGSNeg.text.floatValue)))/testNegGSNeg.text.floatValue + sensiFloat/100/testNegGSPos.text.floatValue);
            float rvNegIC95Inf = exp(logf(rvCalcRaw)-1.96*rvNegIC95EstandrError);
            float rvNegIC95Sup = exp(logf(rvCalcRaw)+1.96*rvNegIC95EstandrError);
            
            rvIC95Label.text = [NSString stringWithFormat:NSLocalizedString(@"rv95LabelT-", nil), rvCalcRaw, rvNegIC95Inf, rvNegIC95Sup];
            
            [dicResultados setObject:@"Test(-)" forKey:@"testPosNeg"];
            [dicResultados setObject:[NSNumber numberWithFloat:rvNegIC95Inf] forKey:@"rvIC95Inf"];
            [dicResultados setObject:[NSNumber numberWithFloat:rvNegIC95Sup] forKey:@"rvIC95Sup"];
            
        }
        
        senIC95Label.text = [NSString stringWithFormat:NSLocalizedString(@"senIC95Label", nil), sensiFloat, sensiIC95Inf, sensiIC95Sup];
        espeIC95Label.text = [NSString stringWithFormat:NSLocalizedString(@"espeIC95Label", nil), espeFloat, espeIC95Inf, espeIC95Sup];
        
        [dicResultados setObject:[NSNumber numberWithFloat:sensiFloat] forKey:@"sen"];
        [dicResultados setObject:[NSNumber numberWithFloat:espeFloat] forKey:@"esp"];

    } else {
        //Si no han rellenado Los 4 campos Raw pondrá este texto en vez de el número calculado antes, ...
        rvIC95Label.text = NSLocalizedString(@"rv95LabelVacia", nil);
    }
    
    //termina llamando a calcula para que termine los cálculos hasta pr Post
    [self calcula:self];
    
}

- (IBAction)copiaResultados:(id)sender {
    
    //CONTRUIR LAS FRASES RESUMEN DE LOS RESULTADOS: UNA PARA EL COMENTARIO DE PREG Y OTRA PARA EL COMENTARIO GENERAL. Y A SU VEZ DISTNTAS SEGÚN HAYA INTRODUCIDO O CALCULADO LR O RAW-DATA
    NSString *resultadosComentarioPreg, *resultadosComentarioGeneral;
    if (rvseControl.selectedSegmentIndex == 0) {
        resultadosComentarioPreg = [NSString stringWithFormat:NSLocalizedString(@"ResultadosDiag", nil),
                            [[dicResultados objectForKey:@"rv"] floatValue],
                            [[dicResultados objectForKey:@"preProb"] floatValue],
                            [[dicResultados objectForKey:@"postProb"] floatValue]];
        
        resultadosComentarioGeneral = [NSString stringWithFormat:NSLocalizedString(@"ResultadosDiagGen", nil),
                                       [[dicResultados objectForKey:@"rv"] floatValue],
                                       [[dicResultados objectForKey:@"preProb"] floatValue],
                                       [[dicResultados objectForKey:@"postProb"] floatValue]];
        
    } else if (rvseControl.selectedSegmentIndex == 1) {
        resultadosComentarioPreg = [NSString stringWithFormat:NSLocalizedString(@"ResultadosDiagSE", nil),
                            [[dicResultados objectForKey:@"sen"] floatValue],
                            [[dicResultados objectForKey:@"esp"] floatValue],
                            
                            [dicResultados objectForKey:@"testPosNeg"],
                            [[dicResultados objectForKey:@"rv"] floatValue],

                            [[dicResultados objectForKey:@"preProb"] floatValue],
                            [[dicResultados objectForKey:@"postProb"] floatValue]];

        resultadosComentarioGeneral = [NSString stringWithFormat:NSLocalizedString(@"ResultadosDiagGenSE", nil),
                                       [dicResultados objectForKey:@"testPosNeg"],
                                       [[dicResultados objectForKey:@"rv"] floatValue],
                                       
                                       [[dicResultados objectForKey:@"preProb"] floatValue],
                                       [[dicResultados objectForKey:@"postProb"] floatValue]];
        
    } else {
        //Si queremos copiar los IC95% habría que tomarlos aquí e incorporarlos a resultadosString
        resultadosComentarioPreg = [NSString stringWithFormat:NSLocalizedString(@"ResultadosDiagRaw", nil),
                            [[dicResultados objectForKey:@"truePos"] floatValue],
                            [[dicResultados objectForKey:@"allEnf"] floatValue],
                            
                            [[dicResultados objectForKey:@"trueNeg"] floatValue],
                            [[dicResultados objectForKey:@"allSanos"] floatValue],
                            
                            [[dicResultados objectForKey:@"sen"] floatValue],
                            [[dicResultados objectForKey:@"esp"] floatValue],

                            [dicResultados objectForKey:@"testPosNeg"],
                            [[dicResultados objectForKey:@"rv"] floatValue],
                            [[dicResultados objectForKey:@"rvIC95Inf"] floatValue],
                            [[dicResultados objectForKey:@"rvIC95Sup"] floatValue],

                            [[dicResultados objectForKey:@"preProb"] floatValue],
                            [[dicResultados objectForKey:@"postProb"] floatValue]];
        
        resultadosComentarioGeneral = [NSString stringWithFormat:NSLocalizedString(@"ResultadosDiagGenRaw", nil),
                                       [dicResultados objectForKey:@"testPosNeg"],
                                       [[dicResultados objectForKey:@"rv"] floatValue],
                                       
                                       [[dicResultados objectForKey:@"rvIC95Inf"] floatValue],
                                       [[dicResultados objectForKey:@"rvIC95Sup"] floatValue],

                                       [[dicResultados objectForKey:@"preProb"] floatValue],
                                       [[dicResultados objectForKey:@"postProb"] floatValue]];
        
    }

    //GUARDA EL RESULTADO EN EL COMENTARIO DE LA PREGUNTA
    [lectCrit.relacionRespuestas setValue:resultadosComentarioPreg forKey:comentarioNumero];
    
    //PARA EL COMENTARIO GENERAL.
    //Mira si hay algo en el comentario general de la lectura y le añade los resultados
    NSMutableString *comentarioContenido;
    if (lectCrit.comentario) {
        comentarioContenido = [[NSMutableString alloc] initWithString:lectCrit.comentario];
        [comentarioContenido appendString:resultadosComentarioGeneral];
        
    } else {
        comentarioContenido = [[NSMutableString alloc] initWithString:resultadosComentarioGeneral];
        
    }
    lectCrit.comentario = comentarioContenido;
    
    //Guardo
    [self saveContext];
    
    //vuelvo al VC anterior
    [self.navigationController popViewControllerAnimated:YES];

    //dejo el botón inhabilitado
    footerBoton.enabled = NO;

}

#pragma mark - Relacionados con el teclado TextDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    	
    //Para poner un boton de ok en la nav bar que retire el teclado
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(ocultaTeclado:)];
    
    //Desplazar la tabla hacia arriba y que no tape los campos con el teclado. NO HACE FALTA EN IOS 7 Y 8
    //[self animateTextField: textField up: YES];
    
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self calcula:self];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    //Elimina el botón OK al retirar el teclado
    self.navigationItem.rightBarButtonItem = nil;    
    
    //Desplazar la tabla hacia arriba y que no pate los campos con el teclado. NO HACE FALTA EN IOS 7 Y 8
    //[self animateTextField: textField up: NO];
    
}	

-(IBAction)ocultaTeclado:(id)sender {
    
    // retira el teclado
    [rvTextField resignFirstResponder];
    [sensTextField resignFirstResponder];
    [espeTextField resignFirstResponder];
    [testNegGSNeg resignFirstResponder];
    [testNegGSPos resignFirstResponder];
    [testPosGSNeg resignFirstResponder];
    [testPosGSPos resignFirstResponder];
    
}

/*
- (void) animateTextField:(UITextField*)textField up:(BOOL)up {
 
    int movementDistance = 100; // tweak as needed

    const float movementDuration = 0.25f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];

}
*/

@end
