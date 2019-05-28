## real time object detection from UVC camera(M-CIS-S6-FX3CON)
0. DARKNET yolo page:
	https://pjreddie.com/darknet/yolo/

1. install Visual C++ Redistributable for MSVS2015
	https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1
	vc_redist.x64.exe

2. install CUDA 10
	https://developer.nvidia.com/cuda-downloads
	windows/x86_64/version 10

3. download Darknet for Windows & Linux
	https://github.com/AlexeyAB/darknet/releases
	https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3/darknet.zip

4. unzip

5. cmd file execute

	darknet\build\darknet\x64\darknet_web_cam_voc.cmd
	
	Nvidia GPU needed


## video capture using UVC camera(M-CIS-S6-FX3CON) and daumpotplayer
1. install daumpotplayer
 	https://potplayer.daum.net/

2. mp4 capture using M-CIS-S6-FX3CON(UVC camera)


## object detection from video file(mp4)
1. video file rename and move
	rename video file to test.mp4
	move to darknet\build\darknet\x64

2. install opencv 3.4.0
	https://sourceforge.net/projects/opencvlibrary/files/opencv-win/3.4.0/

3. file copy opencv_ffmpeg340_64.dll
	copy opencv\build\bin\opencv_ffmpeg340_64.dll to darknet\build\darknet\x64

4. cmd file execute
	darknet\build\darknet\x64\darknet_yolo_v3_video.cmd