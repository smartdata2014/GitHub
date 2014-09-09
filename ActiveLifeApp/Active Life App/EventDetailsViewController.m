//
//  EventDetailsViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()<SWRevealViewControllerDelegate,WebServiceDelegate>{
    IBOutlet UILabel *lblHost, *lblDetails;
    IBOutlet UIScrollView *scrollView, *reportScrollView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITableView *friendsTableView;
    IBOutlet UIView *reportAbuseView;
    IBOutlet UITextView *txtReportDesc;
}

-(IBAction)btnBackPressed:(id)sender;
-(IBAction)btnReportAbusePressed:(id)sender;
-(IBAction)SegmentControlActions:(id)sender;
-(IBAction)reportAbuseButtonActions:(UIButton *)sender;
-(IBAction)reportAbuseRadioButtonActions:(UIButton *)sender;

@property (nonatomic, strong) NSDictionary *responseDict;
@property (nonatomic, strong) NSMutableArray *arrEvents;
@end

@implementation EventDetailsViewController
@synthesize eventId,joined;

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
    _arrEvents = [[NSMutableArray alloc] init];
    reportScrollView.contentSize = CGSizeMake(320, 600);
    txtReportDesc.text = @"Description";
    txtReportDesc.textColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    txtReportDesc.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0].CGColor;
    txtReportDesc.layer.borderWidth = 1.0;
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:eventId forKey:@"event_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",eventId,KAPI_KEY,[postDict valueForKey:@"timestamp"]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    [webserviceCall callWebserviceWithIdentifier:@"EventDetails" andArguments:postDict];
    webserviceCall.tag = 702;

    _responseDict = [[NSDictionary alloc] init];
    // Do any additional setup after loading the view.
}

#pragma mark - General Button Actions

-(IBAction)btnBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnReportAbusePressed:(id)sender{
    NSLog(@"Mark as spam");
    ((UIButton *)[self.view viewWithTag:201]).selected = NO;
    ((UIButton *)[self.view viewWithTag:202]).selected = NO;
    ((UIButton *)[self.view viewWithTag:11]).enabled = NO;
    ((UIButton *)[self.view viewWithTag:11]).alpha = 0.5;
    txtReportDesc.text = @"Description";
    reportAbuseView.hidden = NO;
    [txtReportDesc becomeFirstResponder];
}

-(IBAction)SegmentControlActions:(id)sender{
    
    NSLog(@"Segment..%i",[segmentControl selectedSegmentIndex]);
    if ([segmentControl selectedSegmentIndex]==0) {
        [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
        [(UIButton *)[self.view viewWithTag:102]setSelected:NO];
        _arrEvents = [[_responseDict valueForKey:@"friends"] valueForKey:@"Attending"];
    }
    else{
        [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
        [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
        _arrEvents = [[_responseDict valueForKey:@"friends"] valueForKey:@"Invited"];
    }
    [friendsTableView reloadData];
}

-(void)btnJoinNowPressed:(id)sender{
    NSLog(@"Join Now");
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:[[_responseDict valueForKey:@"event_details"] valueForKey:@"event_id"]  forKey:@"event_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],[[_responseDict valueForKey:@"event_details"] valueForKey:@"event_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 701;
    [webserviceCall callWebserviceWithIdentifier:@"JoinNow" andArguments:postDict];
}

#pragma mark Report Abuse Button Actions

-(IBAction)reportAbuseButtonActions:(UIButton *)sender{
    if ([sender tag]==10) {
        NSLog(@"Cancel");
        [reportScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [txtReportDesc resignFirstResponder];
        reportAbuseView.hidden = YES;
    }
    else if ([sender tag]==11){
        NSLog(@"Submit");
        NSMutableDictionary *postReportDict = [[NSMutableDictionary alloc] init];
        [postReportDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
        [postReportDict setObject:eventId forKey:@"event_id"];
        [postReportDict setObject:((UIButton *)[self.view viewWithTag:201]).selected?@"1":@"0" forKey:@"type"];
        if ([txtReportDesc.text isEqualToString:@"Description"]) {
            [postReportDict setObject:@"" forKey:@"comment"];
        }
        else{
            [postReportDict setObject:txtReportDesc.text forKey:@"comment"];
        }
        [postReportDict setObject:KAPI_KEY forKey:@"api_key"];
        [postReportDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
        [postReportDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],eventId,KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
        
        WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
        webserviceCall.delegate = self;
        webserviceCall.tag = 703;
        [webserviceCall callWebserviceWithIdentifier:@"SetAbuseReport" andArguments:postReportDict];
    }
}

-(IBAction)reportAbuseRadioButtonActions:(UIButton *)sender{
    ((UIButton *)[self.view viewWithTag:11]).enabled = YES;
    ((UIButton *)[self.view viewWithTag:11]).alpha = 1.0;
    
    if ([sender tag] == 201) {
        ((UIButton *)[self.view viewWithTag:201]).selected = YES;
        ((UIButton *)[self.view viewWithTag:202]).selected = NO;
    }
    else{
        ((UIButton *)[self.view viewWithTag:201]).selected = NO;
        ((UIButton *)[self.view viewWithTag:202]).selected = YES;
    }
}

#pragma mark Text View delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    [reportScrollView setContentOffset:CGPointMake(0, 50) animated:YES];
    
    if ([textView.text isEqualToString:@"Description"]) {
        txtReportDesc.textColor = [UIColor darkGrayColor];
        txtReportDesc.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [reportScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [txtReportDesc resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        txtReportDesc.text = @"Description";
        txtReportDesc.textColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    }
}

#pragma mark - Table View Datasource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventDetailCell";
    UITableViewCell *cell;
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 165, 20)];
    labelName.font = [UIFont fontWithName:@"Helvetica Light" size:14.0];
    labelName.text = [[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"friend_name"];
    [cell.contentView addSubview:labelName];
    
 /*
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"location_icon_small.png"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"country"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 32, 165, 20)];
    locationLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    locationLabel.attributedText = myString;
    locationLabel.textColor = [UIColor darkGrayColor];
    [cell.contentView addSubview:locationLabel];
*/
    
    UIImageView *friendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 34, 34)];
    
    friendImageView.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0].CGColor;
    friendImageView.layer.borderWidth = 1.0;
    friendImageView.layer.cornerRadius = friendImageView.frame.size.height/2;
    friendImageView.layer.masksToBounds = YES;
    
    NSURL *url = [NSURL URLWithString:[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]];
    
    [friendImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"No_image_available.png"]];
    [cell.contentView addSubview:friendImageView];

    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(20,49,280,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [cell.contentView addSubview:labelSeparator];
    
    return cell;
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    
    if (Tag == 701) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [AlertView showAlertwithTitle:@"Active Life App" message:[sender valueForKey:@"message"]];
        }
    }
    else if (Tag == 702) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            _responseDict = (NSDictionary *) sender;
            
            _arrEvents = [[_responseDict valueForKey:@"friends"] valueForKey:@"Attending"];
            
            lblDetails.text = [[_responseDict valueForKey:@"event_details"] valueForKey:@"event_description"];
            
            NSLog(@"responseDict..%@",_responseDict);
            
            UILabel *lblEvent = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 25)];
            lblEvent.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
            lblEvent.text = [[_responseDict valueForKey:@"event_details"] valueForKey:@"event_name"];
            
            UILabel *lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 180, 25)];
            lblLocation.font = [UIFont fontWithName:@"Helvetica Light" size:13.0];
            lblLocation.textColor = [UIColor darkGrayColor];
            lblLocation.text = [[_responseDict valueForKey:@"event_details"] valueForKey:@"event_location"];
            
            UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 180, 25)];
            lblTime.font = [UIFont fontWithName:@"Helvetica Light" size:13.0];
            lblTime.textColor = [UIColor darkGrayColor];
            lblTime.text = [[_responseDict valueForKey:@"event_details"] valueForKey:@"event_date"];
            
            UIButton *btnJoinNow = [[UIButton alloc] initWithFrame:CGRectMake(205, 10, 105, 31)];
            btnJoinNow.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0];
            
            if ([joined isEqualToString:@"YES"]) {
                [btnJoinNow setTitle:@"UNJOIN NOW" forState:UIControlStateNormal];
            }
            else{
                [btnJoinNow setTitle:@"JOIN NOW" forState:UIControlStateNormal];
            }
            
            btnJoinNow.titleLabel.textColor = [UIColor whiteColor];
            btnJoinNow.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:11.0];
            
            [btnJoinNow addTarget:self action:@selector(btnJoinNowPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView *eventsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 199)];
            [eventsImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[_responseDict valueForKey:@"event_details"] valueForKey:@"event_image"]]]]];
            
            [scrollView addSubview:eventsImageView];
            [scrollView addSubview:lblEvent];
            [scrollView addSubview:lblLocation];
            [scrollView addSubview:lblTime];
            [scrollView addSubview:btnJoinNow];
            
            lblHost.text = [NSString stringWithFormat:@"   hosted by\n   %@",[[_responseDict valueForKey:@"event_details"] valueForKey:@"event_host"]];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: lblHost.attributedText];
            [text addAttribute: NSFontAttributeName value: [UIFont italicSystemFontOfSize:16.0] range: NSMakeRange(0, [lblHost.text rangeOfString:@"\n"].location+1)];
            [lblHost setAttributedText: text];
            
            [self SegmentControlActions:nil];
        }
    }
    else if (Tag==703){
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [AlertView showAlertwithTitle:@"Active Life App" message:[sender valueForKey:@"message"]];
            [txtReportDesc resignFirstResponder];
            reportAbuseView.hidden = YES;
        }
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
