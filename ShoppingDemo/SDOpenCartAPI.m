#import "SDOpenCartAPI.h"

#import "NSString+UrlEncode.h"
#import "ASIHTTPRequest.h"

#import "Debug.h"
#import "SDAppDelegate.h"

#import "SDTagManSDKAPI.h"

@implementation SDOpenCartAPI

+(NSString *)documents
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

// http://clothing.tagmandemo.com/index.php?route=feed/tagman_feed&api=7fe4771c008a22eb763df47d19e2c6aa&function=products

+(BOOL)getProducts:(id<SDOpenCartAPIDelegate>)delegate
{
    BOOL result = NO;
    int  importedProductCount = 0;
    NSString *url = OPENCART_API_PRODUCTS(200);
    _NSLog(@"Invoking URL : %@",url);

    id json = [SDOpenCartAPI invokeJSONWebService:url];
    if ([json isKindOfClass:NSClassFromString(@"NSDictionary")])
    {
        _NSLog(@"Valid top level");
        NSDictionary *jsonDictionary = (NSDictionary *)json;
        id tagman = [jsonDictionary objectForKey:@"tagman"];
        if ([tagman isKindOfClass:NSClassFromString(@"NSDictionary")])
        {
            _NSLog(@"Found 'tagman' dictionary");
            NSDictionary *tagmanDictionary = (NSDictionary *)tagman;
            id channel = [tagmanDictionary objectForKey:@"channel"];
            if ([channel isKindOfClass:NSClassFromString(@"NSDictionary")])
            {
                _NSLog(@"Found 'channel' dictionary");
                NSDictionary *channelDictionary = (NSDictionary *)channel;
                id products = [channelDictionary objectForKey:@"products"];
                if ([products isKindOfClass:NSClassFromString(@"NSArray")])
                {
                    _NSLog(@"Found 'products' array");
                    NSArray *productsArray = (NSArray *)products;
                    
                    [[SDDatabaseUtils defaultInstance] cleanDatabase];
                    
                    for(id row in productsArray)
                    {
                        if ([row isKindOfClass:NSClassFromString(@"NSDictionary")])
                        {
                            NSDictionary *productRowOuter = (NSDictionary *)row;
                            NSDictionary *productRow      = (NSDictionary *)[productRowOuter objectForKey:@"product"];
                            _NSLog(@"Processing Product %@", [productRow objectForKey:@"title"]);
                            
                            Manufacturer    *manufacturer    = nil;
                            ProductCategory *productCategory = nil;
                            ProductPhoto    *productPhoto    = [[ProductPhoto alloc] init];
                            Product         *product         = [[Product alloc] init];
                            
                            // Find the ProductCategory first
                            NSString *category = [SDOpenCartAPI removeEntities:[productRow objectForKey:@"product_type"]];
                            if (category)
                            {
                                NSString *queryProductCategory = [ProductCategory selectStatementWithCriteria:[NSString stringWithFormat:@"name LIKE '%@'",category] orderBy:nil];

                                _NSLog(@"Product Category SQL : '%@'",queryProductCategory);
                                
                                NSArray  *arrayProductCategory = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryProductCategory] into:@"ProductCategory"];
                                if ([arrayProductCategory count])
                                {
                                    productCategory = (ProductCategory *)[arrayProductCategory objectAtIndex:0];
                                    _NSLog(@"Found Product Category \n%@", [productCategory xml]);
                                }
                                else
                                {
                                    productCategory = [[ProductCategory alloc] init];
                                    [productCategory setName:category];
                                    [productCategory insertRow];
                                    _NSLog(@"Created Product Category \n%@", [productCategory xml]);
                                }
                            }
                            else
                            {
                                _NSLog(@"No Product Category in Product");
                            }
                            
                            NSString *brand = [SDOpenCartAPI removeEntities:[productRow objectForKey:@"brand"]];
                            if (brand)
                            {
                                NSString *queryManufacturer = [Manufacturer selectStatementWithCriteria:[NSString stringWithFormat:@"title LIKE '%@'",brand] orderBy:nil];
                                
                                _NSLog(@"Manufacturer SQL : '%@'",queryManufacturer);
                                
                                NSArray  *arrayManufacturer = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryManufacturer] into:@"Manufacturer"];
                                if ([arrayManufacturer count])
                                {
                                    _NSLog(@"Found Manufacturer '%@'",brand);
                                    manufacturer = (Manufacturer *)[arrayManufacturer objectAtIndex:0];
                                }
                                else
                                {
                                    _NSLog(@"Creating Manufacturer '%@'",brand);
                                    manufacturer = [[Manufacturer alloc] init];
                                    [manufacturer setTitle:brand];
                                    [manufacturer insertRow];
                                }
                            }
                            else
                            {
                                _NSLog(@"No Manufacturer in Product");
                            }

                            [product setValue:[SDOpenCartAPI removeEntities:[productRow objectForKey:@"title"]]         forKey:@"title"];
                            [product setValue:[SDOpenCartAPI removeEntities:[productRow objectForKey:@"link"]]          forKey:@"url"];
                            [product setValue:[SDOpenCartAPI removeEntities:[productRow objectForKey:@"description"]]   forKey:@"details"];
                            [product setValue:[productRow objectForKey:@"id"]            forKey:@"serverUID"];
                            [product setValue:[productRow objectForKey:@"mpn"]           forKey:@"mpn"];
                            [product setValue:[productRow objectForKey:@"currency"]      forKey:@"currency"];

                            NSString *productPriceAsNSString = [productRow objectForKey:@"price"];
                            CGFloat  productPriceAsFloat = [productPriceAsNSString floatValue];
                            NSDecimalNumber *productPriceAsNSDecimalNumber = [[NSDecimalNumber alloc] initWithFloat:productPriceAsFloat];
                            [product setPrice:productPriceAsNSDecimalNumber];

                            NSString *productPriceSpecialAsNSString = [productRow objectForKey:@"price_special"];
                            CGFloat  productPriceSpecialAsFloat = [productPriceSpecialAsNSString floatValue];
                            NSDecimalNumber *productPriceSpecialAsNSDecimalNumber = [[NSDecimalNumber alloc] initWithFloat:productPriceSpecialAsFloat];
                            [product setPriceSpecial:productPriceSpecialAsNSDecimalNumber];

                            //[product setValue:[productRow objectForKey:@"quantity"]      forKey:@"quantity"];
                            [product setValue:[productRow objectForKey:@"upc"]           forKey:@"upc"];
                            [product setValue:[productRow objectForKey:@"weight"]        forKey:@"weight"];
                            [product setValue:[SDOpenCartAPI removeEntities:[productRow objectForKey:@"availability"]]  forKey:@"availability"];
                            [product setValue:[productRow objectForKey:@"sku"]           forKey:@"sku"];
                            [product setCategory:[productCategory uid]];
                            [product setManufacturer:[manufacturer uid]];
                            [product setFeatured:DBTRUE()];
                            NSNumber *promoted = ((productPriceSpecialAsFloat > 0.0f) && (productPriceSpecialAsFloat < productPriceAsFloat) ? DBTRUE() : DBFALSE() );
                            [product setPromoted:promoted];
                            [product insertRow];
                            _NSLog(@"Product created, %@",[product xml]);
                            
                            importedProductCount++;
                            
                            _NSLog(@">>>>(1) %@",[productRow objectForKey:@"image_url"]);
                            
                            NSMutableString *imageUrl = [[NSMutableString alloc] initWithString:[productRow objectForKey:@"image_url"]];
                            [imageUrl replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, imageUrl.length)];
                            [imageUrl replaceOccurrencesOfString:@"[" withString:@"%5B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, imageUrl.length)];
                            [imageUrl replaceOccurrencesOfString:@"]" withString:@"%5D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, imageUrl.length)];

                            if (imageUrl)
                            {
                                _NSLog(@">>>>(2) %@",imageUrl);
                                NSURL     *url       = [NSURL URLWithString:imageUrl];
                                _NSLog(@">>>>(3) %@",[url absoluteString]);
                                NSString  *imageFile = [imageUrl lastPathComponent];
                                _NSLog(@">>>>(4) %@",imageFile);
                                NSString  *imagePath = [[NSString alloc] initWithString: [[SDOpenCartAPI documents] stringByAppendingPathComponent:imageFile]];
                                _NSLog(@">>>>(5) %@",imagePath);
                                
                                [SDOpenCartAPI getImage:url toPath:imagePath];
                                
                                /*
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
                                {
                                    _NSLog(@"Loading product image from '%@'",imageUrl);
                                    NSData  *imageData = [NSData dataWithContentsOfURL:url];
                                    _NSLog(@"Writing product image to '%@'",imagePath);
                                    if (imageData && [imageData length])
                                        [imageData writeToFile:imagePath atomically:YES];
                                    else
                                        _NSLog(@"Warning! imageData was empty, could not write image");
                                });
                                */

                                [productPhoto setDetails:@""];
                                [productPhoto setBundle:DBFALSE()];
                                [productPhoto setHeight:DBINTEGER(200)];
                                [productPhoto setWidth:DBINTEGER(200)];
                                [productPhoto setImage:imagePath];
                                [productPhoto setProduct:product.uid];
                                [productPhoto setUrl:imageUrl];
                                [productPhoto setUseAsThumbnail:DBTRUE()];
                                [productPhoto insertRow];
                                _NSLog(@"Image created, %@",[productPhoto xml]);
                            }
                        }
                    }

                    result = YES;
                    
                    if ([delegate respondsToSelector:@selector(refreshProducts)])
                    {
                        NSObject *obj = (NSObject *)delegate;
                        [obj performSelectorOnMainThread:@selector(refreshProducts) withObject:nil waitUntilDone:NO];
                    }
                } // products
            } // channel
        } // tagman
    } // json

    _NSLog(@"Product Import Complete : %@ - Imported %d Products",(result ? @"Success" : @"Failure"),importedProductCount);
    
    return result;
}

+(void)getImage:(NSURL *)imageURL toPath:(NSString *)imagePath
{
    _NSLog(@"Loading product image from '%@'", imageURL);
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageURL];
    
    [request setCompletionBlock:^{
        _NSLog(@"Image '%@' downloaded.",[imageURL lastPathComponent]);
        NSData *data = [request responseData];
        [data writeToFile:imagePath atomically:YES];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error downloading image: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
}

// http://clothing.tagmandemo.com/index.php?route=feed/tagman_feed&api=7fe4771c008a22eb763df47d19e2c6aa&function=user&email=test@test.com&password=password

// Successful - {"tagman":{"customer":{"id":"2","firstname":"Ben","lastname":"Harris","email":"test@test.com","telephone":"00000000000","fax":"","approved":"1","date_added":"2012-10-24 18:40:12"}}}
// Failure    - {"tagman":{"error":"login failed"}}

+(NSString *)signOnWithEmailAddress:(NSString *)emailAddress password:(NSString *)password
{
    NSString *url = OPENCART_API_USER(/*[NSString stringByUrlEncodingString:*/emailAddress/*]*/,
                                      /*[NSString stringByUrlEncodingString:*/password/*]*/);
    _NSLog(@"Invoking URL : %@",url);

    id json = [SDOpenCartAPI invokeJSONWebService:url];
    
    if ([json isKindOfClass:NSClassFromString(@"NSDictionary")])
    {
        _NSLog(@"Valid top level");
        NSDictionary *jsonDictionary = (NSDictionary *)json;
        id tagman = [jsonDictionary objectForKey:@"tagman"];
        if ([tagman isKindOfClass:NSClassFromString(@"NSDictionary")])
        {
            _NSLog(@"Found 'tagman' dictionary");
            NSDictionary *tagmanDictionary = (NSDictionary *)tagman;
            
            id _error = [tagmanDictionary objectForKey:@"error"];
            if ([_error isKindOfClass:NSClassFromString(@"NSString")])
            {
                _NSLog(@"Found 'error' string - '%@'", (NSString *)_error);
                return [NSString stringWithFormat:@"Error: %@",(NSString *)_error];
            }
            else
            {
                _NSLog(@"Found 'customer' dictionary");
                id customer = [tagmanDictionary objectForKey:@"customer"];
                if ([customer isKindOfClass:NSClassFromString(@"NSDictionary")])
                {
                    NSDictionary *customerDictionary = (NSDictionary *)customer;
                    
                    id customer_id         = [customerDictionary objectForKey:@"id"];
                    id customer_firstname  = [customerDictionary objectForKey:@"firstname"];
                    id customer_lastname   = [customerDictionary objectForKey:@"lastname"];
                    id customer_email      = emailAddress;
                    // id customer_telephone  = [customerDictionary objectForKey:@"telephone"];
                    // id customer_fax        = [customerDictionary objectForKey:@"fax"];
                    id customer_approved   = [customerDictionary objectForKey:@"approved"];
                    id customer_date_added = [customerDictionary objectForKey:@"date_added"];
                    
                    // Find an ACCOUNT entity that matches this account - if none create one.
                    // Then set the ACCOUNT member of the AppDelegate to the account, regardless of found or created.
                    
                    Account *account = nil;
                    if (customer_email)
                    {
                        NSString *queryAccount = [Account selectStatementWithCriteria:[NSString stringWithFormat:@"email LIKE '%@'",(NSString *)customer_email] orderBy:nil];
                        NSArray  *arrayAccount = [[Database sharedDatabaseInstance] load:[[Database sharedDatabaseInstance] executeQuery:queryAccount] into:@"Account"];
                        if ([arrayAccount count])
                        {
                            _NSLog(@"Found Account For '%@'",(NSString *)customer_email);
                            account = (Account *)[arrayAccount objectAtIndex:0];
                        }
                        else
                        {
                            _NSLog(@"Created Account For '%@'",(NSString *)customer_email);
                            account = [[Account alloc] init];
                            
                            [account setValue:customer_id         forKey:@"serverUID"];
                            [account setValue:[SDOpenCartAPI removeEntities:customer_firstname]  forKey:@"forename"];
                            [account setValue:[SDOpenCartAPI removeEntities:customer_lastname]   forKey:@"surname"];
                            [account setValue:[SDOpenCartAPI removeEntities:customer_email]      forKey:@"emailAddress"];
                            // *** Not Used *** [account setValue:customer_telephone  forKey:@""];
                            // *** Not Used *** [account setValue:customer_fax        forKey:@""];
                            [account setValue:customer_approved   forKey:@"approved"];
                            [account setValue:customer_date_added forKey:@"dateAdded"];
                            
                            _NSLog([account xml]);
                            
                            [account insertRow];
                        }
                    }
                    else
                    {
                        _NSLog(@"No Email Address in returned Account");
                        return @"Undefined error";
                    }
                    
                    _NSLog(@"\n%@",[account xml]);

                    SDAppDelegate *appDelegate = (SDAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate setAccount:account];

                    _NSLog(@"Registering sign in with TagMan");
                    [SDTagManSDKAPI tagManSignIn:account];
                }
            }
        }
    }

    _NSLog(@"Returning success");
    return nil;
}

+(id)invokeJSONWebService:(NSString *)url
{
    NSError *error    = nil;
    NSData  *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingUncached error:&error];
    if (jsonData)
    {
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!error)
        {
            NSArray         *keys   = [jsonObjects allKeys];
            NSMutableString *buffer = [[NSMutableString alloc] init];
            for (NSString *key in keys)
            {
                [buffer appendFormat:@"... Key '%@', Value '%@'\n",key,[jsonObjects objectForKey:key]];
            }
            _NSLog(@"Result : \n%@\n",buffer);
            return jsonObjects;
        }
    }
    if (error)
        _NSLog(@"Error invoking web service : %@", [error localizedDescription]);
    return nil;
}

+(NSString *)removeEntities:(NSString *)string
{
    NSMutableString *s = [[NSMutableString alloc] initWithString:string];
    
    [s replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:NSCaseInsensitiveSearch range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:NSCaseInsensitiveSearch range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"&apos;" withString:@"'"  options:NSCaseInsensitiveSearch range:NSMakeRange(0,[s length])];
    [s replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:NSCaseInsensitiveSearch range:NSMakeRange(0,[s length])];
    
    return [NSString stringWithString:s];
}

@end
