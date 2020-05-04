import cv2
import numpy as np

resolution = (0, 0)#x,y
capture = cv2.VideoCapture(0)

capture.set(cv2.CAP_PROP_CONVERT_RGB, False)#RAW capture
resolution = (int(capture.get(cv2.CAP_PROP_FRAME_WIDTH)), int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT)))

while True:
	if capture.isOpened():
		ret, frame = capture.read()
		if(ret):
			frame = np.reshape(frame, (resolution[1], resolution[0]*2))
			ImageY8bit      = frame[:, 0::2]
			ImageCbCr8bit   = frame[:, 1::2]

			ImageY8bitLeft  = ImageY8bit[0:720,    0:1280]
			ImageY8bitRight = ImageY8bit[0:720, 1280:2560]
			ImageCbCr8bitLeft  = ImageCbCr8bit[0:720,    0:1280]
			ImageCbCr8bitRight = ImageCbCr8bit[0:720, 1280:2560]

			cv2.imshow("ImageY8bitLeft", ImageY8bitLeft)
			cv2.imshow("ImageY8bitRight", ImageY8bitRight)
			cv2.imshow("ImageCbCr8bitLeft", ImageCbCr8bitLeft)
			cv2.imshow("ImageCbCr8bitRight", ImageCbCr8bitRight)

		if cv2.waitKey(1) > 0: break	#any key to break

capture.release()
cv2.destroyAllWindows()