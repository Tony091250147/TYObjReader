//
//  TYObj2OpenGLESConverter.m
//  C3D
//
//  Created by tony on 14-9-7.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#import "TYObj2OpenGLESConverter.h"
#import "TYObjReader.h"
#import "SynthesizeSingleton.h"


@implementation TYObj2OpenGLESConverter

SINGLETON(TYObj2OpenGLESConverter)

- (TYModel *)getOBJinfoForFile:(NSString *) filePath
{
    TYModel *model = [TYModel new];
    std::string *fp = new std::string([filePath UTF8String]);
    Model* modelStruct = getOBJinfo(*fp);
    model.vertices = modelStruct->vertices;
    model.positions = modelStruct->positions;
    model.texels = modelStruct->texels;
    model.normals = modelStruct->normals;
    model.faces = modelStruct->faces;
    model.xcen = modelStruct->xcen;
    model.ycen = modelStruct->ycen;
    model.zcen = modelStruct->zcen;
    model.scalefac = modelStruct->scalefac;
    
    free(fp);
    free(modelStruct);
    return model;
}

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
                     scalefac:(float) scalefac
{
    NSString * tmpFP = [NSString stringWithString:filePath];
    std::string *fp = new std::string([tmpFP UTF8String]);
    // Model Data

    float(* tmpPositions)[3] = (float(*)[3])malloc(sizeof(float)*positionNum*3);    // XYZ
    float(*tmpTexels)[2] = (float(*)[2])malloc(sizeof(float)*texelNum*2);          // UV
    float(*tmpNormals)[3] = (float(*)[3])malloc(sizeof(float)*normalNum*3);        // XYZ
    int (*tmpFaces)[9] = (int(*)[9])malloc(sizeof(int)*faceNum*9);              // PTN PTN PTN
    
    extractOBJdata(*fp, tmpPositions, tmpTexels, tmpNormals, tmpFaces, xcen, ycen, zcen, 1);
    free(fp);
//    normalizeNormals(normalNum, tmpNormals);

    for (int i = 0; i < faceNum; i++)
    {
        int vA = tmpFaces[i][0] - 1;
        int vB = tmpFaces[i][3] - 1;
        int vC = tmpFaces[i][6] - 1;

        positions[i*9] = tmpPositions[vA][0];
        positions[i*9+1] = tmpPositions[vA][1];
        positions[i*9+2] = tmpPositions[vA][2];

        positions[i*9+3] = tmpPositions[vB][0];
        positions[i*9+4] = tmpPositions[vB][1];
        positions[i*9+5] = tmpPositions[vB][2];

        positions[i*9+6] = tmpPositions[vC][0];
        positions[i*9+7] = tmpPositions[vC][1];
        positions[i*9+8] = tmpPositions[vC][2];

    }
    
    for (int i = 0; i < faceNum; i++)
    {
        int vtA = tmpFaces[i][1] - 1;
        int vtB = tmpFaces[i][4] - 1;
        int vtC = tmpFaces[i][7] - 1;
        
        texels[i*6] = tmpTexels[vtA][0];
        texels[i*6+1] = tmpTexels[vtA][1];
        
        texels[i*6+2] = tmpTexels[vtB][0];
        texels[i*6+3] = tmpTexels[vtB][1];
        
        texels[i*6+4] = tmpTexels[vtC][0];
        texels[i*6+5] = tmpTexels[vtC][1];
    }
    
    for (int i = 0; i < faceNum; i++)
    {
        int vnA = tmpFaces[i][2] - 1;
        int vnB = tmpFaces[i][5] - 1;
        int vnC = tmpFaces[i][8] - 1;
        
        normals[i*9] = tmpNormals[vnA][0];
        normals[i*9+1] = tmpNormals[vnA][1];
        normals[i*9+2] = tmpNormals[vnA][2];

        normals[i*9+3] = tmpNormals[vnB][0];
        normals[i*9+4] = tmpNormals[vnB][1];
        normals[i*9+5] = tmpNormals[vnB][2];

        normals[i*9+6] = tmpNormals[vnC][0];
        normals[i*9+7] = tmpNormals[vnC][1];
        normals[i*9+8] = tmpNormals[vnC][2];

    }
    
    free(tmpPositions);
    free(tmpTexels);
    free(tmpNormals);
    free(tmpFaces);
}

@end
