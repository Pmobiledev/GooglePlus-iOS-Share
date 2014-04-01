//
//  ViewController.h
//  GooglePlusDemo
//
//  Created by Pranay on 4/1/14.
//  Copyright (c) 2014 Pranay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface ViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

@end
