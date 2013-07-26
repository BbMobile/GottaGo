#import <Foundation/Foundation.h>
#import <SRWebSocket.h>

@interface GGMenulet : NSObject <SRWebSocketDelegate>
{
	NSStatusItem *statusItem;
	SRWebSocket *webSocket;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) SRWebSocket *webSocket;

- (IBAction)quit:(id)sender;

@end
