//
//  Grafico2ViewController.m
//  CASP
//
//  Created by Luis Ruiz del Fresno on 18/04/14.
//  Copyright (c) 2014 Luis Ruiz del Fresno. All rights reserved.
//

#import "Grafico2ViewController.h"
#import "GraficoView2.h"

@interface Grafico2ViewController ()

@end

@implementation Grafico2ViewController

@synthesize datosDic, grafico = _grafico, segmentado = _segmentado;

#define MARGEN_LATERAL  22.0f
#define MARGEN_VERTICAL  10.0f
#define ALTURASEGMENTADO _segmentado.frame.size.height
#define STATUS_BAR      20.0f
#define NAVIGATION_BAR  44.0f
#define TAB_BAR         49.0f
#define ALTURA_LABEL    10.0f
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
//#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
//Para cuando además de detectar que tiene la pantalla de tamaño 4 pulgadas, queremos distinguir el nuevo iPhone (iPhone 5) del nuevo iPod touch.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Forma el gráfico; primero comprueba si existe, en cuyo caso antes de inicializar uno nuevo elimina el previo de su superview y le asigna nil
    //Para que no se superpongan las imágenes: si existe grafico, lo elimina de su superview y lo asigna a nil,
    if (_grafico != nil) {
        [_grafico removeFromSuperview];
        _grafico = nil;
    }
    
    //EXTRAER LA INTERPRETACIÓN DEL DIC Y ABREVIARLA PARA QUE QUEPA EN EL TITLE DE LA BARRA DE NAVEGACIÓN
    NSMutableString *interpretacion = [NSMutableString stringWithString:[datosDic objectForKey:@"interpretacion"]];
    NSRange match;
    match = [interpretacion rangeOfString: @"IC95%: "];
    if (match.location != NSNotFound) [interpretacion replaceCharactersInRange: [interpretacion rangeOfString: @"IC95%: "] withString: @"("];
    
    match = [interpretacion rangeOfString: @"infinito"];
    if (match.location != NSNotFound) [interpretacion replaceCharactersInRange: [interpretacion rangeOfString: @"infinito"] withString: @"inf"];
    
    match = [interpretacion rangeOfString: @"95%CI: "];
    if (match.location != NSNotFound) [interpretacion replaceCharactersInRange: [interpretacion rangeOfString: @"95%CI: "] withString: @"("];
    
    match = [interpretacion rangeOfString: @"infinity"];
    if (match.location != NSNotFound) [interpretacion replaceCharactersInRange: [interpretacion rangeOfString: @"infinity"] withString: @"inf"];
    
    [interpretacion appendString:@")"];
    
    self.title = interpretacion;
    
    //Lo inicalizamos con código y no en storyboard, etc. porque de un cálculo a otro solo mantiene igual el CGRect, su conteniso y etiqueta se dibuja de una forma distinta en cada cálculo
    _grafico = [[GraficoView2 alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + MARGEN_LATERAL,
                                                             self.view.bounds.origin.y + STATUS_BAR + NAVIGATION_BAR + 2 * MARGEN_VERTICAL + ALTURASEGMENTADO,
                                                             self.view.bounds.size.width - 2 * MARGEN_LATERAL,
                                                             self.view.bounds.size.height - STATUS_BAR - NAVIGATION_BAR - TAB_BAR - 5 * MARGEN_VERTICAL - ALTURASEGMENTADO - ALTURA_LABEL)];
    
    _grafico.datosDic = datosDic;
    _grafico.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:_grafico];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (IBAction)pulsoSegmentado:(id)sender {
    if (_segmentado.selectedSegmentIndex == 0) {
        [datosDic setValue:@"Superioridad" forKey:@"SupEqui"];

    } else {
        [datosDic setValue:@"Equivalencia" forKey:@"SupEqui"];

    }
    
    _grafico.datosDic = datosDic;
    [_grafico setNeedsDisplay];
    
}

@end
