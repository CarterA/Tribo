#import "HTTPMessage.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HTTPMessage {
	CFHTTPMessageRef _message;
}

- (id)initEmptyRequest {
	self = [super init];
	if (self) {
		_message = CFHTTPMessageCreateEmpty(NULL, YES);
	}
	return self;
}

- (id)initRequestWithMethod:(NSString *)method URL:(NSURL *)URL version:(NSString *)version {
	self = [super init];
	if (self) {
		_message = CFHTTPMessageCreateRequest(NULL, (__bridge CFStringRef)method, (__bridge CFURLRef)URL, (__bridge CFStringRef)version);
	}
	return self;
}

- (id)initResponseWithStatusCode:(NSInteger)code description:(NSString *)description version:(NSString *)version {
	self = [super init];
	if (self) {
		_message = CFHTTPMessageCreateResponse(NULL, (CFIndex)code, (__bridge CFStringRef)description, (__bridge CFStringRef)version);
	}
	return self;
}

- (void)dealloc {
	if (_message) CFRelease(_message);
}

- (BOOL)appendData:(NSData *)data {
	return CFHTTPMessageAppendBytes(_message, [data bytes], [data length]);
}

- (BOOL)isHeaderComplete {
	return CFHTTPMessageIsHeaderComplete(_message);
}

- (NSString *)version {
	return (__bridge_transfer NSString *)CFHTTPMessageCopyVersion(_message);
}

- (NSString *)method {
	return (__bridge_transfer NSString *)CFHTTPMessageCopyRequestMethod(_message);
}

- (NSURL *)URL {
	return (__bridge_transfer NSURL *)CFHTTPMessageCopyRequestURL(_message);
}

- (NSInteger)statusCode {
	return (NSInteger)CFHTTPMessageGetResponseStatusCode(_message);
}

- (NSDictionary *)allHeaderFields {
	return (__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields(_message);
}

- (NSString *)valueForHeaderField:(NSString *)headerField {
	return (__bridge_transfer NSString *)CFHTTPMessageCopyHeaderFieldValue(_message, (__bridge CFStringRef)headerField);
}

- (void)setValue:(NSString *)value forHeaderField:(NSString *)headerField {
	CFHTTPMessageSetHeaderFieldValue(_message, (__bridge CFStringRef)headerField, (__bridge CFStringRef)value);
}

- (NSData *)messageData {
	return (__bridge_transfer NSData *)CFHTTPMessageCopySerializedMessage(_message);
}

- (NSData *)body {
	return (__bridge_transfer NSData *)CFHTTPMessageCopyBody(_message);
}

- (void)setBody:(NSData *)body {
	CFHTTPMessageSetBody(_message, (__bridge CFDataRef)body);
}

@end
