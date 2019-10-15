# -*- coding: utf-8 -*-
"""
Created on Mon Oct 14 21:42:48 2019

@author: jayja
"""

# -*- coding: utf-8 -*-
"""
Created on Mon Oct 14 20:28:23 2019

@author: jayja
@references: https://en.wikipedia.org/wiki/YUV
"""
#reading and writing images
import cv2
from timeit import default_timer as timer
import numpy as np
import os

def cpu_convert_frame(image):
    yuv = np.zeros_like(image)
    r_channel = image[:, :, 2]
    g_channel = image[:, :, 1]
    b_channel = image[:, :, 0]
    
    yuv[:, :, 0] = 0.2126 * r_channel + 0.7152 * g_channel + 0.0722 * b_channel
    #U and V values may be negative, so we sum them with 128 to always make them positive
    yuv[:, :, 1] = -0.09991 * r_channel - 0.33609 * g_channel + 0.436 * b_channel + 128
    yuv[:, :, 2] = 0.615 * r_channel - 0.55861 * g_channel - 0.05639 * b_channel + 128
    return yuv

def convert_images_cpu(source_dir, destination_dir):
    list_of_files = list(os.walk(source_dir))[0][2] #0: parent directory, 2: all files in directory
    if(len(list_of_files) == 0):
        raise Exception('Files not found. Verify source and destination directory entry')
        
    start = timer()
    for file_name in list_of_files:
        try:
            image = cv2.imread(source_dir + file_name)
            ret_image = cpu_convert_frame(image)
            cv2.imwrite(destination_dir + 'HD_' + file_name, ret_image)
        except Exception as e:
            print(f'File {file_name} not accessible')
            print(e)
    end = timer()
    print(f'Processed total {len(list_of_files)} files')
    print(f'Total time for CPU {end - start} seconds')

def convert_videos_cpu(input_file, output_file):
    start = timer()
    #Capture videos, in this case, captures input_file
    cap = cv2.VideoCapture(input_file)
    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    #fourcc specifies which codec version we want to use. Various include XVID, X264 etc
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    #cv2.VideoWriter(filename, codec, 20.0, (width, height))
    out = cv2.VideoWriter('HD_' + output_file, fourcc, 25.0, (frame_width, frame_height))
    while(cap.isOpened()):
        #ret will be True or False, frame will contain frame
        ret, frame = cap.read()
        if ret == False:
            break
        yuv = cpu_convert_frame(frame)
        out.write(yuv)
        #To get out of the loop
        if cv2.waitKey(1) & 0xFF == ord('a'):
            break
    end = timer()
    
    print(f'Total time for HD_CPU to convert video {end - start} seconds')
    #Releases the camera/ video. 
    cap.release()
    #Releases the output file
    out.release()
    cv2.destroyAllWindows()