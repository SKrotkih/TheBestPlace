//
//  AIInviteFriendsFromContacts.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 6/4/14.
//  Copyright (c) 2014 Sergey Krotkih. All rights reserved.
//

#import "AIInviteFriendsFromContacts.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AIEmailManager.h"

@interface AIInviteFriendsFromContacts () <ABPeoplePickerNavigationControllerDelegate>

@end

@implementation AIInviteFriendsFromContacts

- (void) instantiateViewController
{
    self.friends = [[NSMutableArray alloc] init];
    self.users = [[NSMutableArray alloc] init];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Friends"
                                                         bundle: nil];
    self.inviteFriendsTableViewController = [storyboard instantiateViewControllerWithIdentifier: @"AIInviteFriendsTVC"];
    self.inviteFriendsTableViewController.delegate = self;
    self.inviteFriendsTableViewController.friends = self.friends;
    self.inviteFriendsTableViewController.users = self.users;
    
    self.inviteFriendsTableViewController.titleText = NSLocalizedString(@"Contacts Friends", nil);
    self.inviteFriendsTableViewController.titleSection0 = NSLocalizedString(@"YOU HAVE %i CONTACTS", nil);
    self.inviteFriendsTableViewController.titleSection1 = NSLocalizedString(@"INVITE FRIENDS VIA EMAIL", nil);
    
    [self.parentViewController.navigationController pushViewController: self.inviteFriendsTableViewController
                                                              animated: YES];
}

- (void) generateDataSourse
{
    [self gettingContactsListFromAddressBook];
}

#pragma mark Getting Contacts From Address Book which every has an email address

- (void) gettingContactsListFromAddressBook
{
    [self.friends removeAllObjects];
    [self.users removeAllObjects];
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     if (granted)
                                                     {
                                                         // First time access has been granted, add the contact
                                                         [self gettingDataSourceWithContactsList];
                                                     }
                                                     else
                                                     {
                                                         [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Warning!", nil)
                                                                                      text: NSLocalizedString(@"Access to Contacts denied.", nil)];
                                                     }
                                                 });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        // The user has previously given access, add the contact
        [self gettingDataSourceWithContactsList];
    }
    else
    {
        [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"Access to Contacts denied!", nil)
                                     text: NSLocalizedString(@"You can change privacy settings in settings app.", nil)];
    }
}

- (void) gettingDataSourceWithContactsList
{
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(NULL, NULL);   //   ABAddressBookCreate();
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    for (int i = 0; i < numberOfContacts; i++)
    {
        NSString* name = @"";
        NSString* email = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray* emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
        
        if (fnameProperty != nil)
        {
            name = [NSString stringWithFormat: @"%@", fnameProperty];
        }
        
        if (lnameProperty != nil)
        {
            name = [name stringByAppendingString: [NSString stringWithFormat: @" %@", lnameProperty]];
        }
        
        if ([emailArray count] > 0)
        {
            if ([emailArray count] > 1)
            {
                for (int i = 0; i < [emailArray count]; i++)
                {
                    email = [email stringByAppendingString: [NSString stringWithFormat: @"%@\n", [emailArray objectAtIndex: i]]];
                }
            }
            else
            {
                email = [NSString stringWithFormat: @"%@", [emailArray objectAtIndex: 0]];
            }
        }
        
        if (email.length > 0)
        {
            BOOL isHeFriendAlready = NO;
            
            for (AIUser* friend in self.thoughtsBookFriends)
            {
                if ([friend.email isEqualToString: email])
                {
                    isHeFriendAlready = YES;
                    
                    break;
                }
            }
            
            if (!isHeFriendAlready)
            {
                NSDictionary* dict = @{@"name": name, @"facebookuserid": @"", @"facebookusername": @"", @"photourl": @"", @"email": email};
                [self.friends addObject: dict];
            }
        }
    }
    
    [self addRegisteredUsersForFunctor: ^BOOL(AIUser* user, NSDictionary* friend){
        
        NSString* email = user.email;
        
        if ([email isEqualToString: friend[@"email"]])
        {
            return YES;
        }
        
        return NO;
    }];
    
}

#pragma mark ABPeoplePicker

- (void) sendInviteContactPeoplePickerWithViewController: (UIViewController*) aViewController
{
    // creating the picker
	ABPeoplePickerNavigationController* _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
	// place the delegate of the picker to the controll
	_addressBookController.peoplePickerDelegate = self;
    
	// showing the picker
    [aViewController presentViewController: _addressBookController
                                  animated: YES
                                completion: nil];
}

// Called after a person has been selected by the user.
- (void) peoplePickerNavigationController: (ABPeoplePickerNavigationController*) peoplePicker
                          didSelectPerson: (ABRecordRef) person
{
    // setting the first name
    NSString* firstName = (__bridge NSString*) ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // setting the last name
    NSString* lastName = (__bridge NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString* name = nil;
    
    if (firstName != nil)
    {
        name = [NSString stringWithFormat: @"%@", firstName];
    }
    
    if (lastName != nil)
    {
        name = [name stringByAppendingString: [NSString stringWithFormat: @" %@", lastName]];
    }
    
    NSString* homeEmail = @"";
    NSString* workEmail = @"";
    
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (int i=0; i < ABMultiValueGetCount(emailsRef); i++)
    {
        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        if (currentEmailLabel && currentEmailValue)
        {
            if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo)
            {
                homeEmail = (__bridge NSString*) currentEmailValue;
            }
            
            if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
            {
                workEmail = (__bridge NSString*) currentEmailValue;
            }
            CFRelease(currentEmailLabel);
            CFRelease(currentEmailValue);
        }
        else if (currentEmailValue)
        {
            workEmail = (__bridge NSString*) currentEmailValue;
            CFRelease(currentEmailValue);
        }
    }
    
    CFRelease(emailsRef);
    
    NSString* email = nil;
    
    if (workEmail.length > 0)
    {
        email = workEmail;
    }
    else if (homeEmail.length > 0)
    {
        email = homeEmail;
    }
    
    if (email)
    {
        [self.inviteFriendsTableViewController dismissViewControllerAnimated: YES
                                                                  completion: nil];
        [[AIEmailManager sharedInstance] sendEmailWithInviteWithEmail: email
                                                           friendName: name];
    }
    else
    {
        [AIAlertView showUIAlertWythTitle: NSLocalizedString(@"This contact hasn't email!", nil)
                                     text: [NSString stringWithFormat: NSLocalizedString(@"Can't send invite to %@", nil), name]];
    }
}

// Called after the user has pressed cancel.
- (void) peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController*) peoplePicker
{
}

#pragma mark -

@end
