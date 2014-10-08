//
//  TYObj2OpenGLESConverter.h
//  C3D
//
//  Created by tony on 14-9-7.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYModel.h"
@interface TYObj2OpenGLESConverter : NSObject

+ (TYObj2OpenGLESConverter*)sharedTYObj2OpenGLESConverter;
- (TYModel *)getOBJinfoForFile:(NSString *) filePath;

- (void)extractOBJdataForFile:(NSString *) filePath
                    positions:(int)positionNum
                       texels:(int)texelNum
                      normals:(int)normalNum
                        faces:(int)faceNum
                 withPosition:(float*) positions
                       texels:(float*) texels
                      normals:(float*) normals
                         xcen:(float) xcen
                         ycen:(float) ycen
                         zcen:(float) zcen
                     scalefac:(float) scalefac;

@end
