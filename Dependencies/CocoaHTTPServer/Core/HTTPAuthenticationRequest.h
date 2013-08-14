#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
  // Note: You may need to add the CFNetwork Framework to your project
  #import <CFNetwork/CFNetwork.h>
#endif

@class HTTPMessage;


@interface HTTPAuthenticationRequest : NSObject

- (id)initWithRequest:(HTTPMessage *)request;

@property (readonly, getter = isBasic) BOOL basic;
@property (readonly, getter = isDigest) BOOL digest;

// Basic
@property (readonly) NSString *base64Credentials;

// Digest
@property (readonly) NSString *username;
@property (readonly) NSString *realm;
@property (readonly) NSString *nonce;
@property (readonly) NSString *URI;
@property (readonly) NSString *qualityOfProtection;
@property (readonly) NSString *nonceCount;
@property (readonly) NSString *cnonce;
@property (readonly) NSString *response;

@end
