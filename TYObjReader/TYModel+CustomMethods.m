//
//  TYModel+CustomMethods.m
//  C3D
//
//  Created by tony on 14-9-14.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#import "TYModel+CustomMethods.h"

@implementation TYModel (CustomMethods)

+ (TYModel*)createModelWithDirName:(TYObjModel *)objModel
{
    TYModel *model = [TYModel new];
    model.faces = [objModel.faces intValue];
    model.vertices = [objModel.vertices intValue];
    model.positions = [objModel.positions intValue];
    model.normals = [objModel.normals intValue];
    model.texels = [objModel.texels intValue];

    return model;
}

@end
