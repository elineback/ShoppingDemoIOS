#import "TMContainer.h"

#import "NSFileManager+PathHelper.h"
#import "Debug.h"

#define TM_CONTAINER_RUN_COMPLETE_URL @"http://tagmancomplete/"

@implementation TMContainer

@synthesize delegate  = _delegate;
@synthesize webView   = _webView;
@synthesize url       = _url;
@synthesize timeOut   = _timeOut;
@synthesize timer     = _timer;
@synthesize timedOut  = _timedOut;
@synthesize finished  = _finished;

+ (TMContainer *)containerWithID:(NSString *)identifier
{
    _NSLog(@"[TAGMANSDK] Creating Container With Identifier : %@",identifier);
    return [[TMContainer alloc] initWithID:identifier];
}

- (TMContainer *)initWithID:(NSString *)identifier
{
    if ((self = [super init]) != nil)
    {
        _webView          = [[UIWebView alloc] initWithFrame:CGRectMake(-1, -1, 1, 1)];
        _webView.delegate = self;
        
        NSString *path    = [[[NSFileManager defaultManager].cachesPath stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"html"];
        _url              = [NSURL fileURLWithPath:path];
        
        _timeOut          = TM_DEFAULT_TIMEOUT;
        
        _NSLog(@"[TAGMANSDK] Created Container With Identifier : %@",identifier);
    }
    return self;
}

- (void)run
{
    if (_timer == nil || _timeOut)
    {
        _NSLog(@"[TAGMANSDK] Container running ...");
        
        _timedOut = NO;
        _finished = NO;
        
        NSURLRequest *requestUrl = [NSURLRequest requestWithURL:_url];
        [_webView loadRequest:requestUrl];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeOut
                                                  target:self
                                                selector:@selector(processTimeOut:)
                                                userInfo:_webView
                                                 repeats:NO];
    }
    else
        _NSLog(@"[TAGMANSDK] *** CONTAINER FAILED TO RUN ***");
}

#pragma mark - WebView delegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _NSLog(@"[TAGMANSDK] *** FAILED ***");
    _ERROR(error);
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        
    if ([requestString hasPrefix:@"ios-log:"])
    {
        NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
        NSLog(@"UIWebView console: %@", logString);
        return NO;
    }
    
    if ([TM_CONTAINER_RUN_COMPLETE_URL isEqualToString:[request.URL absoluteString]])
    {
        _finished = YES;
        _timedOut = NO;
        
        [_timer invalidate];
        _timer = nil;
        
        if ([_delegate respondsToSelector:@selector(didCompleteRunForContainer:)])
        {
            _NSLog(@"[TAGMANSDK] COMPLETED REQUEST");
            [_delegate didCompleteRunForContainer:self];
        }
        
        return NO;
    }
    
    return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView
{
    _NSLog(@"[TAGMANSDK] UIWebView STARTING");
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    _NSLog(@"[TAGMANSDK] UIWebView FINISHED");
    
    NSURL *requestURL = [[_webView request] URL];
    NSError *error;
    NSString *page = [NSString stringWithContentsOfURL:requestURL
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    _NSLog(@"page %@", page);
    
    
    NSString *renderedHtml = [_webView stringByEvaluatingJavaScriptFromString:@"document.all[0].innerHTML"];
    _NSLog(@"renderedHtml %@", renderedHtml);
    
    // Now we dump all cookies returned in web view
    [self showCookies];
}

#pragma mark - Dump Cookies to debug log

-(void) showCookies
{
    NSDateFormatter *cookieDateFormatter = [[NSDateFormatter alloc] init];
    [cookieDateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    _NSLog(@"[TAGMANSDK] COOKIES START");
    for (NSHTTPCookie *cookie in cookies)
    {
        _NSLog(@"[TAGMANSDK] Cookie [Comment '%@' CommentURL '%@' Domain '%@' Expires '%@' Secure? '%@' Session? '%@' Path '%@' Value '%@' Version %d]",
               [cookie comment],
               [[cookie commentURL] absoluteString],
               [cookie domain],
               [cookieDateFormatter stringFromDate:[cookie expiresDate]],
               ([cookie isSecure]      ? @"Yes" : @"No"),
               ([cookie isSessionOnly] ? @"Yes" : @"No"),
               [cookie path],
               [cookie value],
               [cookie version]
               );
    }
    _NSLog(@"[TAGMANSDK] COOKIES END");
}

#pragma mark - NSTimer callback

- (void)processTimeOut:(NSTimer *)theTimer
{
    _NSLog(@"[TAGMANSDK] Timed Out Event invoked, checking if request is still active");
    if (!_finished)
    {
        NSString *renderedHtml = [_webView stringByEvaluatingJavaScriptFromString:@"document.all[0].innerHTML"];
        _NSLog(@"renderedHtml %@", renderedHtml);
        
        _NSLog(@"[TAGMANSDK] *** TIMED OUT ***");
        [_webView stopLoading];
        _timedOut = YES;
        
        if (theTimer == _timer)
        {
            _timer = nil;
        }
        
        if ([_delegate respondsToSelector:@selector(didAbortBecauseOfTimeout:)])
        {
            [_delegate didAbortBecauseOfTimeout:self];
        }
    }
}

@end
