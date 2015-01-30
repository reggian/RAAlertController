RAAlertController
==================

A simple UIAlertController wrapper for iOS 7 compatibility.

ARC Compatibility
-----------------

RAAlertController requires ARC.

Installation and Usage
------------

To use RAAlertController, just drag the RAAlertController folder into your project.

See the AlertControllerExample app for usage.


Properties and Methods
----------------------

All properties and methods are mostly the same as UIAlertController's except the presenting.

**RAAlertController has the following additional properties:**

	@property (strong, nonatomic) UIAlertController *uiAlertController;

Provided if you need to access the UIAlertController instance used with iOS 8.

	@property (strong, nonatomic) UIActionSheet *uiActionSheet;
	@property (strong, nonatomic) UIAlertView *uiAlertView;

Provided if you need to access the UIActionSheet or UIAlertView instance used with iOS 7.

**RAAlertAction has one additional property:**

	@property (nonatomic, getter=isPremature) BOOL premature;

Indicates if the handler should be called immediately after button tap. Works with iOS 7 only.

**Presenting the alert:**

	- (void)presentInViewController:(UIViewController *)parentViewController animated:(BOOL)flag completion:(void (^)(void))completion;

The alerts are presented using this method. In iOS 8 this will simply call:

	[parentViewController presentViewController:self.uiAlertController animated:flag completion:completion];

In iOS 7 the action sheet or alert view will be presented accordingly.
