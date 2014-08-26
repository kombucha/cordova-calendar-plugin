//
//  calendarPlugin.m
//  Author: Felix Montanez
//  Date: 01-17-2011
//  Notes:
//
// Contributors : Sean Bedford


#import "CalendarPlugin.h"
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation CalendarPlugin
@synthesize eventStore;

#pragma mark Initialisation functions

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = [super initWithWebView:theWebView];

    if (self) {
        [self initEventStoreWithCalendarCapabilities];
    }

    return self;
}

- (void)initEventStoreWithCalendarCapabilities {
    __block BOOL accessGranted = NO;
    eventStore = [[EKEventStore alloc] init];
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else { // we're on iOS 5 or older
        accessGranted = YES;
    }

    if (accessGranted) {
        self.eventStore = eventStore;
    }
}

#pragma mark Helper Functions

-(NSArray*)findEKEventsWithTitle: (NSString *)title
                        location: (NSString *)location
                         message: (NSString *)message
                       startDate: (NSDate *)startDate
                         endDate: (NSDate *)endDate {

    // Build up a predicateString - this means we only query a parameter if we actually had a value in it
    NSMutableString *predicateString= [[NSMutableString alloc] initWithString:@""];
    if (title.length > 0) {
        [predicateString appendString:[NSString stringWithFormat:@"title == '%@'" , title]];
    }
    if (location.length > 0) {
        [predicateString appendString:[NSString stringWithFormat:@" AND location == '%@'" , location]];
    }
    if (message.length > 0) {
        [predicateString appendString:[NSString stringWithFormat:@" AND notes == '%@'" , message]];
    }

    NSPredicate *matches = [NSPredicate predicateWithFormat:predicateString];

    NSArray *datedEvents = [self.eventStore eventsMatchingPredicate:[eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]];


    NSArray *matchingEvents = [datedEvents filteredArrayUsingPredicate:matches];


    return matchingEvents;
}

#pragma mark Cordova functions

- (void)createEvent:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;

    NSString *callbackId = command.callbackId;

    NSString* title = command.arguments[0];
    NSString* location = command.arguments[1];
    NSString* message = command.arguments[2];
    NSTimeInterval startDate = [command.arguments[3] doubleValue] / 1000.f;
    NSTimeInterval endDate = [command.arguments[4] doubleValue] / 1000.f;
    BOOL allDay = [command.arguments[5] boolValue];

    NSDate *myStartDate = [NSDate dateWithTimeIntervalSince1970:startDate];
    NSDate *myEndDate = [NSDate dateWithTimeIntervalSince1970:endDate];


    EKEvent *myEvent = [EKEvent eventWithEventStore: self.eventStore];
    myEvent.title = title;
    myEvent.location = location;
    myEvent.notes = message;
    myEvent.startDate = myStartDate;
    myEvent.endDate = myEndDate;
    myEvent.allDay = allDay;
    myEvent.calendar = self.eventStore.defaultCalendarForNewEvents;


    EKAlarm *reminder = [EKAlarm alarmWithRelativeOffset:-2*60*60];

    [myEvent addAlarm:reminder];

    NSError *error = nil;
    [self.eventStore saveEvent:myEvent span:EKSpanThisEvent error:&error];

    [self.eventStore saveEvent:myEvent
                          span:EKSpanThisEvent
                         error:&error];

    // Check error code + return result
    if (error) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:error.userInfo.description];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)deleteEvent:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;

    NSString *callbackId = command.callbackId;

    NSString* title = command.arguments[0];
    NSString* location = command.arguments[1];
    NSString* message = command.arguments[2];
    NSTimeInterval startDate = [command.arguments[3] doubleValue] / 1000.f;
    NSTimeInterval endDate = [command.arguments[4] doubleValue] / 1000.f;
    bool delAll = command.arguments[5];

    NSDate *myStartDate = [NSDate dateWithTimeIntervalSince1970:startDate];
    NSDate *myEndDate = [NSDate dateWithTimeIntervalSince1970:endDate];

    NSArray *matchingEvents = [self findEKEventsWithTitle:title location:location message:message startDate:myStartDate endDate:myEndDate];


    if (delAll || matchingEvents.count == 1) {
        // Definitive single match - delete it!
        NSError *error = NULL;
        bool hadErrors = false;
        if (delAll) {
            for (EKEvent * event in matchingEvents) {
                [self.eventStore removeEvent:event span:EKSpanThisEvent error:&error];
                // Check for error codes and return result
                if (error) {
                    hadErrors = true;
                }
            }
        }
        else {
            [self.eventStore removeEvent:[matchingEvents lastObject] span:EKSpanThisEvent error:&error];
        }
        // Check for error codes and return result
        if (error || hadErrors) {
            NSString *messageString;
            if (hadErrors) {
                messageString = @"Error deleting events";
            }
            else {
                messageString = error.userInfo.description;
            }

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:messageString];

        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)findEvent:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;

    NSString *callbackId = command.callbackId;

    NSString* title      = command.arguments[0];
    NSString* location   = command.arguments[1];
    NSString* message    = command.arguments[2];
    NSTimeInterval startDate  = [command.arguments[3] doubleValue] / 1000.f;
    NSTimeInterval endDate    = [command.arguments[4] doubleValue] / 1000.f;

    NSDate *myStartDate = [NSDate dateWithTimeIntervalSince1970:startDate];
    NSDate *myEndDate = [NSDate dateWithTimeIntervalSince1970:endDate];

    NSArray *matchingEvents = [self findEKEventsWithTitle:title location:location message:message startDate:myStartDate endDate:myEndDate];

    NSMutableArray *finalResults = [[NSMutableArray alloc] initWithCapacity:matchingEvents.count];


    // Stringify the results - Cordova can't deal with Obj-C objects
    for (EKEvent * event in matchingEvents) {
        NSMutableDictionary *entry = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        event.title, @"title",
        event.location, @"location",
        event.notes, @"message",
        [event.startDate timeIntervalSince1970], @"startDate",
        [event.endDate timeIntervalSince1970], @"endDate", nil];
        [finalResults addObject:entry];
    }

    if (finalResults.count > 0) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK
                                          messageAsArray:finalResults];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

-(void)modifyEvent:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;

    NSString* title = command.arguments[0];
    NSString* location = command.arguments[1];
    NSString* message = command.arguments[2];
    NSTimeInterval startDate = [command.arguments[3] doubleValue] / 1000.f;
    NSTimeInterval endDate = [command.arguments[4] doubleValue] / 1000.f;

    NSString* ntitle = command.arguments[5];
    NSString* nlocation = command.arguments[6];
    NSString* nmessage = command.arguments[7];
    NSTimeInterval nstartDate = [command.arguments[8] doubleValue] / 1000.f;
    NSTimeInterval nendDate = [command.arguments[9] doubleValue] / 1000.f;

    NSDate *myStartDate = [NSDate dateWithTimeIntervalSince1970:startDate];
    NSDate *myEndDate = [NSDate dateWithTimeIntervalSince1970:endDate];

    // Find matches
    NSArray *matchingEvents = [self findEKEventsWithTitle:title
                                                 location:location
                                                  message:message
                                                startDate:myStartDate
                                                  endDate:myEndDate];

    if (matchingEvents.count == 1) {
        // Presume we have to have an exact match to modify it!
        // Need to load this event from an EKEventStore so we can edit it
        EKEvent *theEvent = [self.eventStore eventWithIdentifier:((EKEvent*)[matchingEvents lastObject]).eventIdentifier];
        if (ntitle) {
            theEvent.title = ntitle;
        }
        if (nlocation) {
            theEvent.location = nlocation;
        }
        if (nmessage) {
            theEvent.notes = nmessage;
        }
        if (nstartDate) {
            NSDate *newMyStartDate = [NSDate dateWithTimeIntervalSince1970:nstartDate];
            theEvent.startDate = newMyStartDate;
        }
        if (nendDate) {
            NSDate *newMyEndDate = [NSDate dateWithTimeIntervalSince1970:nendDate];
            theEvent.endDate = newMyEndDate;
        }

        // Now save the new details back to the store
        NSError *error = nil;
        [self.eventStore saveEvent:theEvent span:EKSpanThisEvent error:&error];

        // Check error code + return result
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                               messageAsString:error.userInfo.description];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

@end
