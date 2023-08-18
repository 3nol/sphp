# This MATLAB code implements the SPHP image stitching method

This warp was originally proposed in the SPHP paper by Chang et al. [1] in 2014.

### OS-specific Implementation

With the dependence on the mysterious `texture_mapping/texture_mapping.exe` file to apply the calculated warp to the images, this implementation is OS-specific.

Currently, it is tweaked to work on Linux (and most likely MacOS - yet untested). For running this implementation on Windows, simply remove the `wine` invocation in line 86 of the file `texture_mapping.m`.

### Setting up VLFeat on Linux

Compiling the needed `MEX` files is not an easy task and I already took steps to fix *compile errors* in the current VLFeat version 0.9.21. 
For more details on this, see their [issue on GitHub](https://github.com/vlfeat/vlfeat/issues/214). 
I also replaced deprecated and removed functions in the MATLAB code.

The \<YOUR-PATH\> variable, that is used below, describes the clone location of this repository.
For the actual compilation, you need to follow these steps. 

1. Make sure that you exported VLFeat's mex path to `LD_LIBRARY_PATH`. Add the following line to your preferred terminal config file, e.g. ".bashrc".

    ```bash
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<YOUR-PATH>/sphp-warp/vlfeat-0.9.21/toolbox/mex/mexa64/
    ```

2. Open MATLAB. Find out where the \<MATLABROOT\> lies, using the `matlabroot` command. Find out which \<ARCH\> you are on, using the `computer` command. The output of `computer` is most likely all-caps and needs to be inserted in lowercase below.

3. Open a terminal and `cd <YOUR-PATH>/sphp-warp/vlfeat-0.9.21`. Then, execute the following command.

    ```bash
    make ARCH=<ARCH> MEX=<MATLABROOT>/bin/mex
    ```

4. VLFeat should now compile fine. The remaining setup is done by calling `run('vlfeat-0.9.21/toolbox/vl_setup')` in the MATLAB code. You can check that this works by running the "run_stitch_example.m" file. 

### Running examples

Run a "run_*_example.m" in MATLAB to reproduce the results shown in the paper and in the supplementary materials.
The implementation in this fork was modified to split up functionality.
Please email the original author (frank@cmlab.csie.ntu.edu.tw) if you have any problems/questions about the code, *not including the changes here*.


The following images are from another source [2]:
```
images/temple_01.jpg
images/temple_02.jpg
```

### References

[1] C.-H. Chang, Y. Sato, and Y.-Y. Chuang. Shape-Preserving Half-Projective Warps for Image Stitching. CVPR 2014.

[2] J. Gao, S. J. Kim, and M. S. Brown. Constructing image panoramas using dual-homography warping. CVPR 2011.
