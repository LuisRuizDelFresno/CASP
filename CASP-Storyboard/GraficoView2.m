//
//  GraficoView2.m
//  Calculadora
//
//  Created by Luis Ruiz del Fresno on 20/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraficoView2.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(angle) ((angle) *180 /M_PI)
#define VERDE_IOS7      76.0/255.0, 217.0/255.0, 100.0/255.0, 1
#define AMARILLO_IOS7   255.0/255.0, 204.0/255.0, 0.0/255.0, 1
#define ROJO_IOS7       255.0/255.0, 59.0/255.0, 48.0/255.0, 1

@implementation GraficoView2

@synthesize datosDic;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //Para que el fondo de la view sea transparente en vez de negro opaco.
        //No coge aquí los datos del diccionario, probablemente si los cogería si habilitamos el método de inicialización casero con el diccionario como parámetro
        
        self.opaque = NO; 
        
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void) drawRect:(CGRect)rect {
    
    //Sacamos los datos del estuido del dic
    rraFloat = [[datosDic objectForKey:@"RRA"] floatValue];
    ic95SupFloat = [[datosDic objectForKey:@"ic95SupRra"] floatValue];
    ic95InfFloat = [[datosDic objectForKey:@"ic95InfRra"] floatValue];
    
    //Calculamos los límites del gráfico. Añadiendo un 20% a derecha e izq  poniendo unos valores mínimos para que siempre entre la no-diferencia y un minimo de terreno de ambos lados. De esa manera las etiquetas de la escala de NNT no se solapan y el gráfico queda más equilibrado
    //Estos límites son valores de riesgo.
    //Calcula el rangoEscala para porcentualizar los números.
    
    if (ic95InfFloat > 0) {         //TODOS POS
        limIzq = ic95SupFloat*1.2;
        if (limIzq < 5) limIzq = 5;
        
        limDcho = -5;
        
        rangoEscala = limIzq-limDcho;
        
    } else {
        if (ic95SupFloat <= 0)  {   //TODOS NEG
            limIzq = 5;
            
            limDcho = ic95InfFloat*1.2;
            if (limDcho > -5) limDcho = -5;
            
            rangoEscala = limIzq-limDcho;
            
        } else {                    // UNO POS OTRO NEG
            limIzq = ic95SupFloat*1.2;
            if (limIzq < 5) limIzq = 5;
            
            limDcho = ic95InfFloat*1.2;
            if (limDcho > -5) limDcho = -5;
            
            rangoEscala = limIzq-limDcho;
            
        }
        
    }
    
    //Llama al metodo que hace un  grafico NNT-Rbasal, con escala de NNT, independientemente del intervalo de confianza del estudio. En Calculadora hay otro método para escala de NNT ajustada al intervalo de confianza del estudio.
    [self graficoNNTRBasalEscalaVariable];
    
    [self representaEstudio];

}

- (void) graficoNNTRBasalEscalaVariable {
    
//CREAr UN CONTEXTO GRÁFICO Y UN ESPACIO DE COLOR
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    
    riesgoBasal = [[datosDic objectForKey:@"riesgoBasal"] floatValue];

//RECTÁNGULO
    //Dimensiones del rectángulo . Con origen en esquina supizq de la UIView GraficoView, ancho todo el de graficoview y alto el alto de graficoview.
    CGRect frameRectangulo = CGRectMake(0, 0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    
    //CALCULOS PARA DEFINIR EQUIVALENCIA. Definomos equivalencia como Reducción del riesgo relativo < 20% o reducción del Riesgo Absoluto < 1%. Por ejemplo: la ICP primaria en general reduce el riesgo relativo e fallecer en un 30%, cuando el riesgo absoluto de fallecer con fibrinolisis es < 3%, la reducción absoluta del riesgo será < 1%. Luego las dos medidas serían clínicamente equivalentes por el criterio de RRA, aunuqe no lo fuesen por el de RRR. EN REALIDA HABRÍA QUE DEFINIR EQUIVALENCI CUANDO LE IC95% SUP DE LOS ENSAYOS POSITIVOS O EL INFERIOR DE LOS NEGATIVOS SUPUSIESEN UNA REDUCCIÓN RELATIVA DEL RIESGO < 20% o RRA < 1. Esbozo con valores absolutos: (fabsf(rraFloat) <= 1) || (fabsf(reduccionRiesgoRelativo) <= 0.2)
    //CGFloat riesgoExp = riesgoBasal - rraFloat;
    //CGFloat reduccionRiesgoRelativo = 1 - riesgoExp / riesgoBasal;
    
    //CREAMOS EL OBJETO GRADIENTE, PARA LO QUE NECESITAMOS EL ESPACIO DE COLOR PRIMERO.
    CGGradientRef gradienteRectSup;
    
    CGFloat rraIzq1, rraIzq2, rraIzq3, rraNoDif, rraDcha3, rraDcha2, rraDcha1;
    if ([[datosDic objectForKey:@"SupEqui"] isEqualToString:@"Equivalencia"]) { //Equivalentes
        
        rraIzq1      = (limIzq-7)/rangoEscala;
        if (rraIzq1 < 0)   rraIzq1 = 0;
        
        rraIzq2   = (limIzq-3)/rangoEscala;
        if (rraIzq2 < 0) rraIzq2 = 0;
        
        rraIzq3   = (limIzq-2)/rangoEscala;
        if (rraIzq3 < 0) rraIzq3 = 0;
        
        rraNoDif       = (limIzq)/rangoEscala;
        if (rraNoDif < 0) rraNoDif = 0;
        
        rraDcha3      = (limIzq +2)/rangoEscala;
        if (rraDcha3 > 1)   rraDcha3 = 1;
        
        rraDcha2   = (limIzq+3)/rangoEscala;
        if (rraDcha2 > 1) rraDcha2 = 1;
        
        rraDcha1   = (limIzq+7)/rangoEscala;
        if (rraDcha1 > 1) rraDcha1 = 1;
        
        size_t num_locations = 7;
        CGFloat locations[] = {rraIzq1, rraIzq2, rraIzq3, rraNoDif, rraDcha3, rraDcha2, rraDcha1};
        CGFloat componentsGradienteSup[] = {
            ROJO_IOS7,
            AMARILLO_IOS7,
            AMARILLO_IOS7,
            VERDE_IOS7,
            AMARILLO_IOS7,
            AMARILLO_IOS7,
            ROJO_IOS7 };
        
        gradienteRectSup = CGGradientCreateWithColorComponents (myColorspace, componentsGradienteSup, locations, num_locations);
                
    } else {
        
        /*Localizaciones de los colores, están situados a puntos concretos de RRA.
         Asumiendo que la frontera de NNT útil-dudoso puede ser 20 y dudoso-inutil 100; en escala RRA estos puntos son respectivamente 5 y 1. La zona amarilla pura sería desde RRA 3 (para crear el gradiente al verde entre 3 y 7 y que quede centrada en el 5) a RRA 2 (para crear el gradiente amarillo al rojo entre 2 y 0, centrado en 1). Luego hacia la derecha se va volviendo rojo hasta ser rojo puo en 0 y hacia la derecha el resto, y verde puro en el 7 y hacia la izquierda.
         Para trasladar estos puntos en escala de RRA, a escala de puntos graficos, calculo que % del rango de los positivos corresponde a cada punto
         Con un if para evitar % negativos, en cuyo caso asigna 0.
         */
        float rraVerde      = (limIzq-7)/rangoEscala;
        if (rraVerde < 0)   rraVerde = 0;
        
        float rraAmarillo   = (limIzq-3)/rangoEscala;
        if (rraAmarillo < 0) rraAmarillo = 0;
        
        float rraAmarillo2   = (limIzq-2)/rangoEscala;
        if (rraAmarillo2 < 0) rraAmarillo2 = 0;
        
        float rraRojo       = (limIzq)/rangoEscala;
        if (rraRojo < 0) rraRojo = 0;
        
        size_t num_locations = 4;
        CGFloat locations[] = {rraVerde, rraAmarillo, rraAmarillo2, rraRojo};
        CGFloat componentsGradienteSup[] = {
            VERDE_IOS7,     //VERDE
            AMARILLO_IOS7,     //AMARILLO
            AMARILLO_IOS7,     //Amarillo
            ROJO_IOS7 };   // Color Fin Rojo
        
        gradienteRectSup = CGGradientCreateWithColorComponents (myColorspace, componentsGradienteSup, locations, num_locations);
                
    }
    
    //Geometría del gradiente
    CGPoint inicioGradSup;  //CGPoint inicial del eje del gradiente lineal (es eje transversal al gradiente).
    CGPoint finGradSup;     //CGPoint del punto final del gradiente
    inicioGradSup.x = CGRectGetMinX(self.bounds);
    inicioGradSup.y = CGRectGetMinY(self.bounds);
    finGradSup.x = CGRectGetMaxX(self.bounds);
    finGradSup.y = CGRectGetMinY(self.bounds);
    
    //Pintamos el gradiente (CGContextDrawLinearGradient). Antes de hacerlo vamos a clipar (CGContextClipToRect) para que el gradiente se quede limitado al rectángulo que nos interesa; y antes de clipar vamos a guardar el estado del contexto (CGContextSaveGState) para luego restaurarlo a la situación no clipada (CGContextRestoreGState) y seguir añadiendo colores, ... en otras zonas.
    CGContextSaveGState(context);                       //Guarda estadod el contexto 
    CGContextClipToRect(context, frameRectangulo);   //Restringe lo que venga detrás a ese área.
    CGContextDrawLinearGradient(context, gradienteRectSup, inicioGradSup, finGradSup, 0); //Colorea
    CGContextRestoreGState(context);                    //Restaura el resto del contexto a la situación guardada
    
//LÍNEA DE NO-DIFERENCIA con sus etiquetas        
    //CALcula posición de la línea de no Dif
    float noDifXPorcentual = limIzq/rangoEscala;
    
    CGFloat componentsLinea[] = {0.0, 0.0, 0.0, 1.0};
    CGColorRef color = CGColorCreate(myColorspace, componentsLinea);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, CGRectGetMaxX(self.bounds)*noDifXPorcentual, CGRectGetMinY(self.bounds));
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds)*noDifXPorcentual, CGRectGetMaxY(self.bounds));
    CGContextStrokePath(context);
    CGColorRelease(color);
    
    //Etiquetas de la escala de infinito
    UILabel *izqInfinitoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)*noDifXPorcentual-2, CGRectGetMaxY(self.bounds)+1, 30, 10)];
    izqInfinitoLabel.text = [NSString stringWithFormat:@"∞"];
    izqInfinitoLabel.font = [UIFont boldSystemFontOfSize:13];
    izqInfinitoLabel.textAlignment = NSTextAlignmentLeft;
    izqInfinitoLabel.backgroundColor = [UIColor clearColor];
    izqInfinitoLabel.textColor = [UIColor blackColor];
    [self addSubview:izqInfinitoLabel];
    
    //Prepara un diccionario con objetos NSNumber para pasarle las posiciones que van a tomar las etiquetas.
    //Estas posiciones son puntos gráficos, no porcentajes ni valores de riesgo
    float posicionXSobreCero = noDifXPorcentual*self.bounds.size.width/2;
    float posicionXBajoCero = (noDifXPorcentual + (1-noDifXPorcentual)/2)*self.bounds.size.width; 
    
    NSNumber *posicionXSobreCeroNumber = [NSNumber numberWithFloat:posicionXSobreCero-5];
    NSNumber *posicionXBajoCeroNumber = [NSNumber numberWithFloat:posicionXBajoCero-5];
    
    NSMutableDictionary *etiquetasDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:posicionXSobreCeroNumber, @"posicionXSobreCeroNumber", posicionXBajoCeroNumber, @"posicionXBajoCeroNumber", nil];
    
    [self escalaNNT:etiquetasDic];
    
    [self escalaRBasal];
    
    [self etiquetasNNT];
    
    CGGradientRelease(gradienteRectSup);
    CGColorSpaceRelease(myColorspace);
    
}

- (void) escalaNNT:(NSDictionary *)etiquetasDic {
    
    //ESCALA NNT.
    //ESCALA DE RRA. Luego los NNT que los va calculando los valores a partir de los de RRA (NNT = 100/(RRA expresado en %)). Ya que la escala de RRA es lineal y la de NNT es logarírmica, lo más facil es colocar los RRA y calcular desde ellos los NNT correspondientes.

    //Dos etiquetas en RRA y NNT condicionadas a tener espacio
    float posicionXSobreCero = [[etiquetasDic objectForKey:@"posicionXSobreCeroNumber"] floatValue];
    if (posicionXSobreCero > 15) {
        float valorRRAIntermedioSobreCero = limIzq - rangoEscala*posicionXSobreCero/self.bounds.size.width;

        UILabel *intermPosNNTLabel = [[UILabel alloc] initWithFrame:CGRectMake(posicionXSobreCero, CGRectGetMaxY(self.bounds)+1, 22, 10)];
        intermPosNNTLabel.text = [NSString stringWithFormat:@"%0.0f", 100/valorRRAIntermedioSobreCero];
        intermPosNNTLabel.font = [UIFont boldSystemFontOfSize:9];
        intermPosNNTLabel.textAlignment = NSTextAlignmentRight;
        intermPosNNTLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:intermPosNNTLabel];
    
    }
    
    float posicionXBajoCero = [[etiquetasDic objectForKey:@"posicionXBajoCeroNumber"] floatValue];
    if (posicionXBajoCero <= 250) {
        float valorRRAIntermedioBajoCero = limIzq - rangoEscala*posicionXBajoCero/self.bounds.size.width;
        
        UILabel *intermNegNNTLabel = [[UILabel alloc] initWithFrame:CGRectMake(posicionXBajoCero, CGRectGetMaxY(self.bounds)+1, 22, 10)];
        intermNegNNTLabel.text = [NSString stringWithFormat:@"%0.0f", fabsf(100/valorRRAIntermedioBajoCero)];
        intermNegNNTLabel.font = [UIFont boldSystemFontOfSize:9];
        intermNegNNTLabel.textAlignment = NSTextAlignmentLeft;
        intermNegNNTLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:intermNegNNTLabel];
    
    }
    
    //Escala NNT
    /*
    UILabel *nNTLabel = [[UILabel alloc] initWithFrame:CGRectMake(-20, CGRectGetMaxY(self.bounds)+1, 30, 10)];
    nNTLabel.text = [NSString stringWithFormat:@"NNT:"];
    nNTLabel.font = [UIFont boldSystemFontOfSize:9];
    nNTLabel.textAlignment = NSTextAlignmentLeft;
    nNTLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:nNTLabel];
    */
    
    UILabel *limIzqNNTLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, CGRectGetMaxY(self.bounds)+1, 20, 10)];
    limIzqNNTLabel.text = [NSString stringWithFormat:@"%0.0f", fabsf(100/limIzq)];
    limIzqNNTLabel.font = [UIFont boldSystemFontOfSize:9];
    limIzqNNTLabel.textAlignment = NSTextAlignmentLeft;
    limIzqNNTLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:limIzqNNTLabel];
    
    UILabel *limDchoNNTLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)-20, CGRectGetMaxY(self.bounds)+1, 22, 10)];
    limDchoNNTLabel.text = [NSString stringWithFormat:@"%0.0f", fabsf(100/limDcho)];
    limDchoNNTLabel.font = [UIFont boldSystemFontOfSize:9];
    limDchoNNTLabel.textAlignment = NSTextAlignmentRight;
    limDchoNNTLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:limDchoNNTLabel];
    
}

- (void) escalaRBasal {
    
    //ESCALA RIESGO BASAL
    UILabel *escalaRBasal20 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)+2, CGRectGetMaxY(self.bounds)*0.2, 30, 10)];
    escalaRBasal20.text = [NSString stringWithFormat:@"80"];
    escalaRBasal20.font = [UIFont systemFontOfSize:9];
    escalaRBasal20.textAlignment = NSTextAlignmentLeft;
    escalaRBasal20.backgroundColor = [UIColor clearColor];
    escalaRBasal20.textColor = [UIColor blueColor];
    [self addSubview:escalaRBasal20];
    
    UILabel *escalaRBasal40 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)+2, CGRectGetMaxY(self.bounds)*0.4, 30, 10)];
    escalaRBasal40.text = [NSString stringWithFormat:@"60"];
    escalaRBasal40.font = [UIFont systemFontOfSize:9];
    escalaRBasal40.textAlignment = NSTextAlignmentLeft;
    escalaRBasal40.backgroundColor = [UIColor clearColor];
    escalaRBasal40.textColor = [UIColor blueColor];
    [self addSubview:escalaRBasal40];
    
    UILabel *escalaRBasal60 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)+2, CGRectGetMaxY(self.bounds)*0.6, 30, 10)];
    escalaRBasal60.text = [NSString stringWithFormat:@"40"];
    escalaRBasal60.font = [UIFont systemFontOfSize:9];
    escalaRBasal60.textAlignment = NSTextAlignmentLeft;
    escalaRBasal60.backgroundColor = [UIColor clearColor];
    escalaRBasal60.textColor = [UIColor blueColor];
    [self addSubview:escalaRBasal60];
    
    UILabel *escalaRBasal80 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)+2, CGRectGetMaxY(self.bounds)*0.8, 30, 10)];
    escalaRBasal80.text = [NSString stringWithFormat:@"20"];
    escalaRBasal80.font = [UIFont systemFontOfSize:9];
    escalaRBasal80.textAlignment = NSTextAlignmentLeft;
    escalaRBasal80.backgroundColor = [UIColor clearColor];
    escalaRBasal80.textColor = [UIColor blueColor];
    [self addSubview:escalaRBasal80];
    
    UILabel *escalaRBasalNombre = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)-25, 5, 60, 10)];
    [escalaRBasalNombre setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    escalaRBasalNombre.text = [NSString stringWithFormat:NSLocalizedString(@"RBasalEtiqueta", nil)];
    escalaRBasalNombre.font = [UIFont boldSystemFontOfSize:9];
    escalaRBasalNombre.textAlignment = NSTextAlignmentRight;
    escalaRBasalNombre.backgroundColor = [UIColor clearColor];
    escalaRBasalNombre.textColor = [UIColor blueColor];
    [self addSubview:escalaRBasalNombre];
    
}

- (void) etiquetasNNT {
    
    UIFont *miFont = [UIFont fontWithName:@"Helvetica-BoldOblique" size:12];
    
    UILabel *etiquetaNNTBeneficio = [[UILabel alloc] initWithFrame:CGRectMake(-20, CGRectGetMaxY(self.bounds)+15, 120, 20)];
    etiquetaNNTBeneficio.text = NSLocalizedString(@"etiquetaNNTBeneficio", nil);
    etiquetaNNTBeneficio.font = miFont;
    etiquetaNNTBeneficio.textAlignment = NSTextAlignmentLeft;
    etiquetaNNTBeneficio.backgroundColor = [UIColor clearColor];
    [self addSubview:etiquetaNNTBeneficio];
    
    UILabel *etiquetaNNTHarm = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bounds)-120, CGRectGetMaxY(self.bounds)+15, 140, 20)];
    etiquetaNNTHarm.text = NSLocalizedString(@"etiquetaNNTHarm", nil);
    etiquetaNNTHarm.font = miFont;
    etiquetaNNTHarm.textAlignment = NSTextAlignmentRight;
    etiquetaNNTHarm.backgroundColor = [UIColor clearColor];
    [self addSubview:etiquetaNNTHarm];
    

}

- (void) representaEstudio {
    
    riesgoBasal = [[datosDic objectForKey:@"riesgoBasal"] floatValue];

    float circuloX          = CGRectGetMaxX(self.bounds)*(limIzq-rraFloat)/rangoEscala;
    float circuloY          = CGRectGetMaxY(self.bounds)*(100-riesgoBasal)/100;
    float circuloRadio      = 4;
    
    //UN círculo
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect rectangle = CGRectMake(circuloX-circuloRadio, circuloY-circuloRadio, circuloRadio*2, circuloRadio*2);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    //Una linea al IC95%Sup    
    CGContextMoveToPoint(context, CGRectGetMaxX(self.bounds)*(limIzq-ic95SupFloat)/rangoEscala, circuloY);
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds)*(limIzq-ic95InfFloat)/rangoEscala, circuloY);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    CGContextStrokePath(context);
    
}

@end
