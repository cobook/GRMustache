// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheVariableElement_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheVariableElement()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
@property (nonatomic) BOOL raw;
- (id)initWithInvocation:(GRMustacheInvocation *)invocation raw:(BOOL)raw;
- (NSString *)htmlEscape:(NSString *)string;
@end


@implementation GRMustacheVariableElement
@synthesize invocation=_invocation;
@synthesize raw=_raw;

+ (id)variableElementWithInvocation:(GRMustacheInvocation *)invocation raw:(BOOL)raw
{
    return [[[self alloc] initWithInvocation:invocation raw:raw] autorelease];
}

- (void)dealloc
{
    [_invocation release];
    [super dealloc];
}


#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderContext:(GRMustacheContext *)context forTemplate:(GRMustacheTemplate *)rootTemplate delegates:(NSArray *)delegates
{
    // invoke
    
    [_invocation invokeWithContext:context];
    
    for (id<GRMustacheTemplateDelegate> delegate in delegates) {
        if ([delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
            // 4.1 API
            [delegate template:rootTemplate willInterpretReturnValueOfInvocation:_invocation as:GRMustacheInterpretationVariable];
        } else if ([delegate respondsToSelector:@selector(template:willRenderReturnValueOfInvocation:)]) {
            // 4.0 API
            [delegate template:rootTemplate willRenderReturnValueOfInvocation:_invocation];
        }
    }
    
    id value = _invocation.returnValue;
    
    
    // interpret
    
    NSString *result = nil;
    if (value && (value != [NSNull null])) {
        result = [value description];
        if (!_raw) {
            result = [self htmlEscape:result];
        }
    }
    
    
    // finish
    
    for (id<GRMustacheTemplateDelegate> delegate in delegates) {
        if ([delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
            // 4.1 API
            [delegate template:rootTemplate didInterpretReturnValueOfInvocation:_invocation as:GRMustacheInterpretationVariable];
        } else if ([delegate respondsToSelector:@selector(template:didRenderReturnValueOfInvocation:)]) {
            // 4.0 API
            [delegate template:rootTemplate didRenderReturnValueOfInvocation:_invocation];
        }
    }
    
    if (!result) {
        return @"";
    }
    return result;
}


#pragma mark Private

- (id)initWithInvocation:(GRMustacheInvocation *)invocation raw:(BOOL)raw
{
    self = [self init];
    if (self) {
        self.invocation = invocation;
        self.raw = raw;
    }
    return self;
}

- (NSString *)htmlEscape:(NSString *)string
{
    NSUInteger length = string.length;
    
    // get a buffer of characters in string
    const unichar *buffer = CFStringGetCharactersPtr((CFStringRef)string);
	if (!buffer) {
		NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
		[string getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
		buffer = [data bytes];
	}
    
    // this string will get filled as we consume buffer's characters
	NSMutableString *resultString = [NSMutableString stringWithCapacity:length];
    
    // The accumulator buffer gathers characters until next character that needs escaping.
    // Its length can not be higher than input string's length.
    NSMutableData *accumulatorData = [NSMutableData dataWithCapacity:sizeof(unichar) * length];
    unichar *accumulatorBuffer = (unichar *)[accumulatorData mutableBytes];
    NSUInteger accumulatorBufferLength = 0;
    
#define APPEND_ACCUMULATOR_TO_RESULT_STRING \
    if (accumulatorBufferLength) { \
        CFStringAppendCharacters((CFMutableStringRef)resultString, accumulatorBuffer, accumulatorBufferLength); \
        accumulatorBufferLength = 0; \
    }
    
    for (NSUInteger i=0; i<length; ++i) {
        UniChar c = buffer[i];
        switch (c) {
            case '&':
                APPEND_ACCUMULATOR_TO_RESULT_STRING
                [resultString appendString:@"&amp;"];
                break;
            
            case '<':
                APPEND_ACCUMULATOR_TO_RESULT_STRING
                [resultString appendString:@"&lt;"];
                break;
                
            case '>':
                APPEND_ACCUMULATOR_TO_RESULT_STRING
                [resultString appendString:@"&gt;"];
                break;
                
            case '"':
                APPEND_ACCUMULATOR_TO_RESULT_STRING
                [resultString appendString:@"&quot;"];
                break;
                
            case '\'':
                APPEND_ACCUMULATOR_TO_RESULT_STRING
                [resultString appendString:@"&apos;"];
                break;
                
            default:
                // append character to accumulator
                accumulatorBuffer[accumulatorBufferLength] = c;
                ++accumulatorBufferLength;
                break;
        }
    }
    
    // consume accumulator
	APPEND_ACCUMULATOR_TO_RESULT_STRING
    
#undef APPEND_ACCUMULATOR_TO_RESULT_STRING
    
    // done
    return resultString;
}

@end
