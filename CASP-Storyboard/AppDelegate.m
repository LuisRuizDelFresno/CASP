//
//  AppDelegate.m
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuLCViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext        = _managedObjectContext;
@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;

#define COLOR_CASP [UIColor colorWithRed: 27.0/255.0 green: 160.0/255.0 blue: 23.0/255.0 alpha: 1.0]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Para forzar que cargue los valores por defecto de configuración de la aplicación, en nuestro caso nombre y correo electrónico del revisor por defecto. En Settings.bundle se especifican unos textos por defecto, que al instalar la aplicación se copian en el apartado de nuestra aplicación en Ajustes. Estos valores deberían pasar a NSUserDefaults (objeto en la RAM digo yo), y desde ahí leerse en cualquier parte de la aplicación donde interesase, llamando a [NSUserDefaults standartdDefults] ... Pero esto sólo ocurre cuando el usuario efectivamente entra en ajustes y cambia algo el texto por defecto. Si no lo hace los por defecto copiados en Ajustes desde Settings.bundle NO están en NSUserDefaults, para que lo estén añadimos estas líneas y el método casero llamado.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults stringForKey:@"nombre_preferences"] length])     [self registerDefaultsFromSettingsBundles];
    if (![[defaults stringForKey:@"correo_preferences"] length])     [self registerDefaultsFromSettingsBundles];
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
    
    MenuLCViewController *menuLCVC = [[navigationController viewControllers] objectAtIndex:0];
    menuLCVC.managedObjectContext = self.managedObjectContext;
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url != nil && [url isFileURL]) {
        NSLog(@"Pasa por %s AHORA SIN EFECTO SOBRE IMPORTACIÓN", __FUNCTION__);
        //[menuLCVC handleOpenURL:url];
    }
    
    if ([[defaults stringForKey:@"nombre_preferences"] isEqualToString:NSLocalizedString(@"No especificado", nil)]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Recomendacion", nil)
                                                        message:NSLocalizedString(@"MensajeRecomendacion", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Vale", nil)
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    
    return YES;
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
    //Las imágenes del TabBar en teoría no hace falta cargarlas aquí se debería poder hacer en Storyboard, pero da un warning de CUICatalog: Invalid asset name supplied: que desaparece cargándolas aquí
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    ((UITabBarItem *)tabBarController.tabBar.items[0]).selectedImage = [UIImage imageNamed:@"123"];
    ((UITabBarItem *)tabBarController.tabBar.items[1]).selectedImage = [UIImage imageNamed:@"AZ"];
    ((UITabBarItem *)tabBarController.tabBar.items[2]).selectedImage = [UIImage imageNamed:@"calculadora"];
    UINavigationController *navControllerDeInteres = [tabBarController.viewControllers objectAtIndex:0];
    MenuLCViewController *menuLCVC = (MenuLCViewController *) [navControllerDeInteres.viewControllers objectAtIndex:0];
    if (url != nil && [url isFileURL]) {
        NSLog(@"Pasa por %s IMPORTANDO", __FUNCTION__);
        
        [menuLCVC handleOpenURL:url];
    }
    
    //El documento importado se ha copiado en una subcarpeta de la carpeta de documentos: /Documents/Inbox . Ahí se van
    //acumulando sino los borramos. Lo borro. intento hacer referencia abstracta a Inbox (que en mi caso es último objeto, los otros son 3 sqlite cuyos nombres empiezan por C y van delante), y borro todo su contenido. No borro sólo el archivo de nombre NombreArchivo porque si el usuario ha importado antes de al actualización actual tendrá varios archivos (con distintos nombres), y si ha importado uno varias veces, se van autonumerando automáticamente.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if([paths count] > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSError *error = nil;
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSArray *documentArray = [filemgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        NSString *inboxPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [documentArray lastObject]];
        NSArray *inboxArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inboxPath error:&error];

        if(error) {
                NSLog(@"Could not get list of documents in directory, error = %@",error);
        } else {
            //NSLog(@"CONTENIDO INBOX-DIRECTORY %@", inboxArray);
            for (NSString *file in [filemgr contentsOfDirectoryAtPath:inboxPath error:&error]) {
                BOOL success = [filemgr removeItemAtPath:[NSString stringWithFormat:@"%@/%@", inboxPath, file] error:&error];
                if (!success || error) {
                    NSLog(@"Algo falló en Inbox, path %@\n y contenido %@", inboxPath, inboxArray);
                }
            }
        }
    }
    

    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];

}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Pasar los valores del Settings.bundle a NSUserDefaults

-(void)registerDefaultsFromSettingsBundles {
    //Necesitamos este método casero porque los valores por defecto los tiene en cache el NSUserDefaults; este los toma de Ajustes (los ajustes de nuestra aplicación especificados por el usuario allí), si no existen no mira automáticamente en el archivo Settings.bundle de la applicación (aunque parezca mentira ??!!??), y eso es lo que queremos forzar con este método que si no hay nada en Ajustes vaya a Settings.bundle. Tomado de stackoverflow question 5491394 o 510216.
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (!settingsBundle) {
        NSLog(@"No ha encontrado el Settings.bunble");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:preferences.count];
    for (NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"]; //============== OJO POR SI ES IDENTIFIER EN VEZ DE KEY
        
        //Para localizar el valor de DefaultValue, antes de que pase al diccionario (en Settings.bundle se pueden localizar el nombre de un elemento pero no su Default Value)
        NSString *valorPorDefecto = NSLocalizedString([prefSpecification objectForKey:@"DefaultValue"], nil);
        
        //Ahora ya Pone el valor localizado en el dic
        if (key)    [defaultsToRegister setObject:valorPorDefecto forKey:key];
        
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
    
}

// Returns the persistent store coordinator for the application.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CASP-Storyboard.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    //Esta línea para habilitar el versionado del modelo con migración lightweight, en la siguiente pasamos el diccionario de opciones
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CASP_CD2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
    
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
