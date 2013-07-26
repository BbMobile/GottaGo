#import <Foundation/Foundation.h>
#import "GGRoom.h"

@interface GGFloor : NSObject
{
	NSMutableDictionary *rooms;
}

@property (strong) NSMutableDictionary *rooms;

- (void)addRoom:(GGRoom *)room forIdentifier:(NSString *)identifier;
- (GGRoom *)roomForIdentifier:(NSString *)identifier;

@end
