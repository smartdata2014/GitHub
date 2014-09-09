//
//  PeopleCustomCell.m
//  SbScribe
//
//  Created by Ramesh on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PeopleCustomCell.h"

@implementation PeopleCustomCell

@synthesize lblName;
//@synthesize lblBirthday;
@synthesize imgUser;
@synthesize _thread,loaderView;
@synthesize objFriends;
@synthesize fbprofileImag,checkmarkImage;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.checkmarkImage.hidden=YES;
        imgUser  = [[UIImageView alloc]initWithFrame:CGRectMake(05,10,25,25)];
        imgUser.backgroundColor = [UIColor clearColor];
//        imgUser.image = [UIImage imageNamed:@"basketball_icon"];
        [self.contentView addSubview:imgUser];
        
        lblName  = [[UILabel alloc]initWithFrame:CGRectMake(100,20,250,30 )];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textColor  = [UIColor colorWithRed:44.0/255.0 green:96.0/255.0  blue:163.0/255.0  alpha:1.0];
        lblName.font = [UIFont fontWithName:@"Helvetica Light" size:13.0];
        [self.contentView addSubview:lblName];
        
//        lblBirthday  = [[UILabel alloc]initWithFrame:CGRectMake(100,20,250,30 )];
//        lblBirthday.backgroundColor = [UIColor clearColor];
//        lblBirthday.textColor  = [UIColor colorWithRed:44.0/255.0 green:96.0/255.0  blue:163.0/255.0  alpha:1.0];
//        lblBirthday.font = [UIFont fontWithName:@"Helvetica" size:18];
//        [self.contentView addSubview:lblBirthday];

        loaderView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loaderView.center = self.imgUser.center;
        loaderView.tag = 3434;
        [loaderView startAnimating];
        [self.contentView addSubview:loaderView];
    }
    return self;
}

#pragma mark forLazy loading
-(void)setImage:(UIImage *)image{
	self.imgUser.image = image;
}

#pragma mark facebook loading
-(void)setCellParametersForFaceBook:(FBFriendlistBO *)objFriend
{
    [objFriend retain];
	objFriends =nil;
	objFriends = objFriend;
    NSLog(@"strFriendImageUrl....%@",objFriend.strFriendImageUrl);
    NSLog(@"first_name....%@",objFriend.first_name);
    

    lblName.frame = CGRectMake(55,5,250,30 );
   // self.imgUser.frame = CGRectMake(05,05,25,25)   ;

    lblName.textAlignment = NSTextAlignmentLeft;
    lblName.numberOfLines = 2;
    lblName.text = [NSString stringWithFormat:@"%@",objFriend.name];

    //self.imgUser.backgroundColor = [UIColor clearColor];

}

#pragma mark forLazy loading

-(void)showFriendImage{
    
	@synchronized(self) 
	{	
		if ([[NSThread currentThread] isCancelled])
		{
			return;
		}
		
        [loaderView startAnimating];
        
		[_thread cancel];	
		[_thread release];
		_thread = nil;
		self.imgUser.image = nil;
		
		if ([objFriends image1])
		{
			self.imgUser.image = [objFriends image1];
			[loaderView stopAnimating];
		}
		else
		{
			_thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadFriendImage) object:nil];
			[_thread start];
		}			
	}
}

- (void)downloadFriendImage
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread sleepForTimeInterval:0.0];
	if (![[NSThread currentThread] isCancelled])
	{
		[objFriends downloadImage];
		
		@synchronized(self) 
		{
			if (![[NSThread currentThread] isCancelled])
			{
				self.imgUser.image = nil;
				[self.imgUser performSelectorOnMainThread:@selector(setImage:) withObject:[objFriends image1] waitUntilDone:NO];
				[loaderView stopAnimating];
			}
		}
	}
	[pool release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [loaderView release];
//    [lblBirthday release];
    [lblName release];
    [imgUser release];
    [super dealloc];

}

@end
