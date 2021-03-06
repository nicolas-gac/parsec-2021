#include "mylib.h"
#include "mylib.cuh"
#include <cuda_runtime.h>

// acces au flux de la camera
std::string gstreamer_pipeline (int capture_width, int capture_height, int display_width, int display_height, int framerate, int flip_method) {
    return "nvarguscamerasrc ! video/x-raw(memory:NVMM), width=(int)" + std::to_string(capture_width) + ", height=(int)" +
           std::to_string(capture_height) + ", format=(string)NV12, framerate=(fraction)" + std::to_string(framerate) +
           "/1 ! nvvidconv flip-method=" + std::to_string(flip_method) + " ! video/x-raw, width=(int)" + std::to_string(display_width) + ", height=(int)" +
           std::to_string(display_height) + ", format=(string)BGRx ! videoconvert ! video/x-raw, format=(string)BGR ! appsink";
}

int main(int, char**)
{ 
    	int capture_width = 1280 ;
    	int capture_height = 720 ;
    	int display_width = 640 ;
    	int display_height = 360 ;
    	int framerate = 60 ;
    	int flip_method = 0 ;

    	std::string pipeline = gstreamer_pipeline(capture_width,
	capture_height,
	display_width,
	display_height,
	framerate,
	flip_method);
    	std::cout << "Using pipeline: \n\t" << pipeline << "\n";

	cv::VideoCapture cap(pipeline, cv::CAP_GSTREAMER);
	//VideoCapture cap(); // open the default camera
	if(!cap.isOpened())  // check if we succeeded
		return -1;
	
	while(1){
		Mat frame;
	    	cap >> frame;
	    	char c=(char)waitKey(25);
		if(c == '1'){				// if '1' est appuye
			Mat NB = noirBlanc(frame);
	    		imshow("NoirEtBlanc", NB);
		}
		else if(c == '2'){			// if '2' est appuye
			Mat seuil = seuillage(frame);
	    		imshow("seuillage", seuil);
		}
		else if (c == '3'){			// if '3' est appuye
			Mat cont = contour(frame);
	    		imshow("contour", cont);
		}
		else if (c == '4'){			// if '4' est appuye
			Mat seuilgpu = seuillageGPU(frame);
	    		imshow("seuillage GPU",seuilgpu);
		}
		else if(c == '5') destroyAllWindows();	// if '5' est appuye

		else imshow("frame", frame);
			
	    	if(c==27)				// if 'esc' est appuye
	      		break;
	}
  	// When everything done, release the video capture object
	cap.release();

	// Closes all the frames
	destroyAllWindows();

	return 0;
}
