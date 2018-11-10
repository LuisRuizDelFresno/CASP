/*
 ModelGlosario.h
 Es clase personal para definir las características del objeto modelo: una glosa.
 Tiene 4 propiedades que son: 3 de ellas las del plist original (el término, la definición y el grupo)
 y una numérica para almacenar el número del array de sección que le sea asignado.
 
 //  Created by Luis Ruiz del Fresno on 16/10/11.
 //  Copyright 2011 __MyCompanyName__. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface ModelGlosario : NSObject {
    NSString *termino;
    NSString *definicion;
    NSString *grupo;
    NSInteger numeroSeccion;
}

@property (nonatomic, copy) NSString *termino;
@property (nonatomic, copy) NSString *definicion;
@property (nonatomic, copy) NSString *grupo;
@property NSInteger numeroSeccion;

@end
