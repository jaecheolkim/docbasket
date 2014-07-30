

#import "NSDictionary-merge.h"

@implementation NSDictionary (merge)

- (NSMutableDictionary*)mergeMutableCopyWithDictionary:(NSDictionary*)dict
{
	NSMutableDictionary* mergedDict = [self mutableCopy];
	
	[mergedDict mergeWithDictionary:dict];
	
	return mergedDict;
}

@end