# DeepBTSeg
DeepBTSeg provides the user-friendly graphical user interface (GUI) of remote state-of-the-art deep learning models, which allow users to conduct deep learning  brain tumor image segmentation without the cumbersome of both software and hardware requirements on users' local computers. 

This repository is the client end Matlab code of DeepBTSeg. We also provide the executable version of DeepBTSeg [here](https://github.com/IQMLatUAB/DeepBTSeg-executable).
 DeepBTSeg is developed under Matlab 2020b and is executable under Matlab 2019b and Matlab 2020a. Running the DeepBTSeg Matlab code under Matlab 2020b is recommended.

# Installation

Dowload DeepBTSeg repository and unzip it.

![](images/9.png)

or try
    
    $ git clone https://github.com/IQMLatUAB/DeepBTSeg.git
Open the DeepNI folder in matlab.

# DeepBTSeg GUI
![](images/DeepBTGUI_whole_window.PNG)
# User instructions
1.Make sure the current folder of Matlab is under DeepBT.

2.Run DeepBT_GUI.m under the DeepBT folder in matlab.

3.Click "Load images" button to select the directory of DICOM images.

4.Using the checklist on the left of the DICOM_selection_GUI window to specify the pre-contrast T1, post-contrast T1, FLAIR, and T2 images.

5.Click “Submit job for selected model” to transmit this job to the server for processing or click “Submit jobs for all models” to apply all models on the current DICOM image series.

6.Click "Check job" under the "Action" menu or "Update status for all jobs" button to refresh the job status and messages from the remote server, which shown in matlab command window.

7.Click "Export results" under the "Action" menu to save processing results as DICOM RTSS file  when the job status is "Completed". Make sure you export results before you close DeepBT  because non-save results will be automatically eliminated.
