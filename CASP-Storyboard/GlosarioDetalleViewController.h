//
//  GlosarioDetalleViewController.h
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

//
//  GlosarioDetalleViewController.h
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 01/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlosarioDetalleViewController : UIViewController <UIWebViewDelegate> {
    
    NSString *terminoDetalle;
    NSString *definicionDetalle;
    UIWebView *sinCelda;
}

@property (nonatomic, strong) NSString *terminoDetalle;
@property (nonatomic, strong) NSString *definicionDetalle;
@property (nonatomic, strong) IBOutlet UIWebView *sinCelda;

@end
