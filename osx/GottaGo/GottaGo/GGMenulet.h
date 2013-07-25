#import <Foundation/Foundation.h>

@interface GGMenulet : NSObject
{
	NSStatusItem *statusItem;
}

@property (strong) NSStatusItem *statusItem;

- (IBAction)quit:(id)sender;

@end
