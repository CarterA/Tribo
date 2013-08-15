#import "HTTPAuthenticationRequest.h"
#import "HTTPMessage.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation HTTPAuthenticationRequest

- (id)initWithRequest:(HTTPMessage *)request {
	self = [super init];
	if (self) {
		
		NSString *authInfo = [request valueForHeaderField:@"Authorization"];
		
		_basic = NO;
		if ([authInfo length] >= 6)
			_basic = ([[authInfo substringToIndex:6] caseInsensitiveCompare:@"Basic "] == NSOrderedSame);
		
		_digest = NO;
		if ([authInfo length] >= 7)
			_digest = ([[authInfo substringToIndex:7] caseInsensitiveCompare:@"Digest "] == NSOrderedSame);
		
		if (_basic)
			_base64Credentials = [[authInfo substringFromIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (_digest) {
			_username = [self quotedSubHeaderFieldValue:@"username" fromHeaderFieldValue:authInfo];
			_realm    = [self quotedSubHeaderFieldValue:@"realm" fromHeaderFieldValue:authInfo];
			_nonce    = [self quotedSubHeaderFieldValue:@"nonce" fromHeaderFieldValue:authInfo];
			_URI      = [self quotedSubHeaderFieldValue:@"uri" fromHeaderFieldValue:authInfo];
			
			// It appears from RFC 2617 that the qop is to be given unquoted
			// Tests show that Firefox performs this way, but Safari does not
			// Thus we'll attempt to retrieve the value as nonquoted, but we'll verify it doesn't start with a quote
			_qualityOfProtection = [self nonquotedSubHeaderFieldValue:@"qop" fromHeaderFieldValue:authInfo];
			if (_qualityOfProtection && ([_qualityOfProtection characterAtIndex:0] == '"'))
				_qualityOfProtection = [self quotedSubHeaderFieldValue:@"qop" fromHeaderFieldValue:authInfo];
			
			_nonceCount = [self nonquotedSubHeaderFieldValue:@"nc" fromHeaderFieldValue:authInfo];
			_cnonce		= [self quotedSubHeaderFieldValue:@"cnonce" fromHeaderFieldValue:authInfo];
			_response	= [self quotedSubHeaderFieldValue:@"response" fromHeaderFieldValue:authInfo];
		}
	}
	return self;
}

/*!
 Retrieves a "Sub Header Field Value" from a given header field value.
 The sub header field is expected to be quoted.
 
 In the following header field:
 Authorization: Digest username="Mufasa", qop=auth, response="6629fae4939"
 The sub header field titled 'username' is quoted, and this method would return the value @"Mufasa".
 */
- (NSString *)quotedSubHeaderFieldValue:(NSString *)param fromHeaderFieldValue:(NSString *)header {
	
	NSRange startRange = [header rangeOfString:[NSString stringWithFormat:@"%@=\"", param]];
	if (startRange.location == NSNotFound)
		return nil;
	
	NSUInteger postStartRangeLocation = startRange.location + startRange.length;
	NSUInteger postStartRangeLength = [header length] - postStartRangeLocation;
	NSRange postStartRange = NSMakeRange(postStartRangeLocation, postStartRangeLength);
	
	NSRange endRange = [header rangeOfString:@"\"" options:0 range:postStartRange];
	if (endRange.location == NSNotFound)
		return nil;
	
	NSRange subHeaderRange = NSMakeRange(postStartRangeLocation, endRange.location - postStartRangeLocation);
	return [header substringWithRange:subHeaderRange];
	
}

/*!
 Retrieves a "Sub Header Field Value" from a given header field value.
 The sub header field is expected to not be quoted.

 In the following header field:
 Authorization: Digest username="Mufasa", qop=auth, response="6629fae4939"
 The sub header field titled 'qop' is nonquoted, and this method would return the value @"auth".
 */
- (NSString *)nonquotedSubHeaderFieldValue:(NSString *)param fromHeaderFieldValue:(NSString *)header {
	
	NSRange startRange = [header rangeOfString:[NSString stringWithFormat:@"%@=", param]];
	if(startRange.location == NSNotFound)
		return nil;
	
	NSUInteger postStartRangeLocation = startRange.location + startRange.length;
	NSUInteger postStartRangeLength = [header length] - postStartRangeLocation;
	NSRange postStartRange = NSMakeRange(postStartRangeLocation, postStartRangeLength);
	
	NSRange endRange = [header rangeOfString:@"," options:0 range:postStartRange];
	if (endRange.location == NSNotFound) {
		// The ending comma was not found anywhere in the header
		// However, if the nonquoted param is at the end of the string, there would be no comma
		// This is only possible if there are no spaces anywhere
		NSRange endRange2 = [header rangeOfString:@" " options:0 range:postStartRange];
		if(endRange2.location != NSNotFound)
			return nil;
		else
			return [header substringWithRange:postStartRange];
	}
	else {
		NSRange subHeaderRange = NSMakeRange(postStartRangeLocation, endRange.location - postStartRangeLocation);
		return [header substringWithRange:subHeaderRange];
	}
	
}

@end
