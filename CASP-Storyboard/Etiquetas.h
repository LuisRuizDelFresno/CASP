//
//  Etiquetas.h
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 13/07/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"

@class LectCrit;

@interface Etiquetas : ExtendedManagedObject //NSManagedObject

@property (nonatomic, strong) NSString * etiquetaNombre;
@property (nonatomic, strong) NSSet *relacionLectCrit;
@end

@interface Etiquetas (CoreDataGeneratedAccessors)

- (void)addRelacionLectCritObject:(LectCrit *)value;
- (void)removeRelacionLectCritObject:(LectCrit *)value;
- (void)addRelacionLectCrit:(NSSet *)values;
- (void)removeRelacionLectCrit:(NSSet *)values;

@end
