#import "DDData.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (DDData)

- (NSData *)md5Digest
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([self bytes], (CC_LONG)[self length], result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)sha1Digest
{
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
	CC_SHA1([self bytes], (CC_LONG)[self length], result);
    return [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)hexStringValue
{
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	
    const unsigned char *dataBuffer = [self bytes];
    NSUInteger i;
    
    for (i = 0; i < [self length]; ++i)
	{
        [stringBuffer appendFormat:@"%02lx", (unsigned long)dataBuffer[i]];
	}
    
    return [[stringBuffer copy] autorelease];
}

- (NSString *)base64Encoded
{
	CFDataRef data = (CFDataRef)self;
	SecTransformRef encoder = SecEncodeTransformCreate(kSecBase64Encoding, NULL);
	SecTransformSetAttribute(encoder, kSecTransformInputAttributeName, data, NULL);
	CFDataRef encodedData = SecTransformExecute(encoder, NULL);
	CFStringRef encodedString = CFStringCreateFromExternalRepresentation(NULL, encodedData, kCFStringEncodingUTF8);
	CFRelease(encoder);
	CFRelease(encodedData);
	return [(NSString *)encodedString autorelease];
}

- (NSData *)base64Decoded
{
	CFDataRef data = (CFDataRef)self;
	SecTransformRef decoder = SecDecodeTransformCreate(kSecBase64Encoding, NULL);
	SecTransformSetAttribute(decoder, kSecTransformInputAttributeName, data, NULL);
	CFDataRef decodedData = SecTransformExecute(decoder, NULL);
	CFRelease(decoder);
	return [(NSData *)decodedData autorelease];
}

@end
