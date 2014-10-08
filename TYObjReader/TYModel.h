//
//  TYModel.h
//  TYTesting
//
//  Created by tony on 14-9-14.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYModel : NSObject
@property (nonatomic, assign) int vertices;
@property (nonatomic, assign) int positions;
@property (nonatomic, assign) int texels;
@property (nonatomic, assign) int normals;
@property (nonatomic, assign) int faces;
@property (nonatomic, assign) float xcen;
@property (nonatomic, assign) float ycen;
@property (nonatomic, assign) float zcen;
@property (nonatomic, assign) float scalefac;
@end
