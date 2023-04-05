//
//  BEUMath.m
//  BEUEngine
//
//  Created by Chris Mele on 2/20/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUMath.h"


@implementation BEUMath


+(double)angleFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
	//double h = hypot(abs(point1.x-point2.x),abs(point1.y-point2.y));
	
	if(point1.x == point2.x && point1.y == point2.y) return 0;
	
	double w = fabs(point2.x - point1.x);
	double h = fabs(point2.y - point1.y);
	
	if(w == 0)
	{
		if(h >= 0)
		{
			return M_PI*2-M_PI_2;
		} else {
			return M_PI_2;
		}
	}
	//double theta = asin((point1.y-point2.y)/h);
	double theta = atan2(h, w);
	
	/*if(point1.x >= point2.x)
	{
		theta = M_2_PI - theta;
	} else*/
	if(point1.x <= point2.x && point1.y <= point2.y)
	{
		//Quadrant I
		//return theta;
	} else if(point1.x > point2.x && point1.y <= point2.y)
	{
		//Quadrant II
		//return M_PI - theta;
		theta = M_PI - theta;
	} else if(point1.x > point2.x && point1.y > point2.y)
	{
		//Quadrant III
		theta = M_PI + theta;
	} else {
		//Quadrant IV
		theta = M_PI*2 - theta;// - theta;
	}
	
	//double degrees = theta * (180/M_PI);
	//NSLog([NSString stringWithFormat:@"THETA: %02f", degrees]);
	return theta;
	
}

+(float)random
{
	
	return ((float)rand()/(float)RAND_MAX);
}


@end
