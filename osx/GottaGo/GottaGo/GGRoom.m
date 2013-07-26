#import "GGRoom.h"

@implementation GGRoom

@synthesize isOccupied = _isOccupied;

- (NSString *)description
{
	return [NSString stringWithFormat:@"<GGRoom which is%@ occupied>", (self.isOccupied) ? @"" : @" not"];
}

@end
