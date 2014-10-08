//
//  TYObjReader.cpp
//  C3D
//
//  Created by tony on 14-9-7.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#include "TYObjReader.h"
#import <Foundation/Foundation.h>

//
//  main.cpp
//  blender2opengles
//
//  Created by RRC on 9/9/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

// C++ Standard Library

Model* getOBJinfo(string fp)
{
    Model *model = (Model*)malloc(sizeof(Model));
    memset(model, 0, sizeof(Model));
    // Open OBJ file
    ifstream inOBJ;
    inOBJ.open(fp);
    if(!inOBJ.good())
    {
        NSLog(@"ERROR OPENING OBJ FILE");
        exit(1);
    }
    
    float xsum = 0.;
    float ysum = 0.;
    float zsum = 0.;
    float xmin = 0.;
    float ymin = 0.;
    float zmin = 0.;
    float xmax = 0.;
    float ymax = 0.;
    float zmax = 0.;
    float xcen, ycen, zcen, scalefac;

    float token1, token2, token3;
    // Read OBJ file
    while(!inOBJ.eof())
    {
        string line;

        getline(inOBJ, line);
        string type = line.substr(0,2);
        
        if(type.compare("v ") == 0)
        {
            model->positions = model->positions+1;
            // Copy line for parsing
            char* l = new char[line.size()+1];
            memcpy(l, line.c_str(), line.size()+1);
            
            // Extract tokens
            strtok(l, " ");
            
            token1 = atof(strtok(NULL, " "));
            token2 = atof(strtok(NULL, " "));
            token3 = atof(strtok(NULL, " "));
            
            xsum += token1;
            ysum += token2;
            zsum += token3;
            
            if (model->positions == 1) {
                xmin = token1;
                xmax = token1;
                ymin = token2;
                ymax = token2;
                zmin = token3;
                zmax = token3;
            } else
            {
                if (token1 < xmin)
                {
                    xmin = token1;
                }
                else if (token1 > xmax)
                {
                    xmax = token1;
                }
                
                if (token2 < ymin)
                {
                    ymin = token2;
                }
                else if (token2 > ymax)
                {
                    ymax = token2;
                }
                
                if (token3 < zmin)
                {
                    zmin = token3;
                }
                else if (token3 > zmax)
                {
                    zmax = token3;
                }
            }
            // Wrap up
            delete[] l;
        } else if(type.compare("vt") == 0)
        {
            model->texels = model->texels+1;
        } else if(type.compare("vn") == 0)
        {
            model->normals = model->normals+1;
        } else if(type.compare("f ") == 0)
        {
            model->faces = model->faces+1;
        }
    }
    
    model->vertices = model->faces*3;
    
    // Close OBJ file
    inOBJ.close();
    
    xcen = xsum / model->positions;
    ycen = ysum / model->positions;
    zcen = zsum / model->positions;
    
    float xdiff = (xmax - xmin);
    float ydiff = (ymax - ymin);
    float zdiff = (zmax - zmin);
    
    if ( ( xdiff >= ydiff ) && ( xdiff >= zdiff ) )
    {
        scalefac = xdiff;
    }
    else if ( ( ydiff >= xdiff ) && ( ydiff >= zdiff ) )
    {
        scalefac = ydiff;
    }
    else
    {
        scalefac = zdiff;
    }
    
    scalefac = 1.0 / scalefac;
    
    model->xcen = xcen;
    model->ycen = ycen;
    model->zcen = zcen;
    model->scalefac = scalefac;
    return model;
}

void extractOBJdata(string fp, float positions[][3], float texels[][2], float normals[][3], int faces[][9], float xcen, float ycen, float zcen, float scalefac)
{
    // Counters
    int p = 0;
    int t = 0;
    int n = 0;
    int f = 0;
    
    // Open OBJ file
    ifstream inOBJ;
    inOBJ.open(fp);
    if(!inOBJ.good())
    {
        NSLog(@"ERROR OPENING OBJ FILE");
        exit(1);
    }
    
    // Read OBJ file
    while(!inOBJ.eof())
    {
        string line;
        getline(inOBJ, line);
        string type = line.substr(0,2);
        
        // Positions
        if(type.compare("v ") == 0)
        {
            // Copy line for parsing
            char* l = new char[line.size()+1];
            memcpy(l, line.c_str(), line.size()+1);
            
            // Extract tokens
            strtok(l, " ");

            positions[p][0] = (atof(strtok(NULL, " ")) - xcen) * scalefac;
            positions[p][1] = (atof(strtok(NULL, " ")) - ycen) * scalefac;
            positions[p][2] = (atof(strtok(NULL, " ")) - zcen) * scalefac;
            
            
            // Wrap up
            delete[] l;
            p++;
        }
        
        // Texels
        else if(type.compare("vt") == 0)
        {
            char* l = new char[line.size()+1];
            memcpy(l, line.c_str(), line.size()+1);
            
            strtok(l, " ");
            for(int i=0; i<2; i++)
                texels[t][i] = atof(strtok(NULL, " "));
            delete[] l;
            t++;
        }
        
        // Normals
        else if(type.compare("vn") == 0)
        {
            char* l = new char[line.size()+1];
            memcpy(l, line.c_str(), line.size()+1);
            
            strtok(l, " ");
            for(int i=0; i<3; i++)
                normals[n][i] = atof(strtok(NULL, " "));

            delete[] l;
            n++;
        }
        
        // Faces
        else if(type.compare("f ") == 0)
        {
            char* l = new char[line.size()+1];
            memcpy(l, line.c_str(), line.size()+1);
            
            strtok(l, " ");
            for(int i=0; i<9; i++)
                faces[f][i] = atoi(strtok(NULL, " /"));
            
            delete[] l;
            f++;
        }
    }

    // Close OBJ file
    inOBJ.close();
}

void normalizeNormals(int normalNum, float normals[][3])
{
    int i = 0;
    float tmpResult;
    for (i = 0; i < normalNum; i++) {
        tmpResult = sqrtf(normals[i][0]*normals[i][0]+normals[i][1]*normals[i][1]+normals[i][2]*normals[i][2]);
        if (tmpResult == 0)
        {
            normals[i][0] = 1.;
            normals[i][1] = 0.;
            normals[i][2] = 0.;
        }
        else
        {
            normals[i][0] = normals[i][0]/tmpResult;
            normals[i][1] = normals[i][1]/tmpResult;
            normals[i][2] = normals[i][2]/tmpResult;
        }
    }
}
