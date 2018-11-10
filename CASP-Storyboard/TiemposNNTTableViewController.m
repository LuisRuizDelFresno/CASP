//
//  TiemposNNTTableViewController.m
//  CASP
//
//  Created by Luis Ruiz del Fresno on 04/04/14.
//  Copyright (c) 2014 Luis Ruiz del Fresno. All rights reserved.
//

#import "TiemposNNTTableViewController.h"

@interface TiemposNNTTableViewController ()

@end

@implementation TiemposNNTTableViewController

#define CELL_MARGIN                 2.0f
#define MargenInternoTextView       8.0f
#define CELL_WIDTH_Grouped          295.0f
#define FONT_SIZE                   [UIFont systemFontOfSize:14.0f]

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
    
    //------------------------------------------------------------------------------------------
    // TITULO NAV BAR
    self.title = NSLocalizedString(@"InterpretacionNNT", nil);
    
    //------------------------------------------------------------------------------------------
    // PARA MOSTRAR U OCULTAR LA CELDA DE IMPORTAR LA CITA O ESCOGER FECHA
    rowTtoPicker = FALSE;
    rowSeguimientoPicker = FALSE;
    rowInterpretacion = FALSE;
    
    _tiemposArray = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
    _periodosArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"día/s", nil), NSLocalizedString(@"semana/s", nil), NSLocalizedString(@"mes/es", nil), NSLocalizedString(@"año/s", nil), nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0)     return _tiemposArray.count;
    return _periodosArray.count;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0)     return _tiemposArray[row];
    
    return _periodosArray[row];
    
}

- (IBAction)interpretaSwitch:(id)sender {
    
    if (_interpretacionSwitch.on){
        //No le doy tamaño al textview porque se lo doy a la row (ajustado al texto), y la row tiene constraints en el Stroyboard que determinan el tamaño del TextView (fijando su limtes respecto a los de la contentView de la celda.
        _elTextView.text = [self construyeInterpretacionConTiempoTto];
        
        rowInterpretacion = TRUE;
        rowSeguimientoPicker = FALSE;
        rowTtoPicker = FALSE;
        
    } else {
        rowInterpretacion = FALSE;
        
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView.tag == 0) {
        NSString *tiempo, *periodo;
        tiempo = [_tiemposArray objectAtIndex:[pickerView selectedRowInComponent:0]];
        periodo = [_periodosArray objectAtIndex:[pickerView selectedRowInComponent:1]];
        
        _tiempoTto = [NSString stringWithFormat:@"%@ %@", tiempo, periodo];
        
        UITableViewCell *celda = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        celda.detailTextLabel.text = _tiempoTto;
        
    } else if (pickerView.tag == 1) {
        NSString *tiempo, *periodo;
        tiempo = [_tiemposArray objectAtIndex:[pickerView selectedRowInComponent:0]];
        periodo = [_periodosArray objectAtIndex:[pickerView selectedRowInComponent:1]];
        
        _tiempoSeguimiento = [NSString stringWithFormat:@"%@ %@", tiempo, periodo];
        
        UITableViewCell *celda = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        celda.detailTextLabel.text = _tiempoSeguimiento;
        
    }

}

#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat alturaRow = 44;
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (!rowTtoPicker)  alturaRow = 0;
        else alturaRow = 240;
        
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        if (!rowSeguimientoPicker)  alturaRow = 0;
        else                        alturaRow = 240;
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        if (!rowInterpretacion) {
            //La idea inicial era darle de altura 0, como otras tablas, pero aquí desencadena un conflicto de constraints que se resuleve dandole 1 punto de altura. Quizás en las otras tablas funcione el 0 por que son dinámicas y en esta no por ser estática.
            alturaRow = 1;
            
        } else {
            alturaRow = [self calculaAlturaTextViewParaTexto:[self construyeInterpretacionConTiempoTto]] + 1;

        }
    }
    
    return alturaRow;
    
}

- (CGFloat )calculaAlturaTextViewParaTexto:(NSString *)texto {
    
    CGSize constraint = CGSizeMake(CELL_WIDTH_Grouped - (CELL_MARGIN * 2) - (MargenInternoTextView *2), 20000.0f);
    
    CGSize sizeTextoCalculado;
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary * attributes = @{NSFontAttributeName : FONT_SIZE,
                                  NSParagraphStyleAttributeName : paragraphStyle};
    
    sizeTextoCalculado = [texto boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil].size;
    
    CGFloat heightTextViewCalculado = MAX(sizeTextoCalculado.height + (MargenInternoTextView * 2), 44);
    
    return heightTextViewCalculado;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //Hacer 2 cosas: desplegar_recoger la row 2 de la seccion 0 + invertir el triangulito de la row 1.
    //Para cada una de esa acciones aisladas no hace falta el bloque de beginUpdates ... endUpdates. Pero para hacerlo conjuntamente sí:
    [self.tableView beginUpdates];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
    
            if (!rowTtoPicker ) {
                rowTtoPicker = TRUE;
                rowSeguimientoPicker = FALSE;
                rowInterpretacion = FALSE;
                [_interpretacionSwitch setOn:NO];
                
            } else {
                rowTtoPicker = FALSE;
        
            }
            
        } else if (indexPath.row == 2) {
            if (!rowSeguimientoPicker) {
                rowSeguimientoPicker = TRUE;
                rowTtoPicker = FALSE;
                rowInterpretacion = FALSE;
                [_interpretacionSwitch setOn:NO];

            } else {
                rowSeguimientoPicker = FALSE;
                
            }

        }
    
    }
    
    [self.tableView endUpdates];

}

- (NSString *)construyeInterpretacionConTiempoTto {
    NSString *nntString;
    if (_tiempoTto && _tiempoSeguimiento) {
        rowSeguimientoPicker = FALSE;
        rowTtoPicker = FALSE;
        
        float rBasal        = [[_resultadosDic objectForKey:@"riesgoBasal"] floatValue];
        float rRA           = [[_resultadosDic objectForKey:@"RRA"] floatValue];
        float ic95SupRRA    = [[_resultadosDic objectForKey:@"ic95SupRra"] floatValue];  //intConf95SupRra;
        float ic95InfRRA    = [[_resultadosDic objectForKey:@"ic95InfRra"] floatValue];// intConf95InfRra;
        
        float intConf95SupNnt = 100/ic95SupRRA;
        float intConf95InfNnt = 100/ic95InfRRA;
    
        float nNTCalculadoAbsoluto, intConf95InfNntAbsoluto, intConf95SupNntAbsoluto;
        float nNTCalculado = 100/rRA;
                              
        if (nNTCalculado < 0)   nNTCalculadoAbsoluto = nNTCalculado * -1;
        else                    nNTCalculadoAbsoluto = nNTCalculado;
    
        if (intConf95InfNnt < 0) intConf95InfNntAbsoluto = intConf95InfNnt * -1;
        else                    intConf95InfNntAbsoluto = intConf95InfNnt;
    
        if (intConf95SupNnt < 0) intConf95SupNntAbsoluto = intConf95SupNnt * -1;
        else                     intConf95SupNntAbsoluto = intConf95SupNnt;
    
        //Interpretación del IC95% del NNT. Construida en 3 segmentos de párrafo según los signos, ... La muestra en UIAlertView
        //En los IC del NNT mantengo el nombre sup e inf que viene de los IC del RRA, aunque a veces (vg Altman BMJ 1998;317:1309–12) se escriban los del NNT intercambiándolos (IC95%_SUP_NNT el que resulta de 100/IC95%_Inf_RRA, ...) para que se asemejen a los del RRA, ... Mantener INF_NNT de INF_RRA y SUP_NNT de SUP_RRA permite representar gráficamente las dos escalas al tiempo y entender mejor que cuanto más alto el valor de NNT menor es el beneficio, ...
    
        NSString *nntString1    = [NSString stringWithFormat:NSLocalizedString(@"bloque 1", nil), [[_resultadosDic objectForKey:@"riesgoBasal"]    floatValue], _tiempoSeguimiento]; // riesgoBasal,
        NSString *nntString21   = [NSString stringWithFormat:NSLocalizedString(@"bloque 2.1", nil), _tiempoTto, nNTCalculadoAbsoluto, intConf95SupNntAbsoluto, intConf95InfNntAbsoluto];
        NSString *nntString22   = [NSString stringWithFormat:NSLocalizedString(@"bloque 2.2", nil), _tiempoTto];
        NSString *nntString23   = [NSString stringWithFormat:NSLocalizedString(@"bloque 2.3", nil), _tiempoTto, nNTCalculadoAbsoluto, intConf95InfNntAbsoluto, intConf95SupNntAbsoluto];
        NSString *nntString31   = [NSString stringWithFormat:NSLocalizedString(@"bloque 3.1", nil), nNTCalculadoAbsoluto, intConf95SupNntAbsoluto, intConf95InfNntAbsoluto];
        NSString *nntString32   = [NSString stringWithFormat:NSLocalizedString(@"bloque 3.2", nil), nNTCalculadoAbsoluto, intConf95InfNntAbsoluto, intConf95SupNntAbsoluto];
        NSString *nntString4    = [NSString stringWithFormat:NSLocalizedString(@"bloque 4", nil)];
    
        //Primero para los SIG POS (el lim inf es pos);
        if (intConf95InfNnt >= 0) {
            //Para la coletilla de string 4. Para sugerir bioequivalencia usamos el criterio de que el beneficio máximo compatible con los datos sea menor que un RR del 20% o un NNT > 100.
            float rrLimInf = (rBasal - ic95SupRRA)/rBasal;

            if ((rrLimInf >= 0.8) || (intConf95InfNnt > 100)) nntString = [NSString stringWithFormat:@"%@%@ %@", nntString1, nntString21, nntString4];
            else                                              nntString = [NSString stringWithFormat:@"%@%@", nntString1, nntString21];
            
        } else {
            if (nNTCalculado >= 0 ) {
                float rrLimInf = (rBasal - ic95SupRRA)/rBasal;

                if ((rrLimInf >= 0.8) || (intConf95InfNnt > 100)) nntString = [NSString stringWithFormat:@"%@%@%@ %@", nntString1, nntString22, nntString31, nntString4];
                else                                              nntString = [NSString stringWithFormat:@"%@%@%@", nntString1, nntString22, nntString31];
            
            } else {
                if (intConf95SupNnt >= 0) {
                    float rrLimSup = (rBasal - ic95InfRRA)/rBasal;

                    if ((rrLimSup <= 1.2) || (intConf95InfNnt < -100)) {
                        nntString = [NSString stringWithFormat:@"%@%@%@ %@", nntString1, nntString22, nntString32, nntString4];
                    } else                         nntString = [NSString stringWithFormat:@"%@%@%@", nntString1, nntString22, nntString32];

                }
                else {
                    float rrLimSup = (rBasal - ic95InfRRA)/rBasal;
                    
                    if ((rrLimSup <= 1.2) || (intConf95InfNnt < -100)) {
                        //Para sugerir bioequivalencia usamos el criterio de que el perjuicio máximo compatible con los datos sea menor que un RR del 20% o un NNT > 100.
                        nntString = [NSString stringWithFormat:@"%@%@ %@", nntString1, nntString23, nntString4];
                        
                    } else {
                        nntString = [NSString stringWithFormat:@"%@%@", nntString1, nntString23];

                    }
                }
            }
        }
        
    } else {
        nntString = [NSString stringWithFormat:NSLocalizedString(@"NecesitaLosTiempos", nil)];
        
    }
    
    return nntString;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
