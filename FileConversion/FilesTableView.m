/*
 *  $Id$
 *
 *  Copyright (C) 2005 - 2007 Stephen F. Booth <me@sbooth.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "FilesTableView.h"

@interface FilesTableView (Private)
- (void) openWithPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo;
@end

@implementation FilesTableView

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	if([menuItem action] == @selector(playWithPlay:))
		return (nil != [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Play"]);
	else if([menuItem action] == @selector(editWithTag:))
		return (nil != [[NSWorkspace sharedWorkspace] fullPathForApplication:@"Tag"]);
	else
		return YES;
}

- (NSDragOperation) draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return (isLocal ? NSDragOperationMove : NSDragOperationCopy);
}

- (void) keyDown:(NSEvent *)event
{
	unichar			key		= [[event charactersIgnoringModifiers] characterAtIndex:0];    
	unsigned int	flags	= [event modifierFlags] & 0x00FF;
    
	if(NSDeleteCharacter == key && 0 == flags) {
		if(-1 == [self selectedRow]) {
			NSBeep();
		}
		else {
			[_filesController removeObjectsAtArrangedObjectIndexes:[self selectedRowIndexes]];
		}
	}
	else {
		[super keyDown:event]; // let somebody else handle the event 
	}
}

// TODO: provide prettier dragging images for files (larger icons ??)
/*
- (NSImage *) dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent*)dragEvent offset:(NSPointPointer)dragImageOffset
{
	return [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns event:dragEvent offset:dragImageOffset];
}
*/

- (NSMenu *) menuForEvent:(NSEvent *)event
{
	NSPoint		location		= [event locationInWindow];
	NSPoint		localLocation	= [self convertPoint:location fromView:nil];
	NSInteger	row				= [self rowAtPoint:localLocation];
	
	if(-1 != row) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		return [self menu];
	}
	
	return nil;
}

- (IBAction) openWithFinder:(id)sender
{
	NSString *path = [[_filesController selection] valueForKey:@"filename"];
	[[NSWorkspace sharedWorkspace] openFile:path];
}

- (IBAction) revealInFinder:(id)sender
{
	NSString *path = [[_filesController selection] valueForKey:@"filename"];
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
}

- (IBAction) playWithPlay:(id)sender
{
	NSString *path = [[_filesController selection] valueForKey:@"filename"];
	[[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Play"];
}

- (IBAction) editWithTag:(id)sender
{
	NSString *path = [[_filesController selection] valueForKey:@"filename"];
	[[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Tag"];
}

- (IBAction) openWith:(id)sender
{
	NSOpenPanel		*panel		= [NSOpenPanel openPanel];
	
	[panel beginSheetForDirectory:nil file:nil types:[NSArray arrayWithObject:@"app"] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(openWithPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];	
}

@end

@implementation FilesTableView (Private)

- (void) openWithPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{	
	if(NSOKButton == returnCode) {
		NSString			*path				= [[_filesController selection] valueForKey:@"filename"];
		NSArray				*applications		= [panel filenames];
		NSString			*applicationPath	= nil;
		unsigned			i;
		
		for(i = 0; i < [applications count]; ++i) {
			applicationPath = [applications objectAtIndex:i];
			[[NSWorkspace sharedWorkspace] openFile:path withApplication:applicationPath];
		}
	}
}

@end
