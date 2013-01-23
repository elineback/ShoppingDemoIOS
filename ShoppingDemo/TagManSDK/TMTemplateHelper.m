#import "TMTemplateHelper.h"
#import "JSONKit.h"
#import "Debug.h"

@implementation TMTemplateHelper

+ (void)replaceTag:(NSString *)tag
        withObject:(id)object
        inTemplate:(NSMutableString *)templateMarkup
{
    NSString *jsonObject;

    if ([object isKindOfClass:[NSNumber class]])
    {
        jsonObject = [object description];
    }
    else if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]])
    {
        jsonObject = [object JSONString];
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        jsonObject = [[object JSONString] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    }

    if (jsonObject != nil)
    {
        [templateMarkup replaceOccurrencesOfString:tag
                                        withString:jsonObject
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, templateMarkup.length)];
    }
}

+ (void)setCondition:(NSString *)name
               value:(BOOL)enabled
          inTemplate:(NSMutableString *)templateMarkup
{

    NSString *tag = [NSString stringWithFormat:TM_TEMPLATE_TAG_IF, name];
    NSRange rangeOfFirstIf, rangeOfEnd, rangeOfElse;

    rangeOfFirstIf = [templateMarkup rangeOfString:tag
                                           options:NSLiteralSearch];

    if (rangeOfFirstIf.location != NSNotFound)
    {
        rangeOfEnd = [templateMarkup rangeOfString:TM_TEMPLATE_TAG_IF_END options:NSLiteralSearch range:NSMakeRange(rangeOfFirstIf.location,
                templateMarkup.length - rangeOfFirstIf.location - 1)];


        BOOL ignoreElse;
        if (rangeOfFirstIf.location != NSNotFound && rangeOfEnd.location != NSNotFound)
        {
            // For now else if is not supported
            rangeOfElse = [templateMarkup rangeOfString:TM_TEMPLATE_TAG_IF_ELSE options:NSLiteralSearch range:NSMakeRange(rangeOfFirstIf.location,
                    rangeOfEnd.location - rangeOfFirstIf.location)];

            ignoreElse = ((rangeOfElse.location == NSNotFound) || (rangeOfElse.location < rangeOfFirstIf.location) || (rangeOfElse.location > rangeOfEnd.location));


            if (enabled)
            {
                if (ignoreElse)
                {
                    [templateMarkup replaceCharactersInRange:rangeOfEnd withString:@""];
                    [templateMarkup replaceCharactersInRange:rangeOfFirstIf withString:@""];
                }
                else
                {
                    [templateMarkup replaceCharactersInRange:NSMakeRange(rangeOfElse.location,  rangeOfEnd.location + rangeOfEnd.length - rangeOfElse.location)
                                                  withString:@""];
                    [templateMarkup replaceCharactersInRange:rangeOfFirstIf withString:@""];
                }
            }
            else
            {
                if (ignoreElse)
                {
                    [templateMarkup replaceCharactersInRange:NSMakeRange(rangeOfFirstIf.location, rangeOfEnd.location + rangeOfEnd.length - rangeOfFirstIf.location)
                                                  withString:@""];
                }
                else
                {
                    [templateMarkup replaceCharactersInRange:rangeOfEnd withString:@""];
                    [templateMarkup replaceCharactersInRange:NSMakeRange(rangeOfFirstIf.location, rangeOfElse.location + rangeOfElse.length - rangeOfFirstIf.location)
                                                  withString:@""];
                }
            }
        }
    }
}

@end
