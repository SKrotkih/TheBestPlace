//
//  Constants.m
//  TheBestPlace
//
//  Created by Sergey Krotkih on 7/31/12.
//  Copyright (c) 2012 Quickoffice. All rights reserved.
//

#import "Constants.h"

#pragma mark - Foursquare

// App: https://foursquare.com/developers/app/Y0CQITUK2UNDGS351JZWEN2ZKW5IOLB0KAN4WKXT5XCZXYDH
NSString* const FoursquareClientId = @"Y0CQITUK2UNDGS351JZWEN2ZKW5IOLB0KAN4WKXT5XCZXYDH";
NSString* const FoursquareClientSecret =  @"L0XDSNINFHFAOBQKLXKXLXQOV3UCZ5DYAIPCIJKG4XT3GHFX";
NSString* const FoursquareCallbackUrl = @"thoughtsbook://foursquare";

NSString* const kFOURSQUARE_CLIET_ID = @"FOURSQUARE_CLIET_ID";
NSString* const kFOURSQUARE_OAUTH_SECRET = @"FOURSQUARE_OAUTH_SECRET";
NSString* const kFOURSQUARE_CALLBACK_URL = @"FOURSQUARE_CALLBACK_URL";
NSString* const kFOURSQUARE_ACCESS_TOKEN = @"FOURSQUARE_ACCESS_TOKEN";

// Access Token URL: https://foursquare.com/oauth2/access_token
// Authorize URL: https://foursquare.com/oauth2/authorize

NSString* const kDefaultFoursquareAccountUserName = @"svmp@ukr.net";
NSString* const kDefaultFoursquareAccountPassword = @"bRooEMnV";
NSString* const kQFoursquareUserIdDefaultValue = @"UserId";

#pragma mark - Facebook

// App: https://developers.facebook.com/x/apps/303195533161137/settings/
NSString* const FacebookAppId = @"303195533161137";
NSString* const FacebookAppSecretKey = @"bb6b6da97f8c325817fc72056f9a198b";

#pragma mark - Twitter

// http://www.amazon.s3.com/
NSString* const CPTwitterOauthToken = @"CPTwitterOauthToken";
NSString* const CPTwitterOauthTokenSecret = @"CPTwitterOauthTokenSecret";
NSString* const CPTwitterGetNewOauthTokensNotification = @"CPTwitterGetNewOauthTokensNotification";
// App: https://apps.twitter.com/app/5877949
NSString* const TwitterConsumerKey = @"CaN26WXGgvhDsAV0EIKmoQ";
NSString* const TwitterConsumerSecret = @"hj7kgruIzwaqsUUHYdd0SLzaIpsZPHmgjvvZAUhmUA";

#pragma mark - GoogleMaps

NSString* const GoogleMapsAPIKey = @"AIzaSyCYDDO89sWhrgunAG6R0pcnkX3ot5Yel28";
NSString* const GoogleMapsAPIKeyBrowser = @"AIzaSyBrJxnPNN_nYbrL1GuWFPqvvMqTnO37ir4";

NSString* const kGotNewUpdateForDatabase = @"GotNewUpdateForDatabase";

#pragma mark - Instagram

// http://instagram.com/developer/clients/manage/?registered=MyThoughts
NSString * const kInstagramClientId = @"c039dc7d033444a3ac7fecbf5b44f319";
NSString * const kInstagramClientSecret = @"5910c73e490c4450bf3369c441ee5c0d";
//WEBSITE URL	http://www.ainatainer.com
//REDIRECT URI	thoughtsbook://instagarm

#pragma mark - Constants

const int kSearchVenuesRadiusInMeters = 15000;
const int kRequestTimeOutInSec = 100;

NSString* const kSignInStateDidChangedNotification = @"SignInStateDidChanged";
NSString* const kTheMainErrorsDomain = @"TheBestPlaceServer";

NSString* const kStatusBarHiddenDefaultValue = @"StatusBarHidden";

#pragma mark Color Hex Values

const UInt32 kHexFacebookAccountNavBarColor = 0x2e4386;
const UInt32 kHexFeedbackNavBarColor = 0xFD7222;
const UInt32 kHexSettingsNavBarColor = 0xFA6407;
const UInt32 kHexLoginNavBarColor = 0xFE771A;

#pragma mark -