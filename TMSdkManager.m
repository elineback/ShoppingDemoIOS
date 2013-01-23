#import "TMSdkManager.h"
#import "Debug.h"

@implementation TMSdkManager

static TMSdkManager *_sharedSdkManager = nil;

@synthesize stagingUrl = _stagingUrl;
@synthesize liveUrl    = _liveUrl;
@synthesize timeout    = _timeout;

#pragma mark - singleton support methods

+ (TMSdkManager *)sharedSdkManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_sharedSdkManager == nil)
        {
            _sharedSdkManager = [[self alloc] init];
        }
    });
    return _sharedSdkManager;
}

#pragma mark - instance methods

- (id)init
{
    if ((self = [super init]) != nil)
    {
        self.stagingUrl = TM_DEFAULT_STAGING_URL;
        self.liveUrl    = TM_DEFAULT_LIVE_URL;
        _timeout        = TM_DEFAULT_TIMEOUT;
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    return self;
}

#pragma mark - SDK methods

- (TMContainer *)setupContainerForPage:(NSInteger)pageId
                            withParams:(NSDictionary *)params
                             andClient:(NSString *)clientId
                             onStaging:(BOOL)useStagingUrl
{
    TMContainer     *container = nil;
    NSString        *templatePath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSError         *error = nil;
    NSMutableString *templateContents = [NSMutableString stringWithContentsOfFile:templatePath
                                                                         encoding:NSUTF8StringEncoding
                                                                            error:&error];

    if (!error)
    {
        [TMTemplateHelper replaceTag:TM_TEMPLATE_TAG_PAGE_ID
                          withObject:[NSNumber numberWithInteger:pageId]
                          inTemplate:templateContents];
        [TMTemplateHelper replaceTag:TM_TEMPLATE_TAG_PARAMETERS
                          withObject:params
                          inTemplate:templateContents];
        [TMTemplateHelper replaceTag:TM_TEMPLATE_TAG_CLIENT_ID
                          withObject:clientId
                          inTemplate:templateContents];
        [TMTemplateHelper replaceTag:TM_TEMPLATE_TAG_STAGING_URL
                          withObject:_stagingUrl
                          inTemplate:templateContents];
        [TMTemplateHelper replaceTag:TM_TEMPLATE_TAG_LIVE_URL
                          withObject:_liveUrl
                          inTemplate:templateContents];
        [TMTemplateHelper setCondition:@"staging"
                                 value:useStagingUrl
                            inTemplate:templateContents];
        
        _NSLog(@"[TAGMANSDK] Constructed Template : \n\n%@\n\n",templateContents);

        NSString *hash = [NSString stringHashUsingSha1:templateContents];
        NSString *path = [[[NSFileManager defaultManager].cachesPath stringByAppendingPathComponent:hash] stringByAppendingPathExtension:@"html"];

        _NSLog(@"[TAGMANSDK] Written To : %@",path);

        error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [templateContents writeToFile:path
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
        }

        if (!error)
        {
            container = [TMContainer containerWithID:hash];
        }
    }

    return container;
}

@end
