//
//  CalculadorasViewController.m
//  CASPe
//
//  Created by Luis Ruiz del Fresno on 08/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculadorasViewController.h"
#import "NNTViewController.h"
#import "DiagViewController.h"

@interface CalculadorasViewController ()

@end

@implementation CalculadorasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"tituloCalculadoras", nil);

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"celdaCalc";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    }
    // Configure the cell...
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"calculadoraNNT", nil);
    } else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"calculadoraDiag", nil);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {

        [self performSegueWithIdentifier:@"segueNNT" sender:self.view];
        
        //NNTViewController *nntVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NNTVC"];
        //[self.navigationController pushViewController:nntVC animated:YES];
    } else if (indexPath.section == 1) {

        [self performSegueWithIdentifier:@"segueDiag" sender:self.view];

        //DiagViewController *diagCalcVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DiagViewController"];
        //[self.navigationController pushViewController:diagCalcVC animated:YES];
    }
}

@end
