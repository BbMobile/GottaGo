#import <Foundation/Foundation.h>
#import <SocketIO.h>
#import <SocketIOPacket.h>
#import "GGFloor.h"
#import "GGRoom.h"

@interface GGMenulet : NSObject <SocketIODelegate>
{
	NSStatusItem *statusItem;
	NSMenuItem *floor4MenuItem;
	NSMenuItem *floor3MenuItem;
	NSMenuItem *floor2MenuItem;
	NSMenuItem *floor1MenuItem;
	NSMutableDictionary *floors;
	SocketIO *socket;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenuItem *floor4MenuItem;
@property (strong) NSMenuItem *floor3MenuItem;
@property (strong) NSMenuItem *floor2MenuItem;
@property (strong) NSMenuItem *floor1MenuItem;
@property (strong) NSMutableDictionary *floors;
@property (strong) SocketIO *socket;

- (void)connect;
- (void)reconnect;
- (void)update;
- (void)chooseFloor4:(id)sender;
- (void)chooseFloor3:(id)sender;
- (void)chooseFloor2:(id)sender;
- (void)chooseFloor1:(id)sender;
- (NSString *)preferredFloor;
- (void)setPreferredFloor:(NSString *)floorKey;
- (void)showOffline;
- (IBAction)quit:(id)sender;

@end
