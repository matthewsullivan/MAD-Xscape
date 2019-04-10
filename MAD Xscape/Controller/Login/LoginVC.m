//
//  LoginVC.m
//  MAD Xscape
//
//  Created by Matthew Sullivan on 2017-06-13.
//  Copyright © 2017 So Creative Inc. All rights reserved.
//

#import "LoginVC.h"
#import "ViewFX.h"
#import "ServiceConnect.h"
#import "Teams.h"


@interface LoginVC () <UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UITextField *loginInput;
@property (strong, nonatomic) UIScrollView *loginScrollView;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backGroundImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBG"]];

    backGroundImg.frame = self.view.bounds;
    backGroundImg.backgroundColor = [UIColor blackColor];
    backGroundImg.contentMode = UIViewContentModeScaleAspectFill;
    backGroundImg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:backGroundImg];
    [self.view sendSubviewToBack:backGroundImg];
    
    [ViewFX applyTiltEffectTo:backGroundImg];
    [ViewFX applyBlurEffectTo:self.view];
    
    /*
     * loginScrollView setup
     */
    self.loginScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.loginScrollView.delegate = self;
    self.loginScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.loginScrollView];
    
    UIView *loginInformation = [[UIView alloc] initWithFrame: CGRectMake(0,
                                                                      0,
                                              self.view.bounds.size.width,
                                                                    220)];
    
    loginInformation.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    UILabel *loginTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                40,
                                  loginInformation.bounds.size.width,
                                                                35)];
    
    loginTitle.text = NSLocalizedString(@"Decoder Password", @"Login Screen Title");
    loginTitle.textColor = [UIColor whiteColor];
    loginTitle.font =[UIFont fontWithName:@"Roboto-Medium" size:20];

    loginTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    loginTitle.textAlignment = NSTextAlignmentCenter;
    
    /*
     * Login Description Setup
     */
    UILabel *loginDescription = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                    80,
                                                                    loginInformation.bounds.size.width - 20,
                                                                    35)];
    
    loginDescription.text = NSLocalizedString(@"If you choose to except this mission please enter the decoder password provided in the email you received. This message will NOT auto destruct in 10 seconds.", @"Login Screen Desription");
    loginDescription.textColor = [UIColor whiteColor];
    loginDescription.font = [UIFont fontWithName:@"Roboto-Regular" size:18];
    loginDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    loginDescription.textAlignment = NSTextAlignmentCenter;
    
    CGSize max = CGSizeMake(loginDescription.frame.size.width, 500);
    CGRect textRect = [loginDescription.text boundingRectWithSize:max
                                             options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                          attributes:@{NSFontAttributeName:loginDescription.font}
                                             context:nil];
    loginDescription.frame = CGRectMake(10,
                                         80,
                                         loginInformation.bounds.size.width - 20,
                                         textRect.size.height);
    loginDescription.lineBreakMode = NSLineBreakByWordWrapping;
    loginDescription.numberOfLines = 0;
    
    /*
     * Login Input setup
     */
    self.loginInput = [[UITextField alloc] initWithFrame:CGRectMake(10,
                                                                230,
                                          self.view.frame.size.width - 20,
                                        50)];
    self.loginInput.borderStyle = UITextBorderStyleRoundedRect;
    self.loginInput.font = [UIFont fontWithName:@"RobotoCondensed-Bold" size:15];
    self.loginInput.textColor = [UIColor colorWithRed:(66/255.0) green:(66/255.0) blue:(66/255.0) alpha:(1.0)];
    self.loginInput.placeholder = @"Enter Decoder Password";
    self.loginInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.loginInput.keyboardType = UIKeyboardTypeDefault;
    self.loginInput.returnKeyType = UIReturnKeyGo;
    self.loginInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.loginInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.loginInput.secureTextEntry = true;
    self.loginInput.keyboardAppearance = UIKeyboardAppearanceDark;
    self.loginInput.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.loginInput.delegate = self;
    self.loginInput.enabled = YES;

    [self.loginInput becomeFirstResponder];
    
    /*
     * Error Label setup
     */
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                200,
                                                                self.view.bounds.size.width,
                                                                35)];
    
    self.errorLabel.text = NSLocalizedString(@"* Decoder Password Incorrect *", @"Login Screen Title");
    self.errorLabel.textColor = [UIColor whiteColor];
    self.errorLabel.font = [UIFont fontWithName:@"Roboto-Italic" size:12];
    
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
   
    [loginInformation addSubview:loginDescription];
    [loginInformation addSubview:loginTitle];

    self.loginScrollView.contentSize = loginInformation.frame.size;
    
    [self.loginScrollView addSubview:self.loginInput];
    [self.loginScrollView addSubview:loginInformation];
    
    [self registerForKeyboardNotifications];
}



#pragma mark - TextField Delegates
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake(self.loginScrollView.frame.size.width / 2 - 25,
                                185,
                                 50,
                                 50);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [indicator startAnimating];
    
    [self.loginScrollView addSubview: indicator];

    [self.errorLabel removeFromSuperview];

    [ServiceConnect startServiceConnection:0 :textField.text andCallback:^(NSDictionary* result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id data in [[result objectForKey:@"response"] objectForKey:@"results"]) {
                if ([data objectForKey:@"date"] == (id)[NSNull null]) {
                    if (![self.loginScrollView.subviews containsObject:self.errorLabel]) {
                        [self.loginScrollView addSubview:self.errorLabel];
                    }
                    
                    [ViewFX applyIncorrectPasswordShakeTo:self.loginInput];
                    
                    [indicator stopAnimating];
                } else {
                    if ([Teams addedTeamSuccessfully:result]) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }

                    break;
                }
            }
             [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        });
    }];

    return YES;
}



- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
     NSDictionary* info = [aNotification userInfo];

     CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
     
     UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+ 50, 0.0);

     self.loginScrollView.contentInset = contentInsets;
     self.loginScrollView.scrollIndicatorInsets = contentInsets;
    
     CGRect aRect = self.view.frame;
     aRect.size.height -= kbSize.height;
     
     if (!CGRectContainsPoint(aRect, self.loginInput.frame.origin) ) {
         [self.loginScrollView scrollRectToVisible:self.loginInput.frame animated:YES];
     }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;

    self.loginScrollView.contentInset = contentInsets;
    self.loginScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
