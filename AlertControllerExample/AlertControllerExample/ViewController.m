//
//  ViewController.m
//  AlertControllerExample
//
//  Created by Andreas de Reggi on 30/01/15.
//  Copyright (c) 2015 Nollie Apps. All rights reserved.
//

#import "ViewController.h"
#import "RAAlertController.h"

@interface ViewController ()
@property (strong, nonatomic) RAAlertController *alertController;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)presentAlert:(id)sender {
	self.alertController = [RAAlertController alertControllerWithTitle:@"Alert"
															   message:@"Do something?"
														preferredStyle:RAAlertControllerStyleAlert];
	[_alertController addAction:[RAAlertAction actionWithTitle:@"Do something"
														 style:RAAlertActionStyleDefault
													   handler:^(RAAlertAction *action) {
														   NSLog(@"... but what?");
													   }]];
	[_alertController addAction:[RAAlertAction actionWithTitle:@"Cancel"
														 style:RAAlertActionStyleCancel
													   handler:^(RAAlertAction *action) {
														   NSLog(@"... or not!");
													   }]];
	[_alertController presentInViewController:self animated:YES completion:^{
		NSLog(@"Alert!");
	}];
}

- (IBAction)presentActionSheet:(id)sender {
	self.alertController = [RAAlertController alertControllerWithTitle:@"Action Sheet"
															   message:@"Pick something:"
														preferredStyle:RAAlertControllerStyleActionSheet];
	[_alertController addAction:[RAAlertAction actionWithTitle:@"I like"
														 style:RAAlertActionStyleDefault
													   handler:^(RAAlertAction *action) {
														   NSLog(@"... me too.");
													   }]];
	[_alertController addAction:[RAAlertAction actionWithTitle:@"Whoah"
														 style:RAAlertActionStyleDestructive
													 premature:YES
													   handler:^(RAAlertAction *action) {
														   NSLog(@"... kaboom?");
													   }]];
	[_alertController addAction:[RAAlertAction actionWithTitle:@"Cancel"
														 style:RAAlertActionStyleCancel
													   handler:^(RAAlertAction *action) {
														   NSLog(@"... or not!");
													   }]];
	[_alertController presentInViewController:self animated:YES completion:^{
		NSLog(@"Action needed!");
	}];
}

@end
