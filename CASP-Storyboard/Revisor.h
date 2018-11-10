//
//  Revisor.h
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 11/07/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ExtendedManagedObject.h"

@class LectCrit;

@interface Revisor : ExtendedManagedObject //NSManagedObject

@property (nonatomic, strong) NSString * revisorEmail;
@property (nonatomic, strong) NSString * revisorID;
@property (nonatomic, strong) NSString * revisorNombre;
@property (nonatomic, strong) NSSet *relacionLectCrit;
@end

@interface Revisor (CoreDataGeneratedAccessors)

- (void)addRelacionLectCritObject:(LectCrit *)value;
- (void)removeRelacionLectCritObject:(LectCrit *)value;
- (void)addRelacionLectCrit:(NSSet *)values;
- (void)removeRelacionLectCrit:(NSSet *)values;
@end
