//
//  DiagViewController.h
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LectCrit.h"
#import "Respuestas.h"
//#import "HeaderViewController.h"

@interface DiagViewController : UITableViewController <UITextFieldDelegate> { //HeaderViewControllerDelegate
    
    UISegmentedControl *rvseControl;
    UISegmentedControl *posnegControl;
    UISegmentedControl *posnegControlRaw;
    
    UISlider *preSlider;
    
    UITextField *rvTextField;
    UITextField *sensTextField;
    UITextField *espeTextField;
    UITextField *testPosGSPos;
    UITextField *testNegGSPos;
    UITextField *testPosGSNeg;
    UITextField *testNegGSNeg;    
    UILabel *senIC95Label;
    UILabel *espeIC95Label;
    UILabel *rvIC95Label;
    
    UILabel *preLabel;
    UILabel *postLabel;
    UILabel *rvCalcLabel;
    float rvCalculado;
    float rvCalcRaw;
    float probPostFloat;
    
    UIButton *footerBoton;
    float rvParaComentario;
    LectCrit *lectCrit;
    NSManagedObjectContext *context;
    NSString *comentarioNumero;
    NSMutableDictionary *dicResultados;
    
}

@property (nonatomic, strong) IBOutlet UISlider *preSlider;

@property (nonatomic, strong) UISegmentedControl *rvseControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *posnegControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *posnegControlRaw;

@property (nonatomic, strong) IBOutlet UITextField *rvTextField;
@property (nonatomic, strong) IBOutlet UITextField *sensTextField;
@property (nonatomic, strong) IBOutlet UITextField *espeTextField;
@property (nonatomic, strong) IBOutlet UITextField *testPosGSPos;
@property (nonatomic, strong) IBOutlet UITextField *testNegGSPos;
@property (nonatomic, strong) IBOutlet UITextField *testPosGSNeg;
@property (nonatomic, strong) IBOutlet UITextField *testNegGSNeg;    

@property (nonatomic, strong) IBOutlet UILabel *preLabel;
@property (nonatomic, strong) IBOutlet UILabel *postLabel;
@property (nonatomic, strong) IBOutlet UILabel *rvCalcLabel;

@property (nonatomic, strong) IBOutlet UILabel *rvIC95Label;
@property (nonatomic, strong) IBOutlet UILabel *senIC95Label;
@property (nonatomic, strong) IBOutlet UILabel *espeIC95Label;

@property (nonatomic, strong) IBOutlet UIButton *footerBoton;
@property (nonatomic, strong) LectCrit                  *lectCrit;
@property (nonatomic, strong) NSManagedObjectContext    *context;
@property (nonatomic, strong) NSString              *comentarioNumero;
@property (nonatomic, strong) NSMutableDictionary   *dicResultados;

- (IBAction)rvOse:(UISegmentedControl *)segmentado;
- (IBAction)calcula:(id)sender;
- (IBAction)calculaDesdeSE:(id)sender;
- (IBAction)calculaDiagDesdeRaw:(id)sender;
- (IBAction)copiaResultados:(id)sender;

@end
