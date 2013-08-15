//
//  ViewController.m
//  samplePullToRefresh
//
//  Created by Gerald Kim on 14/08/13.
//  Copyright (c) 2013 jtribe. All rights reserved.
//

#import "ViewController.h"

@interface UIView (Movement)

- (void)moveOriginTo:(CGPoint)point;

@end

@implementation UIView (Movement)

- (void)moveOriginTo:(CGPoint)point
{
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}

@end


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *growingImageView;

@property JTFullImageState pullState;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGFloat originalYPos;

//Pull To Full-Image View connections
@property (strong, nonatomic) IBOutlet UIView *pullFullImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *innerImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //populating self.pullFullImageView
    [[UINib nibWithNibName:@"PullToFullImageView" bundle:nil] instantiateWithOwner:self options:nil];
    [self.view addSubview:self.pullFullImageView];
    self.originalFrame = self.innerImageView.frame;
    self.originalYPos = -self.pullFullImageView.frame.size.height;
	[self.pullFullImageView moveOriginTo:CGPointMake(0,self.originalYPos)];
    self.pullState = JTFullImageNormal;
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat PULL_DOWN_AMOUNT = self.pullFullImageView.frame.size.height;
    static CGFloat AMOUNT_TO_GROW = 15.0f;
    if (scrollView.contentOffset.y < 0.0f && scrollView.contentOffset.y > -PULL_DOWN_AMOUNT && self.pullState != JTFullImageLoading)
    {
        //Move self.pullFullImageView down by contentOffset
        [self.pullFullImageView moveOriginTo:CGPointMake(0, self.originalYPos - scrollView.contentOffset.y)];
        
        //Grow inner image view based on contentOffset
        CGFloat growingAmount = scrollView.contentOffset.y/(PULL_DOWN_AMOUNT/AMOUNT_TO_GROW);
        self.innerImageView.frame = CGRectMake(self.originalFrame.origin.x + growingAmount,
                                          self.originalFrame.origin.y + growingAmount,
                                          self.originalFrame.size.width - growingAmount * 2,
                                          self.originalFrame.size.height - growingAmount * 2);
        
        //Cancel from pulling state back to normal state
        if (self.pullState == JTFullImagePulling)
        {
            [self setState:JTFullImageNormal];
        }
    }
    //When pulled past the threshold: change appearance
    if (scrollView.contentOffset.y < -PULL_DOWN_AMOUNT && self.pullState == JTFullImageNormal && self.pullState != JTFullImageLoading)
    {
        [self setState:JTFullImagePulling];
    }
}

//If let go beyond threshold, trigger loading
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat PULL_DOWN_AMOUNT = self.pullFullImageView.frame.size.height;
    if (scrollView.contentOffset.y <= -PULL_DOWN_AMOUNT)
    {
        [self.pullFullImageView moveOriginTo:CGPointMake(0, self.originalYPos + PULL_DOWN_AMOUNT)];
        [self setState:JTFullImageLoading];
    }
}

#pragma mark - Pull state handling

- (void)setState:(JTFullImageState)aState
{
    self.pullState = aState;
    switch (aState) {
        case JTFullImagePulling:
            self.outerImageView.image = [UIImage imageNamed:@"outerImage_activated.png"];
            self.innerImageView.image = [UIImage imageNamed:@"innerImage_activated.png"];
            [self.activityIndicator stopAnimating];
            break;
        case JTFullImageNormal:
            self.outerImageView.image = [UIImage imageNamed:@"outerImage"];
            self.innerImageView.image = [UIImage imageNamed:@"innerImage"];
            [self.activityIndicator stopAnimating];
            self.innerImageView.hidden = NO;
            break;
        case JTFullImageLoading:
            [self.activityIndicator startAnimating];
            self.innerImageView.hidden = YES;
            [self triggerBiggerImage];
        default:
            break;
    }
}

- (void)triggerBiggerImage
{
    //Adding in an artificial delay of 2 seconds, then growing image. On completion, set back to normal state
    [UIView animateWithDuration:0.7 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.growingImageView.frame = CGRectMake(0, 0, self.growingImageView.frame.size.width + 20, self.growingImageView.frame.size.height + 20);
        });
    } completion:^(BOOL finished) {
        [self setState:JTFullImageNormal];
        [self.pullFullImageView moveOriginTo:CGPointMake(0, self.originalYPos)];
    }];
}

@end
