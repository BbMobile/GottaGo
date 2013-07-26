#import "GGMenulet.h"

@implementation GGMenulet

@synthesize statusItem = _statusItem;
@synthesize webSocket = _webSocket;

- (void)awakeFromNib
{
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setEnabled:YES];
	[self.statusItem setHighlightMode:YES];
	//[self.statusItem setTitle:@"Vacant Vacant"];
	[self.statusItem setTarget:self];
	
	// Set icon
	NSImage *menuIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuIcon" ofType:@"png"]];
	[self.statusItem setImage:menuIcon];
	
	// Set menu
	NSMenu *menu = [[NSMenu alloc] init];
	[menu setAutoenablesItems:NO];
	
	NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"GottaGo" action:nil keyEquivalent:@""];
	[menuItem setTarget:self];
	[menuItem setEnabled:NO];
	[menu insertItem:menuItem atIndex:0];
	
	NSMenuItem *separatorMenuItem = [NSMenuItem separatorItem];
	[menu insertItem:separatorMenuItem atIndex:1];
	
	NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@""];
	[quitMenuItem setTarget:self];
	[quitMenuItem setEnabled:YES];
	[menu insertItem:quitMenuItem atIndex:2];
	
	[self.statusItem setMenu:menu];
	
	NSURL *url = [NSURL URLWithString:@"http://gottago.medu.com:8080"];
	self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
	dispatch_async(dispatch_get_main_queue(), ^{
        self.webSocket.delegate = self;
        [self.webSocket open];
    });
}

- (IBAction)quit:(id)sender
{
	[NSApp terminate:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	NSLog(@"webSocket:didReceiveMessage:");
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	NSLog(@"webSocketDidOpen:");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
	NSLog(@"webSocket:didFailWithError:");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	NSLog(@"didCloseWithCode:reason:wasClean");
	NSLog(@"%@", reason);
}

@end
