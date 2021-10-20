#include "mylib.h"
//---------------------noirBlanc-----------------------

Mat noirBlanc(Mat frame)
{ 
	Mat im_gray_out;
	
	if (frame.empty())
	exit(0);
	
	cvtColor(frame,im_gray_out,COLOR_RGB2GRAY);	
	return im_gray_out;
}



//---------------------get_frame-----------------------

Mat get_frame(Mat frame)
{
	if (frame.empty())
	exit(0);
	
	return frame;
}

//---------------------seuillage------------------------

Mat seuillage(Mat frame)
{ 
	float nr;
	uchar r,v,b;
	Mat frame_out;
	frame_out.create(frame.rows,frame.cols,CV_8UC3);

	if (frame.empty())
	exit(0);
	
	for(int i = 0; i < frame.rows; i++)
	{
		for(int j = 0; j < frame.cols; j++)
		{
			
			b = frame.at<Vec3b>(i,j)[0];
			v = frame.at<Vec3b>(i,j)[1];
			r = frame.at<Vec3b>(i,j)[2];
			
			nr = r/sqrt(r*r+b*b+v*v);
			
			if (nr > 0.7){
				frame_out.at<Vec3b>(i,j)[0] = b;
				frame_out.at<Vec3b>(i,j)[1] = r;
				frame_out.at<Vec3b>(i,j)[2] = r;
			}
			else{
				frame_out.at<Vec3b>(i,j)[0] = b;
				frame_out.at<Vec3b>(i,j)[1] = v;
				frame_out.at<Vec3b>(i,j)[2] = r;
			}
		}
	}
	return frame_out;
}


//---------------------contour------------------------

Mat contour(Mat frame)
{ 
	
	Mat frame_out,frame_grayt;
	
	cvtColor(frame,frame_grayt,COLOR_RGB2GRAY);
	frame_out.create(frame.rows,frame.cols,CV_8UC1);
	
	if (frame.empty())
	exit(0);
	
	for (int i=1;i<frame.rows;i++){
		for (int j=1;j<frame.cols;j++){
			short temp;
			temp = (-1)*(short)frame_grayt.at<uchar>(i,j-1)+(-1)*(short)frame_grayt.at<uchar>(i-1,j)+(-1)*(char)frame_grayt.at<uchar>(i,j+1)+(-1)*(short)frame_grayt.at<uchar>(i+1,j)+4*(short)frame_grayt.at<uchar>(i,j);
			
			frame_out.at<uchar>(i,j)=(uchar)abs(temp);
		}
	}
	return frame_out;
}


