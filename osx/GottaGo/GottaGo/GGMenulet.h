#import <Foundation/Foundation.h>
#import <SocketIO.h>
#import <SocketIOPacket.h>
#import "GGFloor.h"
#import "GGRoom.h"

@interface GGMenulet : NSObject <SocketIODelegate>
{
	NSStatusItem *statusItem;
	NSMutableDictionary *floors;
	SocketIO *socket;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) NSMutableDictionary *floors;
@property (strong) SocketIO *socket;

- (void)connect;
- (void)reconnect;
- (void)update;
- (void)showOffline;
- (IBAction)quit:(id)sender;

@end
