//
//  SHKItem.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/18/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKItem.h"
#import "SHK.h"
#import "SHKConfiguration.h"


@interface SHKItem()

@property (nonatomic, retain) NSMutableDictionary *custom;

- (NSString *)shareTypeToString:(SHKShareType)shareType;
- (void)setExtensionPropertiesDefaultValues;

@end


@implementation SHKItem

@synthesize shareType;
@synthesize URL, URLContentType, image, title, text, tags, data, mimeType, filename;
@synthesize custom;
@synthesize printOutputType;
@synthesize mailBody, mailJPGQuality, mailToRecipients, isMailHTML, mailShareWithAppSignature;
@synthesize facebookURLSharePictureURI, facebookURLShareDescription;

- (void)dealloc
{
	[URL release];
	
	[image release];
	
	[title release];
	[text release];
	[tags release];
	
	[data release];
	[mimeType release];
	[filename release];
	
	[custom release];
    
    [mailBody release];
    [mailToRecipients release];
    [facebookURLSharePictureURI release];
    [facebookURLShareDescription release];
	
	[super dealloc];
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self setExtensionPropertiesDefaultValues];
    }
    return self;
}

- (void)setExtensionPropertiesDefaultValues {
    
    printOutputType = [SHKCONFIG(printOutputType) intValue];
    
    mailBody = [SHKCONFIG(mailBody) retain];
    mailToRecipients = [SHKCONFIG(mailToRecipients) retain];
    mailJPGQuality = [SHKCONFIG(mailJPGQuality) floatValue];
    isMailHTML = [SHKCONFIG(isMailHTML) boolValue];
    mailShareWithAppSignature = [SHKCONFIG(sharedWithSignature) boolValue];
    
    facebookURLShareDescription = [SHKCONFIG(facebookURLShareDescription) retain];
    facebookURLSharePictureURI = [SHKCONFIG(facebookURLSharePictureURI) retain];
}

+ (id)URL:(NSURL *)url
{
	return [self URL:url title:nil contentType:SHKURLContentTypeWebpage];
}

+ (id)URL:(NSURL *)url title:(NSString *)title
{
	return [self URL:url title:title contentType:SHKURLContentTypeWebpage];
}

+ (id)URL:(NSURL *)url title:(NSString *)title contentType:(SHKURLContentType)type {
    
    SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeURL;
	item.URL = url;
	item.title = title;
    item.URLContentType = type;
	
	return [item autorelease];
    
}

+ (id)image:(UIImage *)image
{
	return [SHKItem image:image title:nil];
}

+ (id)image:(UIImage *)image title:(NSString *)title
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeImage;
	item.image = image;
	item.title = title;
	
	return [item autorelease];
}

+ (id)text:(NSString *)text
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeText;
	item.text = text;
	
	return [item autorelease];
}

+ (id)file:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType title:(NSString *)title
{
	SHKItem *item = [[self alloc] init];
	item.shareType = SHKShareTypeFile;
	item.data = data;
	item.filename = filename;
	item.mimeType = mimeType;
	item.title = title;
	
	return [item autorelease];
}

#pragma mark -

- (void)setCustomValue:(NSString *)value forKey:(NSString *)key
{
	if (custom == nil)
		self.custom = [NSMutableDictionary dictionaryWithCapacity:0];
	
	if (value == nil)
		[custom removeObjectForKey:key];
		
	else
		[custom setObject:value forKey:key];
}

- (NSString *)customValueForKey:(NSString *)key
{
	return [custom objectForKey:key];
}

- (BOOL)customBoolForSwitchKey:(NSString *)key
{
	return [[custom objectForKey:key] isEqualToString:SHKFormFieldSwitchOn];
}


#pragma mark -

+ (id)itemFromDictionary:(NSDictionary *)dictionary
{
	SHKItem *item = [[self alloc] init];
	item.shareType = [[dictionary objectForKey:@"shareType"] intValue];	

	item.URLContentType = [[dictionary objectForKey:@"URLContentType"] intValue];
	
	if ([dictionary objectForKey:@"URL"] != nil)
		item.URL = [NSURL URLWithString:[dictionary objectForKey:@"URL"]];
	
	item.title = [dictionary objectForKey:@"title"];
	item.text = [dictionary objectForKey:@"text"];
	item.tags = [dictionary objectForKey:@"tags"];	
	
	if ([dictionary objectForKey:@"custom"] != nil)
		item.custom = [[[dictionary objectForKey:@"custom"] mutableCopy] autorelease];
	
	if ([dictionary objectForKey:@"mimeType"] != nil)
		item.mimeType = [dictionary objectForKey:@"mimeType"];

	if ([dictionary objectForKey:@"filename"] != nil)
		item.filename = [dictionary objectForKey:@"filename"];

	if ([dictionary objectForKey:@"image"] != nil)
		item.image = [UIImage imageWithData:[dictionary objectForKey:@"image"]];
    
    item.printOutputType = [[dictionary objectForKey:@"printOutputType"] intValue];
    item.mailBody = [dictionary objectForKey:@"mailBody"];
    item.isMailHTML = [[dictionary objectForKey:@"isMailHTML"] boolValue];
    item.mailToRecipients = [dictionary objectForKey:@"mailToRecipients"];
    item.mailJPGQuality = [[dictionary objectForKey:@"mailJPGQuality"] floatValue];
    item.mailShareWithAppSignature = [[dictionary objectForKey:@"mailShareWithAppSignature"] boolValue];
    item.facebookURLShareDescription = [dictionary objectForKey:@"facebookURLShareDescription"];
    item.facebookURLSharePictureURI = [dictionary objectForKey:@"facebookURLSharePictureURI"];

	return [item autorelease];
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
		
	[dictionary setObject:[NSNumber numberWithInt:shareType] forKey:@"shareType"];
    [dictionary setObject:[NSNumber numberWithInt:URLContentType] forKey:@"URLContentType"];
	
	if (custom != nil)
		[dictionary setObject:custom forKey:@"custom"];
	
	if (URL != nil)
		[dictionary setObject:[URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"URL"];
	 
	 if (title != nil)
		[dictionary setObject:title forKey:@"title"];
	 
	 if (text != nil)		 
		 [dictionary setObject:text forKey:@"text"];
	
	if (tags != nil)
		[dictionary setObject:tags forKey:@"tags"];
	
	if (mimeType != nil)
		[dictionary setObject:mimeType forKey:@"mimeType"];
	
	if (filename != nil)
		[dictionary setObject:filename forKey:@"filename"];
	
	if (data != nil)
		[dictionary setObject:data forKey:@"data"];
	
	if (image != nil)
		[dictionary setObject:UIImagePNGRepresentation(image) forKey:@"image"];
    
    [dictionary setObject:[NSNumber numberWithInt:printOutputType] forKey:@"printOutputType"];
    
    if (mailBody) {
        [dictionary setObject:mailBody forKey:@"mailBody"];
    }
    
    [dictionary setObject:[NSNumber numberWithBool:isMailHTML] forKey:@"isMailHTML"];
    
    if (mailToRecipients) {
        [dictionary setObject:mailToRecipients forKey:@"mailToRecipients"];
    }
    
    [dictionary setObject:[NSNumber numberWithFloat:mailJPGQuality] forKey:@"mailJPGQuality"];
    
    [dictionary setObject:[NSNumber numberWithBool:mailShareWithAppSignature] forKey:@"mailShareWithAppSignature"];
    
    if (facebookURLSharePictureURI) {
        [dictionary setObject:facebookURLSharePictureURI forKey:@"facebookURLSharePictureURI"];
    }
    
    if (facebookURLShareDescription) {
        [dictionary setObject:facebookURLShareDescription forKey:@"facebookURLShareDescription"];
    }    
	
	// If you add anymore, make sure to add a method for retrieving them to the itemWithDictionary function too
	
	return dictionary;
}

- (NSString *)description {
    
    NSString *result = [NSString stringWithFormat:@"Share type: %@\nURL:%@\nURLContentType: %i\nImage:%@\nTitle: %@\nText: %@\nTags:%@\nCustom fields:%@\n\nSharer specific\n\nPrint output type: %i\nmailBody: %@\nisMailHTML: %i\nmailToRecipients: %@\nmailJPGQuality: %f\nmailShareWithAppSignature: %i\nfacebookURLSharePictureURI: %@\nfacebookURLShareDescription: %@", 
                        [self shareTypeToString:self.shareType],
                        [self.URL absoluteString],
                        self.URLContentType,
                        [self.image description], 
                        self.title, self.text, 
                        self.tags, 
                        [self.custom description],
                        self.printOutputType,
                        self.mailBody,
                        self.isMailHTML,
                        [self.mailToRecipients description],
                        self.mailJPGQuality,
                        self.mailShareWithAppSignature,
                        self.facebookURLSharePictureURI,
                        self.facebookURLShareDescription];
    
    return result;
}

- (NSString *)shareTypeToString:(SHKShareType)type {
    
    NSString *result = nil;
    
    switch(type) {
            
        case SHKShareTypeUndefined:
            result = @"SHKShareTypeUndefined";
            break;
        case SHKShareTypeURL:
            result = @"SHKShareTypeURL";
            break;
        case SHKShareTypeText:
            result = @"SHKShareTypeText";
            break;
        case SHKShareTypeImage:
            result = @"SHKShareTypeImage";
            break;
        case SHKShareTypeFile:
            result = @"SHKShareTypeFile";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }
    
    return result;
}

@end
