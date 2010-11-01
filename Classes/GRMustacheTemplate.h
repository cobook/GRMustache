//
//  GRMustacheTemplate.h
//

#import <Foundation/Foundation.h>
#import "GRMustacheElement.h"


@class GRMustacheTemplateLoader;

@interface GRMustacheTemplate: GRMustacheElement {
	GRMustacheTemplateLoader *templateLoader;
	NSURL *url;
	NSString *templateString;
	NSString *otag;
	NSString *ctag;
	NSInteger p;
	NSInteger curline;
	NSMutableArray *elems;
}


// Renders object with the template contained in the templateString argument.
// Partials would be looked from current working directory.
+ (NSString *)renderObject:(id)object
				fromString:(NSString *)templateString
					 error:(NSError **)outError;

// Renders object with the template loaded from url, whose content must be encoded in UTF8.
// Partials would be looked relatively to url.
+ (NSString *)renderObject:(id)object
		 fromContentsOfURL:(NSURL *)url
					 error:(NSError **)outError;

// Renders object with the template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (NSString *)renderObject:(id)object
			  fromResource:(NSString *)name
					bundle:(NSBundle *)bundle
					 error:(NSError **)outError;

// Renders object with the template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (NSString *)renderObject:(id)object
			  fromResource:(NSString *)name
			 withExtension:(NSString *)ext
					bundle:(NSBundle *)bundle
					 error:(NSError **)outError;

// Returns a template with the templateString argument.
// Partials would be looked from current working directory.
+ (id)parseString:(NSString *)templateString
			error:(NSError **)outError;

// Returns a template loaded from url, whose content must be encoded in UTF8.
// Partials would be looked relatively to url.
+ (id)parseContentsOfURL:(NSURL *)url
				   error:(NSError **)outError;

// Returns a template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (id)parseResource:(NSString *)name
			 bundle:(NSBundle *)bundle
			  error:(NSError **)outError;

// Returns a template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (id)parseResource:(NSString *)name
	  withExtension:(NSString *)ext
			 bundle:(NSBundle *)bundle
			  error:(NSError **)outError;


// Renders.
- (NSString *)renderObject:(id)object;

@end
