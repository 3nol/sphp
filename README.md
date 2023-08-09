# This MATLAB code implements the SPHP image stitching method

This warp was originally proposed in the SPHP paper by Chang et al. [1] in 2014.

### OS-specific Implementation

With the dependence on the mysterious `texture_mapping/texture_mapping.exe` file to apply the calculated warp to the images, this implementation is OS-specific.

Currently, it is tweaked to work on Linux (and most likely MacOS - yet untested). For running this implementation on Windows, simply remove the `wine` invocation in line 86 of the file `texture_mapping.m`.

### Running the warp

This branch `stereo` is a reduced form of the repository on `master`.
It focuses on running the SPHP warp on two input images, and a given input homography `H0`.
Run "SPHP_stereo_warp.m" in MATLAB to reproduce the results shown in the paper.
Given two input file names and `H0`, this function returns two warped images and masks.

The implementation in this fork was modified to split up functionality.
Please email the original author (frank@cmlab.csie.ntu.edu.tw) if you have any problems/questions about the code, *not including the changes here*.

### References

[1] C.-H. Chang, Y. Sato, and Y.-Y. Chuang. Shape-Preserving Half-Projective Warps for Image Stitching. CVPR 2014.
