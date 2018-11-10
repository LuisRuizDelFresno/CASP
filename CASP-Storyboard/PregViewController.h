//
//  PregViewController.h
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LectCrit;

//esta declaracion de clase s debe a que en el método de delgación entra la clase como un parámetro, si no entrase no haría flata la declaración de clase.
@class PregViewController;

@protocol PregViewControllerDelegate <NSObject>
- (void) respuestaEnDelegante:(NSDictionary *)dicRespuesta;
@end

@interface PregViewController : UITableViewController <UITextViewDelegate> {
    
    NSString *notaColor;
    //NSDictionary *dicColor;
    UILabel *labelPregunta;
    UISegmentedControl *botonRespuesta;
    UILabel *labelPista;
    UITextView *textViewComentario;
    UILabel *labelCalcula;
    
    NSString *preguntaString;
    NSString *pistaString;
    NSIndexPath *celdaSeleccionadaP;
    
    NSString *plantillaID;
    
    NSNumber *alturaTextViewNumber;

    NSManagedObjectContext *context;
    LectCrit *laLectCrit;

    NSString    *placeholder;
    
    int numeroComentario;
    //NSLayoutConstraint *constraintToAdjust;     //APPLE 1/8 BIS
    
}

@property (nonatomic, strong) NSString *notaColor;
//@property (nonatomic, strong) NSDictionary *dicColor;

@property (nonatomic, strong) NSString *preguntaString;
@property (nonatomic, strong) NSString *pistaString;
@property (nonatomic, strong) NSIndexPath *celdaSeleccionadaP;

@property (nonatomic, strong) IBOutlet UILabel *labelPregunta;
@property (nonatomic, strong) IBOutlet UISegmentedControl *botonRespuesta;
@property (nonatomic, strong) IBOutlet UILabel *labelPista;
@property (nonatomic, strong) IBOutlet UITextView *textViewComentario;
@property (nonatomic, strong) IBOutlet UILabel *labelCalcula;

@property (nonatomic, strong) NSString *plantillaID;

@property (nonatomic, strong) NSNumber *alturaTextViewNumber;

@property (nonatomic, strong) LectCrit                  *laLectCrit;
@property (nonatomic, strong) NSManagedObjectContext    *context;

@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic)       int numeroComentario;
@property (nonatomic, weak) id <PregViewControllerDelegate> delegate;

// the height constraint we want to change when the keyboard shows/hides
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintToAdjust;     //APPLE 1/8 BIS-BIS

-(IBAction)botonRespuestaPulsado:(id)sender;

@end
