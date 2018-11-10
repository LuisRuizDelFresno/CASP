//
//  Respuestas.h
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 17/08/13.
//
//

#import <Foundation/Foundation.h>
#import "ExtendedManagedObject.h"
#import <CoreData/CoreData.h>

@class LectCrit;

@interface Respuestas : ExtendedManagedObject// NSManagedObject

@property (nonatomic, strong) NSString * plantillaID;
@property (nonatomic, strong) NSString * r0;
@property (nonatomic, strong) NSString * r1;
@property (nonatomic, strong) NSString * r2;
@property (nonatomic, strong) NSString * r3;
@property (nonatomic, strong) NSString * r4;
@property (nonatomic, strong) NSString * r5;
@property (nonatomic, strong) NSString * r6;
@property (nonatomic, strong) NSString * r7;
@property (nonatomic, strong) NSString * r8;
@property (nonatomic, strong) NSString * r9;
@property (nonatomic, strong) NSString * r10;
@property (nonatomic, strong) NSString * r11;
@property (nonatomic, strong) NSString * r12;
@property (nonatomic, strong) NSString * c0;
@property (nonatomic, strong) NSString * c1;
@property (nonatomic, strong) NSString * c2;
@property (nonatomic, strong) NSString * c3;
@property (nonatomic, strong) NSString * c4;
@property (nonatomic, strong) NSString * c5;
@property (nonatomic, strong) NSString * c6;
@property (nonatomic, strong) NSString * c7;
@property (nonatomic, strong) NSString * c8;
@property (nonatomic, strong) NSString * c9;
@property (nonatomic, strong) NSString * c10;
@property (nonatomic, strong) NSString * c11;
@property (nonatomic, strong) NSString * c12;
@property (nonatomic, strong) LectCrit *relacionLectCrit;

@end
