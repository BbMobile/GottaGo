#import "GGFloor.h"

@implementation GGFloor

@synthesize rooms = _rooms;

- (void)addRoom:(GGRoom *)room forIdentifier:(NSString *)identifier
{
	if (!self.rooms)
	{
		self.rooms = [NSMutableDictionary dictionary];
	}
	[self.rooms setValue:room forKey:identifier];
}

- (GGRoom *)roomForIdentifier:(NSString *)identifier
{
	return [self.rooms valueForKey:identifier];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<GGFloor with %ld rooms>", [self.rooms count]];
}

@end
