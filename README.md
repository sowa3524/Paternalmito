# Paternalmito
Analysis1:Tracking of the posterior boundary of NMY-2::GFP and paternal mitochondria

We used a three-step analysis of time-lapse movie to track the average X coordinates (along the A-P axis) of paternal mitochondria and the X coordinates of the posterior boundary of NMY-2::GFP patches in each embryo. 

Analysis 5: Calculation of Mander’s coefficient of MTR (red) and DNC-1::mNG (green) before the shuffling (M1raw) and after the shuffling (M1shuffled) of pixels in the green channel. 
To use this app:
1) Open and run the analysis5_pmcoloc.mlapp in Matlab
2) In 'path', specify the input folder that contains the two-channel (red and green) tif images to be analyzed.
3) Click 'Load Image' to select and import the image to be analyzed.
4) Click on the spot of interest on the imported image to set the top-left corner of the ROI, the coordinates of this spot will be shown in the app as 'Starting X' and 'Starting Y' in the unit of pixels. Then specify the ROI size by inputting 'Width delta X' and 'Height delta Y' in the units of pixels. The width and height of the ROI do not need to be the same. Then click 'Set ROI', and the ROI selected will be outlined in yellow. 
5) Input 'Red Threshold', 'Green Threshold', and 'Random Seed', then click 'Analysis'.The app will randomly shuffle the pixels in the green channel, and calculate Mander's coefficient before and after the shuffling. The shuffling results could be different when inputting different random seeds, so it's recommended to choose the same random seed for different samples of the same experiment. 
6) Mander's coefficients are shown in the 'Result' window. The app also automatically copies to the clipboard the N of pixels above the red threshold, N of pixels above the green threshold, N of pixels above both thresholds before shuffling, and N of pixels above both thresholds after shuffling. These four values can be directly pasted into software like Excel for downstream analysis. 
