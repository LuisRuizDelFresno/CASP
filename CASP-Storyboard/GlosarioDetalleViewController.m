//
//  GlosarioDetalleViewController.m
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

//
//  GlosarioDetalleViewController.m
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 01/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GlosarioDetalleViewController.h"
#import "NNTViewController.h"
#import "DiagViewController.h"

@implementation GlosarioDetalleViewController

@synthesize terminoDetalle, definicionDetalle, sinCelda;

//Para identificar a los iPhone con pantallas más pequeñas que el 6Plius, que son los que llevan imágenes @2x, mientras que las del 6Plus (y previsiblemente los posteriores son @3x)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)

#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))   //En iphone puede que baste comprobar que responde al método de scale por un factor de 2, pero para que sea válido tanto en iPad como en iPhone parece que ese necesario chequear dos cosas: que el iOs es superior a 4 (responde a displayLinkWithTarget:) y que responde al scale.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sinCelda.delegate = self;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark WebView Delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        
        NSURL *url = request.URL;
        NSString *urlString = url.absoluteString;
        NSString *ultimoComponente = [urlString lastPathComponent];
        
        //Check if special link
        if ([ultimoComponente isEqualToString:@"NNTCalc"]) {
            
            [self performSegueWithIdentifier:@"GlosarioANNT" sender:self];
            
        } else if ([ultimoComponente isEqualToString:@"DiagCalc"]) {
            
            [self performSegueWithIdentifier:@"GlosarioADiagCalc" sender:self];

        }
        
        return NO;
        
    }
    
    return YES;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = terminoDetalle;
    
    NSString *imagePath = [[NSBundle mainBundle] resourcePath]; //Se encuentra la imagen tanto al listar resourcePath como bundlePath
    NSURL *imagenURL = [NSURL fileURLWithPath:imagePath];

    //Para que las imágenes 3@x sean las pod defecto, identificamos los iPhone con pantallas más pequeñas que el 6Plius (que son los que llevan imágenes @2x: 4, 5 y 6 noPlus), y le cambiamos la imagen a @2x). Una forma mejor de hacer esto es como en las otras imágenes, que el html que se carga en el webview estuviese definido independizando el texto de la imagen, y nombrar a la imagen por el nombre de su asset, que ya se encargaría el dsipocitivo de tomar la de tamaño correcto. O mejor aún que el html incorporase la fáormula, en el estilo y tamaño necesario como un texto más, no como una imagen
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5 || IS_IPHONE_6) {
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"ABI@3x.png"       withString:@"ABI@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"AbRI@3x.png"      withString:@"AbRI@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"ARR@3x.png"       withString:@"ARR@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"LRNeg@3x.png"     withString:@"LRNeg@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"LRPos@3x.png"     withString:@"LRPos@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"NNH@3x.png"       withString:@"NNH@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"NNT@3x.png"       withString:@"NNT@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"PostPr@3x.png"    withString:@"PostPr@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"PostOdds@3x.png"  withString:@"PostOdds@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"PreOdds@3x.png"   withString:@"PreOdds@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"RBI@3x.png"       withString:@"RBI@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"RR@3x.png"        withString:@"RR@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"RRI@3x.png"       withString:@"RRI@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"RRR@3x.png"       withString:@"RRR@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"Sensi@3x.png"     withString:@"Sensi@2x.png"];
        definicionDetalle = [definicionDetalle stringByReplacingOccurrencesOfString:@"Speci@3x.png"     withString:@"Speci@2x.png"];

        //Deja las imágenes de Heterogeneidad y CI llamadas ...@2x.png, que es la original porque pasarlas a mitad de tamaño sólo es empeorarla, no había alta y baja resolución sólo una: la original.
        
    }
    
    //[sinCelda setScalesPageToFit:YES];
    
    [sinCelda loadHTMLString:definicionDetalle baseURL:imagenURL];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;// for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
