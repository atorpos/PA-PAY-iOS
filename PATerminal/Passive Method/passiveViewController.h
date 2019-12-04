//
//  passiveViewController.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/05/07.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SERVICE.h"

@class writefiles;
@interface passiveViewController : UIViewController {
    CGFloat curwidth;
    CGFloat curheigh;
    UIImageView *showqrview;
    NSUserDefaults *defaults;
    NSString *signstring;
    writefiles *writefileclass;
}

@property (copy) NSString *stringvalue;
@end
