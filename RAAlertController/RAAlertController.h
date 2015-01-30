//
//  RAAlertController.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RAAlertActionStyle) {
	RAAlertActionStyleDefault = 0,
	RAAlertActionStyleCancel,
	RAAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, RAAlertControllerStyle) {
	RAAlertControllerStyleActionSheet = 0,
	RAAlertControllerStyleAlert
};

@interface RAAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(RAAlertActionStyle)style handler:(void (^)(RAAlertAction *action))handler;
+ (instancetype)actionWithTitle:(NSString *)title style:(RAAlertActionStyle)style premature:(BOOL)flag handler:(void (^)(RAAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) RAAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, getter=isPremature) BOOL premature;

@end

@interface RAAlertController : NSObject

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(RAAlertControllerStyle)preferredStyle;

- (void)addAction:(RAAlertAction *)action;
@property (nonatomic, readonly) NSArray *actions;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray *textFields;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) RAAlertControllerStyle preferredStyle;

@property (strong, nonatomic) UIAlertController *uiAlertController;
@property (strong, nonatomic) UIActionSheet *uiActionSheet;
@property (strong, nonatomic) UIAlertView *uiAlertView;

- (void)presentInViewController:(UIViewController *)parentViewController animated:(BOOL)flag completion:(void (^)(void))completion;

@end

