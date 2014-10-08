//
//  TYObjReader.h
//  C3D
//
//  Created by tony on 14-9-7.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#ifndef __C3D__TYObjReader__
#define __C3D__TYObjReader__

#ifdef __DECCXX
#include <iostream>
#else
#include <sstream>
#endif

#include <string>
#include <fstream>

using namespace std;
// Model Structure
typedef struct Model
{
    int vertices;
    int positions;
    int texels;
    int normals;
    int faces;
    float xcen;
    float ycen;
    float zcen;
    float scalefac;
}
Model;

Model *getOBJinfo(string fp);

void extractOBJdata(string fp, float positions[][3], float texels[][2], float normals[][3], int faces[][9], float xcen, float ycen, float zcen, float scalefac);

void normalizeNormals(int normalNum, float normals[][3]);
#endif /* defined(__C3D__TYObjReader__) */
