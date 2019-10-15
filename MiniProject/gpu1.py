# -*- coding: utf-8 -*-
"""
Created on Mon Oct 14 21:45:15 2019

@author: jayja
"""

import os
#used for cuda Python
from numba import vectorize
import cv2
from timeit import default_timer as timer
import numpy as np
#output scalar(input scalars)
#output scalar is returned
@vectorize(['float32(float32, float32, float32)'], target = 'cuda')
def ret_y_channel(r_channel, g_channel, b_channel):
    return 0.2126 * r_channel + 0.7152 * g_channel + 0.0722 * b_channel

@vectorize(['float32(float32, float32, float32)'], target = 'cuda')
def ret_u_channel(r_channel, g_channel, b_channel):
    return -0.09991 * r_channel - 0.33609 * g_channel + 0.436 * b_channel + 128

@vectorize(['float32(float32, float32, float32)'], target = 'cuda')
def ret_v_channel(r_channel, g_channel, b_channel):
    return 0.615 * r_channel - 0.55861 * g_channel - 0.05639 * b_channel + 128

def gpu_convert_frame(image):
    height, width, channel = image.shape
    red_channel = image[:, :, 2]
    green_channel = image[:, :, 1]
    blue_channel = image[:, :, 0]
    red_channel = red_channel.reshape(height * width).astype('float32')
    green_channel = green_channel.reshape(height * width).astype('float32')
    blue_channel = blue_channel.reshape(height * width).astype('float32')
    
    y_channel = ret_y_channel(red_channel, green_channel, blue_channel)
    u_channel = ret_u_channel(red_channel, green_channel, blue_channel)
    v_channel = ret_v_channel(red_channel, green_channel, blue_channel)
    
    y_channel = y_channel.reshape(height, width)
    u_channel = u_channel.reshape(height, width)
    v_channel = v_channel.reshape(height, width)
    
    yuv = np.zeros_like(image)
    yuv[:, :, 0] = y_channel
    yuv[:, :, 1] = u_channel
    yuv[:, :, 2] = v_channel
    
    return yuv

def convert_images_gpu(source_dir, destination_dir):
    list_of_files = list(os.walk(source_dir))[0][2]
    
    if(len(list_of_files) == 0):
        raise Exception('Files not found. Verify source and destination directory entry')
        
    start = timer()
    for file_name in list_of_files:
        try:
            image = cv2.imread(source_dir + file_name)
            ret_image = gpu_convert_frame(image)
            cv2.imwrite(destination_dir + 'HDgpu_' +file_name, ret_image)
        except Exception as e:
            print(f'File {file_name} not accessible')
            print(e)
    end = timer()
    print(f'Processed tool {len(list_of_files)} files')
    print(f'Total time for GPU {end - start} seconds')
    
def convert_video_gpu(input_file, output_file):
    start = timer()
    cap = cv2.VideoCapture(input_file)
    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    #fourcc specifies which codec version we want to use. Various include XVID, X264 etc
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    #cv2.VideoWriter(filename, codec, 20.0, (width, height))
    out = cv2.VideoWriter('HDgpu_' + output_file, fourcc, 25.0, (frame_width, frame_height))
    while(cap.isOpened()):
        #ret will be True or False, frame will contain frame
        ret, frame = cap.read()
        if ret == False:
            break
        yuv = gpu_convert_frame(frame)
        out.write(yuv)
        #To get out of the loop
        if cv2.waitKey(1) & 0xFF == ord('a'):
            break
    end = timer()
    
    print(f'Total time for HD_GPU to convert video {end - start} seconds')
    #Releases the camera/ video. 
    cap.release()
    #Releases the output file
    out.release()
    cv2.destroyAllWindows()