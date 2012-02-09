//
//  TBSite+Scripting.m
//  Tribo
//
//  Created by Carter Allen on 2/7/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSite+Scripting.h"

@implementation TBSite (Scripting)
- (NSScriptObjectSpecifier *)objectSpecifierForPost:(TBPost *)post {
	NSScriptObjectSpecifier *postSpecifier = nil;
	NSUInteger postIndex = [self.posts indexOfObject:post];
	if (postIndex != NSNotFound) {
		NSScriptObjectSpecifier *siteSpecifier = self.objectSpecifier;
		postSpecifier = [[NSIndexSpecifier alloc] initWithContainerClassDescription:[siteSpecifier keyClassDescription] containerSpecifier:siteSpecifier key:@"posts" index:postIndex];
	}
	return postSpecifier;
}
- (NSScriptObjectSpecifier *)objectSpecifier {
	NSScriptObjectSpecifier *documentSpecifier = [[[NSDocumentController sharedDocumentController] documentForURL:self.root] objectSpecifier];
	NSPropertySpecifier *siteSpecifier = [[NSPropertySpecifier alloc] initWithContainerClassDescription:documentSpecifier.keyClassDescription containerSpecifier:documentSpecifier key:@"site"];
	return siteSpecifier;
}
@end
