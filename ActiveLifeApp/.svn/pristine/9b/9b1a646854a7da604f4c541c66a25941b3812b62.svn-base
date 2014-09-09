//
//  MDDirectionService.m
//  MapsDirections
//
//  Created by Mano Marks on 4/8/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "MDDirectionService.h"

@interface MDDirectionService()
{
    NSData *data;
}
@property (assign, nonatomic) BOOL sensor;
@property (assign, nonatomic) BOOL alternatives;
@property (strong, nonatomic) NSURL *directionsURL;
@property (strong, nonatomic) NSArray *waypoints;
@end

@implementation MDDirectionService

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

- (void)setDirectionsQuery:(NSDictionary *)query withSelector:(SEL)selector withDelegate:(id)delegate
{
    NSArray *waypoints = query[@"waypoints"];
    NSString *origin = waypoints[0];
    int waypointCount = [waypoints count];
    int destinationPos = waypointCount - 1;
    NSString *destination = waypoints[destinationPos];
    NSString *sensor = query[@"sensor"];
    NSMutableString *url =
    [NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@",
     kMDDirectionsURL, origin, destination, sensor];
    if(waypointCount > 2)
    {
        [url appendString:@"&waypoints=optimize:true"];
        int wpCount = waypointCount-2;
        for(int i=1;i<wpCount;i++)
        {
            [url appendString: @"|"];
            [url appendString:[waypoints objectAtIndex:i]];
        }
    }
    url = [[url
           stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] mutableCopy];
    _directionsURL = [NSURL URLWithString:url];
    [self retrieveDirections:selector withDelegate:delegate];
}

- (void)retrieveDirections:(SEL)selector withDelegate:(id)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        data = [NSData dataWithContentsOfURL:_directionsURL];
//        NSLog(@"Direction Data : %@",data);
        if(data != nil)
        {
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:&error];
            
            NSDictionary *dict = (NSDictionary *)result;
            if ([[dict objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Direction Found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Internal Error Occur" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return;
                NSArray *jsonArray = (NSArray *)result; //convert to an array
                if (error == nil)
                    NSLog(@"Direct = %@", result);
                NSLog(@"Json Array =%@", jsonArray);
                
                for (id element in jsonArray) {
                    NSLog(@"Element: %@", [element description]);
                    
                }
                
            }
        }
        [self fetchedData:data withSelector:selector withDelegate:delegate];
    });
}

- (void)fetchedData:(NSData *)data1 withSelector:(SEL)selector withDelegate:(id)delegate
{
  
      NSError* error;
      NSDictionary *json = [NSJSONSerialization  JSONObjectWithData:data1 options:kNilOptions error:&error];
      [delegate performSelector:selector withObject:json];
}

@end
