//
//  MenuViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "MenuViewController.h"
#import "FriendsListViewController.h"

@interface MenuViewController ()<WebServiceDelegate>
{
    NSArray *menuArray;
}
@end

@implementation MenuViewController

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
    menuArray = [[NSMutableArray alloc] initWithObjects:@"All Events",@"Search",@"Notifications",@"My Events",@"My Friends",@"Friend Requests",@"Create Events",@"Profile",@"Invite Friends",@"Settings",nil];
    self.tableView.scrollEnabled = NO;
    self.view.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0];
    // Do any additional setup after loading the view.
}

-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

#pragma mark - Table View Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectZero];
    tempView.backgroundColor=[UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0];
    return tempView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0];
    UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, 220, 20)];
    senderLabel.font = [UIFont fontWithName:@"Helvetica Light" size:18.0];
    senderLabel.text = [menuArray objectAtIndex:indexPath.row];
    senderLabel.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:senderLabel];
    return cell;
}

#pragma mark - Table View Delagate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = [self revealViewController];
    UIViewController *frontViewController;
    if(indexPath.row == 0)
    {
        HomeViewController *homeViewController= [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        frontViewController = homeViewController;
    }
    else if (indexPath.row == 1)
    {
        SearchViewController *searchViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SearchViewController"];
        frontViewController = searchViewController;
    }
    else if (indexPath.row == 2)
    {
        NotificationsViewController *notificationsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
        frontViewController = notificationsViewController;
    }
    else if (indexPath.row == 3)
    {
        MyEventsViewController *acivitiesViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"MyEventsViewController"];
        frontViewController = acivitiesViewController;
    }
    else if (indexPath.row == 4)
    {
        MyFriendsListViewController *myFriendsListViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"MyFriendsListViewController"];
        frontViewController = myFriendsListViewController;
    }

    else if (indexPath.row == 5)
    {
        FriendRequestViewController *friendRequestViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"FriendRequestViewController"];
        frontViewController = friendRequestViewController;
    }

    else if (indexPath.row == 6)
    {
        CreateEventViewController *createEventViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
        frontViewController = createEventViewController;
    }
    else if (indexPath.row == 7)
    {
        ProfileViewController *profileViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        frontViewController = profileViewController;
    }
    else if (indexPath.row == 8)
    {
        InviteFriendsViewController *inviteFriendsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"InviteFriendsViewController"];
        frontViewController = inviteFriendsViewController;
    }
    else if (indexPath.row == 9)
    {
        SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        frontViewController = settingsViewController;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    navigationController.navigationBar.translucent = YES;
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:14.0/255.0 green:112.0/255.0 blue:220.0 /255.0 alpha:1.0];

    [revealController pushFrontViewController:navigationController animated:YES];
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
