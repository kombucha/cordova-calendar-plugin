//
//  CalendarPlugin.h
//  Author: Felix Montanez
//  Date: 01-17-2011
//  Notes:
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>


@interface CalendarPlugin : CDVPlugin

@property (nonatomic, retain) EKEventStore* eventStore;

- (void)initEventStoreWithCalendarCapabilities;

-(NSArray*)findEKEventsWithTitle: (NSString *) title
                        location: (NSString *) location
                         message: (NSString *) message
                       startDate: (NSDate *) startDate
                         endDate: (NSDate *) endDate;

// Calendar Instance methods
- (void)createEvent:(CDVInvokedUrlCommand*)command;
- (void)modifyEvent:(CDVInvokedUrlCommand*)command;
- (void)findEvent:(CDVInvokedUrlCommand*)command;
- (void)deleteEvent:(CDVInvokedUrlCommand*)command;

@end
