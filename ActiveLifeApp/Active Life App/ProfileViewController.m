//
//  ProfileViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()<SWRevealViewControllerDelegate,UIScrollViewDelegate,WebServiceDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    IBOutlet UILabel *lblName, *lblPlace, *lblInterestTags, *lblAboutMe;
    IBOutlet UIImageView *imgProfilePic;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITableView *eventTableView;
    IBOutlet UIScrollView *scrollView;

}
-(IBAction)btnLogOutPressed:(id)sender;
-(IBAction)btnMenuPressed:(id)sender;
-(IBAction)btnGetNextIcons:(id)sender;
-(IBAction)btnAddProfileImage:(id)sender;
-(IBAction)saveProfileImage:(id)sender;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSDictionary *responseDict;
@property (nonatomic, strong) NSMutableArray *arrEvents;

@end

@implementation ProfileViewController

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
//    _responseDict = [[NSDictionary alloc] init];
//    _arrEvents = [[NSMutableArray alloc] init];
//    _responseDict = (NSDictionary *)[Helper ReadFromJSONStore:@"Profile.json"];
//    
//    //  lblName.text = [_responseDict valueForKey:@"Name"];
//    //  lblPlace.text = [_responseDict valueForKey:@"Location"];
//    //  lblInterestTags.text = [_responseDict valueForKey:@"Interest Tags"];
//    //  lblAboutMe.text = [_responseDict valueForKey:@"About me"];
//    _arrEvents = [_responseDict valueForKey:@"Upcoming Events"];
    
//    NSString *fbuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"]
    
    [(UIButton *)[self.view viewWithTag:301] setHidden:NO];
    [(UIButton *)[self.view viewWithTag:302] setHidden:YES];

//    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *postDict =[[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.tag = 401;
    webserviceCall.delegate = self;
    [webserviceCall callWebserviceWithIdentifier:@"UserProfile" andArguments:postDict];
    
    //    scrollView.contentSize = CGSizeMake(800,100);
    //    [scrollView scrollRectToVisible:CGRectMake(290, 145, 145, 100) animated:YES];
    // Do any additional setup after loading the view.
}

#pragma mark - General Button Actions

-(IBAction)btnGetNextIcons:(UIButton *)sender{
    NSLog(@"sender.tag....%i",[sender tag]);
    [scrollView setContentOffset:CGPointMake(146*([sender tag]-99), 0) animated:YES];
}

-(IBAction)btnGetPreviousIcons:(UIButton *)sender
{
    NSLog(@"sender.tag....%i",[sender tag]);
    // [scrollView setContentOffset:CGPointMake(140*([sender tag]-100), 0) animated:YES];
//    if (([sender tag]-100) > 1)
//    {
        [scrollView setContentOffset:CGPointMake(146*([sender tag]-99)-146, 0) animated:YES];
//    }
//    else
//    {
//        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    }
}


-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
    
//    UINavigationController *navController =(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
//    [navController popViewControllerAnimated:YES];
}

-(IBAction)SegmentControlActions:(id)sender{
    NSLog(@"Segment..%i",[segmentControl selectedSegmentIndex]);
    if ([segmentControl selectedSegmentIndex]==0) {
        [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
        [(UIButton *)[self.view viewWithTag:102]setSelected:NO];
        _arrEvents = [_responseDict valueForKey:@"upcomming_events"];
    }
    else{
        [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
        [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
        _arrEvents = [_responseDict valueForKey:@"attended_events"];
    }
    [eventTableView reloadData];
}

#pragma mark - Create Activity List ScrollView

-(void)createActivityScrollView :(NSArray *)array{
    
    NSLog(@"array..%@",array);
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(164, 175, 146, 86);
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
 
    int totalCount = [array count];
    NSMutableDictionary *viewCountDict=[[NSMutableDictionary alloc] init];
    
    if (totalCount>=8) {
        
        int localValue=totalCount;
        
        for (int k=0; k<2; k++) {
            if (k==0) {
                if (totalCount==8) {
                    localValue-=8;
                    [viewCountDict setObject:@"8" forKey:[NSString stringWithFormat:@"view%i",k]];
                }else{
                    localValue-=7;
                    [viewCountDict setObject:@"7" forKey:[NSString stringWithFormat:@"view%i",k]];
                }
            }else{
                int value=localValue/6;
                for (int i=0; i<value; i++) {
                    [viewCountDict setObject:@"6" forKey:[NSString stringWithFormat:@"view%i",k]];
                    k+=1;
                }
                int value2=localValue%6;
                if (value2==1) {
                    [viewCountDict setObject:@"7" forKey:[NSString stringWithFormat:@"view%i",k-1]];
                    k+=1;
                    
                }else if(value2>0){
                    [viewCountDict setObject:[NSString stringWithFormat:@"%i",value2] forKey:[NSString stringWithFormat:@"view%i",k]];
                }
            }
        }
        
    }else{
        [viewCountDict setObject:[NSString stringWithFormat:@"%i",totalCount] forKey:@"view0"];
    }

    NSLog(@"%@",viewCountDict);
    int arrayinc = [[viewCountDict objectForKey:[NSString stringWithFormat:@"view0"]] integerValue];

    for (int viewCount=0; viewCount<[viewCountDict count]; viewCount++) {
        if (viewCount==0) {
            int k=[[viewCountDict objectForKey:@"view0"] intValue];
            for (int j=0; j<k; j++) {
                if (j<4)
                {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(33*(j)+8+146*viewCount ,13, 25, 25)];
                    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[[array objectAtIndex:j] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
                    [scrollView addSubview:imageView];
                }
                else if (j>=4){
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(33*(j-4)+8+146*viewCount ,48, 25, 25)];
                    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[[array objectAtIndex:j] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
                    [scrollView addSubview:imageView];
                }
                
            }
            if ([viewCountDict count]>1) {
                UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(33*3+8+146*viewCount ,48, 25, 25)];
                [btnNext addTarget:self action:@selector(btnGetNextIcons:) forControlEvents:UIControlEventTouchUpInside];
                [btnNext setBackgroundImage:[UIImage imageNamed:@"more_arrow_icon.png"] forState:UIControlStateNormal];
                btnNext.tag = 100 + (viewCount);
                [scrollView addSubview:btnNext];
            }
        }else{
            int k=[[viewCountDict objectForKey:[NSString stringWithFormat:@"view%i",viewCount]] intValue];
            
            for (int j=0; j<k; j++) {

                if (j<3)
                {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(33*(j+1)+8+146*viewCount ,13, 25, 25)];
                    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[[array objectAtIndex:j+arrayinc] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
                    [scrollView addSubview:imageView];
                }
                else if (j>=3){
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(33*(j-3)+8+146*viewCount ,48, 25, 25)];
                    [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[[array objectAtIndex:j+arrayinc] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
                    [scrollView addSubview:imageView];
                }

            }
            arrayinc += k;

            UIButton *btnPrevious=[[UIButton alloc]initWithFrame:CGRectMake(33*4+22+146*(viewCount-1), 13, 25, 25)];
            [btnPrevious addTarget:self action:@selector(btnGetPreviousIcons:) forControlEvents:UIControlEventTouchUpInside];
            [btnPrevious setBackgroundImage:[UIImage imageNamed:@"less_arrow_icon.png"] forState:UIControlStateNormal];
            btnPrevious.tag = 100 + (viewCount-1);
            [scrollView addSubview:btnPrevious];
            
            if (k==6) {
                UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(33*3+8+146*viewCount ,48, 25, 25)];
                [btnNext addTarget:self action:@selector(btnGetNextIcons:) forControlEvents:UIControlEventTouchUpInside];
                [btnNext setBackgroundImage:[UIImage imageNamed:@"more_arrow_icon.png"] forState:UIControlStateNormal];
                btnNext.tag = 100 + (viewCount);
                [scrollView addSubview:btnNext];
                
            }
        }
        scrollView.contentSize = CGSizeMake(146*(viewCount+1),86);
    }
}

#pragma mark - Selecting Profile Image Methods

-(IBAction)btnAddProfileImage:(UIButton *)sender{
//    UIButton *button = (UIButton *)[self.view viewWithTag:111];

    NSString *fbuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    if ([fbuid isEqualToString:@""]) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                  delegate: self
                                         cancelButtonTitle: @"Cancel"
                                    destructiveButtonTitle: nil
                                         otherButtonTitles: @"Take a new image", @"Choose from existing", nil];
    }
    else{
        _actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                  delegate: self
                                         cancelButtonTitle: @"Cancel"
                                    destructiveButtonTitle: nil
                                         otherButtonTitles: @"Fetch photo from facebook",@"Take a new image", @"Choose from existing", nil];

    }
    [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];

    [_actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //        if (actionSheet.tag == 401) {
    
    NSString *fbuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    if (![fbuid isEqualToString:@""]) {
    
        switch (buttonIndex) {
            case 0:
                [self fetchProfilePicFromFacebook];
                break;
            case 1:
                [self choosePhotoFromExistingImages];
                break;
            case 2:
                [self choosePhotoFromExistingImages];
            default:
                [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                break;
        }

    }
    else{
        switch (buttonIndex) {
            case 0:
                [self takeNewPhotoFromCamera];
                break;
            case 1:
                [self choosePhotoFromExistingImages];
            default:

                [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                break;
        }
    }
}

- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [(UIButton *)[self.view viewWithTag:301] setHidden:YES];
    [(UIButton *)[self.view viewWithTag:302] setHidden:NO];
    
    NSLog(@"info..%@",info);
     UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    imgProfilePic.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)saveProfileImage:(id)sender{
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.tag = 402;
    webserviceCall.delegate = self;
    NSData *imageData = UIImageJPEGRepresentation(imgProfilePic.image, 0.2);
    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:base64 forKey:@"image"];
    [postDict setObject:[[AppDelegate GloabalInfo]valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo]valueForKey:@"user_id"],KAPI_KEY,[postDict valueForKey:@"timestamp"]]] forKey:@"signature"];
    
    [webserviceCall callWebserviceWithIdentifier:@"AddProfileImage" andArguments:postDict];
}

-(void)fetchProfilePicFromFacebook{

//    AppDelegate *appdelegate  = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appdelegate addChargementLoader];

    
    [(UIButton *)[self.view viewWithTag:301] setHidden:YES];
    [(UIButton *)[self.view viewWithTag:302] setHidden:NO];

    NSString *fbuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"];
    imgProfilePic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",fbuid]]]];
//    [appdelegate removeChargementLoader];
}

#pragma mark - Table View Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0.0);
    static NSString *CellIdentifier = @"ProfileCells";
    UITableViewCell *cell;                                               
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 11, 150, 20)];
    senderLabel.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
    senderLabel.text = [[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"event_name"];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"location_icon_small.png"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"event_location"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 32, 83, 20)];
    locationLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    locationLabel.attributedText = myString;
    locationLabel.textColor = [UIColor darkGrayColor];
    
    attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"time_icon_small"];
    attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"event_date"]]];
    [myString insertAttributedString:attachmentString atIndex:0];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 32, 130, 20)];
    timeLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    timeLabel.attributedText = myString;
    timeLabel.textColor = [UIColor darkGrayColor];
    
    UIImageView *eventImgView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 19, 25, 25)];
    
    NSString *capitalisedSentence = [[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"event_activity"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                                                        withString:[[[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"event_activity"] substringToIndex:1] capitalizedString]];
    
    NSLog(@"Imagessssssssssssssss.....%@",[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]);
    
    eventImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_icon",[capitalisedSentence  stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    
    eventImgView.contentMode = UIViewContentModeScaleToFill;
    [cell.contentView addSubview:eventImgView];
    
    
    
    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(22.5, 63, 275,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    [cell.contentView addSubview:senderLabel];
    [cell.contentView addSubview:locationLabel];
    [cell.contentView addSubview:timeLabel];
    [cell.contentView addSubview:eventImgView];
    [cell.contentView addSubview:labelSeparator];
    
    return cell;
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{

    if (Tag == 401) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            _responseDict = (NSDictionary *)sender;
            lblName.text = [_responseDict valueForKey:@"username"];
            lblPlace.text = [_responseDict valueForKey:@"user_location"];
            lblInterestTags.text = [_responseDict valueForKey:@"interest_tags"];
            _arrEvents = [_responseDict valueForKey:@"upcomming_events"];
            
            if ([[_responseDict valueForKey:@"profile_picture"] isEqualToString:@""]) {
                imgProfilePic.image = [UIImage imageNamed:@"No_image_available"];

                [(UIButton *)[self.view viewWithTag:800] setTitle:@"Add Image" forState:UIControlStateNormal];
            }
            else{
                imgProfilePic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_responseDict valueForKey:@"profile_picture"]]]];
                
                [(UIButton *)[self.view viewWithTag:800] setTitle:@"Edit Image" forState:UIControlStateNormal];
            }
            
//            if (![[_responseDict valueForKey:@"profile_picture"] isEqualToString:@""]) {
//            }
//            else{
//                imgProfilePic.image = [UIImage imageNamed:@"No_image_available"];
//            }
            
            
            UIImageView *locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(168, 91, 12, 16)];
            locationIcon.image = [UIImage imageNamed:@"location_icon"];
            [self.view addSubview:locationIcon];
            
            [self createActivityScrollView:[[_responseDict valueForKey:@"interest_tags"]componentsSeparatedByString:@", "]];
            [eventTableView reloadData];
        }
    }
    else if (Tag == 402){
        
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [AlertView showAlertwithTitle:@"Active Life App" message:@"Your profile picture has been changed successfully."];
        }
    }
    else{
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [(UIButton *)[self.view viewWithTag:301] setHidden:NO];
            [(UIButton *)[self.view viewWithTag:302] setHidden:YES];
        }
    }
    [self SegmentControlActions:nil];
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
