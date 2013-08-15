#import <Foundation/Foundation.h>

@interface NSNumber (DDNumber)

+ (BOOL)parseString:(NSString *)string intoSInt64:(SInt64 *)integer;
+ (BOOL)parseString:(NSString *)string intoUInt64:(UInt64 *)integer;

+ (BOOL)parseString:(NSString *)string intoNSInteger:(NSInteger *)integer;
+ (BOOL)parseString:(NSString *)string intoNSUInteger:(NSUInteger *)integer;

@end
