//
//  Grafico2ViewController.h
//  CASP
//
//  Created by Luis Ruiz del Fresno on 18/04/14.
//  Copyright (c) 2014 Luis Ruiz del Fresno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraficoView2;

@interface Grafico2ViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *datosDic;
@property (nonatomic, strong) GraficoView2 *grafico;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentado;

- (IBAction)pulsoSegmentado:(id)sender;

@end

