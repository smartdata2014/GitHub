//
//  AppStereoUtil.m
//  VintageRadioFinal
//
//  Created by Guillaume Rivron on 03/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppStereoUtil.h"


NSString *AppStereoGetRadiosDone = @"AppStereoGetRadiosDone";
static NSString *kRequestRequestData = @"requestData";
static NSString *kRequestNotificationName = @"notificationName";
static NSString *kRequestRequestDescription = @"requestDescription";
static NSString *kRequestRequestURL = @"requestURL";

@interface AppStereoUtil (Private)
- (void)doWSRequest:(NSDictionary *)argumentsDictionary;
- (void)doWSRequest:(NSString *)url dataString:(NSString *)dataString notificationName:(NSString *)notificationName description:(NSString *)description;
@end

@implementation AppStereoUtil


- (void)doWSRequest:(NSDictionary *)argumentsDictionary {
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];// memory leaks
	//if (_WIFI || _WWAN){
	NSLog(@"Requête sur \"%@\" au serveur distant.", [argumentsDictionary objectForKey:kRequestRequestDescription]);
	[self doWSRequest:[argumentsDictionary objectForKey:kRequestRequestURL]
		   dataString:[argumentsDictionary objectForKey:kRequestRequestData]
	 notificationName:[argumentsDictionary objectForKey:kRequestNotificationName]
		  description:[argumentsDictionary objectForKey:kRequestRequestDescription]];
	//}
	//[pool release];// memory leaks
}



- (void)doWSRequest:(NSString *)urlString dataString:(NSString *)dataString notificationName:(NSString *)notificationName description:(NSString *)description {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"data : %@",dataString);
	NSURL *url = [[NSURL alloc] initWithString:urlString];//
	NSLog(@"url:%@", url);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[url release];
	
	
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:@"iPhoneV1" forHTTPHeaderField:@"X-AppStereo-Application-Id"];
	[request addValue:@"fr" forHTTPHeaderField:@"Accept-Language"];
	
	[request setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ([response isKindOfClass:[NSHTTPURLResponse class]] && [(NSHTTPURLResponse *)response statusCode] == 200) {
		
		NSString *reply = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		
		NSLog(@"reply : %@",reply);
		
	//	NSDictionary *jsonDic = [reply JSONValue];
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:[reply JSONValue] userInfo:nil];
//		[reply release];
	}
	
	else {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:response ];
		
		[NSThread exit];
		
		return;
	}
	
	
	[pool release];
	
	[NSThread exit];
}

- (void)beginGetResource:(NSString *)resourceType transactionid:(NSString *) tid{
	
	NSLog(@"beginressource") ;
	NSString *resourceNotification = nil;
	if ([resourceType isEqualToString:@"getAll"]) {
		resourceNotification = AppStereoGetRadiosDone;
	}else if ([resourceType isEqualToString:@"getToken"]) {
		resourceNotification = AppStereoGetRadiosDone;
	}
	
//	NSDictionary *argumentsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:APPSTEREO_WS_URL_BASE, APPSTEREO_WS_GET_STATIC_RESOURCES], kRequestRequestURL,
//										 [NSString stringWithFormat:APPSTEREO_WS_GETALLDATA_DATA_FORMAT, resourceType], kRequestRequestData, //, nil, postalCode, nil, nil], kRequestRequestData,
//										 resourceNotification, kRequestNotificationName,
//										 @"get-static-resources", kRequestRequestDescription,
//										 nil];
//	//[resourceNotification release];
//	
////	NSString *uuid = [[UIDevice currentDevice] systemVersion] ;
////	NSString *systemversion = [[UIDevice currentDevice] uniqueIdentifier] ;
//	NSString *req = [NSString stringWithFormat:APPSTEREO_WS_GETALLDATA_DATA_FORMAT, resourceType] ;
//	
//	NSLog(@"requete %@",req);
//	[NSThread detachNewThreadSelector:@selector(doWSRequest:) toTarget:self withObject:argumentsDictionary];
}


- (void)beginGetRadio:(NSString *)resourceType transactionid:(NSString *) tid{
	
	NSLog(@"transaction id = %@", tid);
	NSLog(@"beginressource") ;
	NSString *resourceNotification = nil;
	if ([resourceType isEqualToString:@"getAll"]) {
		resourceNotification = AppStereoGetRadiosDone;
	}else if ([resourceType isEqualToString:@"getToken"]) {
		resourceNotification = AppStereoGetRadiosDone;
	}
	
		
//	NSDictionary *argumentsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:APPSTEREO_WS_URL_BASE, APPSTEREO_WS_GET_STATIC_RESOURCES], kRequestRequestURL,
//										 [NSString stringWithFormat:APPSTEREO_WS_GETALLDATA_DATA_FORMAT,[[UIDevice currentDevice] uniqueIdentifier],[[UIDevice currentDevice] systemVersion], resourceType , tid], kRequestRequestData, //, nil, postalCode, nil, nil], kRequestRequestData,
//										 resourceNotification, kRequestNotificationName,
//										 @"get-static-resources", kRequestRequestDescription,
//										 nil];
//	NSString *uuid = [[UIDevice currentDevice] systemVersion] ;
//	NSString *systemversion = [[UIDevice currentDevice] uniqueIdentifier] ;
//	NSString *req = [NSString stringWithFormat:APPSTEREO_WS_GETALLDATA_DATA_FORMAT,uuid, systemversion , resourceType , tid] ;
// //	NSLog("request %c", req) ;
//	//[resourceNotification release];
//	
//	[NSThread detachNewThreadSelector:@selector(doWSRequest:) toTarget:self withObject:argumentsDictionary];
}

@end
