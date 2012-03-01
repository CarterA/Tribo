//
//  TBPublisher.m
//  Tribo
//
//  Created by Carter Allen on 2/28/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBPublisher.h"
#import "TBSite.h"

@interface TBPublisher ()

@end

@implementation TBPublisher
@synthesize site = _site;
@synthesize protocol = _protocol;
@synthesize progressHandler = _progressHandler;
@synthesize completionHandler = _completionHandler;
@synthesize errorHandler = _errorHandler;

- (id)initWithSite:(TBSite *)site {
	self = [super init];
	if (self) {
		self.site = site;
	}
	return self;
}

- (void)publish {
	
	[self.site process:nil];
	
	NSTask *rsync = [[NSTask alloc] init];
	NSURL *bundledRsyncURL = [[NSBundle mainBundle] URLForResource:@"rsync" withExtension:@""];
	rsync.launchPath = bundledRsyncURL.path;
	
	NSPipe *outputPipe = [NSPipe pipe];
	rsync.standardOutput = outputPipe;
	NSPipe *errorPipe = [NSPipe pipe];
	rsync.standardError = errorPipe;
	NSPipe *nullFileHandle = [NSFileHandle fileHandleWithNullDevice];
	rsync.standardInput = nullFileHandle;
		
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObject:@"--recursive"];
	[arguments addObject:@"--times"];
	[arguments addObject:@"--compress"];
	[arguments addObject:@"--info=progress2"];
	[arguments addObject:[self.site.destination.path stringByAppendingString:@"/"]];
	[arguments addObject:@"carterallen@zcr.me:~/sites/cartera.me/public/test"];
	rsync.arguments = arguments;
	
	NSMutableDictionary *environment = [NSMutableDictionary dictionary];
	NSURL *authenticationToolURL = [[NSBundle mainBundle] URLForResource:@"Tribo Authentication Tool" withExtension:@""];
	[environment setObject:authenticationToolURL.path forKey:@"SSH_ASKPASS"];
	[environment setObject:@"NONE" forKey:@"DISPLAY"];
	[environment setObject:@"" forKey:@"SSH_AUTH_SOCK"];
	[environment setObject:@"/Users/carterallen" forKey:@"HOME"];
	[environment setObject:@"/usr/bin/ssh -i /Users/carterallen/.ssh/id_rsa -F /dev/null" forKey:@"RSYNC_RSH"];
	[environment setObject:@"/Users/carterallen/.ssh/id_rsa" forKey:@"TB_IDENTITY_PATH"];
	rsync.environment = environment;
	
	NSFileHandle *outputFileHandle = [rsync.standardOutput fileHandleForReading];
	__block NSString *lastNewLine = @"";
	__block NSInteger lastPercentage = 0;
	NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	[outputFileHandle setReadabilityHandler:^(NSFileHandle *fileHandle) {
		
		NSString *availableOutput = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSASCIIStringEncoding];
		NSString *lastLine = [[availableOutput componentsSeparatedByCharactersInSet:newlineCharacterSet] lastObject];
		if (![lastLine isEqualToString:lastNewLine]) {
			NSArray *components = [lastLine componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
			for (NSString *component in components) {
				if (![component hasSuffix:@"%"]) continue;
				NSInteger integerValue = [component integerValue];
				if (integerValue == lastPercentage) return;
				if (self.progressHandler) self.progressHandler(integerValue, 100);
				lastPercentage = integerValue;
			}
		}
		
	}];
	
	NSFileHandle *errorFileHandle = [rsync.standardError fileHandleForReading];
	[errorFileHandle setReadabilityHandler:^(NSFileHandle *fileHandle) {
		
		NSString *availableOutput = [[NSString alloc] initWithData:fileHandle.availableData encoding:NSASCIIStringEncoding];
		NSLog(@"stderr: %@", availableOutput);
		
	}];
	
	[rsync setTerminationHandler:^(NSTask *task) {
		if (self.completionHandler) self.completionHandler();
	}];
	
	[rsync launch];
	
}

@end
