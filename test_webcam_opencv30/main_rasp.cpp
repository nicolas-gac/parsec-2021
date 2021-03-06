#include "opencv2/opencv.hpp"


using namespace cv;

int main(int, char **)
{
	VideoCapture cap(0); // open the default camera
	if (!cap.isOpened()) // check if we succeeded
		return -1;



	for (;;)
	{
		Mat frame, frame_out;
		// Record the start event
		cap >> frame; // get a new frame from camera
		imshow("input", frame);


		if (waitKey(1) == 27)
			break;
	}
	// the camera will be deinitialized automatically in VideoCapture destructor
	return 0;
}
