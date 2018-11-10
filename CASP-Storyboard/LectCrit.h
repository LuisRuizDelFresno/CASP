//
//  LectCrit.h
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 11/07/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"
#import "Respuestas.h"
#import "Revisor.h"
#import "Etiquetas.h"

//@class Etiquetas, Respuestas, Revisor;

@interface LectCrit : ExtendedManagedObject

@property (nonatomic, strong) NSString  * titulo;
@property (nonatomic, strong) NSString  * tipoArt;

@property (nonatomic, strong) NSString  * revista;

@property (nonatomic, strong) NSDate    * fecha;

@property (nonatomic, strong) NSString  * comentario;
@property (nonatomic, strong) NSString  * modificable;      //**********

@property (nonatomic, strong) NSString  * pubmedID;
@property (nonatomic, strong) NSString  * etiquetaIndice;

@property (nonatomic, strong) NSSet     *relacionEtiquetas;
@property (nonatomic, strong) Respuestas *relacionRespuestas;
@property (nonatomic, strong) Revisor   *relacionRevisor;

@end

@interface LectCrit (CoreDataGeneratedAccessors)

- (void)addRelacionEtiquetasObject:(Etiquetas *)value;
- (void)removeRelacionEtiquetasObject:(Etiquetas *)value;
- (void)addRelacionEtiquetas:(NSSet *)values;
- (void)removeRelacionEtiquetas:(NSSet *)values;
@end
