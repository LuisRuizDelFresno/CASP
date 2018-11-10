//Modificado de http://vladimir.zardina.org/2010/03/serializing-archivingunarchiving-an-nsmanagedobject-graph/
// y https://gist.github.com/nuthatch/5607405

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ExtendedManagedObject: NSManagedObject

//CONVIERTE EL MANAGEDOBJECT EN UN NSDICTIONARY.
- (NSDictionary*) toDictionary;

//ASIGNA VALORES A LOS ATRIBUTOS Y RELACIONES DE UN MANAGEDOBJECT, DESDE UN NSDICTIONARY
- (void) populateFromDictionary:(NSDictionary*)dict;

//CREA MANAGEDOBJECT NUEVO Y LE DA VALORES A SUS ATRIBUTOS Y RELACIONES.
+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context;

//PARA OBTENER EL NSDICTIONARY DEL EMAIL Pasado a MenuVC
//- (NSDictionary *)dictFromURL:(NSURL *)importURL;

//PARA PREPARAR EL OBJETO PARA ENVIO POR EMAIL
- (NSData *)exportToNSData;

@end