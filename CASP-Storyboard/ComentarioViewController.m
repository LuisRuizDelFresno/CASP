//  Basado en la Sample Code ### KeyboardAccessory ###
//  https://developer.apple.com/library/ios/samplecode/KeyboardAccessory/Introduction/Intro.html#//apple_ref/doc/uid/DTS40009462
//
//  ComentarioViewController.m
//  CASP
//
//  Created by Luis Ruiz del Fresno on 15/1/15.
//  Copyright (c) 2015 Luis Ruiz del Fresno. All rights reserved.
//

#import "ComentarioViewController.h"
#import "AppDelegate.h"

@interface ComentarioViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;

// the height constraint we want to change when the keyboard shows/hides
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintToAdjust;

@end


#pragma mark -

@implementation ComentarioViewController

#define VERDE_TEXTO                 [UIColor colorWithRed: 27.0/255.0 green: 100.0/255.0 blue: 23.0/255.0 alpha: 0.8]

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // TITULO NAV BAR
    self.title = NSLocalizedString(@"comentarios", nil);
    
    // set the right bar button item initially to "Edit" state
    self.navigationItem.rightBarButtonItem = self.editButton;
        
    if (!_lecturaCritica.comentario.length)  self.textView.text = NSLocalizedString(@"Escriba aquí sus comentarios", nil);
    else                                    self.textView.text = _lecturaCritica.comentario;

    //Para que coloree los textos
    [self colorDelTexto];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    //PAra evita el error de que no encuentra un NSManagedObjetModel Etiquetas, tomado de stackoverflow.com/questions/1074539/passing-a-managedobjectcontext-to-a-second-view
    if (_context == nil) {
        _context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSLog(@"NO HABIA MANAGEDOBJECT CONTEXT DONDE DEBIA HABERLO: %s", __FUNCTION__);
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    // observe keyboard hide and show notifications to resize the text view appropriately
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // start editing the UITextView (makes the keyboard appear when the application launches)
    //[self editAction:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    //------------------------------------------------------------------------------------------
    [self saveContext];

}

- (void)saveContext {
    NSError *error = nil;
    if (_context != nil) {
        if ([_context hasChanges] && ![_context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender {
    
    // user tapped the Done button, release first responder on the text view
    [self.textView resignFirstResponder];
}

- (IBAction)editAction:(id)sender {
    
    // user tapped the Edit button, make the text view first responder
    [self.textView becomeFirstResponder];
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
        
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    
    [aTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    return YES;
}

- (void)adjustSelection:(UITextView *)textView {
    
    // workaround to UITextView bug, text at the very bottom is slightly cropped by the keyboard
    if ([textView respondsToSelector:@selector(textContainerInset)]) {
        [textView layoutIfNeeded];
        CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        caretRect.size.height += textView.textContainerInset.bottom;
        [textView scrollRectToVisible:caretRect animated:NO];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqual:NSLocalizedString(@"Escriba aquí sus comentarios", nil)]) textView.text = @"";
    
    [self adjustSelection:textView];
        
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    [self adjustSelection:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = NSLocalizedString(@"Escriba aquí sus comentarios", nil);
        _lecturaCritica.comentario = nil;
        
    } else {
        if (![textView.text isEqual:NSLocalizedString(@"Escriba aquí sus comentarios", nil)]) _lecturaCritica.comentario = textView.text;
        
    }
    
    //Para que coloree los textos
    [self colorDelTexto];
    
}

- (void) colorDelTexto {
    if ([_textView.text isEqual:NSLocalizedString(@"Escriba aquí sus comentarios", nil)])   _textView.textColor = VERDE_TEXTO;
    else                                                                                    _textView.textColor = [UIColor blackColor];
    
}


#pragma mark - Responding to keyboard events

- (void)adjustTextViewByKeyboardState:(BOOL)showKeyboard keyboardInfo:(NSDictionary *)info {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    // transform the UIViewAnimationCurve to a UIViewAnimationOptions mask
    UIViewAnimationCurve animationCurve = [info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState;
    if (animationCurve == UIViewAnimationCurveEaseIn) {
        animationOptions |= UIViewAnimationOptionCurveEaseIn;
    }
    else if (animationCurve == UIViewAnimationCurveEaseInOut) {
        animationOptions |= UIViewAnimationOptionCurveEaseInOut;
    }
    else if (animationCurve == UIViewAnimationCurveEaseOut) {
        animationOptions |= UIViewAnimationOptionCurveEaseOut;
    }
    else if (animationCurve == UIViewAnimationCurveLinear) {
        animationOptions |= UIViewAnimationOptionCurveLinear;
    }
    
    [self.textView setNeedsUpdateConstraints];
    
    if (showKeyboard) {
        NSValue *keyboardFrameVal = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
        
        // adjust the constraint constant to include the keyboard's height
        self.constraintToAdjust.constant += keyboardFrame.size.height;
    }
    else {
        self.constraintToAdjust.constant = 0;
    }
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    // now that the frame has changed, move to the selection or point of edit               // ADAPTAR AL CURSOR
    NSRange selectedRange = self.textView.selectedRange;
    [self.textView scrollRangeToVisible:selectedRange];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:YES keyboardInfo:userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:NO keyboardInfo:userInfo];
}

@end