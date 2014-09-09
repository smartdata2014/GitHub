//
//  AppStereoUtil.h
//  VintageRadioFinal
//
//  Created by Guillaume Rivron on 03/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPSTEREO_WS_URL_BASE @"http://therese.lesmobilizers.com/cgi-bin/WebObjects/zeturfFrontend.woa/wa/ws/"
#define APPSTEREO_WS_GET_STATIC_RESOURCES @""
#define APPSTEREO_WS_CONNECTION_OPEN @"connection-open"

#define APPSTEREO_WS_GETSTATICRESOURCES_DATA_FORMAT @"{\"reponse\":\"%@\"}"

//// Here you put the Request template %@ is data you will put
#define APPSTEREO_WS_GETALLDATA_DATA_FORMAT @"{\"header\": {\"stats\": {\"device\": \"%@\",\"system-version\": \"%@\"},\"appid\": \"2097649D-4AC9-437A-B1F6-370679E18387\",\"protocol_version\": 1},\"request\": {\"methodName\": \"%@\",\"args\": {\"transaction_id\":%@}}}"

extern NSString *AppStereoGetRadiosDone;


@interface AppStereoUtil : NSObject {

	
	
}

//- (void)beginGetResource:(NSString *)resourceType;
- (void)beginGetRadio:(NSString *)resourceType transactionid:(NSString *) tid ;

@end
