//
//  InfoCASPeViewController.m
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

#import "InfoCASPeViewController.h"

@implementation InfoCASPeViewController

@synthesize delegate, miTextView;

#define COLOR_CASP [UIColor colorWithRed: 27.0/255.0 green: 160.0/255.0 blue: 23.0/255.0 alpha: 1.0]

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)done:(id)sender {
    [self.delegate infoCASPeViewControllerDidFinish:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //************* PARA SOLVENTAR EL PROBLEM CON LAS LANGUAGE IDS + REGION IDS DE IOS9
    NSArray<NSString *> *availableLanguages = @[@"en", @"es"];
    NSString *codigoIdioma = [[[NSBundle preferredLocalizationsFromArray:availableLanguages] firstObject] mutableCopy];
    
    //LA LINEA SIGUIENTE FUNCIONABA ANTES DE IOS9
    //NSString *codigoIdioma = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSLog(@"Códgigo idioma %@", codigoIdioma);
    //********************

    if ([codigoIdioma isEqualToString:@"es"]) miTextView.text = @"CASP (Critical Appraisal Skills Programme) (Programa de habilidades en lectura crítica) es un programa creado por el Institute of Health Sciences de Oxford (Universidad de Oxford y NHS R&D) para ayudar a los \"decisores\"(*) del Servicio de Salud a adquirir habilidades en la búsqueda de información y en lectura crítica de la literatura científica en salud, de modo que pudieran obtener así la \"evidencia científica\" necesaria para tomar sus decisiones. CASP colabora con el centro para la medicina Basada en la Evidencia (Centre for evidence Based Medicine) de la Universidad de Oxford que enseña a los clínicos cómo tomar decisiones, basadas en la evidencia, sobre un paciente concreto.\n\nEn España existe una red CASP (CASP España - CASPe) con múltiples nodos distribuidos por el territorio y una sede coordinadora ubicada en Alicante. CASPe forma parte de una organización internacional llamada CASP Internacional con la que comparte filosofía y experiencias docentes y de organización, materiales desarrollados en conjunto, así como proyectos de investigación sobre la docencia.\n\nCASPe es una organización abierta, sin ánimo de lucro y que se basa en la colaboración entre personas.\n\n(*) CASP y también CASPe trabajan para cualquier tipo de persona involucrada en las decisiones de salud: Clínicos, farmacéuticos, gestores, ciudadanos, etc., y promueven un aprendizaje multidisciplinar.";
    else miTextView.text = @"How can you tell whether a piece of research has been done properly and that the information it reports is reliable and trustworthy? How can you decide what to believe when making a health care decision, when research on the same topic comes to different different conclusions? This is where critical appraisal skills help.\n\nCritical appraisal is the process of carefully and systematically examining research to judge its trustworthiness, and its value and relevance in a particular context.\n\nThe purpose of the Critical Appraisal Skills Programme (CASP) is to help provide the skills necessary for finding and critically evaluating the best scientific evidence on which to base health care decisions.  CASP uses specific specialised methods to train people in the skills required to understand research, and has developed a wide range of educational materials and methods. These include the means to support organisations and health care systems in the cascade of skills, and their diffusion and management within a framework of sustainable growth.\n\nBackground\nThe Critical Appraisal Skills Programme (CASP) was developed in Oxford in 1993 and has since helped to develop an evidence based approach in health and social care, working with local, national and international partner organisations. CASPs workshops and resources aim to help participants put knowledge into practice by learning how to systematically formulate questions, find research evidence, appraise research evidence and act on what they find.\n\nDr Amanda Burls, one of the founders of CASP in Oxford. has also played a key role in the development of the CASP International Network (CASPin), a non-profit making organisation for people promoting skills in finding, critically appraising and acting on research evidence. CASPin has been an informal network since 1998, and members have developed similar critical appraisal skills programmes in Spain (CASP-CoreData), Hungary, Poland, Romania, Japan, Norway and India. Many individuals have organised CASP workshops in about 30 other countries, settings and audiences, particularly South America, and Central and Eastern Europe.";
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
