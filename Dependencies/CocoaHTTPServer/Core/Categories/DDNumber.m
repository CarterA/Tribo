#import "DDNumber.h"

@implementation NSNumber (DDNumber)

+ (BOOL)parseString:(NSString *)string intoSInt64:(SInt64 *)integer {
	
	if (string == nil) {
		*integer = 0;
		return NO;
	}
	
	errno = 0;
	// On both 32-bit and 64-bit machines, long long = 64 bit
	*integer = strtoll([string UTF8String], NULL, 10);
	
	if (errno != 0) return NO;
	return YES;
	
}

+ (BOOL)parseString:(NSString *)string intoUInt64:(UInt64 *)integer {
	
	if (string == nil) {
		*integer = 0;
		return NO;
	}

	errno = 0;
	// On both 32-bit and 64-bit machines, unsigned long long = 64 bit
	*integer = strtoll([string UTF8String], NULL, 10);

	if(errno != 0) return NO;
	return YES;

}

+ (BOOL)parseString:(NSString *)string intoNSInteger:(NSInteger *)integer {
	
	if (string == nil) {
		*integer = 0;
		return NO;
	}
	
	errno = 0;
	// On LP64, NSInteger = long = 64 bit
	// Otherwise, NSInteger = int = long = 32 bit
	*integer = strtol([string UTF8String], NULL, 10);
	
	if(errno != 0) return NO;
	return YES;
	
}

+ (BOOL)parseString:(NSString *)string intoNSUInteger:(NSUInteger *)integer
{
	if (string == nil) {
		*integer = 0;
		return NO;
	}
	
	errno = 0;
	// On LP64, NSUInteger = unsigned long = 64 bit
	// Otherwise, NSUInteger = unsigned int = unsigned long = 32 bit
	*integer = strtoul([string UTF8String], NULL, 10);
	
	if(errno != 0) return NO;
	return YES;
	
}

@end
