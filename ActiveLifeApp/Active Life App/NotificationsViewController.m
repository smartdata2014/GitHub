//
//  NotificationsViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "NotificationsViewController.h"

@interface NotificationsViewController (){
    IBOutlet UITableView *notifyTableView;
}

-(IBAction)btnMenuPressed:(id)sender;
-(IBAction)btnLogOutPressed:(id)sender;
-(void)btnRemoveNotificationPressed:(id)sender;
@property (nonatomic, strong) NSMutableArray *arrEvents;

@end

@implementation NotificationsViewController

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
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"NotificationsArray..%@",[AppDelegate NotificationsArray]);
    _arrEvents = [[NSMutableArray alloc] init];
    if ([AppDelegate NotificationsArray].count!=0) {
        [_arrEvents addObjectsFromArray:[AppDelegate NotificationsArray]];
    }
    else{
        [AlertView showAlertwithTitle:@"Active Life App" message:@"No notifications available."];
    }
    [notifyTableView reloadData];    
}

#pragma mark - General Button Actions

-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

#pragma mark - Table View Datasource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 94;
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
    static NSString *CellIdentifier = @"NotificationCells";
    UITableViewCell *cell;
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *labelNotification = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 220, 45)];
    labelNotification.numberOfLines = 3;
    labelNotification.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    labelNotification.textColor = [UIColor grayColor];
    labelNotification.text = [[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"alert"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss zz"];

    NSDate *date1 = [format dateFromString:[NSString stringWithFormat:@"%@",[[_arrEvents objectAtIndex:indexPath.row] valueForKey:@"RecievedDate"]]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                               fromDate:date1
                                                 toDate:[NSDate date]
                                                options:0];
    
    NSLog(@"Difference in date components: %@  %i/%i/%i/%i",date1,components.day,components.hour,components.minute,components.second);
    
    NSString *labelTimeStr;
    
    if (components.day==1) {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        labelTimeStr = [NSString stringWithFormat:@"Yesterday at %@",[timeFormatter stringFromDate:date1]];
    }
    else if(components.day == 0){
        if (components.hour>0) {
            labelTimeStr = [NSString stringWithFormat:@"%i hours ago",components.hour];
        }
        else if (components.minute>0){
            labelTimeStr = [NSString stringWithFormat:@"%i minutes ago",components.minute];
        }
        else if (components.second>0){
            labelTimeStr = [NSString stringWithFormat:@"%i seconds ago",components.second];
        }
    }
    else{
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
        [newDateFormatter setDateFormat:@"dd MMMM 'at' HH:mm"];
        labelTimeStr = [NSString stringWithFormat:@"%@",[newDateFormatter stringFromDate:date1]];
    }
    
    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(75, 60, 145, 15)];
    labelTime.numberOfLines = 1;
    labelTime.font = [UIFont fontWithName:@"Helvetica Light" size:9.0];
    labelTime.textColor = [UIColor grayColor];
    labelTime.text = labelTimeStr;
    
    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(20,93,280,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 25, 44, 44)];
    [imageView setImage:[UIImage imageNamed:@"Basketball_icon"]];
    
    UIButton *btnCrossMark = [[UIButton alloc] initWithFrame:CGRectMake(275, 63, 30, 30)];
    [btnCrossMark addTarget:self action:@selector(btnRemoveNotificationPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnCrossMark setImage:[UIImage imageNamed:@"crossmark_icon"] forState:UIControlStateNormal];
    btnCrossMark.tag = 100 + indexPath.row;
    
    [cell.contentView addSubview:labelTime];
    [cell.contentView addSubview:btnCrossMark];
    [cell.contentView addSubview:labelNotification];
    [cell.contentView addSubview:labelSeparator];
    [cell.contentView addSubview:imageView];
    return cell;
}

#pragma mark - Deleting The Table View Cell

-(void)btnRemoveNotificationPressed:(UIButton *)sender{
    NSLog(@"btnRemoveNotificationPressed");
   [[AppDelegate NotificationsArray] removeObjectAtIndex:sender.tag - 100];
    [self viewWillAppear:YES];
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
