/**
 * The HTTPMessage class is a simple Objective-C wrapper around Apple's CFHTTPMessage class.
**/

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif

#define HTTPVersion1_0  ((NSString *)kCFHTTPVersion1_0)
#define HTTPVersion1_1  ((NSString *)kCFHTTPVersion1_1)


@interface HTTPMessage : NSObject

- (id)initEmptyRequest;
- (id)initRequestWithMethod:(NSString *)method URL:(NSURL *)URL version:(NSString *)version;
- (id)initResponseWithStatusCode:(NSInteger)code description:(NSString *)description version:(NSString *)version;

- (BOOL)appendData:(NSData *)data;

@property (readonly, getter = isHeaderComplete) BOOL headerComplete;
@property (readonly) NSString *version;
@property (readonly) NSString *method;
@property (readonly) NSURL *URL;
@property (readonly) NSInteger statusCode;
@property (readonly) NSDictionary *allHeaderFields;
@property (readonly) NSData *messageData;
@property (nonatomic, strong) NSData *body;

- (NSString *)valueForHeaderField:(NSString *)headerField;
- (void)setValue:(NSString *)value forHeaderField:(NSString *)headerField;

@end
