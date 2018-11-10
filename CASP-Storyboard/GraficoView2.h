//
//  GraficoView2.h
//  Calculadora
//
//  Created by Luis Ruiz del Fresno on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraficoView2 : UIView {
    float ic95SupFloat;
    float ic95InfFloat;
    float riesgoBasal;

    float rraFloat;
    float rangoEscala;
    float limIzq;
    float inteSup;
    float centro;
    float inteInf;
    float sobreCero;
    float bajoCero;
    float limDcho;
    
    NSDictionary *datosDic;
}

@property (nonatomic, strong) NSDictionary *datosDic;

@end
