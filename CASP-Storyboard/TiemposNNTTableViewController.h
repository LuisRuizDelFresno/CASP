//
//  TiemposNNTTableViewController.h
//  CASP
//
//  Created by Luis Ruiz del Fresno on 04/04/14.
//  Copyright (c) 2014 Luis Ruiz del Fresno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TiemposNNTTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    BOOL    rowTtoPicker;
    BOOL    rowSeguimientoPicker;
    BOOL    rowInterpretacion;

}

@property (nonatomic, strong) NSArray *tiemposArray;
@property (nonatomic, strong) NSArray *periodosArray;
@property (nonatomic, strong) IBOutlet UISwitch *interpretacionSwitch;
@property (nonatomic, strong) NSString *tiempoTto;
@property (nonatomic, strong) NSString *tiempoSeguimiento;
@property (nonatomic, strong) NSDictionary *resultadosDic;
@property (nonatomic, strong) IBOutlet UITextView *elTextView;

- (IBAction)interpretaSwitch:(id)sender;

@end
