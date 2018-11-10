//
//  NNTViewController.m
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NNTViewController.h"
#import "Grafico2ViewController.h"
#import "TiemposNNTTableViewController.h"

@interface NNTViewController ()

@end

@implementation NNTViewController

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@synthesize absOraw, tituloHeader;
@synthesize interprVsGrafico, actionSheet, nntLabel, riesgoExpLabel, reducRiesgoAbsLabel, riesgoRelativoLabel, riesgoControlLabel, riesgoRelativo95Label, reducRiesgoAbs95, reducRiesgorelativo, footerBoton, picker, periodosArray, tiemposArray;
@synthesize rAbsCon, rAbsExp, controlNo, controlSi, expNo, expSi, nntString, dicResultados, comentarioNumero;
@synthesize lectCrit, context;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"tituloCalcNNT", nil);

    [self tablaFooter];
    [self tablaHeader];
    
    interprVsGrafico.hidden = YES;
    
    dicResultados = [[NSMutableDictionary alloc] initWithCapacity:1];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (void)tablaHeader {
    
    tituloHeader.text = NSLocalizedString(@"tituloHeaderSeccion", nil);
    [absOraw setTitle:NSLocalizedString(@"segmentAbsRaw0", nil) forSegmentAtIndex:0];
    [absOraw setTitle:NSLocalizedString(@"segmentAbsRaw1", nil) forSegmentAtIndex:1];

    absOraw.selectedSegmentIndex = 0;
    
}

- (void)tablaFooter {
    
    [footerBoton setTitle:NSLocalizedString(@"Copiar los Resultados en Comentarios", nil) forState:UIControlStateNormal];
    [footerBoton addTarget:self action:@selector(copiaResultados:) forControlEvents:UIControlEventTouchUpInside];
    
    footerBoton.enabled = NO;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat alturaRow = 44;
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (absOraw.selectedSegmentIndex == 0)  alturaRow = 125; //o 130?
            else                                    alturaRow = 0;
            
        } else if (indexPath.row == 1) {
            if (absOraw.selectedSegmentIndex == 0)  alturaRow = 0;
            else                                    alturaRow = 161;

        }
    } else if (indexPath.section == 0) {
        if (![interprVsGrafico isHidden])   alturaRow = 73;

    }
    
    return alturaRow;
}

#pragma mark - segmentedControl alternanteNNT

-(IBAction)cambiaCeldaNNT:(id)sender {
    
    if (absOraw.selectedSegmentIndex == 0) {
        interprVsGrafico.hidden = YES;

        [self calculaNNTDesdeRiesgos:self];
        
    } else if (absOraw.selectedSegmentIndex == 1) {
        //interprVsGrafico.hidden = NO;

        [self calculaNNTRaw:self];
        
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

}

#pragma mark - Cálculos

-(IBAction)calculaNNTRaw:(id)sender {
    
    BOOL activaBoton = NO;
    //Sólo calcula si todos los campos de la tabla 2x2 están rellenos
    if (controlSi.text.length >0 && controlNo.text.length >0 && expSi.text.length >0 && expNo.text.length > 0) {
        
        //1. RIESGOS BASALES
        riesgoBasal = 100 * controlSi.text.floatValue / (controlSi.text.floatValue + controlNo.text.floatValue);
        float riesgoExp = 100 * expSi.text.floatValue / (expSi.text.floatValue + expNo.text.floatValue);
        
        [dicResultados setObject:[NSNumber numberWithFloat:expSi.text.floatValue] forKey:@"expSi"];
        [dicResultados setObject:[NSNumber numberWithFloat:(expSi.text.floatValue + expNo.text.floatValue)] forKey:@"expTotal"];
        [dicResultados setObject:[NSNumber numberWithFloat:controlSi.text.floatValue] forKey:@"controlSi"];
        [dicResultados setObject:[NSNumber numberWithFloat:(controlSi.text.floatValue + controlNo.text.floatValue)] forKey:@"controlTotal"];
        [dicResultados setObject:[NSNumber numberWithFloat:riesgoBasal] forKey:@"rieBasal"];
        
        //2. RRA Y SU INTERVALO DE CONFIANZA
        reduccionRiesAbs = riesgoBasal - riesgoExp;
        float totalGrupoControl = controlSi.text.floatValue + controlNo.text.floatValue;
        float totalGrupoExp = expSi.text.floatValue + expNo.text.floatValue;
        float errorEstandarRRA = sqrtf((riesgoBasal*(100-riesgoBasal)/totalGrupoControl) + (riesgoExp*(100-riesgoExp)/totalGrupoExp));
        intConf95InfRra = reduccionRiesAbs - 1.96*errorEstandarRRA;
        intConf95SupRra = reduccionRiesAbs + 1.96*errorEstandarRRA;
        
        float nntInfFloat = 100/intConf95InfRra;
        float nntSupFloat = 100/intConf95SupRra;
        [dicResultados setObject:[NSNumber numberWithFloat:reduccionRiesAbs] forKey:@"rra"];

        //4. RELLENAMOS LAS ETIQUETAS.
        float riesgoRelativo = riesgoExp / riesgoBasal;
        
        if (riesgoBasal < 10) riesgoControlLabel.text = [NSString stringWithFormat:NSLocalizedString(@"riesgoBasalLabelSmall", nil), riesgoBasal];
        else  riesgoControlLabel.text = [NSString stringWithFormat:NSLocalizedString(@"riesgoBasalLabel", nil), riesgoBasal];  
        
        if (riesgoExp < 10) riesgoExpLabel.text = [NSString stringWithFormat:NSLocalizedString(@"riesgoExpLabelSmall", nil), riesgoExp];
        else riesgoExpLabel.text = [NSString stringWithFormat:NSLocalizedString(@"riesgoExpLabel", nil), riesgoExp];
        
        if (reduccionRiesAbs < 10) reducRiesgoAbs95.text = [NSString stringWithFormat:NSLocalizedString(@"RRA95LabelSmall", nil), reduccionRiesAbs, intConf95InfRra, intConf95SupRra];
        else reducRiesgoAbs95.text = [NSString stringWithFormat:NSLocalizedString(@"RRA95Label", nil), reduccionRiesAbs, intConf95InfRra, intConf95SupRra];
        
        riesgoRelativo95Label.text = [NSString stringWithFormat:NSLocalizedString(@"riesgoRelaLabel", nil), riesgoRelativo];
        nNTCalculado = 100/reduccionRiesAbs;
        
        NSString *nnTPuntualString, *nnTInfString, *nnTSupString, *nnTFinalString;
        if (intConf95InfRra > 0) {
            nnTPuntualString = [NSString stringWithFormat:@"NNT %0.1f,", nNTCalculado];
            nnTInfString = [NSString stringWithFormat:@"%0.0f", nntSupFloat];
            nnTSupString = [NSString stringWithFormat:@"%0.0f", nntInfFloat];
            nnTFinalString = [NSString stringWithFormat:NSLocalizedString(@"NNTInterpretacion", nil), nnTPuntualString, nnTInfString, NSLocalizedString(@"NNTInterpretacionConexionA", nil), nnTSupString];
            
        } else {
            nnTInfString = [NSString stringWithFormat:@"NNH %0.0f", fabsf(nntInfFloat)];

            if (reduccionRiesAbs > 0) {
                nnTPuntualString = [NSString stringWithFormat:@"NNT %0.1f,", nNTCalculado];
                nnTSupString = [NSString stringWithFormat:@"NNT %0.0f", nntSupFloat];
                nnTFinalString = [NSString stringWithFormat:NSLocalizedString(@"NNTInterpretacion", nil), nnTPuntualString, nnTInfString, NSLocalizedString(@"NNTInterpretacionConexionInfinito", nil), nnTSupString];

            } else {
                nnTPuntualString = [NSString stringWithFormat:@"NNH %0.1f", fabsf(nNTCalculado)];
                if (intConf95SupRra > 0) {
                    nnTSupString = [NSString stringWithFormat:@"NNT %0.0f", nntSupFloat];
                    nnTFinalString = [NSString stringWithFormat:NSLocalizedString(@"NNTInterpretacion", nil), nnTPuntualString, nnTInfString, NSLocalizedString(@"NNTInterpretacionConexionInfinito", nil), nnTSupString];

                } else {
                    nnTSupString = [NSString stringWithFormat:@"NNH %0.0f", fabsf(nntSupFloat)];
                    nnTFinalString = [NSString stringWithFormat:NSLocalizedString(@"NNTInterpretacion", nil), nnTPuntualString, nnTInfString, NSLocalizedString(@"NNTInterpretacionConexionA", nil), nnTSupString];

                }
                
            }
            
        }
        
        nntLabel.text = nnTFinalString;
        nntString = nnTFinalString; //Para llevarla al dic que se pasa al VC grafico
        
        [dicResultados setObject:[NSNumber numberWithFloat:nNTCalculado] forKey:@"nnt"];
        [dicResultados setObject:[NSNumber numberWithFloat:nntInfFloat] forKey:@"nnt95Inf"];
        [dicResultados setObject:[NSNumber numberWithFloat:nntSupFloat] forKey:@"nnt95Sup"];
        
        [self.tableView beginUpdates];
        interprVsGrafico.hidden = NO;
        [self.tableView endUpdates];

        activaBoton = YES;
        
    } else {
        
        riesgoExpLabel.text = NSLocalizedString(@"riesgoExpLabelVacia", nil);
        riesgoControlLabel.text = NSLocalizedString(@"riesgoConLabelVacia", nil);
        riesgoRelativo95Label.text = NSLocalizedString(@"riesgoRelLabelVacia", nil);
        reducRiesgoAbs95.text = NSLocalizedString(@"reducRiesgoAbs95LabelVacia", nil);
        nntLabel.text = @"NNT:";
        
        [self.tableView beginUpdates];
        interprVsGrafico.hidden = YES;
        [self.tableView endUpdates];
    }
    
    if (activaBoton && lectCrit)     footerBoton.enabled = YES;
    
}

- (IBAction)calculaNNTDesdeRiesgos:(id)sender {
    
    //SI SE METE UN VALOR QUE EXCEDA DE 0-100 BORRA ESE CAMPO Y SACA UNA ALERTA EXPLICÁNDOLO
    if (rAbsCon.text.floatValue >100 || rAbsCon.text.floatValue < 0 || rAbsExp.text.floatValue > 100 || rAbsExp.text.floatValue < 0) {
        
        if (sender == rAbsExp) {
            rAbsExp.text = nil;
        } else {
            rAbsCon.text = nil;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ValorNoValido", nil) message:NSLocalizedString(@"ValorValido", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"De acuerdo", nil)  otherButtonTitles:nil];
        [alert show];
    }

    BOOL activaBoton = NO;
    if (rAbsCon.text.length > 0 && rAbsExp.text.length > 0) {
        
        float reducRiesAbs = rAbsCon.text.floatValue - rAbsExp.text.floatValue;
        float riesgoRelativo = rAbsExp.text.floatValue / rAbsCon.text.floatValue;
        float nNTCalc = 100 / reducRiesAbs;
        float redRieRel = 1-riesgoRelativo;
        
        //Los muestra en las etiquetas. La de NNT cambia si el valor no es significativo.
        reducRiesgoAbsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"RRALabel", nil), reducRiesAbs];
        riesgoRelativoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"riesgoRelaLabel", nil), riesgoRelativo];
        reducRiesgorelativo.text = [NSString stringWithFormat:NSLocalizedString(@"RRRLabel", nil), redRieRel];
        nntLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NNTLabel", nil), nNTCalc];
        
        //Los copia para copiaResultados
        riesgoBasalUsuarioParaCopiaResultados = rAbsCon.text.floatValue;
        reduccionRiesAbsParaCopiaResultado = reducRiesAbs;
        nNTCalculadoParaCopiaResultado = nNTCalc;
        [dicResultados setObject:[NSNumber numberWithFloat:rAbsCon.text.floatValue] forKey:@"rieBasal"];
        [dicResultados setObject:[NSNumber numberWithFloat:reducRiesAbs] forKey:@"rra"];
        [dicResultados setObject:[NSNumber numberWithFloat:nNTCalc] forKey:@"nnt"];

        activaBoton = YES;
        
    } else {
        reducRiesgoAbsLabel.text = NSLocalizedString(@"reducRiesgoAbsLabelVacia", nil);
        riesgoRelativoLabel.text = NSLocalizedString(@"riesgoRelLabelVacia", nil);
        reducRiesgorelativo.text = NSLocalizedString(@"redRisrelLabVacia", nil);
        nntLabel.text = @"NNT:";
    }
    
    if (activaBoton && lectCrit)     footerBoton.enabled = YES;

}

- (IBAction)copiaResultados:(id)sender {
    //Prepara textos distintos para el comentario de la pregunta y el comentario general de la lectura crítica
    NSString *resultadosComentPreg, *resultadosComentGen;
    if (absOraw.selectedSegmentIndex == 0) {
        resultadosComentPreg = [NSString stringWithFormat:NSLocalizedString(@"ResultadosRCTDesdeRiesgos", nil),
                            [[dicResultados objectForKey:@"nnt"] floatValue],
                            [[dicResultados objectForKey:@"rieBasal"] floatValue],
                            [[dicResultados objectForKey:@"rra"] floatValue]];
        
        resultadosComentGen = [NSString stringWithFormat:NSLocalizedString(@"ResultadosRCTGen", nil),
                                 [[dicResultados objectForKey:@"nnt"] floatValue],
                                 [[dicResultados objectForKey:@"rieBasal"] floatValue]];

    } else {
        resultadosComentPreg = [NSString stringWithFormat:NSLocalizedString(@"ResultadosRCTDesdeRaw", nil),
                                [[dicResultados objectForKey:@"expSi"] floatValue],
                                [[dicResultados objectForKey:@"expTotal"] floatValue],
                                [[dicResultados objectForKey:@"controlSi"] floatValue],
                                [[dicResultados objectForKey:@"controlTotal"] floatValue],
                                [[dicResultados objectForKey:@"nnt"] floatValue],
                                [[dicResultados objectForKey:@"nnt95Inf"] floatValue],
                                [[dicResultados objectForKey:@"nnt95Sup"] floatValue],                                
                                [[dicResultados objectForKey:@"rieBasal"] floatValue]];
        

        resultadosComentGen = [NSString stringWithFormat:NSLocalizedString(@"ResultadosRCTGen", nil),
                               [[dicResultados objectForKey:@"nnt"] floatValue],
                               [[dicResultados objectForKey:@"rieBasal"] floatValue]];
        
    }
    
    NSMutableString *comentarioContenido;
    if (lectCrit.comentario) {
        comentarioContenido = [[NSMutableString alloc] initWithString:lectCrit.comentario];
        [comentarioContenido appendString:resultadosComentGen];
        
    } else {
        comentarioContenido = [[NSMutableString alloc] initWithString:resultadosComentGen];
        
    }
    
    //Pone el texto correspondeinte al comentario general de la lectura
    lectCrit.comentario = comentarioContenido;
    
    //Pone el comentario de la pregunta en su lugar de la lectura crítica
    [lectCrit.relacionRespuestas setValue:resultadosComentPreg forKey:comentarioNumero];
    
    // Save the object to persistent store
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
 
    //Elimina el botón OK al retirar el teclado
    self.navigationItem.rightBarButtonItem = nil;    
    
    //Desplazar la tabla hacia arriba y que no tapa los campos con el teclado. En JournalClub lo hacemos de otra forma más sencilla (aumentar el contentInset de la tabla en la altura del keyboard y luego scroll NO HACE FALTA EN IOS 7 Y 8
    //[self animateTextField: textField up: NO];
    
}	

-(IBAction)ocultaTeclado:(id)sender {
    
    //Obtiene la tag del campo de texto en el que se encuentre el foco, para hacer unas cosas u otras. No puedo pregunta directamente el tag del sender porque en mi ejemplo el sender es siempre el botón Ok, no el campo de texto directamente
    
    //finalmente retira el teclado
    [controlNo resignFirstResponder];
    [controlSi resignFirstResponder];
    [expNo resignFirstResponder];
    [expSi resignFirstResponder];
    [rAbsCon resignFirstResponder];
    [rAbsExp resignFirstResponder];
    
}

-(IBAction)interpretaVsGrafica:(id)sender {
    
    if (interprVsGrafico.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"NNTInterpretacion" sender:self];
        
    } else if (interprVsGrafico.selectedSegmentIndex == 1) {
        
        //Ocultar el tecjado si estaba presente, que si no al volver del gráfico da problemas de colocación de la vista y el teclado.
        [self ocultaTeclado:self];
        
        [self performSegueWithIdentifier:@"NNTCalcAGrafico2" sender:self];

    }
    
    //Deselecciona el segmento seleccionado, dejando todos deseleccionados. Si hago lo de especificar el segmento "-1" se disparan los métodos de todos los segmentos y da errores de navegación o pantallas no deseadas.
    [interprVsGrafico setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //PAra fromar el grafico pasa los datos necesarios a GraficoView2 en un dic. Para enviar los float a otro ViewController empaquetados en un NSDictionary, tiene que ir envueltos (wraped) en un objeto, porque los float, int, ... son "tipos básicos" no son objetos, y en el diccionario tiene que ir objetos. Envolverlos por ejemplo en NSNumber. Los objetos NSString, objetos son.
    NSNumber *intConf95InfRraNumber = [NSNumber numberWithFloat:intConf95InfRra];
    NSNumber *intConf95SupRraNumber = [NSNumber numberWithFloat:intConf95SupRra];
    NSNumber *riesgoBasalNumber = [NSNumber numberWithFloat:riesgoBasal];
    NSNumber *reducRANumber = [NSNumber numberWithFloat:reduccionRiesAbs];
    
    NSDictionary *datosDicIni = [[NSDictionary alloc] initWithObjectsAndKeys:intConf95InfRraNumber, @"ic95InfRra",intConf95SupRraNumber, @"ic95SupRra", riesgoBasalNumber, @"riesgoBasal", reducRANumber, @"RRA", nntString, @"interpretacion", nil];

    if ([[segue identifier] isEqualToString:@"NNTCalcAGrafico2"]) {
    
        Grafico2ViewController *graficoVC = [segue destinationViewController];
        NSMutableDictionary *dicMutable = [NSMutableDictionary dictionaryWithDictionary:datosDicIni];
        graficoVC.datosDic = dicMutable; //--pass nodeID from ViewNodeViewController
        
    } else if ([[segue identifier] isEqualToString:@"NNTInterpretacion"]) {
        TiemposNNTTableViewController *interpretacionVC = [segue destinationViewController];
        interpretacionVC.resultadosDic = datosDicIni;
        
    }

}

@end
