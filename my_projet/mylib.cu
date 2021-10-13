#include "mylib.h"
#include "mylib.cuh"
//---------------------noirBlanc-----------------------

Mat noirBlanc(Mat frame)
{ 
	Mat im_gray_out;
	
	if (frame.empty())
	exit(0);
	
	cvtColor(frame,im_gray_out,CV_RGB2GRAY);	
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
	
	if (frame.empty())
	exit(0);
	
	for(int i = 0; i < frame.rows; i++)
	{
		for(int j = 0; j < frame.cols; j++)
		{
			
			b = frame.at<Vec3b>(i,j)[0];
			v = frame.at<Vec3b>(i,j)[1];
			r = frame.at<Vec3b>(i,j)[2];
			
			nr = v/sqrt(r*r+b*b+v*v);
			
			if (nr > 0.6){
				frame.at<Vec3b>(i,j)[0] = b;
				frame.at<Vec3b>(i,j)[1] = r;
				frame.at<Vec3b>(i,j)[2] = v;
			}
			else{
				frame.at<Vec3b>(i,j)[0] = b;
				frame.at<Vec3b>(i,j)[1] = v;
				frame.at<Vec3b>(i,j)[2] = r;
			}
		}
	}
	return frame;
}


//---------------------contour------------------------

Mat contour(Mat frame)
{ 
	
	Mat frame_out,frame_grayt;
	
	cvtColor(frame,frame_grayt,CV_BGR2GRAY);
	frame_out.create(frame.rows,frame.cols,CV_8UC1);
	
	if (frame.empty())
	exit(0);
	
	for (int i=1;i<frame.rows;i++){
		for (int j=1;j<frame.cols;j++){
			short temp;
			temp = (-1)*(short)frame_grayt.at<uchar>(i,j-1)+(-1)*(short)frame_grayt.at<uchar>(i-1,j)+(-1)*(char)frame_grayt.at<uchar>(i,j+1)+(-1)*(short)frame_grayt.at<uchar>(i+1,j)+4*(short)frame_grayt.at<uchar>(i,j);
			
			frame_out.at<uchar>(i,j)=(uchar)abs(temp);
			
			if(frame_out.at<uchar>(i,j)>23) frame_out.at<uchar>(i,j)=255;
			else frame_out.at<uchar>(i,j)=0;
		}
	}
	return frame_out;
}


Mat seuillageGPU( Mat in)
{
	cudaError_t error;
	Mat out;
	out.create(in.rows,in.cols,CV_8UC3);
	
	// allocate host memory
	unsigned char *h_image_in_GPU ;
	h_image_in_GPU=in.data;
	
	cudaEvent_t start,stop,start_mem,stop_mem;
	error = cudaEventCreate(&start_mem);
	error = cudaEventCreate(&stop_mem);
	
	error = cudaEventRecord(start, NULL);
	error = cudaEventSynchronize(start);
	
	// images on device memoryÍÍÍ
	unsigned char *d_image_in_GPU;
	unsigned char *d_image_out_GPU;
	
	const unsigned long int mem_size=in.cols*in.rows*3*sizeof(unsigned char);
	
	// Alocation mémoire de d_image_in et d_image_out sur la carte GPU
	cudaMalloc((void**) &d_image_in_GPU,mem_size );
	cudaMalloc((void**) &d_image_out_GPU, mem_size);
	
	// copy host memory to device
	cudaMemcpy(d_image_in_GPU, h_image_in_GPU,mem_size ,cudaMemcpyHostToDevice);
	
	error = cudaEventRecord(stop_mem, NULL);
	
	// Wait for the stop event to complete
	error = cudaEventSynchronize(stop_mem);
	float msecMem = 0.0f;
	error = cudaEventElapsedTime(&msecMem, start, stop_mem);
	
	// setup execution parameters -> découpage en threads
	dim3 threads(BLOCK_SIZE,BLOCK_SIZE);
	dim3 grid(in.rows/BLOCK_SIZE,in.cols/BLOCK_SIZE);
	
	// lancement des threads executé sur la carte GPU
	kernel_seuillageGPU<<< grid, threads >>>(d_image_in_GPU, d_image_out_GPU,in.cols);
	
	// Record the start event
	error = cudaEventRecord(start_mem, NULL);
	error = cudaEventSynchronize(start_mem);
	
	// copy result from device to host
	cudaMemcpy(out.data, d_image_out_GPU, mem_size,cudaMemcpyDeviceToHost);
	cudaFree(d_image_in_GPU);
	cudaFree(d_image_out_GPU);
	float msecTotal,msecMem2;
	error = cudaEventRecord(stop, NULL);
	error = cudaEventSynchronize(stop);
	error = cudaEventElapsedTime(&msecTotal, start, stop);
	error = cudaEventElapsedTime(&msecMem2, start_mem, stop);
	
	return out;
}

