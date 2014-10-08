//
//  TYModelViewController.h
//  C3D
//
//  Created by tony on 14-9-8.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "TYModel.h"

@interface TYModelViewController : GLKViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) TYModel *objModel;
@end
