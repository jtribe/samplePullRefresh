//
//  ViewController.h
//  samplePullToRefresh
//
//  Created by Gerald Kim on 14/08/13.
//  Copyright (c) 2013 jtribe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JTFullImagePulling = 0,
    JTFullImageNormal,
    JTFullImageLoading
} JTFullImageState;

@interface ViewController : UIViewController <UIScrollViewDelegate>

@end
