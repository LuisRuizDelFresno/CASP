//
//  LectCritViewController.h
//  CASP-CoreData
//
//  Created by Luis Ruiz del Fresno on 02/04/13.
//
//

#import <UIKit/UIKit.h>
#import "LectCrit.h"
#import <MessageUI/MessageUI.h>

@interface LectCritViewController : UITableViewController <UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate> {

    NSManagedObjectContext      *context;
    LectCrit *lecturaCritica;
        
    LectCrit *lecturaDuplicada;
    
    UIToolbar       *barraTeclado;
    UISegmentedControl *miSegmentedControl;
    NSIndexPath      *indexNuevo;
    
    UITextView      *textView100;
    UITextView      *textView101;
    UITextView      *textView102;
    
    UITableViewCell *celdaActiva;

    CGFloat         alturaTextView;
    NSMutableArray *alturasArray;
    
    NSArray         *plantillasMenuArray;
    
    UIActionSheet   *actionSheetFecha;
    UIDatePicker    *fechaPicker;

    UIBarButtonItem *botonCancelar;
    
    BOOL    rowDatePicker;
    BOOL    rowImportacion;
    BOOL    textoCambio;
    
    UIButton *pubMedBoton;
        
    UIActivityIndicatorView *indicadorActividad;
    
    CGRect cursorEnTabla;
}

@property (nonatomic, strong)           LectCrit                  *lecturaCritica; //Entidad que le pasan
@property (nonatomic, strong)           LectCrit                  *lecturaDuplicada;
@property (nonatomic, strong)           NSManagedObjectContext    *context;
@property (nonatomic, strong) IBOutlet  UIToolbar               *barraTeclado;
@property (nonatomic, strong) IBOutlet  UISegmentedControl      *miSegmentedControl;
@property (nonatomic, strong)           NSIndexPath             *indexNuevo;
@property (nonatomic, strong)           UITextView              *textView100;
@property (nonatomic, strong)           UITextView              *textView101;
@property (nonatomic, strong)           UITextView              *textView102;
@property (nonatomic, strong)           UITableViewCell         *celdaActiva;
@property (nonatomic, strong)           NSMutableArray          *alturasArray;
@property (nonatomic, strong)           NSArray                 *plantillasMenuArray;
@property (nonatomic, strong)           UIActionSheet           *actionSheetFecha;
@property (nonatomic, strong)           UIDatePicker            *fechaPicker;
@property (nonatomic, strong)           UIBarButtonItem         *botonCancelar;
@property (nonatomic, strong)           UIButton                *pubMedBoton;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicadorActividad;

- (NSArray *) obtienePlantillaUsada;
- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//- (void) centradoVerticalTextView:(UITextView *)elTextView;
- (void) colorDelTextoDeLaCelda:(UITableViewCell *)cell;
- (NSArray *)ordenaPickedTags:(NSSet *)pickedTags;
- (NSString *) fechaFormateada:(NSDate *)date;

- (IBAction)importarUnPubMed:(id)sender;
- (IBAction)cancelaFecha:(id)sender;
- (IBAction)guardaFecha:(id)sender;
- (IBAction)fechaEscogida:(id)sender;

@end
