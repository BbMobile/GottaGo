#import "GGMenulet.h"

@implementation GGMenulet

@synthesize statusItem = _statusItem;
@synthesize floors = _floors;
@synthesize socket = _socket;

- (void)awakeFromNib
{
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setEnabled:YES];
	[self.statusItem setHighlightMode:YES];
	//[self.statusItem setTitle:@"Checking Checking"];
	[self.statusItem setTarget:self];
	
	// Set icon
	NSImage *menuIcon = [NSImage imageNamed:@"MenuIcons-XX"];
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
	
	self.floors = [NSMutableDictionary dictionary];
	
	[self connect];
}

- (void)connect
{
	self.socket = [[SocketIO alloc] initWithDelegate:self];
	[self.socket connectToHost:@"dev-gottago.medu.com" onPort:8080];
}

- (void)reconnect
{
	[self showOffline];
	[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(connect) userInfo:nil repeats:NO];
}

- (void)update
{
	NSMutableArray *strings = [NSMutableArray array];
	NSString *imagePrefix = @"MenuIcons-";
	
	for (NSString *floorKey in self.floors)
	{
		GGFloor *floor = [self.floors valueForKey:floorKey];
		//NSLog(@"Floor %@ with %ld rooms:", floorKey, [floor.rooms count]);
		for (NSString *roomKey in floor.rooms)
		{
			GGRoom *room = [floor.rooms valueForKey:roomKey];
			//NSLog(@"  Room %@: %@", roomKey, room);
			[strings addObject:(room.isOccupied) ? @"O" : @"V"];
		}
	}
	
	NSImage *menuIcon = [NSImage imageNamed:[imagePrefix stringByAppendingString:[strings componentsJoinedByString:@""]]];
	[self.statusItem setImage:menuIcon];
}

- (void)showOffline
{
	NSImage *menuIcon = [NSImage imageNamed:@"MenuIcons-XX"];
	[self.statusItem setImage:menuIcon];
}

- (IBAction)quit:(id)sender
{
	[NSApp terminate:self];
}

#pragma mark - SocketIODelegate

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
	[self reconnect];
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
	[self reconnect];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
	NSDictionary *args = [packet.args objectAtIndex:0];
	
	NSArray *floorsArray = [args valueForKey:@"floorsArray"];
	if (floorsArray)
	{
		for (NSArray *floor in floorsArray)
		{
			GGFloor *f = [[GGFloor alloc] init];
			for (NSDictionary *room in floor)
			{
				GGRoom *r = [[GGRoom alloc] init];
				r.isOccupied = ([[room valueForKey:@"status"] intValue] == 0) ? NO : YES;
				[f addRoom:r forIdentifier:[room valueForKey:@"room"]];
				[self.floors setValue:f forKey:[[room valueForKey:@"floor"] stringValue]];
			}
		}
		
		[self update];
	}
	
	if ([args valueForKey:@"room"])
	{
		GGFloor *floor = [self.floors valueForKey:[[args valueForKey:@"floor"] stringValue]];
		if (floor)
		{
			GGRoom *room = [floor roomForIdentifier:[args valueForKey:@"room"]];
			room.isOccupied = ([[args valueForKey:@"status"] intValue] == 0) ? NO : YES;
		}
		
		[self update];
	}
}

@end
