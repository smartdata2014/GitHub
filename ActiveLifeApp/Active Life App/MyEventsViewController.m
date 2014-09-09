//
//  AcivitiesViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "MyEventsViewController.h"

@interface MyEventsViewController ()<SWRevealViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,WebServiceDelegate>
{
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITableView *tblActivities;
}
-(IBAction)btnMenuPressed:(id)sender;
-(IBAction)btnLogOutPressed:(id)sender;
-(IBAction)SegmentControlActions:(id)sender;

@property (nonatomic, strong) NSDictionary *responseDict;
@property (nonatomic, strong) NSMutableDictionary *eventsDict;
@property (nonatomic, strong) NSMutableArray *monthArray;

@end

@implementation MyEventsViewController

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
    self.navigationController.navigationBarHidden = YES;

    _eventsDict = [[NSMutableDictionary alloc] init];
    _monthArray = [[NSMutableArray alloc] init];
//    _responseDict = (NSDictionary *)[Helper ReadFromJSONStore:@"Activities.json"];
    

    NSLog(@"responseDict..%@",_responseDict);
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self callWeserviceToFetchMyEvents];
}

#pragma mark - Button Actions

-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

-(IBAction)SegmentControlActions:(id)sender{
    
    [self callWeserviceToFetchMyEvents];
    NSLog(@"Segment..%i",[segmentControl selectedSegmentIndex]);
}

#pragma mark - Table View Datasource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 78.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_monthArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,32)];
//    tempView.backgroundColor=[UIColor colorWithRed:63.0/255.0 green:80.0/255.0 blue:161.0/255.0 alpha:1.0];
//    
//    tempView.tag = section;
//    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(20,0,300,32)];
//    tempLabel.backgroundColor=[UIColor colorWithRed:63.0/255.0 green:80.0/255.0 blue:161.0/255.0 alpha:1.0];
//    tempLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
//    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0];
//    
//    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HeaderTapped:)];
//    [tempView addGestureRecognizer:headerTapped];
//    BOOL manyCells = [[_ArrayBool objectAtIndex:section] boolValue];
//    
//    UIImageView *upDownArrow  = [[UIImageView alloc] initWithImage:manyCells ? [UIImage imageNamed:@"downarrow"] : [UIImage imageNamed:@"rightarrow"]];
//    upDownArrow.frame = CGRectMake(self.view.frame.size.width-30,10,13,13);
//    
//    int i=0;
//    for (id key in [_ExerciseDict allKeys]) {
//        NSLog(@"%@ - %@",key,[_ExerciseDict objectForKey:key]);
//        if(section == i){
//            tempLabel.text = key;
//        }
//        [tempView addSubview:tempLabel];
//        i++;
//    }
//    [tempView addSubview:upDownArrow];
//    return tempView;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 33.0)];
    customView.backgroundColor = [UIColor whiteColor];
    
    UILabel * headerNameLabel = [[UILabel alloc] init];
    
    if (section==0) {
        headerNameLabel.textColor = [UIColor colorWithRed:19/255.f green:182/255.f blue:243/255.f alpha:1.0];
    }
    else{
        headerNameLabel.textColor = [UIColor darkGrayColor];
    }
    
    headerNameLabel.backgroundColor=[UIColor clearColor];
    headerNameLabel.font = [UIFont fontWithName:@"Helvetica Oblique" size:16.0];
    headerNameLabel.frame = CGRectMake(20, 0, 150, 33.0);
  //  headerNameLabel.backgroundColor=[UIColor lightGrayColor];
    headerNameLabel.text = [_monthArray objectAtIndex:section];
    [customView addSubview:headerNameLabel];
     return customView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_eventsDict valueForKey:[_monthArray objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityCells";
    UITableViewCell *cell;
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd, hh:mm a"];
    NSDate *eventDate= [dateFormatter dateFromString:[[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_date"]];
    
    NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc] init];
    [shortDateFormatter setDateFormat:@"EE - MM/dd"];
    
    NSString *dateDay = [shortDateFormatter stringFromDate:eventDate];
    
    UILabel *dateLbl=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 20)];
    dateLbl.text = dateDay;
    dateLbl.textAlignment=NSTextAlignmentCenter;
    dateLbl.font=[UIFont fontWithName:@"Helvetica Neue" size:12];

    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320,1)];
    
    if (indexPath.section == 0) {
        dateLbl.textColor=[UIColor whiteColor];
        dateLbl.backgroundColor=[UIColor colorWithRed:19/255.f green:182/255.f blue:243/255.f alpha:1.0];
        labelSeparator.backgroundColor = [UIColor colorWithRed:19/255.f green:182/255.f blue:243/255.f alpha:1.0];
    }
    else{
        dateLbl.textColor=[UIColor darkGrayColor];
        dateLbl.backgroundColor=[UIColor colorWithWhite:0.8 alpha:1.0];
        labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *EventName = [[UILabel alloc] initWithFrame:CGRectMake(30, 26, 220, 20)];
    EventName.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    EventName.text = [[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_name"];

    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"location_icon_small.png"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_location"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 45, 83, 20)];
    locationLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    locationLabel.attributedText = myString;
    locationLabel.textColor = [UIColor darkGrayColor];
    
    attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"time_icon_small"];
    attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_date"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 45, 130, 20)];
    timeLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    timeLabel.attributedText = myString;
    timeLabel.textColor = [UIColor darkGrayColor];
    
    UIImageView *eventImgView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 27, 25, 25)];
    
    NSString *capitalisedSentence = [[[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_activity"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                                                        withString:[[[[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_activity"] substringToIndex:1] capitalizedString]];
    
    NSLog(@"Imagessssssssssssssss.....%@",[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]);
    
    eventImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    
    eventImgView.contentMode = UIViewContentModeScaleToFill;
    
    
      [cell.contentView addSubview:labelSeparator];
      [cell.contentView addSubview:eventImgView];
      [cell.contentView addSubview:locationLabel];
      [cell.contentView addSubview:timeLabel];
      [cell.contentView addSubview:dateLbl];
      [cell.contentView addSubview:EventName];
    return cell;
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EventDetailsViewController *eventDetailsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
    eventDetailsViewController.eventId = [[[_eventsDict valueForKey:[_monthArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"event_id"];
    if ([segmentControl selectedSegmentIndex]==0) {
        eventDetailsViewController.joined = @"YES";
    }
    [self.navigationController pushViewController:eventDetailsViewController animated:YES];
}

#pragma mark - Call Webservice to Fetch My Events

-(void)callWeserviceToFetchMyEvents{
    
    _responseDict = [[NSDictionary alloc] init];
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    [webserviceCall callWebserviceWithIdentifier:@"MyEvents" andArguments:postDict];
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
//    _responseDict = (NSDictionary *)[Helper ReadFromJSONStore:@"Activities.json"];
    if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
        _responseDict = [sender valueForKey:@"events"];
        [_monthArray removeAllObjects];
        if ([segmentControl selectedSegmentIndex]==0) {
            [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
            [(UIButton *)[self.view viewWithTag:102]setSelected:NO];
            _eventsDict = [_responseDict valueForKey:@"attending_events"];
        }
        else{
            [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
            [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
            _eventsDict = [_responseDict valueForKey:@"invited_events"];
        }
        [_monthArray addObjectsFromArray:[_eventsDict allKeys]];
        [tblActivities reloadData];
    }
}

-(void)webRequestFailed:(id)sender{
    NSLog(@"webRequestFailed");    
}

#pragma mark - Memory Warning

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
