//
//  GlosarioMenuViewController.h
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCASPeViewController.h"

//HABRÍA QUE QUITAR LA DELEGACIÓN DE AQUÍ Y PASARLA A VIEWDIDLOAD O SIMILAR CONDICIONADA AL IUOS DEL DISPOSITIVO.

@interface GlosarioMenuViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    
    //UISearchControllerDelegate
    NSMutableArray *glosarioArray;
    NSMutableArray *glosarioFiltradoArray;
    NSMutableArray *titulosSeccion;
    BOOL			searchWasActive;
    
}

@property (nonatomic, strong) NSMutableArray *glosarioArray;
@property (nonatomic, strong) NSMutableArray *glosarioFiltradoArray;
@property (nonatomic, strong) NSMutableArray *titulosSeccion;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@end
