////////////////////////////////////////////////////////////////////////////////
//
//  Created by William Shakour on 12/07/2012.
//  Modified by Andy Brick on 22/11/2012.
//  Copyright (c) 2012 Mobile Impossible - http://mobileimpossible.com/.
//  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

#define TM_DEFAULT_TIMEOUT 10.0

@class TMContainer;
@protocol TMContainerDelegate <NSObject>
@optional
    -(void) didCompleteRunForContainer:(TMContainer *)container;
    -(void) didAbortBecauseOfTimeout:(TMContainer *)container;
@end

@interface TMContainer : NSObject <UIWebViewDelegate>
{
    id<TMContainerDelegate> _delegate;
    UIWebView              *_webView;
    NSURL                  *_url;
    NSTimeInterval          _timeOut;
    NSTimer                *_timer;
    BOOL                    _timedOut;
    BOOL                    _finished;
}

@property (strong,nonatomic) id<TMContainerDelegate> delegate;
@property (strong,nonatomic) UIWebView              *webView;
@property (strong,nonatomic) NSURL                  *url;
@property (assign,nonatomic) NSTimeInterval          timeOut;
@property (strong,nonatomic) NSTimer                *timer;
@property (assign,nonatomic) BOOL                    timedOut;
@property (assign,nonatomic) BOOL                    finished;

+ (TMContainer *)containerWithID:(NSString *)identifier;
- (TMContainer *)initWithID:(NSString *)identifier;
- (void)run;
- (void)showCookies;
- (void)processTimeOut:(NSTimer *)theTimer;

@end
