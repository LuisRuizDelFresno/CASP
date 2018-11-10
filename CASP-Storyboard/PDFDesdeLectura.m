//
//  Modificado de PdfGenerationDemoViewController.m
//  PdfGenerationDemo
//
//  Created by Uppal'z on 16/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PDFDesdeLectura.h"
#import "Respuestas.h"
#import "Revisor.h"

@implementation PDFDesdeLectura

@synthesize dicLectura;

#define VERSION_iOS_7_O_MAYOR       floor(NSFoundationVersionNumber) > (NSFoundationVersionNumber_iOS_6_1)
#define kBorderWidth            1.0
#define kBorderInset            20.0    //Margen exteriro al marco
#define kMarginInset            10.0    //Margen interior, de marco a texto/línea,... y entre objetos
#define kPosicionYPieDesdeAbajo 40.0
#define kLineWidth              1.0

#define kFontTituloPagina1                  [UIFont boldSystemFontOfSize:18.0]
#define kFontEnunciadoSeccion               [UIFont boldSystemFontOfSize:14.0]
#define kFontTextoGeneral                   [UIFont systemFontOfSize:14.0]
#define kFontRespuestaComentarioPreg        [UIFont italicSystemFontOfSize:14.0]

#define kColorRectangulo        0.9, 0.9, 0.9, 1.0
#define kColorTexto             0.0, 0.0, 0.0, 1.0

#pragma mark - View lifecycle
- (id)initConLectura:(LectCrit *)laLectura {
    self = [super init];
    if (self) {        
        
        //HABRIA QUE HACER ESTE DICCIONARIO CON LA LECTURA: laLectura
        NSMutableDictionary *dicMutableFinal = [[NSMutableDictionary alloc] initWithCapacity:1];

        NSString *revisionString = [NSString stringWithFormat:@"%@. %@ %@", laLectura.relacionRevisor.revisorNombre, laLectura.relacionRevisor.revisorEmail, laLectura.fecha];
        NSDictionary *encabezamiento = [NSDictionary dictionaryWithObjectsAndKeys:
                                        laLectura.titulo,       @"tituloAbreviado",
                                        laLectura.tipoArt,      @"tipoArticulo",
                                        laLectura.revista,      @"referencia",
                                        revisionString,         @"revisor", nil];
        [dicMutableFinal setValue:encabezamiento forKey:@"encabezamiento"];
        
        if (laLectura.relacionRespuestas) {
            
            //PARA IR COMBINANDO PREG (del plist) y RESPUESTAS (de CoreData).
            //Cargar en un array la plantilla que tenga asignada la lectura
            NSString *pathPreguntas = [[NSBundle mainBundle] pathForResource:laLectura.relacionRespuestas.plantillaID ofType:@"plist"];
            NSMutableDictionary *plantillaDic = [NSMutableDictionary dictionaryWithContentsOfFile:pathPreguntas];
            
            //de esa plantilla toma LOGO1 LOGO2 
            [dicMutableFinal setValue:[plantillaDic objectForKey:@"logo1"] forKey:@"logo1"];
            if ([plantillaDic objectForKey:@"logo2"])   [dicMutableFinal setValue:[plantillaDic objectForKey:@"logo2"] forKey:@"logo2"];
            
            //ENUNCIADOS DE SECCIÖN, DE PREG, RESPUESTAS y COMENTARIOS DE PREG
            NSArray *preguntasArray = [plantillaDic objectForKey:@"preguntas"]; 
        
            int s = 0;  //Para numerar la clave de las secciones
            int r = 0;  //PAra numerar la clave de las respuestas y comentarios
            for (NSDictionary *dicSecc in preguntasArray) {
                NSMutableDictionary *dicSeccMutable = [NSMutableDictionary dictionaryWithDictionary:dicSecc];
                [dicSeccMutable setValue:[[dicSecc objectForKey:@"bloque"] uppercaseString] forKey:@"enunciadoSeccion"];
                [dicSeccMutable removeObjectForKey:@"bloque"];
                [dicSeccMutable removeObjectForKey:@"preguntas"];
                
                NSArray *preguntas = [dicSecc objectForKey:@"preguntas"];
                NSMutableArray *preguntasMutableArray = [[NSMutableArray alloc] initWithCapacity:1];
                for (NSDictionary *preguntaDic in preguntas) {
                    NSMutableDictionary *preguntaDicMutable = [NSMutableDictionary dictionaryWithDictionary:preguntaDic];
                    [preguntaDicMutable removeObjectForKey:@"literalC"];
                    [preguntaDicMutable removeObjectForKey:@"pista"];
                    [preguntaDicMutable removeObjectForKey:@"comentario"];
                    [preguntaDicMutable removeObjectForKey:@"color"];
                    
                    NSString *respuestaCruda = [laLectura.relacionRespuestas valueForKey:[NSString stringWithFormat:@"r%i", r]];
                    
                    NSString *respuestaTraducida;
                    if ([respuestaCruda isEqualToString:@"greenColor"]) respuestaTraducida = NSLocalizedString(@"SíEnRespuestas", nil);
                    else if ([respuestaCruda isEqualToString:@"yellowColor"])   respuestaTraducida = NSLocalizedString(@"No sé", nil);
                    else if ([respuestaCruda isEqualToString:@"redColor"]) respuestaTraducida = NSLocalizedString(@"NoEnRespuestas", nil);
                    else    respuestaTraducida = NSLocalizedString(@"NoResponde", nil);
                    [preguntaDicMutable setValue:respuestaTraducida forKey:@"respuesta"];
                    
                    NSString *comentarioPreg = [laLectura.relacionRespuestas valueForKey:[NSString stringWithFormat:@"c%i", r]];
                    [preguntaDicMutable setValue:comentarioPreg forKey:@"comentarioPreg"];
                    
                    [preguntasMutableArray addObject:preguntaDicMutable];
                    r++;

                }
                
                [dicSeccMutable setValue:preguntasMutableArray forKey:@"preguntasSeccion"];
                [dicMutableFinal setValue:dicSeccMutable forKey:[NSString stringWithFormat:@"seccion%i", s]];
                s++;
            }
            
            //Los textos que vienen en primera pagina en la plantilla vacia 
            NSDictionary *datosCASPPlantilla = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [plantillaDic valueForKey:@"pagina1Marca"],                 @"marcaCASP",
                                                [plantillaDic valueForKey:@"pagina1CitameAsi"],             @"citameCASP",
                                                [plantillaDic valueForKey:@"pagina1TipoArt"],               @"tipoArticuloCASP",
                                                [plantillaDic valueForKey:@"pagina1ComentariosGenerales"],  @"comentariosCASP",
                                                [plantillaDic valueForKey:@"recuerde"],                     @"recuerdeCASP",
                                                nil];
            
            [dicMutableFinal setValue:datosCASPPlantilla forKey:@"datosCASP"];
            
        }
        
        NSString *comentario = laLectura.comentario;
        [dicMutableFinal setValue:comentario forKey:@"comentarioGeneralRevisor"];

        NSString *recordatorio = @"Recuerde que los estudios observacionales son una evidencia de poca fuerza, que en el caso de tratamientos u otra intervención lo ideal es un ensayo clínico aleatorizado";
        [dicMutableFinal setValue:recordatorio forKey:@"recordatorio"];

        dicLectura = dicMutableFinal;
        
        //NSLog(@"Diccionario de la lectura %@", dicMutableFinal);
        /*
         Dic
         - encabezamiento Dic   - tituloAbreviado
                                - tipoArticulo del revisor
                                - referencia, uns sola string que trae agregados por este orden: autores, titulo, revista
                                - revisor,  una sola string que trae agregados por este orden: nombre, email, fecha, siguiendo plantilla CASP
         
         - logo1 nombre del logo de la izq
         - logo2 nombre del logo de la dcha si existe
         - seccion0 Dic    - enunciadoSeccion
                           - preguntasSeccion Array - preg 1 Dic    - literal
                                                                    - caracter
                                                                    - respuesta
                                                                    - comentario Preg
                                                    - preg 2 Diic
                                                    - preg 3 Dic
         - seccion1 Dic     - enunciadoSeccion
                            - preguntasSeccion Array    - preg 1 Dic
                                                        - preg 2 Dic
                                                        - preg 3 Dic
         - seccion2 Dic     - enunciadoSeccion
                            - preguntasSeccion array    - preg 1 Dic
                                                        - preg 2 Dic
                                                        - preg 3 Dic
         
         - pie de pagina: Número Pag
         
         - comentario general autor
         - Datos CASP:          - tipoArt CASP
                                - comentario CASP
                                - recuerde CASP
                                - marca CASP
                                - citame CASP
         */
        
        //Este tamaño de página es el estandar llamado Letter en EEUU, Canada, Méjico y algunos otros. En Europe,... el estandar es A4 que en puntos es 595.44 x 841.68. Tomado de las explicaciones de http://stackoverflow.com/questions/4755480/ios-4-how-do-i-simulate-an-a4-printer y http://en.wikipedia.org/wiki/Paper_size
        //Estos tamaños están en puntos, que sacamos tomando el papel en pulgadas y multiplicando por 72 dpi.
        //El pots tiene una solución buena para escoger el tamaño de hoja a usar: automáticamente detectando la localización del usuario y modificable por el usuario en settings. Pongo aquó solo la parte de detección automática de momento.
        
        //Tamaño estandar en Europa. Que lo cambiamos por el de EEUU, Canada o Mexico si el dospositivo está configurado con esas localizaciones 
        pageSize =  CGSizeMake(595.44, 841.68);
                
        if([[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] isEqualToString:@"US"] || [[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] isEqualToString:@"CA"] || [[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] isEqualToString:@"MX"])    pageSize =  CGSizeMake(612, 792);
        
        currentPage = 0;

    }
        
    return self;
}

- (NSData *)formaDataPDFDesdeDiccionario {
    
    //Este método va llamando a los submétodos de forma ordenada para que se encuentren las ivariables de altura correctamente
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    posicionYTrasHeader = kBorderInset;

    //Pone el Logo, Titulo y Subtitulo en la primera página
    [self drawLogoTituloYSubtitulo];
    
    //Pone los elementos comunes a cualquier
    [self drawObjetosComunesConReferenciaYRevisor];
    
    //Saca los dic de seccion y los va pasando 1 a 1
    for(int i = 0; i < 3; i++) {
        NSString *seccionClave = [NSString stringWithFormat:@"seccion%i", i];
        NSDictionary *dicSeccion = [dicLectura objectForKey:seccionClave];
        
        NSString *enunciadoSeccion = [dicSeccion objectForKey:@"enunciadoSeccion"];
        [self drawEnunciadoSeccion:enunciadoSeccion];

        NSArray *preguntasArray = [dicSeccion objectForKey:@"preguntasSeccion"];
        for (NSDictionary *pregDic in preguntasArray) {
            [self drawPregunta:pregDic];

        }
    }
    
    [self drawComentarioRevisor];

    [self drawLineaGruesa];
    
    [self drawTipoArtCASP];
    
    [self drawComentariosCASP];
    
    [self drawRecordatorioCASP];
    
    [self drawMarcaCASP];
    
    [self drawCitanosAsi];
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
        
    return pdfData;
    
}

- (void) drawLogoTituloYSubtitulo {
    
    CGFloat posicionYInicioLogoTitSubtit = posicionYTrasHeader;

    //---------------------------------------------------------------------------------------
    //Configurar la IMAGEN 1 y la 2
    //---------------------------------------------------------------------------------------
    UIImage *logo1 = [UIImage imageNamed:[dicLectura objectForKey:@"logo1"]];
    CGRect logo1Rect = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                  kBorderInset + kBorderWidth + kMarginInset,
                                  logo1.size.width,
                                  logo1.size.height);
   
    UIImage *logo2 = [UIImage imageNamed:[dicLectura objectForKey:@"logo2"]];
    CGRect logo2Rect = CGRectMake(pageSize.width -(kBorderInset + kBorderWidth + kMarginInset + logo2.size.width),
                                  kBorderInset + kBorderWidth + kMarginInset,
                                  logo2.size.width,
                                  logo2.size.height);
    
    //---------------------------------------------------------------------------------------
    //Configurar el TITULO PAG 1
    //---------------------------------------------------------------------------------------
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, kColorTexto);
    
    NSString *titulo = [[dicLectura objectForKey:@"encabezamiento"] objectForKey:@"tituloAbreviado"];
    CGFloat anchoPosibleTitulo = pageSize.width - 2*kBorderInset -2*kBorderWidth - 3*kMarginInset - logo1Rect.size.width;
    if (logo2)  anchoPosibleTitulo = anchoPosibleTitulo - logo2.size.width -kMarginInset;
    
    CGSize tituloSize;
    CGSize constraintTitulo = CGSizeMake(anchoPosibleTitulo,
                                   pageSize.height - 2*kBorderInset - 2*kBorderWidth - 3*kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleTitulo = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleTitulo.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleTitulo.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesTitulo = @{NSFontAttributeName : kFontTituloPagina1,
                                      NSParagraphStyleAttributeName : paragraphStyleTitulo};
        
    tituloSize = [titulo boundingRectWithSize:constraintTitulo
                                   options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                attributes:attributesTitulo
                                   context:nil].size;
    
    CGRect renderingRectTitulo = CGRectMake(kBorderInset + kBorderWidth + 2*kMarginInset + logo1Rect.size.width,
                                            kBorderInset + kBorderWidth + kMarginInset + 0.2*logo1Rect.size.height,
                                            tituloSize.width,
                                            tituloSize.height);
    
    //---------------------------------------------------------------------------------------
    //Configurar el SUBTITULO pag 1
    //---------------------------------------------------------------------------------------
    NSString *subtitulo = [[dicLectura objectForKey:@"encabezamiento"] objectForKey:@"tipoArticulo"];

    CGSize subtituloSize;
    CGSize constraintSubtitulo = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 3*kMarginInset - logo1Rect.size.width,
                                            pageSize.height - 2*kBorderInset - 2*kBorderWidth - 4*kMarginInset - tituloSize.height - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleSubtitulo = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleSubtitulo.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleSubtitulo.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesSubtitulo = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleSubtitulo};
        
    subtituloSize = [subtitulo boundingRectWithSize:constraintSubtitulo
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributesSubtitulo
                                          context:nil].size;
    
    CGFloat posicionYSubtitulo = MAX(kBorderInset + kBorderWidth + 3*kMarginInset + tituloSize.height,
                                     kBorderInset + kBorderWidth + kMarginInset + 0.8*logo1Rect.size.height - subtituloSize.height);
    
    CGRect renderingRectSubtitulo = CGRectMake(kBorderInset + kBorderWidth + 2*kMarginInset + logo1Rect.size.width,
                                               posicionYSubtitulo,
                                               subtituloSize.width,
                                               subtituloSize.height);
    
    //Da valor a posicionYTrasHeader para que el siguiente método la use.
    posicionYTrasHeader = MAX(renderingRectSubtitulo.origin.y + renderingRectSubtitulo.size.height,
                              logo1Rect.origin.y + logo1Rect.size.height) + kMarginInset;
    
    //---------------------------------------------------------------------------------------
    //Configurar y dibujar el RECTANGULO
    //---------------------------------------------------------------------------------------
    CGRect rectangle = CGRectMake(kBorderInset + kBorderWidth,
                                  posicionYInicioLogoTitSubtit,
                                  pageSize.width - 2*kBorderInset - 2*kBorderWidth,
                                  posicionYTrasHeader - kBorderWidth - posicionYInicioLogoTitSubtit);
    CGContextSetRGBFillColor(currentContext, kColorRectangulo);
    CGContextFillRect(currentContext, rectangle);
    
    //---------------------------------------------------------------------------------------
    //Dibuja el logo, el título y subtítulo, después de dibujar el rectángulo para que queden encima del rectángulo
    //---------------------------------------------------------------------------------------
    //Cambiar el color vigente al del texto para los textos que vienen detrás
    CGContextSetRGBFillColor(currentContext, kColorTexto);
    
    [logo1 drawInRect:logo1Rect];
    
    [logo2 drawInRect:logo2Rect];
    
    [titulo drawInRect:renderingRectTitulo withAttributes:attributesTitulo];
    
    [subtitulo drawInRect:renderingRectSubtitulo withAttributes:attributesSubtitulo];
    
}

- (void) drawObjetosComunesConReferenciaYRevisor {
    
    CGFloat posicionYInicioComunes = posicionYTrasHeader- kMarginInset;
    
    //---------------------------------------------------------------------------------------
    //REFERENCIA
    //---------------------------------------------------------------------------------------
    NSString *referencia = [[dicLectura objectForKey:@"encabezamiento"] objectForKey:@"referencia"];
    
    CGSize referenciaSize;
    CGSize constraintReferencia = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                             pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleReferencia = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleReferencia.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleReferencia.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesReferencia = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleReferencia};
        
    referenciaSize = [referencia boundingRectWithSize:constraintReferencia
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesReferencia
                                                context:nil].size;
        
    CGRect renderingRectReferencia = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                posicionYTrasHeader,
                                                referenciaSize.width,
                                                referenciaSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectReferencia.size.height + kMarginInset;
    
    //---------------------------------------------------------------------------------------
    //REVISOR
    //---------------------------------------------------------------------------------------
    NSString *revisor = [[dicLectura objectForKey:@"encabezamiento"] objectForKey:@"revisor"];

    CGSize revisorSize;
    CGSize constraintRevisor = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                          pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleRevisor = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleRevisor.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleRevisor.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesRevisor = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleRevisor};
        
    revisorSize = [revisor boundingRectWithSize:constraintRevisor
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesRevisor
                                                context:nil].size;

    CGRect renderingRectRevisor = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                posicionYTrasHeader,
                                                revisorSize.width,
                                                revisorSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectRevisor.size.height + kMarginInset;

    //---------------------------------------------------------------------------------------
    //Configurar y dibujar el rectángulo (sólo la parte de elementos comunes)
    //---------------------------------------------------------------------------------------
    CGRect rectangle = CGRectMake(kBorderInset + kBorderWidth,
                                  posicionYInicioComunes,
                                  pageSize.width - 2*kBorderInset - 2*kBorderWidth,
                                  posicionYTrasHeader - kBorderWidth - posicionYInicioComunes);
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, kColorRectangulo);
    CGContextFillRect(currentContext, rectangle);

    //---------------------------------------------------------------------------------------
    //Dibuja la referencia y el revisor lo último para que queden encima del rectángulo
    //---------------------------------------------------------------------------------------
    //Cambiar el color vigente al del texto para los textos que vienen detrás
    CGContextSetRGBFillColor(currentContext, kColorTexto);
    
    [referencia drawInRect:renderingRectReferencia withAttributes:attributesReferencia];
    
    [revisor drawInRect:renderingRectRevisor withAttributes:attributesRevisor];
    
    //---------------------------------------------------------------------------------------
    //LINEA. No la dibujamos pero calculamos los espacios como si estuviese
    //---------------------------------------------------------------------------------------
    posicionYTrasHeader = posicionYTrasHeader + kLineWidth + kMarginInset;
    posicionYSumatoria = posicionYTrasHeader;
    
    //---------------------------------------------------------------------------------------
    //MARCO DE CADA PAGINA.
    //---------------------------------------------------------------------------------------
    [self drawBorder];
    
    //---------------------------------------------------------------------------------------
    //NÚMERO DE CADA PAGINA.
    //---------------------------------------------------------------------------------------
    currentPage++;
    [self escribePiePaginaConPageNumber:currentPage];
    
    //NSLog(@"POSICIÖN Y TRAS NUEVA PÁGINA %f", posicionYTrasHeader);

}

- (void) drawLine {
    
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, kLineWidth);
    CGContextSetStrokeColorWithColor(currentContext, [UIColor lightGrayColor].CGColor);
    
    CGPoint startPoint = CGPointMake(kBorderInset + kBorderWidth + kMarginInset, posicionYTrasHeader);
    CGPoint endPoint = CGPointMake(pageSize.width - kBorderInset - kBorderWidth - kMarginInset, posicionYTrasHeader);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    
    posicionYTrasHeader = posicionYTrasHeader + kLineWidth + kMarginInset;
    posicionYSumatoria = posicionYTrasHeader;
    //NSLog(@"POSICIÓN Y TRAS HEADER = Sumatoria TRAS LINEA %f", posicionYTrasHeader);

    
}

- (void) drawBorder {
    
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor brownColor];
    
    CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width - 2*kBorderInset, pageSize.height - 2*kBorderInset);
    
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
        
}

- (void) escribePiePaginaConPageNumber:(NSInteger)pageNumber {
    
    NSString *pieTexto = [NSString stringWithFormat:NSLocalizedString(@"Lectura %@", nil), [[dicLectura objectForKey:@"encabezamiento"] objectForKey:@"tituloAbreviado"]];
    NSString* pieNumero = [NSString stringWithFormat:NSLocalizedString(@"Page %d", nil), pageNumber];
    NSString* pageNumberString = [NSString stringWithFormat:@"%@. %@", pieTexto, pieNumero];
    
    UIFont* theFont = [UIFont systemFontOfSize:12];
    
    CGSize pageNumberStringSize;
    
    NSMutableParagraphStyle * paragraphStylePageNumber = [[NSMutableParagraphStyle alloc] init];
    paragraphStylePageNumber.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStylePageNumber.alignment = NSTextAlignmentCenter;
        
    NSDictionary * attributesPageNumber = @{NSFontAttributeName:theFont,
                                      NSParagraphStyleAttributeName : paragraphStylePageNumber};
        
    pageNumberStringSize = [pageNumberString boundingRectWithSize:pageSize
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesPageNumber
                                                context:nil].size;
    
    CGRect pageNumberStringRenderingRect = CGRectMake(kBorderInset,
                                   pageSize.height - kPosicionYPieDesdeAbajo,
                                   pageSize.width - 2*kBorderInset,
                                   pageNumberStringSize.height);

    
    [pageNumberString drawInRect:pageNumberStringRenderingRect withAttributes:attributesPageNumber];
    
}

- (void) drawEnunciadoSeccion:(NSString *)enunciadoSeccion {
    
    //Enunicado Seccion
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    CGSize enunciadoSeccionSize;
    CGSize constraintEnunciadoSeccion = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributes = @{NSFontAttributeName : kFontEnunciadoSeccion,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
    enunciadoSeccionSize = [enunciadoSeccion boundingRectWithSize:constraintEnunciadoSeccion
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes
                                                context:nil].size;
    
    CGRect renderingRectEnunciadoSeccion = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                            posicionYTrasHeader + kMarginInset,
                                            enunciadoSeccionSize.width,
                                            enunciadoSeccionSize.height);
        
    //Para saber si pasa a otra página calcula el rectángulo donde tendría que ir el texto, si excede la posición del pie inicia nuevaPágina (donde se resetea el valor de posicionYTrasheader) y re-calcula el rectángulo. Si no excede la posición del pie directamente escribe el texto
    posicionYSumatoria = posicionYTrasHeader  + renderingRectEnunciadoSeccion.size.height + kMarginInset;
    
    if (posicionYSumatoria > (pageSize.height - 40)) {
        
        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectEnunciadoSeccion = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                   posicionYTrasHeader + kMarginInset,
                                                   enunciadoSeccionSize.width,
                                                   enunciadoSeccionSize.height);
    }
    
    [enunciadoSeccion drawInRect:renderingRectEnunciadoSeccion withAttributes:attributes];
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectEnunciadoSeccion.size.height + 2*kMarginInset;
    posicionYSumatoria = posicionYTrasHeader;

}

- (void) drawPregunta:(NSDictionary *)pregDic {
    
    //---------------------------------------------------------------------------------------
    //Enunciado
    //---------------------------------------------------------------------------------------
    NSString *enunciadoPregunta = [pregDic objectForKey:@"literal"];
    
    CGSize enunciadoPreguntaSize;
    CGSize constraintEnunciadopregunta = CGSizeMake(0.75*pageSize.width - kBorderInset - kBorderWidth - 1.5*kMarginInset,
                                                    pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleEnunciado = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleEnunciado.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleEnunciado.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributes = @{NSFontAttributeName : kFontTextoGeneral,
                        NSParagraphStyleAttributeName : paragraphStyleEnunciado};
        
    enunciadoPreguntaSize = [enunciadoPregunta boundingRectWithSize:constraintEnunciadopregunta
                                                            options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:attributes
                                                            context:nil].size;
        
    CGRect renderingRectEnunciadoPregunta = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                       posicionYTrasHeader,
                                                       enunciadoPreguntaSize.width,
                                                       enunciadoPreguntaSize.height);
    
    //---------------------------------------------------------------------------------------
    // Respuesta
    //---------------------------------------------------------------------------------------
    NSString *respuesta = [pregDic objectForKey:@"respuesta"];
    
    CGSize respuestaSize;
    CGSize constraintRespuesta = CGSizeMake(0.25*pageSize.width - kBorderInset - kBorderWidth - 1.5*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleRespuesta = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleRespuesta.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleRespuesta.alignment = NSTextAlignmentRight;
        
    NSDictionary * attributesRespuesta =           @{NSFontAttributeName : kFontRespuestaComentarioPreg,
                                           NSParagraphStyleAttributeName : paragraphStyleRespuesta};
        
    respuestaSize = [respuesta boundingRectWithSize:constraintRespuesta
                                            options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributesRespuesta
                                            context:nil].size;
    
    CGRect renderingRectRespuesta = CGRectMake(pageSize.width - kBorderInset - kBorderWidth - kMarginInset - respuestaSize.width,
                                               posicionYTrasHeader,
                                               respuestaSize.width,
                                               respuestaSize.height);

    posicionYTrasHeader = posicionYTrasHeader + enunciadoPreguntaSize.height + kMarginInset;
    
    if (posicionYTrasHeader > (pageSize.height - 40)) {
        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectEnunciadoPregunta = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                    posicionYTrasHeader,
                                                    enunciadoPreguntaSize.width,
                                                    enunciadoPreguntaSize.height);
        
        renderingRectRespuesta = CGRectMake(pageSize.width - kBorderInset - kBorderWidth - kMarginInset - respuestaSize.width,
                                            posicionYTrasHeader,
                                            respuestaSize.width,
                                            respuestaSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + enunciadoPreguntaSize.height + kMarginInset;
        
    }
    
    [enunciadoPregunta drawInRect:renderingRectEnunciadoPregunta withAttributes:attributes];

    [respuesta drawInRect:renderingRectRespuesta withAttributes:attributesRespuesta];
    
    //---------------------------------------------------------------------------------------
    // Comentario de la Preg,
    //Descompuesto en párrafos para que rellene mejor la página que si exigimos que entre entero o nada.
    //---------------------------------------------------------------------------------------
    NSString *comentarioPreg = [pregDic objectForKey:@"comentarioPreg"];
    NSArray *parrafosArray = [comentarioPreg componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (int i = 0; i < parrafosArray.count; i++) {
        NSString *parrafo = [parrafosArray objectAtIndex:i];
        
        CGSize parrafoComentarioPregSize;
        CGSize constraintParrafoComentarioPreg = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                                            800); //pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo
        
        NSMutableParagraphStyle * paragraphStyleComentario = [[NSMutableParagraphStyle alloc] init];
        paragraphStyleComentario.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyleComentario.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributesComentario =       @{NSFontAttributeName : kFontRespuestaComentarioPreg,
                                            NSParagraphStyleAttributeName : paragraphStyleComentario};
        
        parrafoComentarioPregSize = [parrafo boundingRectWithSize:constraintParrafoComentarioPreg
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:attributesComentario
                                                          context:nil].size;
        
        CGRect renderingRectParrafoComentarioPreg = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                               posicionYTrasHeader,
                                                               parrafoComentarioPregSize.width,
                                                               parrafoComentarioPregSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + parrafoComentarioPregSize.height;
        
        if (posicionYTrasHeader > (pageSize.height - 40)) {
            [self iniciaOtraPaginaYLlamaObjetosComunes];

            renderingRectParrafoComentarioPreg = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                            posicionYTrasHeader,
                                                            parrafoComentarioPregSize.width,
                                                            parrafoComentarioPregSize.height);
            
            posicionYTrasHeader = posicionYTrasHeader + parrafoComentarioPregSize.height;

        }
        
        [parrafo drawInRect:renderingRectParrafoComentarioPreg withAttributes:attributesComentario ];
        
    }
    
    //---------------------------------------------------------------------------------------
    //Dentro del método drawLine se actualizan los valores de posicionYTrasHeader y posicionYSumatoria.
    //Simulo aquí donde va a quedar posicionYSumatoria tras la línea, en vez de llamar al método ahora para que no lopinte
    //---------------------------------------------------------------------------------------
    posicionYTrasHeader = posicionYTrasHeader + kMarginInset;
    //NSLog(@"POSICIÓN Y TRAS HEADER TRAS PREGUNTA %@\n %f", comentarioPreg, posicionYTrasHeader);
    [self drawLine];
    
}

- (void) drawComentarioRevisor {

    //---------------------------------------------------------------------------------------
    //Epígrafe "Comentario"
    //---------------------------------------------------------------------------------------
    NSString *epigrafeComentario = NSLocalizedString(@"Comentarios", nil);
    
    CGSize epigrafeComentarioSize;
    CGSize constraintEpigrafeComentario = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleEpigrafe = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleEpigrafe.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleEpigrafe.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesEpigrafe = @{NSFontAttributeName : kFontEnunciadoSeccion,
                                      NSParagraphStyleAttributeName : paragraphStyleEpigrafe};
        
    epigrafeComentarioSize = [epigrafeComentario boundingRectWithSize:constraintEpigrafeComentario
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesEpigrafe
                                                context:nil].size;
    
    CGRect renderingRectEpigrafeComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                posicionYTrasHeader + kMarginInset,
                                                epigrafeComentarioSize.width,
                                                epigrafeComentarioSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectEpigrafeComentario.size.height + kMarginInset;
    
    //NSLog(@"POSICIÓN Y TRAS HEADER DESPUES DE EPIGRAFE COMMENT %f", posicionYTrasHeader);

    //---------------------------------------------------------------------------------------
    //COMENTARIO - CONTENIDO - fragmentado por párrafos como los comentarios de las preguntas para que lo parta entre páginas si es necesario.
    //---------------------------------------------------------------------------------------
    
    [epigrafeComentario drawInRect:renderingRectEpigrafeComentario withAttributes:attributesEpigrafe];

    NSString *comentario = [dicLectura objectForKey:@"comentarioGeneralRevisor"];
    NSArray *parrafosArray = [comentario componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (int i = 0; i < parrafosArray.count; i++) {
        NSString *parrafo = [parrafosArray objectAtIndex:i];
        
        CGSize parrafoComentarioSize;
        CGSize constraintParrafoComentario = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                                            800); //pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo
        
        NSMutableParagraphStyle * paragraphStyleComentario = [[NSMutableParagraphStyle alloc] init];
        paragraphStyleComentario.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyleComentario.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributesComentario =       @{NSFontAttributeName : kFontTextoGeneral,
                                                      NSParagraphStyleAttributeName : paragraphStyleComentario};
        
        parrafoComentarioSize = [parrafo boundingRectWithSize:constraintParrafoComentario
                                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:attributesComentario
                                                          context:nil].size;
        
        CGRect renderingRectParrafoComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                               posicionYTrasHeader,
                                                               parrafoComentarioSize.width,
                                                               parrafoComentarioSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + parrafoComentarioSize.height;
        
        if (posicionYTrasHeader > (pageSize.height - 40)) {
            [self iniciaOtraPaginaYLlamaObjetosComunes];
            
            renderingRectParrafoComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                            posicionYTrasHeader,
                                                            parrafoComentarioSize.width,
                                                            parrafoComentarioSize.height);
            
            posicionYTrasHeader = posicionYTrasHeader + parrafoComentarioSize.height;
            
        }
        
        [parrafo drawInRect:renderingRectParrafoComentario withAttributes:attributesComentario ];
        
    }

    posicionYTrasHeader = posicionYTrasHeader + kMarginInset;
    
    //NSLog(@"COMENTARIO AUTOR %@ \nPOSICIÓN Y TRAS COMENTARIO %f", comentario, posicionYTrasHeader);
    
    /*
    // ********************************************
    VERSIÓN ANTERIOR DE DISPOSICIÓN DEL COMENTARIO (SIN FRAGMENTAR POR PÁRRAFOS) QUE TENÍA EL INCONVENIENTE DE QUE A VECES SÓLO MOSTRABA UN ALÍNEA EN EL PDF SI NO CABÍA EN LA MISMA PÁGINA.
     NSString *comentario = [dicLectura objectForKey:@"comentarioGeneralRevisor"];
    
    CGSize comentarioSize;
    CGSize constraintComentario = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleComentario = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleComentario.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleComentario.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesComentario = @{NSFontAttributeName : kFontTextoGeneral,
                                            NSParagraphStyleAttributeName : paragraphStyleComentario};
        
    comentarioSize = [comentario boundingRectWithSize:constraintComentario
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesComentario
                                                context:nil].size;
    
    CGRect renderingRectComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                       posicionYTrasHeader,
                                                       comentarioSize.width,
                                                       comentarioSize.height);

    //NSLog(@"COMENTARIO AUTOR %@ \n COMENTARIOSIZE.HEIGHT %f", comentario, comentarioSize.height);
    
    //---------------------------------------------------------------------------------------
    //Para saber si pasa a otra página calcula el rectángulo donde tendría que ir el texto,
        //si excede la posición del pie inicia nuevaPágina (donde se resetea el valor de posicionYTrasheader) y re-calcula el rectángulo.
        //Si no excede la posición del pie directamente escribe el texto
    //---------------------------------------------------------------------------------------
    posicionYSumatoria = posicionYTrasHeader + renderingRectComentario.size.height + kMarginInset;

    if (posicionYSumatoria > (pageSize.height - 40)) {

        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectEpigrafeComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                     posicionYTrasHeader + kMarginInset,
                                                     epigrafeComentarioSize.width,
                                                     epigrafeComentarioSize.height);

        posicionYTrasHeader = posicionYTrasHeader + renderingRectEpigrafeComentario.size.height + kMarginInset;

        renderingRectComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                    posicionYTrasHeader,
                                                    comentarioSize.width,
                                                    comentarioSize.height);
    }
    
    [epigrafeComentario drawInRect:renderingRectEpigrafeComentario withAttributes:attributesEpigrafe];
    
    [comentario drawInRect:renderingRectComentario withAttributes:attributesComentario];
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectComentario.size.height + kMarginInset;
    // ********************************************
    */
    
    posicionYSumatoria = posicionYTrasHeader;

}

- (void) drawLineaGruesa {
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, 2.0);
    CGContextSetStrokeColorWithColor(currentContext, [UIColor lightGrayColor].CGColor);
    
    CGPoint startPoint = CGPointMake(kBorderInset + kBorderWidth + kMarginInset, posicionYTrasHeader);
    CGPoint endPoint = CGPointMake(pageSize.width - kBorderInset - kBorderWidth - kMarginInset, posicionYTrasHeader);
    
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    
    posicionYTrasHeader = posicionYTrasHeader + kLineWidth + kMarginInset;
    posicionYSumatoria = posicionYTrasHeader;
    
}

- (void) drawTipoArtCASP {
    
    //---------------------------------------------------------------------------------------
    // Epígrafe "de InfoCASP"
    //---------------------------------------------------------------------------------------
    NSString *epigrafeComentario = NSLocalizedString(@"InfoCASP", nil);
    
    CGSize epigrafeComentarioSize;
    CGSize constraintEpigrafeComentario = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleInfo = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleInfo.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleInfo.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesInfo = @{NSFontAttributeName : kFontEnunciadoSeccion,
                                    NSParagraphStyleAttributeName : paragraphStyleInfo};
        
    epigrafeComentarioSize = [epigrafeComentario boundingRectWithSize:constraintEpigrafeComentario
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesInfo
                                                context:nil].size;
    
    CGRect renderingRectEpigrafeComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                        posicionYTrasHeader + kMarginInset,
                                                        epigrafeComentarioSize.width,
                                                        epigrafeComentarioSize.height);
    
    posicionYSumatoria = posicionYTrasHeader + renderingRectEpigrafeComentario.size.height + kMarginInset;

    if (posicionYSumatoria > (pageSize.height - 40)) {
        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectEpigrafeComentario = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                              posicionYTrasHeader + kMarginInset,
                                              epigrafeComentarioSize.width,
                                              epigrafeComentarioSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectEpigrafeComentario.size.height + kMarginInset;
        
    }

    [epigrafeComentario drawInRect:renderingRectEpigrafeComentario withAttributes:attributesInfo];

    posicionYTrasHeader = posicionYTrasHeader + renderingRectEpigrafeComentario.size.height + kMarginInset;

    //---------------------------------------------------------------------------------------
    // Enunciado del tipo de artículo según la pag 1 de plantilla CASP
    //---------------------------------------------------------------------------------------
    NSString *tipoArtCASPSring = [[dicLectura objectForKey:@"datosCASP"] objectForKey:@"tipoArticuloCASP"];
    
    CGSize tipoArtCASPSize;
    CGSize constraintTipoArtCASP = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleTipoArt = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleTipoArt.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleTipoArt.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesTipoArt = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleTipoArt};
        
    tipoArtCASPSize = [tipoArtCASPSring boundingRectWithSize:constraintTipoArtCASP
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesTipoArt
                                                context:nil].size;
    
    CGRect renderingRectTipoArtCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                posicionYTrasHeader,
                                                tipoArtCASPSize.width,
                                                tipoArtCASPSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectTipoArtCASP.size.height + kMarginInset;
        
    //Dentro del método drawLine se actualizan los valores de posicionYTrasHeader y posicionYSumatoria.
    //Simulo aquí donde va a quedar posicionYSumatoria tras la línea, en vez de llamar al método ahora para que no lopinte
    posicionYSumatoria = posicionYTrasHeader + kLineWidth + kMarginInset;
    
    if (posicionYSumatoria > (pageSize.height - 40)) {
        [self iniciaOtraPaginaYLlamaObjetosComunes];

        renderingRectTipoArtCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                              posicionYTrasHeader,
                                              tipoArtCASPSize.width,
                                              tipoArtCASPSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectTipoArtCASP.size.height + kMarginInset;

    }
    
    [tipoArtCASPSring drawInRect:renderingRectTipoArtCASP withAttributes:attributesTipoArt];
    
}

- (void) drawComentariosCASP {
    
    //---------------------------------------------------------------------------------------
    //Comentario CASP
    //---------------------------------------------------------------------------------------
    NSString *comentariosCASPString = [[dicLectura objectForKey:@"datosCASP"] objectForKey:@"comentariosCASP"];
    
    CGSize comentariosCASPSize;
    CGSize constraintComentarioCASP = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);

    NSMutableParagraphStyle * paragraphStyleComentarioCASP = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleComentarioCASP.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleComentarioCASP.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesComentarioCASP = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleComentarioCASP};
        
    comentariosCASPSize = [comentariosCASPString boundingRectWithSize:constraintComentarioCASP
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesComentarioCASP
                                                context:nil].size;
        
    CGRect renderingRectComentariosCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                 posicionYTrasHeader,
                                                 comentariosCASPSize.width,
                                                 comentariosCASPSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectComentariosCASP.size.height + kMarginInset;
    
    //Dentro del método drawLine se actualizan los valores de posicionYTrasHeader y posicionYSumatoria.
    //Simulo aquí donde va a quedar posicionYSumatoria tras la línea, en vez de llamar al método ahora para que no lopinte
    posicionYSumatoria = posicionYTrasHeader + kLineWidth + kMarginInset;
    
    if (posicionYSumatoria > (pageSize.height - 40)) {
        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectComentariosCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                              posicionYTrasHeader,
                                              comentariosCASPSize.width,
                                              comentariosCASPSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectComentariosCASP.size.height + kMarginInset;
        
    }
    
    [comentariosCASPString drawInRect:renderingRectComentariosCASP withAttributes:attributesComentarioCASP];
    
    //NSLog(@"COMMENT GEN \nCONSTRAINT %@ \nSize %@ \nRECT %@", NSStringFromCGSize(constraintComentarioCASP), NSStringFromCGSize(comentariosCASPSize), NSStringFromCGRect(renderingRectComentariosCASP));

}

- (void) drawRecordatorioCASP {
    
    //Si no hay recordatorio (plantillas en español), no hay nada de lo siguiente
    NSString *recordatorio = [[dicLectura objectForKey:@"datosCASP"] objectForKey:@"recuerdeCASP"];
    if (recordatorio.length) {
        //---------------------------------------------------------------------------------------
        //Epígrafe Recordatorio
        //---------------------------------------------------------------------------------------
        NSString *epigrafeRecordatorio = NSLocalizedString(@"Recuerde", nil);
    
        CGSize epigrafeRecordatorioSize;
        CGSize constraintEpigrafeRecordatorio = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
        NSMutableParagraphStyle * paragraphStyleEpigrafe = [[NSMutableParagraphStyle alloc] init];
        paragraphStyleEpigrafe.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyleEpigrafe.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributesEpigrafe = @{NSFontAttributeName : kFontEnunciadoSeccion,
                                      NSParagraphStyleAttributeName : paragraphStyleEpigrafe};
        
        epigrafeRecordatorioSize = [epigrafeRecordatorio boundingRectWithSize:constraintEpigrafeRecordatorio
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesEpigrafe
                                                context:nil].size;
    
        CGRect renderingRectEpigrafeRecordatorio = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                        posicionYTrasHeader + kMarginInset,
                                                        epigrafeRecordatorioSize.width,
                                                        epigrafeRecordatorioSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectEpigrafeRecordatorio.size.height + kMarginInset;
    
        //---------------------------------------------------------------------------------------
        // Recordatorio
        //---------------------------------------------------------------------------------------
        CGSize recordatorioSize;
        CGSize constraintRecordatorio = CGSizeMake(pageSize.width - 2*kBorderInset - 2*kBorderWidth - 2*kMarginInset,
                                                pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
        
        NSMutableParagraphStyle * paragraphStyleRecordatorio = [[NSMutableParagraphStyle alloc] init];
        paragraphStyleRecordatorio.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyleRecordatorio.alignment = NSTextAlignmentLeft;
            
        NSDictionary * attributesRecordatorio = @{NSFontAttributeName : kFontTextoGeneral,
                                        NSParagraphStyleAttributeName : paragraphStyleRecordatorio};
            
        recordatorioSize = [recordatorio boundingRectWithSize:constraintRecordatorio
                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributesRecordatorio
                                                    context:nil].size;
        
        CGRect renderingRectRecordatorio = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                posicionYTrasHeader,
                                                recordatorioSize.width,
                                                recordatorioSize.height);
        
        //Para saber si pasa a otra página calcula el rectángulo donde tendría que ir el texto, si excede la posición del pie inicia nuevaPágina (donde se resetea el valor de posicionYTrasheader) y re-calcula el rectángulo. Si no excede la posición del pie directamente escribe el texto
        posicionYSumatoria = posicionYTrasHeader + renderingRectRecordatorio.size.height + kMarginInset;
    
        if (posicionYSumatoria > (pageSize.height - 40)) {
            
            [self iniciaOtraPaginaYLlamaObjetosComunes];
        
            renderingRectEpigrafeRecordatorio = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                         posicionYTrasHeader + kMarginInset,
                                                         epigrafeRecordatorioSize.width,
                                                         epigrafeRecordatorioSize.height);
            
            posicionYTrasHeader = posicionYTrasHeader + renderingRectEpigrafeRecordatorio.size.height + kMarginInset;

            renderingRectRecordatorio = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                             posicionYTrasHeader,
                                             recordatorioSize.width,
                                             recordatorioSize.height);
        }
        
        [epigrafeRecordatorio drawInRect:renderingRectEpigrafeRecordatorio withAttributes:attributesEpigrafe];
        
        [recordatorio drawInRect:renderingRectRecordatorio withAttributes:attributesRecordatorio];
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectRecordatorio.size.height + kMarginInset;
        posicionYSumatoria = posicionYTrasHeader;
        

    }

    
}

- (void) drawMarcaCASP {
    
    //---------------------------------------------------------------------------------------
    // Marca CASP
    //---------------------------------------------------------------------------------------
    NSString *marcaCASPString = [[dicLectura objectForKey:@"datosCASP"] objectForKey:@"marcaCASP"];
    
    CGSize marcaCASPSize;
    CGSize constraintMarcaCASP = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleMarca = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleMarca.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleMarca.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesMarca = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleMarca};
        
    marcaCASPSize = [marcaCASPString boundingRectWithSize:constraintMarcaCASP
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesMarca
                                                context:nil].size;
    
    CGRect renderingRectMarcaCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                 posicionYTrasHeader,
                                                 marcaCASPSize.width,
                                                 marcaCASPSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectMarcaCASP.size.height + kMarginInset;
    
    //Dentro del método drawLine se actualizan los valores de posicionYTrasHeader y posicionYSumatoria.
    //Simulo aquí donde va a quedar posicionYSumatoria tras la línea, en vez de llamar al método ahora para que no lopinte
    posicionYSumatoria = posicionYTrasHeader + kLineWidth + kMarginInset;
    
    if (posicionYSumatoria > (pageSize.height - 40)) {
        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectMarcaCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                              posicionYTrasHeader,
                                              marcaCASPSize.width,
                                              marcaCASPSize.height+20);
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectMarcaCASP.size.height + kMarginInset;
        
    }
    
    [marcaCASPString drawInRect:renderingRectMarcaCASP withAttributes:attributesMarca];
    
    //NSLog(@"MARCA \n%@ \nCONSTRAINT DE MARCA %@ \nMARCACASPSize %@ \nRECT DE MARCA %@", marcaCASPString, NSStringFromCGSize(constraintMarcaCASP), NSStringFromCGSize(marcaCASPSize), NSStringFromCGRect(renderingRectMarcaCASP));

}

- (void) drawCitanosAsi {
    
    //---------------------------------------------------------------------------------------
    // Cítanos así
    //---------------------------------------------------------------------------------------
    NSString *citameCASPString = [[dicLectura objectForKey:@"datosCASP"] objectForKey:@"citameCASP"];
    
    CGSize citameCASPSize;
    CGSize constraintCitameCASP = CGSizeMake(pageSize.width - 2*kBorderInset -2*kBorderWidth - 2*kMarginInset,
                                            pageSize.height - posicionYTrasHeader - kMarginInset - kPosicionYPieDesdeAbajo);
    
    NSMutableParagraphStyle * paragraphStyleCitame = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleCitame.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleCitame.alignment = NSTextAlignmentLeft;
        
    NSDictionary * attributesCitame = @{NSFontAttributeName : kFontTextoGeneral,
                                      NSParagraphStyleAttributeName : paragraphStyleCitame};
        
    citameCASPSize = [citameCASPString boundingRectWithSize:constraintCitameCASP
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesCitame
                                                context:nil].size;
    
    CGRect renderingRectCitameCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                                 posicionYTrasHeader,
                                                 citameCASPSize.width,
                                                 citameCASPSize.height);
    
    posicionYTrasHeader = posicionYTrasHeader + renderingRectCitameCASP.size.height + kMarginInset;
    
    //Dentro del método drawLine se actualizan los valores de posicionYTrasHeader y posicionYSumatoria.
    //Simulo aquí donde va a quedar posicionYSumatoria tras la línea, en vez de llamar al método ahora para que no lopinte
    posicionYSumatoria = posicionYTrasHeader;
    
    if (posicionYSumatoria > (pageSize.height - 40)) {
        [self iniciaOtraPaginaYLlamaObjetosComunes];
        
        renderingRectCitameCASP = CGRectMake(kBorderInset + kBorderWidth + kMarginInset,
                                              posicionYTrasHeader,
                                              citameCASPSize.width,
                                              citameCASPSize.height);
        
        posicionYTrasHeader = posicionYTrasHeader + renderingRectCitameCASP.size.height + kMarginInset;
        
    }
    
    
    [citameCASPString drawInRect:renderingRectCitameCASP withAttributes:attributesCitame];
    
}

- (void) iniciaOtraPaginaYLlamaObjetosComunes {
    
    //Start a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    posicionYTrasHeader = kBorderInset + kBorderWidth + kMarginInset;
    
    [self drawObjetosComunesConReferenciaYRevisor];
    
}

@end
