//
//  InfoCASPeViewController.h
//  CASP-Storyboard
//
//  Created by Luis Ruiz del Fresno on 05/10/13.
//  Copyright (c) 2013 Luis Ruiz del Fresno. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoCASPeViewControllerDelegate;

@interface InfoCASPeViewController : UIViewController {

    id <InfoCASPeViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, unsafe_unretained) id <InfoCASPeViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextView *miTextView;

- (IBAction)done:(id)sender;

@end

@protocol InfoCASPeViewControllerDelegate

- (void)infoCASPeViewControllerDidFinish:(InfoCASPeViewController *)infoCASPeViewController;

@end