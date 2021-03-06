//  NSMenuAdditions.h
//  SubEthaEdit
//
//  Created by Dominik Wagner on 27.03.06.

#import <Cocoa/Cocoa.h>

@interface NSMenu (NSMenuTCMAdditions)
- (void)removeAllItems;
@end

@interface NSMenuItem (NSMenuItemTCMAdditions)
- (void)setMark:(BOOL)aMark;
- (id)autoreleasedCopy;
- (NSComparisonResult)compareAlphabetically:(NSMenuItem *)aNotherMenuItem;
- (void)setKeyEquivalentBySettingsString:(NSString *)aKeyEquivalentSettingsString;
@end
