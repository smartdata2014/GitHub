//
//  WebserviceCall.h
//  Active Life
//
//  Created by sdnmacmini10 on 13/02/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
//#import "ASIFormDataRequest.h"

@protocol WebServiceDelegate <NSObject>

-(void)webRequestFinished:(id)sender forTag:(int)Tag;
-(void)webRequestFailed:(id)sender;

@end

@interface WebserviceCall : NSObject
{
    id <WebServiceDelegate> delegate;
}
+(id)sharedInstance;

-(void)callWebserviceWithIdentifier:(NSString *)identifier andArguments :(NSDictionary *)arguments;

-(void)showActivityIndicator;
-(void)hideActivityIndicator;
-(id)callWebserviceForUploadingVideoWithArguments :(NSDictionary *)arguments;
- (BOOL)connectedToInternet;
@property (nonatomic,assign) int tag;
@property (nonatomic,strong) id delegate;

@end
