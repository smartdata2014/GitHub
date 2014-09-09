//
//  SearchViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<SWRevealViewControllerDelegate,WebServiceDelegate>
{
    IBOutlet UITableView *eventsTableView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITextField *txtSearch;
    CLLocationManager *locationManager;
}
-(IBAction)btnMenuPressed:(id)sender;
@property (nonatomic, strong) NSMutableArray *responseArr;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property(nonatomic,strong)IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSDictionary *responseDict;
-(IBAction)btnSegmentControlPressed:(id)sender;
-(IBAction)btnLogOutPressed:(id)sender;
@end

@implementation SearchViewController
bool searching=0;

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
//    _responseArr = [[NSMutableArray alloc] init];
    _searchArr = [[NSMutableArray alloc] init];
//  _responseArr = (NSMutableArray *)[[Helper ReadFromJSONStore:@"Search.json"]valueForKey:@"Events"];
    [self btnSegmentControlPressed:nil];
    NSLog(@"_responseArr..%@",_responseArr);
    
      // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];
}

#pragma mark - General Button Actions

-(IBAction)btnMenuPressed:(id)sender{
    [_searchBar resignFirstResponder];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
    
//    UINavigationController *navController =(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
//    [navController popViewControllerAnimated:YES];
}

#pragma mark - Segment Control Action

-(IBAction)btnSegmentControlPressed:(id)sender{
    NSLog(@"Segment..%i",[segmentControl selectedSegmentIndex]);
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    if ([segmentControl selectedSegmentIndex]==0) {
        [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
        [(UIButton *)[self.view viewWithTag:102]setSelected:NO];
        [postDict setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"current_time"];
        txtSearch.placeholder = @"Search by name";
    }
    else{
        [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
        [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
        [postDict setObject:[NSString stringWithFormat:@"%f%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude] forKey:@"lat_long"];
        txtSearch.placeholder = @"Search by location";
    }
    [webserviceCall callWebserviceWithIdentifier:@"AllEvents" andArguments:postDict];
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
    return searching ? [_searchArr count]:[_responseArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    UITableViewCell *cell;
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 11, 210, 20)];
    eventLabel.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
    eventLabel.text = [[searching?_searchArr:_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_name"];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"location_icon_small"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[searching?_searchArr:_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_location"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 32, 83, 20)];
    locationLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    
    locationLabel.attributedText = myString;
    locationLabel.textColor = [UIColor darkGrayColor];
    
    attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"time_icon_small"];
    attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[searching?_searchArr:_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_date"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 32, 130, 20)];
    timeLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    timeLabel.attributedText = myString;
    timeLabel.textColor = [UIColor darkGrayColor];
    
    UIImageView *eventImgView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 19, 25, 25)];
//    eventImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[[[[_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_activity"] lowercaseString] stringByReplacingOccurrencesOfString:@"" withString:@"_"]]];
    
    NSString *capitalisedSentence = [[[_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_activity"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                                                                         withString:[[[[_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_activity"] substringToIndex:1] capitalizedString]];
    
    
    
    eventImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];

    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(22.5, 63, 275,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    [cell.contentView addSubview:eventLabel];
    [cell.contentView addSubview:locationLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:eventImgView];
    [cell.contentView addSubview:labelSeparator];
    
    return cell;
}

#pragma mark - Table View Delagate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EventDetailsViewController *eventDetailsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
    eventDetailsViewController.eventId = [[searching?_searchArr:_responseArr objectAtIndex:indexPath.row] valueForKey:@"event_id"];
    [self.navigationController pushViewController:eventDetailsViewController animated:YES];
}

//#pragma mark - Search Bar Delegate Methods
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    NSLog(@"searchText..%@",searchText);
//    searching = searchText.length ?1:0;
//    NSPredicate *predicate;
//    predicate = [NSPredicate predicateWithFormat:@"SELF.event_name beginswith[cd] %@",searchText];
//    NSArray *tempArray = [_responseArr filteredArrayUsingPredicate:predicate];
//    _searchArr = [NSMutableArray arrayWithArray:tempArray];
//    [eventsTableView reloadData];
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    searching = 0;
//    [searchBar resignFirstResponder];
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
//    searching = 0;
//    [searchBar resignFirstResponder];
//}

#pragma mark - Textfield Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"searchText..%@",string);
   NSString *searchStr;
    
    if (string.length == 0) {
        searchStr = [textField.text substringWithRange: NSMakeRange (0, textField.text.length-1)];
    }
    else{
        searchStr = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    
    searching = searchStr.length ?1:0;
    NSPredicate *predicate;
    
    if ([segmentControl selectedSegmentIndex]==0) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.event_name beginswith[cd] %@",searchStr];
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"SELF.event_location beginswith[cd] %@",searchStr];
    }
    
    NSArray *tempArray = [_responseArr filteredArrayUsingPredicate:predicate];
    _searchArr = [NSMutableArray arrayWithArray:tempArray];
    [eventsTableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    textField.text = @"";
     [textField resignFirstResponder];
     searching = 0;
    [eventsTableView reloadData];
    return YES;
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    _responseArr = [[NSMutableArray alloc] init];
    [_responseArr addObjectsFromArray:[sender valueForKey:@"events"]];
    [eventsTableView reloadData];
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
