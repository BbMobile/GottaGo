#import "GGMenulet.h"

@implementation GGMenulet

@synthesize statusItem = _statusItem;
@synthesize goMenuItem = _goMenuItem;
@synthesize gottaGo = _gottaGo;
@synthesize floor4MenuItem = _floor4MenuItem;
@synthesize floor3MenuItem = _floor3MenuItem;
@synthesize floor2MenuItem = _floor2MenuItem;
@synthesize floor1MenuItem = _floor1MenuItem;
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
	
	self.goMenuItem = [[NSMenuItem alloc] initWithTitle:@"Notify When Vacant" action:@selector(notifyWhenVacant:) keyEquivalent:@""];
	[self.goMenuItem setTarget:self];
	[self.goMenuItem setEnabled:NO];
	[menu insertItem:self.goMenuItem atIndex:0];
	
	NSMenuItem *separatorMenuItem1 = [NSMenuItem separatorItem];
	[menu insertItem:separatorMenuItem1 atIndex:1];
	
	// Build the floor list
	// So hacky -- should really be built upon the list of floors delivered in the initial socket.io message
	NSString *preferredFloor = [self preferredFloor];
	
	self.floor4MenuItem = [[NSMenuItem alloc] initWithTitle:@"Floor 4" action:@selector(chooseFloor4:) keyEquivalent:@""];
	[self.floor4MenuItem setTarget:self];
	[self.floor4MenuItem setEnabled:NO];
	[menu insertItem:self.floor4MenuItem atIndex:2];
	if ([preferredFloor isEqualToString:@"4"]) [self.floor4MenuItem setState:NSOnState];
	
	self.floor3MenuItem = [[NSMenuItem alloc] initWithTitle:@"Floor 3" action:@selector(chooseFloor3:) keyEquivalent:@""];
	[self.floor3MenuItem setTarget:self];
	[self.floor3MenuItem setEnabled:YES];
	[menu insertItem:self.floor3MenuItem atIndex:3];
	if ([preferredFloor isEqualToString:@"3"]) [self.floor3MenuItem setState:NSOnState];
	
	self.floor2MenuItem = [[NSMenuItem alloc] initWithTitle:@"Floor 2" action:@selector(chooseFloor2:) keyEquivalent:@""];
	[self.floor2MenuItem setTarget:self];
	[self.floor2MenuItem setEnabled:YES];
	[menu insertItem:self.floor2MenuItem atIndex:4];
	if ([preferredFloor isEqualToString:@"2"]) [self.floor2MenuItem setState:NSOnState];
	
	self.floor1MenuItem = [[NSMenuItem alloc] initWithTitle:@"Floor 1" action:@selector(chooseFloor1:) keyEquivalent:@""];
	[self.floor1MenuItem setTarget:self];
	[self.floor1MenuItem setEnabled:NO];
	[menu insertItem:self.floor1MenuItem atIndex:5];
	if ([preferredFloor isEqualToString:@"1"]) [self.floor1MenuItem setState:NSOnState];
	
	NSMenuItem *separatorMenuItem2 = [NSMenuItem separatorItem];
	[menu insertItem:separatorMenuItem2 atIndex:6];
	
	NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@""];
	[quitMenuItem setTarget:self];
	[quitMenuItem setEnabled:YES];
	[menu insertItem:quitMenuItem atIndex:7];
	
	[self.statusItem setMenu:menu];
	
	self.floors = [NSMutableDictionary dictionary];
	self.gottaGo = NO;
	
	[self connect];
}

- (void)notifyWhenVacant:(id)sender
{
	self.gottaGo = YES;
}

- (void)chooseFloor4:(id)sender
{
	[self.floor4MenuItem setState:NSOnState];
	[self.floor3MenuItem setState:NSOffState];
	[self.floor2MenuItem setState:NSOffState];
	[self.floor1MenuItem setState:NSOffState];
	[self setPreferredFloor:@"4"];
	[self update];
}

- (void)chooseFloor3:(id)sender
{
	[self.floor4MenuItem setState:NSOffState];
	[self.floor3MenuItem setState:NSOnState];
	[self.floor2MenuItem setState:NSOffState];
	[self.floor1MenuItem setState:NSOffState];
	[self setPreferredFloor:@"3"];
	[self update];
}

- (void)chooseFloor2:(id)sender
{
	[self.floor4MenuItem setState:NSOffState];
	[self.floor3MenuItem setState:NSOffState];
	[self.floor2MenuItem setState:NSOnState];
	[self.floor1MenuItem setState:NSOffState];
	[self setPreferredFloor:@"2"];
	[self update];
}

- (void)chooseFloor1:(id)sender
{
	[self.floor4MenuItem setState:NSOffState];
	[self.floor3MenuItem setState:NSOffState];
	[self.floor2MenuItem setState:NSOffState];
	[self.floor1MenuItem setState:NSOnState];
	[self setPreferredFloor:@"1"];
	[self update];
}

- (NSString *)preferredFloor
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *preferredFloor = [prefs stringForKey:@"preferredFloor"];
	
	return (preferredFloor) ? preferredFloor : @"2"; // Default floor is 2 -- the first floor to recieve a GottaGo unit
}

- (void)setPreferredFloor:(NSString *)floorKey
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:floorKey forKey:@"preferredFloor"];
	[prefs synchronize];
}

- (void)connect
{
	self.socket = [[SocketIO alloc] initWithDelegate:self];
	[self.socket connectToHost:@"gottago.medu.com" onPort:8080];
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
	
	for (int f = 1; f <= 4; f++)
	{
		NSString *floorKey = [NSString stringWithFormat:@"%d", f];
		if ([floorKey isEqualToString:[self preferredFloor]])
		{
			GGFloor *floor = [self.floors valueForKey:floorKey];
			if (!floor)
			{
				// No floor data exists, so mark it as offline
				[strings addObject:@"X"];
				[strings addObject:@"X"];
			}
			else
			{
				GGRoom *room1 = [floor.rooms valueForKey:@"a"];
				GGRoom *room2 = [floor.rooms valueForKey:@"b"];
				[strings addObject:(room1.isOccupied) ? @"O" : @"V"];
				[strings addObject:(room2.isOccupied) ? @"O" : @"V"];
				
				// Enable the GottaGo menu item if both rooms are occupied
				[self.goMenuItem setEnabled:(room1.isOccupied && room2.isOccupied)];
				
				// Deliver notification if needed
				if (self.gottaGo && (!room1.isOccupied || !room2.isOccupied))
				{
					self.gottaGo = NO; // Only deliver the notification for a single vacancy
					[self deliverNotification];
				}
			}
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

- (void)deliverNotification
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	[notification setTitle:@"GottaGo"];
	[notification setInformativeText:@"A bathroom is now available"];
	
	NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
	[center setDelegate:self];
	[center deliverNotification:notification];
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

#pragma mark - NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
