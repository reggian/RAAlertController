//
//  RAAlertController.m
//
//  Version 0.1, January 30th, 2015
//
//  Created by Andreas de Reggi on 30. 01. 2015.
//  Copyright (c) 2015 Nollie Apps.
//
//  Get the latest version from here:
//
//  https://github.com/Reggian/RAAlertController
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "RAAlertController.h"

typedef void (^ActionHandler)(RAAlertAction *action);
typedef void (^CompletionHandler)(void);

//--------------------------------------------------------------------------------------------------------------
#pragma mark - RAAlertAction -
//--------------------------------------------------------------------------------------------------------------

@interface RAAlertAction ()
@property (strong, nonatomic) UIAlertAction *uiAlertAction;
@property (copy, nonatomic) ActionHandler handler;
@property (strong, nonatomic) NSString *title;
@property (nonatomic) RAAlertActionStyle style;
@end

@implementation RAAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(RAAlertActionStyle)style handler:(void (^)(RAAlertAction *action))handler {
	return [self actionWithTitle:title style:style premature:NO handler:handler];
}

+ (instancetype)actionWithTitle:(NSString *)title style:(RAAlertActionStyle)style premature:(BOOL)flag handler:(void (^)(RAAlertAction *action))handler
{
	RAAlertAction *alertAction = [[RAAlertAction alloc] init];
	if (NSClassFromString(@"UIAlertAction")) {
		void (^uiHandler)(UIAlertAction *action) = NULL;
		if (handler != NULL) {
			alertAction.handler = handler;
			uiHandler = ^(UIAlertAction *action) {
				alertAction.handler(alertAction);
			};
		}
		alertAction.uiAlertAction = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyle)style handler:uiHandler];
	}
	else {
		alertAction.title = title;
		alertAction.style = style;
		alertAction.handler = handler;
	}
	alertAction.premature = flag;
	return alertAction;
}

- (NSString *)title {
	return (self.uiAlertAction != nil ? self.uiAlertAction.title : _title);
}

- (RAAlertActionStyle)style {
	return (self.uiAlertAction != nil ? (RAAlertActionStyle)self.uiAlertAction.style : _style);
}

- (BOOL)isEnabled {
	return (self.uiAlertAction != nil ? self.uiAlertAction.enabled : YES);
}

- (void)setEnabled:(BOOL)enabled {
	if (self.uiAlertAction != nil) {
		[self.uiAlertAction setEnabled:enabled];
	}
}

//--------------------------------------------------------------------------------------------------------------

- (void)setPremature:(BOOL)premature
{
	if (self.uiAlertAction == nil) {
		_premature = premature;
	}
#ifdef DEBUG
	else if (premature) {
		NSLog(@"WARNING : RAAlertController Premature action handling is not supported by iOS 8. Unfortunately.");
	}
#endif
}

@end

//--------------------------------------------------------------------------------------------------------------
#pragma mark - RAAlertController -
//--------------------------------------------------------------------------------------------------------------

@interface RAAlertController () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic) RAAlertControllerStyle preferredStyle;
@property (strong, nonatomic) NSArray *actions;
@property (nonatomic) NSUInteger cancelActionIndex;
@property (nonatomic) NSUInteger destructiveActionIndex;

@property (copy, nonatomic) CompletionHandler presentationCompletion;
@end

@implementation RAAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(RAAlertControllerStyle)preferredStyle {
	RAAlertController *controller = [[RAAlertController alloc] init];
	if (NSClassFromString(@"UIAlertController")) {
		controller.uiAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyle)preferredStyle];
	}
	else {
		controller.title = title;
		controller.message = message;
		controller.preferredStyle = preferredStyle;
		controller.cancelActionIndex = NSNotFound;
		controller.destructiveActionIndex = NSNotFound;
	}
	return controller;
}

- (void)addAction:(RAAlertAction *)action {
	if (self.uiAlertController != nil) {
		self.actions = [self.actions arrayByAddingObject:action];
		[self.uiAlertController addAction:action.uiAlertAction];
	}
	else if (![self.uiAlertView isVisible] && ![self.uiActionSheet isVisible]) {
		self.actions = [self.actions arrayByAddingObject:action];
		switch (action.style) {
			case RAAlertActionStyleCancel:
				if (self.cancelActionIndex == NSNotFound) {
					self.cancelActionIndex = [self.actions indexOfObject:action];
				}
				else {
					[NSException raise:NSInternalInconsistencyException
								format:@"RAAlertController can only have one action with a style of RAAlertActionStyleCancel"];
				}
				break;
			case RAAlertActionStyleDestructive:
				switch (_preferredStyle) {
					case RAAlertControllerStyleActionSheet:
						if (self.destructiveActionIndex == NSNotFound) {
							self.destructiveActionIndex = [self.actions indexOfObject:action];
						}
#ifdef DEBUG
						else {
							NSLog(@"WARNING : RAAlertController -addAction: Only one action with a style of RAAlertActionStyleDestructive is supported on iOS 7.");
						}
#endif
						break;
					case RAAlertControllerStyleAlert:
#ifdef DEBUG
						NSLog(@"WARNING : RAAlertController -addAction: Actions with a style of RAAlertActionStyleDestructive are not supported with RAAlertController with a style of RAAlertControllerStyleAlert on iOS 7.");
#endif
						break;
				}
				break;
			case RAAlertActionStyleDefault:
				break;
		}
	}
}

- (NSArray *)actions {
	return _actions ?: [NSArray array];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
	if (self.uiAlertController != nil) {
		[self.uiAlertController addTextFieldWithConfigurationHandler:configurationHandler];
	}
#ifdef DEBUG
	else {
		NSLog(@"WARNING : RAAlertController -addTextFieldWithConfigurationHandler: Not supported on iOS 7.");
	}
#endif
}

- (NSArray *)textFields {
	return self.uiAlertController.textFields;
}

- (NSString *)title {
	return (self.uiAlertController != nil ? self.uiAlertController.title : _title);
}

- (NSString *)message {
	return (self.uiAlertController != nil ? self.uiAlertController.message : _message);
}

- (RAAlertControllerStyle)preferredStyle {
	return (self.uiAlertController != nil ? (RAAlertControllerStyle)self.uiAlertController.preferredStyle : _preferredStyle);
}

//--------------------------------------------------------------------------------------------------------------

- (void)presentInViewController:(UIViewController *)parentViewController animated:(BOOL)flag completion:(void (^)(void))completion
{
	if (self.uiAlertController != nil) {
		[parentViewController presentViewController:self.uiAlertController animated:flag completion:completion];
	}
	else {
		self.presentationCompletion = completion;
		switch (_preferredStyle) {
			case RAAlertControllerStyleActionSheet: {
				NSMutableArray *actions = [NSMutableArray arrayWithCapacity:[self.actions count]];
				NSString *destructiveButtonTitle = nil;
				if (self.destructiveActionIndex != NSNotFound) {
					RAAlertAction *alertAction = self.actions[self.destructiveActionIndex];
					destructiveButtonTitle = alertAction.title;
					[actions addObject:alertAction];
				}
				self.uiActionSheet = [[UIActionSheet alloc] initWithTitle:_title
															   delegate:self
													  cancelButtonTitle:nil
												 destructiveButtonTitle:destructiveButtonTitle
													  otherButtonTitles:nil];
				[self.actions enumerateObjectsUsingBlock:^(RAAlertAction *alertAction, NSUInteger idx, BOOL *stop) {
					if (idx != self.cancelActionIndex && idx != self.destructiveActionIndex) {
						[_uiActionSheet addButtonWithTitle:alertAction.title];
						[actions addObject:alertAction];
					}
				}];
				if (self.cancelActionIndex != NSNotFound) {
					RAAlertAction *alertAction = self.actions[self.cancelActionIndex];
					[_uiActionSheet addButtonWithTitle:alertAction.title];
					[_uiActionSheet setCancelButtonIndex:_uiActionSheet.numberOfButtons - 1];
					[actions addObject:alertAction];
				}
				[_uiActionSheet showInView:parentViewController.view];
				self.actions = [actions copy];
				break;
			}
			case RAAlertControllerStyleAlert: {
				NSMutableArray *actions = [NSMutableArray arrayWithCapacity:[self.actions count]];
				self.uiAlertView = [[UIAlertView alloc] initWithTitle:_title
															message:_message
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:nil];
				[self.actions enumerateObjectsUsingBlock:^(RAAlertAction *alertAction, NSUInteger idx, BOOL *stop) {
					if (idx != self.cancelActionIndex) {
						[_uiAlertView addButtonWithTitle:alertAction.title];
						[actions addObject:alertAction];
					}
				}];
				if (self.cancelActionIndex != NSNotFound) {
					RAAlertAction *alertAction = self.actions[self.cancelActionIndex];
					[_uiAlertView addButtonWithTitle:alertAction.title];
					[_uiAlertView setCancelButtonIndex:_uiAlertView.numberOfButtons - 1];
					[actions addObject:alertAction];
				}
				[_uiAlertView show];
				self.actions = [actions copy];
				break;
			}
		}
	}
}

//--------------------------------------------------------------------------------------------------------------
#pragma mark - UIActionSheetDelegate
//--------------------------------------------------------------------------------------------------------------

//// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//	
//}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	if (actionSheet.cancelButtonIndex >= 0 && actionSheet.cancelButtonIndex < [self.actions count]) {
		RAAlertAction *alertAction = self.actions[actionSheet.cancelButtonIndex];
		if (alertAction.handler != NULL) {
			alertAction.handler(alertAction);
		}
	}
}

//// before animation and showing view
//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
//	
//}

// after animation
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
	if (self.presentationCompletion != NULL) {
		self.presentationCompletion();
	}
}

// before animation and hiding view
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex >= 0 && buttonIndex < [self.actions count]) {
		RAAlertAction *alertAction = self.actions[buttonIndex];
		if ([alertAction isPremature] && alertAction.handler != NULL) {
			alertAction.handler(alertAction);
		}
	}
}

// after animation
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex >= 0 && buttonIndex < [self.actions count]) {
		RAAlertAction *alertAction = self.actions[buttonIndex];
		if (![alertAction isPremature] && alertAction.handler != NULL) {
			alertAction.handler(alertAction);
		}
	}
	self.uiActionSheet = nil;
}

//--------------------------------------------------------------------------------------------------------------
#pragma mark - UIAlertViewDelegate
//--------------------------------------------------------------------------------------------------------------

//// Called when a button is clicked. The view will be automatically dismissed after this call returns
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//
//}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView {
	if (alertView.cancelButtonIndex >= 0 && alertView.cancelButtonIndex < [self.actions count]) {
		RAAlertAction *alertAction = self.actions[alertView.cancelButtonIndex];
		if (alertAction.handler != NULL) {
			alertAction.handler(alertAction);
		}
	}
}

//// before animation and showing view
//- (void)willPresentAlertView:(UIAlertView *)alertView {
//	
//}

// after animation
- (void)didPresentAlertView:(UIAlertView *)alertView {
	if (self.presentationCompletion != NULL) {
		self.presentationCompletion();
	}
}

// before animation and hiding view
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex >= 0 && buttonIndex < [self.actions count]) {
		RAAlertAction *alertAction = self.actions[buttonIndex];
		if ([alertAction isPremature] && alertAction.handler != NULL) {
			alertAction.handler(alertAction);
		}
	}
}

// after animation
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex >= 0 && buttonIndex < [self.actions count]) {
		RAAlertAction *alertAction = self.actions[buttonIndex];
		if (![alertAction isPremature] && alertAction.handler != NULL) {
			alertAction.handler(alertAction);
		}
	}
	self.uiAlertView = nil;
}

//// Called after edits in any of the default fields added by the style
//- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
//	return YES;
//}

@end
