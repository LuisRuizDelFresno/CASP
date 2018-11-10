//
//  ComentarioViewController.h
//  CASP
//
//  Created by Luis Ruiz del Fresno on 15/1/15.
//  Copyright (c) 2015 Luis Ruiz del Fresno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LectCrit.h"

@interface ComentarioViewController : UIViewController

@property (nonatomic, strong)           LectCrit                  *lecturaCritica; //Entidad que le pasan
@property (nonatomic, strong)           NSManagedObjectContext    *context;

@end

