//
//  CreateEventViewController.h
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol CreateEventDelegate <NSObject>

@end

@interface CreateEventViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,NSURLConnectionDataDelegate>
{
    id <CreateEventDelegate> delegate;
    IBOutlet UIImageView *name_checkmark;
    UIDatePicker *chPicker;
    BOOL select;
    NSString *datePickerType;
    IBOutlet UITableView *tableLocSuggetion;
}
-(IBAction)timeAction:(id)sender;
-(IBAction)ageAction:(id)sender;

@property (nonatomic, strong) NSString *eventStoreCalendarIdentifier;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableArray *locSuggetionArray;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) id delegate;
@end
