//
//  NNTViewController.h
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NumberKeypadDecimalPoint.h"
#import "LectCrit.h"

@interface NNTViewController : UITableViewController  <UITextFieldDelegate> {
    
    UILabel *nntLabel;
    
    UISegmentedControl *absOraw;
    UILabel *tituloHeader;
    
    UITextField *controlNo;
    UITextField *controlSi;
    UITextField *expNo;
    UITextField *expSi;
    UITextField *rAbsExp;
    UITextField *rAbsCon;
    
    UILabel *riesgoControlLabel;
    UILabel *riesgoExpLabel;
    UILabel *reducRiesgoAbs95;
    UILabel *riesgoRelativo95Label;
    UILabel *reducRiesgoAbsLabel;
    UILabel *riesgoRelativoLabel;
    UILabel *reducRiesgorelativo;
    
    float riesgoBasal;
    float reduccionRiesAbs;
    float intConf95SupRra;
    float intConf95InfRra;
    float nNTCalculado;
    
    float riesgoBasalUsuarioParaCopiaResultados;
    float reduccionRiesAbsParaCopiaResultado;
    float nNTCalculadoParaCopiaResultado;

    UISegmentedControl *interprVsGrafico;
    UIActionSheet *actionSheet;
    UIPickerView *picker;
    NSArray *periodosArray;
    NSArray *tiemposArray;

    LectCrit *lectCrit;
    NSManagedObjectContext *context;
    NSString *nntString;
    
    UIButton *footerBoton;
    
    NSString *comentarioNumero;
    NSMutableDictionary *dicResultados;

}

@property (nonatomic, strong) IBOutlet UILabel *nntLabel;

@property (nonatomic, strong) IBOutlet UISegmentedControl *absOraw;
@property (nonatomic, strong) IBOutlet UILabel *tituloHeader;

@property (nonatomic, strong) IBOutlet UITextField *controlNo;
@property (nonatomic, strong) IBOutlet UITextField *controlSi;
@property (nonatomic, strong) IBOutlet UITextField *expNo;
@property (nonatomic, strong) IBOutlet UITextField *expSi;
@property (nonatomic, strong) IBOutlet UITextField *rAbsExp;
@property (nonatomic, strong) IBOutlet UITextField *rAbsCon;

@property (nonatomic, strong) IBOutlet UILabel *riesgoControlLabel;
@property (nonatomic, strong) IBOutlet UILabel *riesgoExpLabel;
@property (nonatomic, strong) IBOutlet UILabel *reducRiesgoAbs95;
@property (nonatomic, strong) IBOutlet UILabel *riesgoRelativo95Label;
@property (nonatomic, strong) IBOutlet UILabel *reducRiesgoAbsLabel;
@property (nonatomic, strong) IBOutlet UILabel *riesgoRelativoLabel;
@property (nonatomic, strong) IBOutlet UILabel *reducRiesgorelativo;

@property (nonatomic, strong) IBOutlet UISegmentedControl *interprVsGrafico;
@property (nonatomic, strong)          UIActionSheet *actionSheet;
@property (nonatomic, strong)          UIPickerView *picker;
@property (nonatomic, strong)          NSArray *periodosArray;
@property (nonatomic, strong)          NSArray *tiemposArray;

@property (nonatomic, strong) LectCrit                  *lectCrit;
@property (nonatomic, strong) NSManagedObjectContext    *context;
@property (nonatomic, strong) NSString *nntString;

@property (nonatomic, strong) IBOutlet UIButton *footerBoton;

@property (nonatomic, strong) NSString *comentarioNumero;
@property (nonatomic, strong) NSMutableDictionary *dicResultados;

-(IBAction)cambiaCeldaNNT:(id)sender;
-(IBAction)calculaNNTRaw:(id)sender;
- (IBAction)calculaNNTDesdeRiesgos:(id)sender;
-(IBAction)ocultaTeclado:(id)sender;
- (IBAction)copiaResultados:(id)sender;

@end
