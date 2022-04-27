#!/usr/bin/env python3

import os
import rospy
from std_msgs.msg import String



def callback(data):
    print(data.data)
    if data.data=="detect":
        print("launching...")
        os.system('cd ~/figma/orb/try/OpenCV-Face-Recognition/FacialRecognition/ && ls && python3 ./03_face_recognition.py')   
    

    
def listener():
    
    rospy.init_node('recognitionNode', anonymous=True)

    rospy.Subscriber("recognitionSub",String, callback)

    rospy.spin()

if __name__ == '__main__':    
    listener()