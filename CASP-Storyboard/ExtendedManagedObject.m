//
//Modificado de http://vladimir.zardina.org/2010/03/serializing-archivingunarchiving-an-nsmanagedobject-graph/ Contenía un warning ue he quitado aunque he dejado el código al que hacía referencia: #warning "Change CLASS_PREFIX if it's not ABC")


#import "ExtendedManagedObject.h"

@implementation ExtendedManagedObject

#define DATE_ATTR_PREFIX @"dAtEaTtr:"
#define CLASS_PREFIX @"ABC"

#pragma mark -
#pragma mark Dictionary conversion methods

/* Método trasladado a MenuVC
-(NSDictionary *)dictFromURL:(NSURL *)importURL {
    
    //Des-serializar un JSON
    //URL que trae datos JSON -> NSData [NSData dataWithContentOfURL] -> NSDict o NSArray [NSJSONSerialization JSONObjectWithData:options:error:]
    NSData *dataJson = [NSData dataWithContentsOfURL:importURL];
    
    NSError *error = nil;
    NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:dataJson
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    
    if(!myDictionary)   NSLog(@"Error: %@",error);
    
    return myDictionary;
    
 }
*/

- (NSData *)exportToNSData {
    
    //Convierte el objeto (estructura y contenido) en NSData; y lo comprime gracias al método gzDeflate de la extensióm de NSData: NSData+CocoaDevUsersAdditions.h
    NSDictionary *objetoParaExportarDict = [self toDictionary];
    
    NSError *error = nil;
    NSData *dataJson = [NSJSONSerialization dataWithJSONObject:objetoParaExportarDict options:NSJSONWritingPrettyPrinted error:&error];
    
    return dataJson;
}

- (NSDictionary *) toDictionaryWithTraversalHistory:(NSMutableArray*)traversalHistory {
    
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];

    NSMutableArray *localTraversalHistory = nil;
    
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableArray arrayWithCapacity:[attributes count] + [relationships count] + 1];
    } else {
        localTraversalHistory = traversalHistory;
    }
    
    [localTraversalHistory addObject:self];
    
    [dict setObject:[[self class] description] forKey:@"class"];
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        
        if (value != nil) {
            if ([value isKindOfClass:[NSDate class]]) {
                NSTimeInterval date = [(NSDate*)value timeIntervalSinceReferenceDate];
                NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
                [dict setObject:[NSNumber numberWithDouble:date] forKey:dateAttr];
            } else {
                [dict setObject:value forKey:attr];
            }
        }
    }
    
    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];
        
        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            
            // Our set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            
            for (ExtendedManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
                }
            }
            
            [dict setObject:[NSArray arrayWithArray:dictSet] forKey:relationship];
        }
        else if ([value isKindOfClass:[NSOrderedSet class]]) {
            // To-many relationship

            // The core data set holds an ordered collection of managed objects
            NSOrderedSet* relatedObjects = (NSOrderedSet*) value;

            // Our ordered set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];

            for (ExtendedManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
                }
            }

            [dict setObject:[NSOrderedSet orderedSetWithArray:dictSet] forKey:relationship];
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            
            ExtendedManagedObject* relatedObject = (ExtendedManagedObject*) value;
            
            if ([localTraversalHistory containsObject:relatedObject] == NO) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                //[dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory] forKey:relationship];
                
                //Modifico esta línea para que no se sigan las relaciones subsiguientes del objeto ya relacionado
                [dict setObject:[relatedObject toDictionarySinRelacionesSubsiguientes:localTraversalHistory] forKey:relationship];
            }
            
        }
    }
    
    if (traversalHistory == nil) {
        [localTraversalHistory removeAllObjects];
    }
    
    return dict;
}

- (NSDictionary *) toDictionarySinRelacionesSubsiguientes:(NSMutableArray*)traversalHistory {
    
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + 1];

    //NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    //NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[attributes count] + [relationships count] + 1];
    
    NSMutableArray *localTraversalHistory = nil;
    
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableArray arrayWithCapacity:[attributes count] + 1];
        
    } else {
        localTraversalHistory = traversalHistory;
        
    }
    
    [localTraversalHistory addObject:self];
    
    [dict setObject:[[self class] description] forKey:@"class"];
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        
        if (value != nil) {
            if ([value isKindOfClass:[NSDate class]]) {
                NSTimeInterval date = [(NSDate*)value timeIntervalSinceReferenceDate];
                NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
                [dict setObject:[NSNumber numberWithDouble:date] forKey:dateAttr];
            } else {
                [dict setObject:value forKey:attr];
            }
        }
    }
    
    if (traversalHistory == nil) {
        [localTraversalHistory removeAllObjects];
    }
    
    return dict;
}

- (NSDictionary*) toDictionary {
    return [self toDictionaryWithTraversalHistory:nil];
}

+ (id) decodedValueFrom:(id)codedValue forKey:(NSString*)key {
    if ([key hasPrefix:DATE_ATTR_PREFIX] == YES) {
        // This is a date attribute
        NSTimeInterval dateAttr = [(NSNumber*)codedValue doubleValue];
        
        return [NSDate dateWithTimeIntervalSinceReferenceDate:dateAttr];
    } else {
        // This is an attribute
        return codedValue;
    }
}

- (void) populateFromDictionary:(NSDictionary*)dict {
    //Obtiene una string del dic que si es class está indicando que su valor (value) es el nombre de una entity, dependiendo de si es un dic o un array o un set o no se qué de las fechas, va haciendo una cosa u otra. En el caso de las etiquetas es un set, lo pasa a un array de diccionarios y llama a otro método para crear objetos de esa entidad a partir de los diccionarios.
    //OJO: ¿es correcta esta línea?
    NSManagedObjectContext* context = [self managedObjectContext];
        
    for (NSString* key in dict) {
        if ([key isEqualToString:@"class"]) {
            continue;
        }
        
        NSObject* value = [dict objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject* relatedObject =
            [ExtendedManagedObject createManagedObjectFromDictionary:(NSDictionary*)value
                                                           inContext:context];
            
            [self setValue:relatedObject forKey:key];
            
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];
            
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                
                NSString *entidadString = [relatedObjectDict objectForKey:@"class"];
                NSString *entidadValor = [relatedObjectDict objectForKey:@"etiquetaNombre"];
                
                NSManagedObject* relatedObject = nil;

                if (entidadValor) {
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    fetchRequest.entity = [NSEntityDescription entityForName:entidadString inManagedObjectContext:context];
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"etiquetaNombre == %@", entidadValor]];
                    [fetchRequest setFetchLimit:1];
                    
                    NSError *error = nil;
                                
                    // if there's no object fetched, return nil
                    if ([context countForFetchRequest:fetchRequest error:&error] == 0) {
                        relatedObject = [ExtendedManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                                   inContext:context];
                        if (error != nil) {
                            NSLog(@"ERROR: %@ %@", [error localizedDescription], [error userInfo]);
                        }
                    } else {
                
                        // fetch your object
                        relatedObject = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
                        if (error != nil) {
                            NSLog(@"ERROR: %@ %@", [error localizedDescription], [error userInfo]);
                        }
                    }
                } else {
                
                    NSError *error = nil;
                    relatedObject = [ExtendedManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                         inContext:context];
                    if (error != nil) {
                        NSLog(@"ERROR: %@ %@", [error localizedDescription], [error userInfo]);
                    }
                }

                [relatedObjects addObject:relatedObject];
            }

        }
        else if ([value isKindOfClass:[NSOrderedSet class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableOrderedSet* relatedObjects = [self mutableOrderedSetValueForKey:key];

            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {

                NSString *entidadString = [relatedObjectDict objectForKey:@"class"];
                NSString *entidadValor = [relatedObjectDict objectForKey:@"etiquetaNombre"];
            
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.entity = [NSEntityDescription entityForName:entidadString inManagedObjectContext:context];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"etiquetaNombre == %d", entidadValor]];
                [fetchRequest setFetchLimit:1];
            
                NSError *error = nil;
                NSManagedObject* relatedObject = nil;
            
                // if there's no object fetched, return nil
                if ([context countForFetchRequest:fetchRequest error:&error] == 0) {

                    relatedObject = [ExtendedManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                                               inContext:context];
                } else {
                    
                    // fetch your object
                    relatedObject = [[context executeFetchRequest:fetchRequest error:&error] lastObject];
                    if (error != nil) {
                        NSLog(@"ERROR: %@ %@", [error localizedDescription], [error userInfo]);
                    }
                }
                [relatedObjects addObject:relatedObject];
            }

        }
        else if (value != nil) {
            
            if ([key hasPrefix:DATE_ATTR_PREFIX] == NO)
                [self setValue:[ExtendedManagedObject decodedValueFrom:value forKey:key] forKey:key];
            else {
                //  the entity Transaction is not key value coding-compliant for the key "dAtEaTtr:timestamp".
                NSString *originalKey = [key stringByReplacingOccurrencesOfString:DATE_ATTR_PREFIX withString:@""];
                [self setValue:[ExtendedManagedObject decodedValueFrom:value forKey:key] forKey:originalKey];
            }
        }
    }
}

+ (ExtendedManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                                   inContext:(NSManagedObjectContext*)context {
    NSString* class = [dict objectForKey:@"class"];

    // strip off class prefix, if the names in our data model don't match the class names!
    NSString* name = [class stringByReplacingOccurrencesOfString:CLASS_PREFIX withString:@""];

    ExtendedManagedObject* newObject =
    (ExtendedManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:name
                                                    inManagedObjectContext:context];

    [newObject populateFromDictionary:dict];

    return newObject;
}

@end
