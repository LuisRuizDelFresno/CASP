//
//  Modificado de PdfGenerationDemoViewController.h
//  PdfGenerationDemo
//
//  Created by Uppal'z on 16/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LectCrit.h"

@interface PDFDesdeLectura : NSObject {
    CGSize  pageSize;
    CGFloat posicionYSumatoria;
    CGFloat posicionYTrasHeader;
    
    NSDictionary *dicLectura;
    
    int currentPage;
}

@property (nonatomic, strong) NSDictionary *dicLectura;

- (id) initConLectura:(LectCrit *)laLectura;
- (NSData *) formaDataPDFDesdeDiccionario;

@end
