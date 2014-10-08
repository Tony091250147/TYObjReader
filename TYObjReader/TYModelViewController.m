//
//  TYModelViewController.m
//  C3D
//
//  Created by tony on 14-9-8.
//  Copyright (c) 2014年 Tony. All rights reserved.
//

#import "TYModelViewController.h"
#import "TYObj2OpenGLESConverter.h"
#import "cube.h"
@interface TYModelViewController () 
{
    // Touch-handling
	float _startingTouchDistance, _previousScale;
	float _instantObjectScale, _instantXRotation, _instantYRotation, _instantXTranslation, _instantYTranslation, _instantZTranslation;
	CGPoint _lastMovementPosition, _previousDirectionOfPanning;
	BOOL _twoFingersAreMoving, _pinchGestureUnderway;
    float currentModelScaleFactor;
    CATransform3D currentCalculatedMatrix;
    float * _positions;
    float * _texels;
    float * _normals;
    NSArray *_activity;

    float   _rotate;

}

@property (nonatomic, strong) TYObj2OpenGLESConverter *tyObjOpenGLESConverter;
@property (nonatomic, strong) GLKBaseEffect* effect;
@property (nonatomic, strong) UIColor *viewBackgroundColor;
@end

@implementation TYModelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up context
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // Set up view
    GLKView* glkview = (GLKView *)self.view;
    self.viewBackgroundColor = [UIColor whiteColor];
    glkview.context = context;

    // OpenGL ES Settings
//    glDisable(GL_CULL_FACE);
    glEnable(GL_CULL_FACE);
//    glCullFace(GL_BACK);
//    glDisable(GL_DEPTH_TEST);
//    glEnable(GL_BLEND);
    
    currentModelScaleFactor = 1.0;
    
    [self loadModelData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    free(_positions);
    free(_normals);
    free(_texels);
}

- (void)loadModelData
{
    // Capture author info &  user status
    
    free(_positions);
    free(_normals);
    free(_texels);

    self.tyObjOpenGLESConverter = [TYObj2OpenGLESConverter sharedTYObj2OpenGLESConverter];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"starship" ofType:@"obj"];
    self.objModel = [self.tyObjOpenGLESConverter getOBJinfoForFile:filePath];
    
    _positions = malloc(sizeof(float)*self.objModel.faces * 9);
    _normals = malloc(sizeof(float)*self.objModel.faces * 9);
    _texels = malloc(sizeof(float)*self.objModel.faces * 6);
    
    
    
    [self.tyObjOpenGLESConverter extractOBJdataForFile:filePath
                                               positions:self.objModel.positions
                                                texels:self.objModel.texels
                                               normals:self.objModel.normals
                                                 faces:self.objModel.faces
                                          withPosition:_positions
                                                texels:_texels
                                               normals:_normals
                                                  xcen:self.objModel.xcen
                                                  ycen:self.objModel.ycen
                                                  zcen:self.objModel.zcen
                                              scalefac:self.objModel.scalefac];
    
    
    //    GLfloat currentModelViewMatrix[16]  = {0.402560,0.094840,0.910469,0.000000, 0.913984,-0.096835,-0.394028,0.000000, 0.050796,0.990772,-0.125664,0.000000, 0.000000,0.000000,0.000000,1.000000};
    GLfloat currentModelViewMatrix[16]  = {1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0};
    [self convertMatrix:currentModelViewMatrix to3DTransform:&currentCalculatedMatrix];
    
    // Create effect
    [self createEffect];
}

- (void)createEffect
{
    // Initialize
    self.effect = [[GLKBaseEffect alloc] init];
    
    // Texture
//    NSDictionary* options = @{ GLKTextureLoaderOriginBottomLeft: @YES};
//    NSError* error;
//
//    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:self.objModel.jpgFilePath options:options error:&error];
//    
//    if(texture == nil)
//        NSLog(@"Error loading file: %@", [error localizedDescription]);
//    
//    self.effect.texture2d0.name = texture.name;
//    self.effect.texture2d0.enabled = true;
    
    // Light

    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    self.effect.lightingType = GLKLightingTypePerPixel;
}

- (void)setMatrices
{
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ModelView Matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, -5.0f);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(45.0f));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(_rotate));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(_rotate));
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

//- (void)setMatrices
//{
//    // Projection Matrix
//    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
//    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
//    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
//    self.effect.transform.projectionMatrix = projectionMatrix;
//    
//    // ModelView Matrix
//    
//    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
//    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, -5.0f);
//    GLKMatrix4 currentMatrix = [self matrixFrom3DTransformation:currentCalculatedMatrix];
//    
//    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(modelViewMatrix, currentMatrix);
//    
//}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    CGFloat red, green, blue, alpha;
    
    [self.viewBackgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    glClearColor(red, green, blue, alpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (self.objModel == nil) {
        return;
    }
    // Prepare effect
    [self.effect prepareToDraw];

    // Set matrices
    [self setMatrices];
    
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float)*0, _positions);
    
    // Texels
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float)*0, _texels);
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float)*0, _normals);
    
    
    // Draw Model
//    glDrawArrays(GL_TRIANGLES, 0, [self.objModel.vertices intValue]);
    glDrawArrays(GL_TRIANGLES, 0, self.objModel.vertices);
}

- (void)update
{
    _rotate += 1.0f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Touch handling

- (float)distanceBetweenTouches:(NSSet *)touches;
{
	int currentStage = 0;
	CGPoint point1 = CGPointZero;
	CGPoint point2 = CGPointZero;
	
	
	for (UITouch *currentTouch in touches)
	{
		if (currentStage == 0)
		{
			point1 = [currentTouch locationInView:self.view];
			currentStage++;
		}
		else if (currentStage == 1)
		{
			point2 = [currentTouch locationInView:self.view];
			currentStage++;
		}
		else
		{
		}
	}
	return (sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y)));
}

- (CGPoint)commonDirectionOfTouches:(NSSet *)touches;
{
	// Check to make sure that both fingers are moving in the same direction
	
	int currentStage = 0;
	CGPoint currentLocationOfTouch1 = CGPointZero, currentLocationOfTouch2 = CGPointZero, previousLocationOfTouch1 = CGPointZero, previousLocationOfTouch2 = CGPointZero;
	
	
	for (UITouch *currentTouch in touches)
	{
		if (currentStage == 0)
		{
			previousLocationOfTouch1 = [currentTouch previousLocationInView:self.view];
			currentLocationOfTouch1 = [currentTouch locationInView:self.view];
			currentStage++;
		}
		else if (currentStage == 1)
		{
			previousLocationOfTouch2 = [currentTouch previousLocationInView:self.view];
			currentLocationOfTouch2 = [currentTouch locationInView:self.view];
			currentStage++;
		}
		else
		{
		}
	}
	
	CGPoint directionOfTouch1, directionOfTouch2, commonDirection;
	// The sign of the Y touches is inverted, due to the inverted coordinate system of the iPhone
	directionOfTouch1.x = currentLocationOfTouch1.x - previousLocationOfTouch1.x;
	directionOfTouch1.y = previousLocationOfTouch1.y - currentLocationOfTouch1.y;
	directionOfTouch2.x = currentLocationOfTouch2.x - previousLocationOfTouch2.x;
	directionOfTouch2.y = previousLocationOfTouch2.y - currentLocationOfTouch2.y;
	
	// A two-finger movement should result in the direction of both touches being positive or negative at the same time in X and Y
	if (!( ((directionOfTouch1.x <= 0) && (directionOfTouch2.x <= 0)) || ((directionOfTouch1.x >= 0) && (directionOfTouch2.x >= 0)) ))
		return CGPointZero;
	if (!( ((directionOfTouch1.y <= 0) && (directionOfTouch2.y <= 0)) || ((directionOfTouch1.y >= 0) && (directionOfTouch2.y >= 0)) ))
		return CGPointZero;
	
	// The movement ranges are averaged out
	commonDirection.x = ((directionOfTouch1.x + directionOfTouch2.x) / 2.0f);
	commonDirection.y = ((directionOfTouch1.y + directionOfTouch2.y) / 2.0f);
	
    
	return commonDirection;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    NSMutableSet *currentTouches = [[event touchesForView:self.view] mutableCopy];
    [currentTouches minusSet:touches];
	
	// New touches are not yet included in the current touches for the view
	NSSet *totalTouches = [touches setByAddingObjectsFromSet:[event touchesForView:self.view]];
	if ([totalTouches count] > 1)
	{
		_startingTouchDistance = [self distanceBetweenTouches:totalTouches];
		_previousScale = 1.0f;
		_twoFingersAreMoving = NO;
		_pinchGestureUnderway = NO;
		_previousDirectionOfPanning = CGPointZero;
	}
	else
	{
		_lastMovementPosition = [[touches anyObject] locationInView:self.view];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	if ([[event touchesForView:self.view] count] > 1) // Pinch gesture, possibly two-finger movement
	{
		CGPoint directionOfPanning = CGPointZero;
		
		// Two finger panning
		if ([touches count] > 1) // Check to make sure that both fingers are moving
		{
			directionOfPanning = [self commonDirectionOfTouches:touches];
		}
		
		if ( (directionOfPanning.x != 0) || (directionOfPanning.y != 0) ) // Don't scale while doing the two-finger panning
		{
			if (_pinchGestureUnderway)
			{
				if (sqrt(_previousDirectionOfPanning.x * _previousDirectionOfPanning.x + _previousDirectionOfPanning.y * _previousDirectionOfPanning.y) > 0.1 )
				{
					_pinchGestureUnderway = NO;
				}
				_previousDirectionOfPanning.x += directionOfPanning.x;
				_previousDirectionOfPanning.y += directionOfPanning.y;
			}
			if (!_pinchGestureUnderway)
			{
				_twoFingersAreMoving = YES;
                [self translateModelByScreenDisplacementInX:directionOfPanning.x inY:directionOfPanning.y];
                
				_previousDirectionOfPanning = CGPointZero;
			}
		}
		else
		{
			float newTouchDistance = [self distanceBetweenTouches:[event touchesForView:self.view]];
			if (_twoFingersAreMoving)
			{
				// If fingers have moved more than 10% apart, start pinch gesture again
				if ( fabs(1 - (newTouchDistance / _startingTouchDistance) / _previousScale) > 0.3 )
				{
					_twoFingersAreMoving = NO;
				}
			}
			if (!_twoFingersAreMoving)
			{
				// Scale using pinch gesture
                [self scaleModelByFactor:(newTouchDistance / _startingTouchDistance) / _previousScale];
                
				_previousScale = (newTouchDistance / _startingTouchDistance);
				_pinchGestureUnderway = YES;
			}
		}
	}
	else // Single-touch rotation of object
	{
		CGPoint currentMovementPosition = [[touches anyObject] locationInView:self.view];
        [self rotateModelFromScreenDisplacementInX:(currentMovementPosition.x - _lastMovementPosition.x) inY:(currentMovementPosition.y - _lastMovementPosition.y)];
        
		_lastMovementPosition = currentMovementPosition;
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self handleTouchesEnding:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self handleTouchesEnding:touches withEvent:event];
}

- (void)handleTouchesEnding:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *remainingTouches = [[event touchesForView:self.view] mutableCopy];
    [remainingTouches minusSet:touches];
	if ([remainingTouches count] < 2)
	{
		_twoFingersAreMoving = NO;
		_pinchGestureUnderway = NO;
		_previousDirectionOfPanning = CGPointZero;
		
		_lastMovementPosition = [[remainingTouches anyObject] locationInView:self.view];
	}
}

#pragma mark Model manipulation

- (void)rotateModelFromScreenDisplacementInX:(float)xRotation inY:(float)yRotation;
{
	// Perform incremental rotation based on current angles in X and Y
	GLfloat totalRotation = sqrt(xRotation*xRotation + yRotation*yRotation);
	
	CATransform3D temporaryMatrix = CATransform3DRotate(currentCalculatedMatrix, totalRotation * M_PI / 180.0,
														((xRotation/totalRotation) * currentCalculatedMatrix.m12 + (yRotation/totalRotation) * currentCalculatedMatrix.m11),
														((xRotation/totalRotation) * currentCalculatedMatrix.m22 + (yRotation/totalRotation) * currentCalculatedMatrix.m21),
														((xRotation/totalRotation) * currentCalculatedMatrix.m32 + (yRotation/totalRotation) * currentCalculatedMatrix.m31));
    
	if ((temporaryMatrix.m11 >= -100.0) && (temporaryMatrix.m11 <= 100.0))
    {
		currentCalculatedMatrix = temporaryMatrix;
    }
}

- (void)scaleModelByFactor:(float)scaleFactor;
{
    // Scale the view to fit current multitouch scaling
	CATransform3D temporaryMatrix = CATransform3DScale(currentCalculatedMatrix, scaleFactor, scaleFactor, scaleFactor);
	
	if ((temporaryMatrix.m11 >= -100.0) && (temporaryMatrix.m11 <= 100.0))
    {
		currentCalculatedMatrix = temporaryMatrix;
        currentModelScaleFactor = currentModelScaleFactor * scaleFactor;
    }
}

- (void)translateModelByScreenDisplacementInX:(float)xTranslation inY:(float)yTranslation;
{
//    float scalingForMovement;
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        scalingForMovement = 85.0f;
//    }
//    else
//    {
//        scalingForMovement = 200.0f;
//    }
//    
//    
//    // Translate the model by the accumulated amount
//	float currentScaleFactor = sqrt(pow(currentCalculatedMatrix.m11, 2.0f) + pow(currentCalculatedMatrix.m12, 2.0f) + pow(currentCalculatedMatrix.m13, 2.0f));
//    
//	xTranslation = xTranslation * scalingForMovement / (currentScaleFactor * currentScaleFactor);
//	yTranslation = yTranslation * scalingForMovement / (currentScaleFactor * currentScaleFactor);
//    
//	// Use the (0,4,8) components to figure the eye's X axis in the model coordinate system, translate along that
//	CATransform3D temporaryMatrix = CATransform3DTranslate(currentCalculatedMatrix, xTranslation * currentCalculatedMatrix.m11, xTranslation * currentCalculatedMatrix.m21, xTranslation * currentCalculatedMatrix.m31);
//	// Use the (1,5,9) components to figure the eye's Y axis in the model coordinate system, translate along that
//	temporaryMatrix = CATransform3DTranslate(temporaryMatrix, yTranslation * currentCalculatedMatrix.m12, yTranslation * currentCalculatedMatrix.m22, yTranslation * currentCalculatedMatrix.m32);
//	
//	if ((temporaryMatrix.m11 >= -100.0) && (temporaryMatrix.m11 <= 100.0))
//    {
//		currentCalculatedMatrix = temporaryMatrix;
//    }
}

- (void)resetModelViewMatrix;
{
 	GLfloat currentModelViewMatrix[16]  = {0.402560,0.094840,0.910469,0.000000, 0.913984,-0.096835,-0.394028,0.000000, 0.050796,0.990772,-0.125664,0.000000, 0.000000,0.000000,0.000000,1.000000};
	[self convertMatrix:currentModelViewMatrix to3DTransform:&currentCalculatedMatrix];
    currentModelScaleFactor = 1.0;
}

#pragma mark - OpenGL matrix helper methods

- (GLKMatrix4)matrixFrom3DTransformation:(CATransform3D)transform
{
    GLKMatrix4 matrix = GLKMatrix4Make(transform.m11, transform.m12, transform.m13, transform.m14,
                                       transform.m21, transform.m22, transform.m23, transform.m24,
                                       transform.m31, transform.m32, transform.m33, transform.m34,
                                       transform.m41, transform.m42, transform.m43, transform.m44);
    
    return matrix;
}

- (void)convertMatrix:(GLfloat *)matrix to3DTransform:(CATransform3D *)transform3D;
{
	transform3D->m11 = (CGFloat)matrix[0];
	transform3D->m12 = (CGFloat)matrix[1];
	transform3D->m13 = (CGFloat)matrix[2];
	transform3D->m14 = (CGFloat)matrix[3];
	transform3D->m21 = (CGFloat)matrix[4];
	transform3D->m22 = (CGFloat)matrix[5];
	transform3D->m23 = (CGFloat)matrix[6];
	transform3D->m24 = (CGFloat)matrix[7];
	transform3D->m31 = (CGFloat)matrix[8];
	transform3D->m32 = (CGFloat)matrix[9];
	transform3D->m33 = (CGFloat)matrix[10];
	transform3D->m34 = (CGFloat)matrix[11];
	transform3D->m41 = (CGFloat)matrix[12];
	transform3D->m42 = (CGFloat)matrix[13];
	transform3D->m43 = (CGFloat)matrix[14];
	transform3D->m44 = (CGFloat)matrix[15];
}


@end
