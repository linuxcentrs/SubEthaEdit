//
//  TCMMMLogStatisticsEntry.m
//  SubEthaEdit
//
//  Created by Dominik Wagner on 21.08.07.
//  Copyright 2007 TheCodingMonkeys. All rights reserved.
//

#import "TCMMMLogStatisticsEntry.h"
#import "TCMMMLoggingState.h"
#import "TCMMMUser.h"
#import "TCMMMLoggedOperation.h"
#import "SelectionOperation.h"
#import "TextOperation.h"
#import "UserChangeOperation.h"

@interface TCMMMLogStatisticsEntry (TCMMMLogStatisticsEntryPrivateAdditions)
- (void)setDateOfLastActivity:(NSCalendarDate *)aDate;
@end

@implementation TCMMMLogStatisticsEntry

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)aKey {
	NSSet *result = [super keyPathsForValuesAffectingValueForKey:aKey];
	static NSSet *S_dateAffectingSet = nil;
	if (!S_dateAffectingSet) S_dateAffectingSet = [[NSSet alloc] initWithObjects:@"operationCount",@"deletedCharacters",@"insertedCharacters",@"selectedCharacters",nil];
	if ([S_dateAffectingSet containsObject:aKey]) {
		result = [result setByAddingObject:@"dateOfLastActivity"];
	}
	return result;
}

- (id)initWithMMUser:(TCMMMUser *)aUser {
    if ((self=[super init])) {
        [self setDateOfLastActivity:[NSCalendarDate distantPast]];
        user = [aUser retain];
    }
    return self;
}

// only for usage in a tableview cell
- (id)copyWithZone:(NSZone *)aZone {
    return [self retain];
}

- (void)dealloc {
    [lastActivity release];
    [user release];
    [super dealloc];
}

- (void)updateWithOperation:(TCMMMLoggedOperation *)anOperation {
    id op = [anOperation operation];
    NSAssert([[op userID] isEqualToString:[user userID]],@"Updating this user with an operation from another User");
    if ([[anOperation date] timeIntervalSinceDate:lastActivity]>0) {
        [self setDateOfLastActivity:[anOperation date]];
    }
    operationCount++;
    if ([[op operationID] isEqualToString:[TextOperation operationID]]) {
        deletedCharacters+=[op affectedCharRange].length;
        insertedCharacters+=[[op replacementString] length];
        isInside = YES;
    } else if ([[op operationID] isEqualToString:[SelectionOperation operationID]]) {
        selectedCharacters+=[op selectedRange].length;
        isInside = YES;
    } else if ([[op operationID] isEqualToString:[UserChangeOperation operationID]]) {
        if ([(UserChangeOperation *)op type] == UserChangeTypeLeave) {
            isInside = NO;
        } else {
            isInside = YES;
        }
    }
}

- (BOOL)isInside {
    return isInside;
}

- (TCMMMLoggingState *)loggingState {
    return self->loggingState;
}

- (void)setLoggingState:(TCMMMLoggingState *)aLoggingState {
    self->loggingState = aLoggingState;
}

- (unsigned long)operationCount {
    return operationCount;
}
- (unsigned long)deletedCharacters {
    return deletedCharacters;
}
- (unsigned long)insertedCharacters {
    return insertedCharacters;
}
- (unsigned long)selectedCharacters {
    return selectedCharacters;
}
- (void)setDateOfLastActivity:(NSCalendarDate *)aDate {
    [self willChangeValueForKey:@"dateOfLastActivity"];
    [lastActivity autorelease];
     lastActivity = [aDate retain];
    [self didChangeValueForKey:@"dateOfLastActivity"];
}
- (TCMMMUser *)user {
    return user;
}
- (NSCalendarDate *)dateOfLastActivity {
    return lastActivity;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ user:%@ lastActivity:%@ opCount:%u delChar:%u insChar:%u selChar:%u",[self class],[self user],lastActivity,operationCount,deletedCharacters,insertedCharacters,selectedCharacters];
}
@end
