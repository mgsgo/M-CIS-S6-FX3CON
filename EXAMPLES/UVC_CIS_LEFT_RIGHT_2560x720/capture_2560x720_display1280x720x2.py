import cv2
import numpy as np

resolution = (0, 0)#x,y
capture = cv2.VideoCapture(0)

capture.set(cv2.CAP_PROP_CONVERT_RGB, True)#color capture
resolution = (int(capture.get(cv2.CAP_PROP_FRAME_WIDTH)), int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT)))

while True:
	if capture.isOpened():
		ret, frame = capture.read()
		if(ret):
			ImageLeft  = frame[0:720,    0:1280]
			ImageRight = frame[0:720, 1280:2560]

			cv2.imshow("ImageLeft", ImageLeft)
			cv2.imshow("ImageRight", ImageRight)

		if cv2.waitKey(1) > 0: break	#any key to break

capture.release()
cv2.destroyAllWindows()