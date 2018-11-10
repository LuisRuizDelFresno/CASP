//
//  PlantillaDetalleViewController.h
//  TableSearch
//
//  Created by Luis Ruiz del Fresno on 27/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LectCrit.h"
#import "PregViewController.h"

@interface PlantillaDetalleViewController : UITableViewController <PregViewControllerDelegate> {
    NSString        *recibeColor;
    NSString        *nombrePlantillaCorto;
    NSString        *plantillaID;
    NSMutableArray  *tipoArtiPregArray;
    UILabel         *muestraColor;
    NSIndexPath     *celdaSeleccionadaD;
    
    NSManagedObjectContext  *context;
    LectCrit                *laLectCrit;
    
}

@property (nonatomic, strong) NSString *plantillaID;
@property (nonatomic, strong) NSString *nombrePlantillaCorto;
@property (nonatomic, strong) NSString *recibeColor;
@property (nonatomic, strong) NSMutableArray *tipoArtiPregArray;
@property (nonatomic, strong) UILabel *muestraColor;
@property (nonatomic, strong) NSIndexPath *celdaSeleccionadaD;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) LectCrit *laLectCrit;

-(IBAction)customActionPressed:(id)sender;

@end
