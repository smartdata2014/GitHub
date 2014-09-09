//
//  HomeViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "HomeViewController.h"
#import "MDDirectionService.h"

@interface HomeViewController ()<SWRevealViewControllerDelegate,GMSMapViewDelegate,CLLocationManagerDelegate,WebServiceDelegate,CreateEventDelegate,CLLocationManagerDelegate,MNMBottomPullToRefreshManagerClient>
{
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITableView *eventTableView;
    IBOutlet UIScrollView *eventScrollView;
    GMSMapView *mapView_;
//    CLLocationManager *locationManager;
    GMSCameraPosition *camera;
//    CLLocation *currentLocation;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageNumber;
//  IBOutlet UIBarButtonItem* revealButtonItem;
}

@property (strong, nonatomic) NSMutableArray *eventsArray;
@property (strong, nonatomic) NSMutableArray *waypoints;
@property (strong, nonatomic) NSMutableArray *waypointStrings;

-(IBAction)btnLogOutPressed:(id)sender;
-(IBAction)btnMenuPressed:(id)sender;
-(IBAction)SegmentControlActions:(id)sender;

-(void)intializeMap;
-(void)getDirection;

@end

@implementation HomeViewController
NSUInteger featuredindex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    _eventsArray = [[NSMutableArray alloc] init];
    self.waypoints = [NSMutableArray array];
    self.waypointStrings = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    [self SegmentControlActions:nil];
    pageNumber = 1;
    reloads_ = -1;
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:90.0f tableView:eventTableView withClient:self];

    self.tableHeightConstraint.constant = 275;
    [eventTableView needsUpdateConstraints];
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self getAllEventsForPage:1];
}

-(void)viewWillDisappear:(BOOL)animated{
    //    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - General Button Actions

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
//    UINavigationController *navController =(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
//    [navController popViewControllerAnimated:YES];
}

-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

-(IBAction)SegmentControlActions:(id)sender{

    NSLog(@"Segment..%i",[segmentControl selectedSegmentIndex]);
    if ([segmentControl selectedSegmentIndex]==0) {
        [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
        [(UIButton *)[self.view viewWithTag:102]setSelected:NO];
        eventTableView.hidden = NO;
        mapView_.hidden = YES;
        NSLog(@"ListView");
    }
    else{
        [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
        [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
        eventTableView.hidden = YES;
        mapView_.hidden = NO;
        NSLog(@"Map View");
    }
}

-(void)btnJoinNowPressed:(UIButton *)sender{
    NSLog(@"Join Now");
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:[[_eventsArray objectAtIndex:0] valueForKey:@"event_id"] forKey:@"event_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[NSString stringWithFormat:@"%@%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],[[_eventsArray objectAtIndex:0] valueForKey:@"event_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]] forKey:@"signature"];
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 702;
    [webserviceCall callWebserviceWithIdentifier:@"JoinNow" andArguments:postDict];
}

-(void)btnfeaturedEventPressed:(UIButton *)sender{
    NSLog(@"btnfeaturedEventPressed");
    
    if ([[[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_creator_id"] isEqualToString:[[AppDelegate GloabalInfo] valueForKey:@"user_id"]]) {
        CreateEventViewController *createEventViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
        createEventViewController.eventId = [[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_id"];
        [self.navigationController pushViewController:createEventViewController animated:YES];
    }
    else{
        EventDetailsViewController *eventDetailsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
        eventDetailsViewController.eventId = [[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_id"];
        [self.navigationController pushViewController:eventDetailsViewController animated:YES];
    }
}

#pragma mark - MapView Intialization

-(void)intializeMap{
    
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    [locationManager startUpdatingLocation];
//  [GMSServices provideAPIKey:@"AIzaSyCMRm98LNzDI93Mqa87NsC1viEhEmtadKM"];
    
    camera = [GMSCameraPosition cameraWithLatitude:[[[_eventsArray objectAtIndex:0] valueForKey:@"event_latitude"] doubleValue]
                                                            longitude:[[[_eventsArray objectAtIndex:0] valueForKey:@"event_longitude"] doubleValue]
                                                                 zoom:5];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 293, 320, 286) camera:camera];
//    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 64, 320, 460) camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.mapType = kGMSTypeNormal;
    mapView_.indoorEnabled = YES;
    mapView_.accessibilityElementsHidden = NO;
    mapView_.settings.scrollGestures = YES;
    mapView_.settings.zoomGestures = YES;
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.delegate = self;
    mapView_.hidden = YES;
    
//    Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(22.25,76.02);
//    marker.title = @"Indore";
//    marker.snippet = @"India";
//    marker.map = mapView_;
    
    [self.view addSubview:mapView_];
//  [self.view bringSubviewToFront:mapView_];
    [self placeMarkers];
}

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    currentLocation = [[CLLocation alloc] init];
//    currentLocation = (CLLocation *)[locations lastObject];
//    camera =  [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:9.0];
//    [locationManager stopUpdatingLocation];
//    locationManager = nil;
//}

-(void)placeMarkers
{
    // Creates a marker in the center of the map
    for (int i=0; i<[_eventsArray count]; i++) {
        GMSMarker *marker = [[GMSMarker alloc] init];

        marker.infoWindowAnchor = CGPointMake(0, 0);
        marker.position = CLLocationCoordinate2DMake([[[_eventsArray objectAtIndex:i] valueForKey:@"event_latitude"] doubleValue], [[[_eventsArray objectAtIndex:i] valueForKey:@"event_longitude"] doubleValue]);
//        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.title = [[_eventsArray objectAtIndex:i] valueForKey:@"event_name"];
        marker.snippet = [[_eventsArray objectAtIndex:i] valueForKey:@"event_location"];
//        marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];

        NSLog(@"Event Name..%@",[NSString stringWithFormat:@"%@_pin",[[_eventsArray objectAtIndex:i] valueForKey:@"event_name"]]);
 
        NSLog(@"MAP IMAGE..%@",[NSString stringWithFormat:@"%@_pin",[[[[_eventsArray objectAtIndex:i] valueForKey:@"event_activity"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]);
        
        marker.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@_pin",[[[[_eventsArray objectAtIndex:i] valueForKey:@"event_activity"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
        marker.opacity = 0.9;
        marker.map = mapView_;
        marker.userData = [NSString stringWithFormat:@"%i",i];
    }
}

//- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
//{
//    for (int i=0; i<[_eventsArray count]; i++) {
//        GMSMarker *marker = [[GMSMarker alloc] init];
//        marker.infoWindowAnchor = CGPointMake(0, 0);
//        marker.position = CLLocationCoordinate2DMake([[[_eventsArray objectAtIndex:i] valueForKey:@"event_latitude"] doubleValue], [[[_eventsArray objectAtIndex:i] valueForKey:@"event_longitude"] doubleValue]);
//        marker.title = [[_eventsArray objectAtIndex:i] valueForKey:@"event_name"];
//        marker.snippet = [[_eventsArray objectAtIndex:i] valueForKey:@"event_location"];
//        marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
//        marker.opacity = 0.9;
//        marker.map = mapView;
//    }
//    return YES;
//}

#pragma mark - MapView Delagate Methods

- (UIView *) mapView:(GMSMapView *)  mapView markerInfoWindow: (GMSMarker *) marker
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 70)];
    view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    view.layer.cornerRadius = 5.0;
    view.layer.borderColor = [UIColor colorWithRed:41.0/255.0 green:153.0/255.0 blue:241.0 /255.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 1.0;
    
    UILabel *labelEvent = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 165, 20)];
    labelEvent.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
    labelEvent.textColor = [UIColor darkGrayColor];
    labelEvent.text = [[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_name"];
    [view addSubview:labelEvent];
    
    UILabel *labelLocation = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 165, 20)];
    labelLocation.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    labelLocation.textColor = [UIColor darkGrayColor];
    labelLocation.text = [[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_location"];
    [view addSubview:labelLocation];
    
    UILabel *labelDateTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 165, 20)];
    labelDateTime.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    labelDateTime.textColor = [UIColor darkGrayColor];
    labelDateTime.text = [[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_date"];
    [view addSubview:labelDateTime];

    UIImageView *eventImgView = [[UIImageView alloc] initWithFrame:CGRectMake(182, 22.5, 25, 25)];
    
    
    NSString *capitalisedSentence = [[[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_activity"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                                                        withString:[[[[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_activity"] substringToIndex:1] capitalizedString]];
    

    
    eventImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];

    [view addSubview:eventImgView];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(215, 10, 7, 12)];
    [arrowImage setImage:[UIImage imageNamed:@"arrowgrey.png"]];
    [view addSubview:arrowImage];

//    UIButton *btnDirections = [[UIButton alloc] initWithFrame:CGRectMake(182, 38, 40, 40)];
//    btnDirections = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnDirections setImage:[UIImage imageNamed:@"direction_icon"] forState:UIControlStateNormal];
//    btnDirections.backgroundColor = [UIColor yellowColor];
//    btnDirections.tag = [marker.userData integerValue];
//    [btnDirections addTarget:self action:@selector(getDirection:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:btnDirections];
//    [view bringSubviewToFront:btnDirections];
    
//    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(182, 38, 40, 40)];
//    btnView.backgroundColor = [UIColor yellowColor];
//    [view addSubview:btnView];
//    view.backgroundColor = [UIColor redColor];
    return view;
}

/*
-(void)getDirection:(UIButton *)sender
{
    NSLog(@"getDirection called");
    
    CLLocationCoordinate2D firstTapPosition = CLLocationCoordinate2DMake( mapView_.myLocation.coordinate.latitude, mapView_.myLocation.coordinate.longitude);
    
    GMSMarker *firstTapMarker = [GMSMarker markerWithPosition:firstTapPosition];
    firstTapMarker.map = mapView_;
    [self.waypoints addObject:firstTapMarker];
    
//  NSString *firstPositionString = [NSString stringWithFormat:@"%f,%f", 43.669000,-79.698053];
    
    NSString *firstPositionString = [NSString stringWithFormat:@"%f,%f", mapView_.myLocation.coordinate.latitude,mapView_.myLocation.coordinate.longitude];
    [self.waypointStrings addObject:firstPositionString];
    
    CLLocationCoordinate2D secondTapPosition = CLLocationCoordinate2DMake([[[_eventsArray objectAtIndex:[sender tag]] valueForKey:@"event_latitude"]doubleValue],[[[_eventsArray objectAtIndex:[sender tag]] valueForKey:@"event_latitude"]doubleValue]);
    
    GMSMarker *secondTapMarker = [GMSMarker markerWithPosition:secondTapPosition];
    secondTapMarker.map = mapView_;
    [self.waypoints addObject:secondTapMarker];
    NSString *secondPositionString = [NSString stringWithFormat:@"%f,%f",[[[_eventsArray objectAtIndex:[sender tag]] valueForKey:@"event_latitude"]doubleValue],[[[_eventsArray objectAtIndex:[sender tag]] valueForKey:@"event_latitude"]doubleValue]];
    [self.waypointStrings addObject:secondPositionString];
    if (self.waypoints.count > 1)
    {
        NSDictionary *query = @{ @"sensor" : @"false", @"waypoints" : self.waypointStrings };
        MDDirectionService *mds = [[MDDirectionService alloc] init];
        SEL selector = @selector(addDirections:);
        [mds setDirectionsQuery:query withSelector:selector withDelegate:self];
    }
}
*/

- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker{
    NSLog(@"didTapInfoWindowOfMarker");
    
    if ([[[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_creator_id"] isEqualToString:[[AppDelegate GloabalInfo] valueForKey:@"user_id"]]) {
        CreateEventViewController *createEventViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
        createEventViewController.eventId = [[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_id"];
        [self.navigationController pushViewController:createEventViewController animated:YES];
    }
    else{
        EventDetailsViewController *eventDetailsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
        eventDetailsViewController.eventId = [[_eventsArray objectAtIndex:[marker.userData integerValue]] valueForKey:@"event_id"];
        [self.navigationController pushViewController:eventDetailsViewController animated:YES];
    }
}

//-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
//{
//    //  Source Point
//    //    CLLocationCoordinate2D firstTapPosition = CLLocationCoordinate2DMake(43.669000,-79.698053);
//    //    CLLocationCoordinate2D firstTapPosition = CLLocationCoordinate2DMake(projectMapView.myLocation.coordinate.latitude,projectMapView.myLocation.coordinate.longitude);
//    CLLocationCoordinate2D firstTapPosition = CLLocationCoordinate2DMake( mapView_.myLocation.coordinate.latitude, mapView_.myLocation.coordinate.longitude);
//    
//    GMSMarker *firstTapMarker = [GMSMarker markerWithPosition:firstTapPosition];
//    firstTapMarker.map = mapView_;
//    [self.waypoints addObject:firstTapMarker];
//    
//    //    NSString *firstPositionString = [NSString stringWithFormat:@"%f,%f", 43.669000,-79.698053];
//    NSString *firstPositionString = [NSString stringWithFormat:@"%f,%f", mapView_.myLocation.coordinate.latitude,mapView_.myLocation.coordinate.longitude];
//    [self.waypointStrings addObject:firstPositionString];
//    
//    //  Destination Point
//    //    CLLocationCoordinate2D secondTapPosition = CLLocationCoordinate2DMake(-43.669000,-79.698053);
//    
//    CLLocationCoordinate2D secondTapPosition = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude);
//    GMSMarker *secondTapMarker = [GMSMarker markerWithPosition:secondTapPosition];
//    secondTapMarker.map = mapView_;
//    [self.waypoints addObject:secondTapMarker];
//    
//    //    NSString *secondPositionString = [NSString stringWithFormat:@"%f,%f", -43.669000,-79.698053];
//    NSString *secondPositionString = [NSString stringWithFormat:@"%f,%f", coordinate.latitude,coordinate.longitude];
//    [self.waypointStrings addObject:secondPositionString];
//    
//    NSLog(@"self.waypoints..%@",self.waypoints);
//    
//    if (self.waypoints.count > 1)
//    {
//        NSDictionary *query = @{ @"sensor" : @"false", @"waypoints" : self.waypointStrings };
//        MDDirectionService *mds = [[MDDirectionService alloc] init];
//        SEL selector = @selector(addDirections:);
//        [mds setDirectionsQuery:query withSelector:selector withDelegate:self];
//    }
//}

/*
-(void)addDirections:(NSDictionary *)json
{
    NSDictionary *routes = json[@"routes"][0];
    NSDictionary *route = routes[@"overview_polyline"];
    NSString *overview_route = route[@"points"];
    
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    [polyline setStrokeColor:[UIColor redColor]];
    [polyline setStrokeWidth:3.0f];
    polyline.map = mapView_;
}
*/
-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    //    [mapView clear];
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    NSLog(@"map became idle");
    //    [self placeMarkers];
}

#pragma mark - Table View Datasource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_eventsArray count];
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,22)];
//    tempView.backgroundColor=[UIColor colorWithRed:63.0/255.0 green:80.0/255.0 blue:161.0/255.0 alpha:1.0];
//    tempView.tag = section;
//    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,0,300,22)];
//    tempLabel.backgroundColor=[UIColor colorWithRed:63.0/255.0 green:80.0/255.0 blue:161.0/255.0 alpha:1.0];
//    tempLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
//    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0];
//    
//    tempLabel.text = [[_eventsArray allKeys] objectAtIndex:section];
//    [tempView addSubview:tempLabel];
//    return tempView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0.0);
    
    static NSString *CellIdentifier = @"AllEvents";
    UITableViewCell *cell;
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 11, 210, 20)];
    senderLabel.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
    senderLabel.text = [[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_name"];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"location_icon_small.png"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_location"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 32, 83, 20)];
    locationLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    locationLabel.attributedText = myString;
    locationLabel.textColor = [UIColor darkGrayColor];

    attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"time_icon_small"];
    attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_date"]]];
    [myString insertAttributedString:attachmentString atIndex:0];

    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 32, 130, 20)];
    timeLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    timeLabel.attributedText = myString;
    timeLabel.textColor = [UIColor darkGrayColor];
    
    UIImageView *eventImgView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 19, 25, 25)];

    NSString *capitalisedSentence = [[[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_activity"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                        withString:[[[[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_activity"] substringToIndex:1] capitalizedString]];
    
      NSLog(@"Imagessssssssssssssss.....%@",[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]);
    
    eventImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    
    eventImgView.contentMode = UIViewContentModeScaleToFill;

    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(22.5, 63, 275,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    [cell.contentView addSubview:senderLabel];
    [cell.contentView addSubview:locationLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:eventImgView];
    [cell.contentView addSubview:labelSeparator];
    return cell;
}

#pragma mark - Table View Delagate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_creator_id"] isEqualToString:[[AppDelegate GloabalInfo] valueForKey:@"user_id"]]) {
        CreateEventViewController *createEventViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
        createEventViewController.eventId = [[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_id"];
        [self.navigationController pushViewController:createEventViewController animated:YES];
    }
    else{
        EventDetailsViewController *eventDetailsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
        eventDetailsViewController.eventId = [[_eventsArray objectAtIndex:indexPath.row] valueForKey:@"event_id"];
        [self.navigationController pushViewController:eventDetailsViewController animated:YES];
    }
}

#pragma mark - Pull to refresh
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullToRefreshManager_ tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager
{
    pageNumber ++;
    
    NSLog(@"pageNumberpageNumber....%i",pageNumber);
    
    [self getAllEventsForPage:pageNumber];
//
//    if ([projectTypeString isEqualToString:@"active"])
//    {
//        requestString = [NSString stringWithFormat:@"getMyProjects.json?role_id=%@&page=%i",userTypeString,pageNumber];
//        [self getMoreProjects:requestString];
//    }else{
//        requestString = [NSString stringWithFormat:@"getAllMyArchivedProjects.json?role_id=%@&page=%i",userTypeString,pageNumber];
//        [self getMoreProjects:requestString];
//    }
}

-(void)stopReloading
{
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)loadTable
{
    reloads_++;
    [eventTableView reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [pullToRefreshManager_ relocatePullToRefreshView];
}

#pragma mark - Fetching Event Page Wise  

-(void)getAllEventsForPage : (int)page{
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    [postDict setObject:[NSString stringWithFormat:@"%i",page] forKey:@"page_num"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    [webserviceCall callWebserviceWithIdentifier:@"AllEvents" andArguments:postDict];
    webserviceCall.tag = 701;
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    
    [self stopReloading];
    
    if (Tag==701) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            
            if ([sender valueForKey:@"last_page"]) {
                [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
            }
            
            [_eventsArray addObjectsFromArray:[sender valueForKey:@"events"]];
            
            NSLog(@"_eventsArray_eventsArray_eventsArray.....%@",_eventsArray);
  
            featuredindex = [_eventsArray indexOfObjectPassingTest:
                               ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                               {
                                   return [[dict objectForKey:@"featured_event"] isEqualToString:@"1"];
                               }
                               ];
                NSLog(@"featuredindex...%d",(int)2147483647);
            
            if (featuredindex!=NSNotFound) {
                UILabel *lblEvent = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 25)];
                lblEvent.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
                lblEvent.text = [[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_name"];
                
                UILabel *lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 180, 25)];
                lblLocation.font = [UIFont fontWithName:@"Helvetica Light" size:13.0];
                lblLocation.textColor = [UIColor darkGrayColor];
                lblLocation.text = [[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_location"];
                
                UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 180, 25)];
                lblTime.font = [UIFont fontWithName:@"Helvetica Light" size:13.0];
                lblTime.textColor = [UIColor darkGrayColor];
                lblTime.text = [[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_date"];
                
                UIButton *featuredEventButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 199)];
                [featuredEventButton setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[_eventsArray objectAtIndex:featuredindex] valueForKey:@"event_image"]]]] forState:UIControlStateNormal];
                [featuredEventButton addTarget:self action:@selector(btnfeaturedEventPressed:) forControlEvents:UIControlEventTouchUpInside];
                featuredEventButton.contentMode = UIViewContentModeScaleAspectFill;
                
                UIButton *btnJoinNow = [[UIButton alloc] initWithFrame:CGRectMake(205, 10, 105, 31)];
                [btnJoinNow setImage:[UIImage imageNamed:@"btn_joinnow"] forState:UIControlStateNormal];
                [btnJoinNow addTarget:self action:@selector(btnJoinNowPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [eventScrollView addSubview:featuredEventButton];
                [eventScrollView addSubview:btnJoinNow];
                [eventScrollView addSubview:lblEvent];
                [eventScrollView addSubview:lblLocation];
                [eventScrollView addSubview:lblTime];

            }
                [eventTableView reloadData];
                [self intializeMap];
        }else{
            [pullToRefreshManager_ setPullToRefreshViewVisible:NO];
        }
    }
 }

-(void)webRequestFailed:(id)sender{
    NSLog(@"webRequestFailed");
    [self stopReloading];
}

#pragma mark - Memory Warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
