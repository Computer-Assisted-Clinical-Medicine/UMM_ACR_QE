This document gives a brief overview on how to perform the evaluation using the automated quality assurance methods provided in this package.

Creating Datasets:
------------------

The package contains a graphical user interface that can be used to create datasets (.mat-files) that can be processed by Matlab. The interface can be started by typing OpenPhantomGUI in the command. The list at the bottom contains an example dataset, that has been acquired with Siemens 3T Skyra MR scanner. After loading, scroll through the slices and define which slice is used for which evaluation (e.g. when the slice with the large grid structure shows up, klick "Spatial Linearity"). After all slices are defined, klick Save and the dataset will be stored in "Phantom Datasets". Note, that an automated extraction of the parameters has been implemented based on the IMAGEN-protocol. This might not work with other measurements. In this case the dataset will be saved as "Unknown dataset" and can be renamed afterwards. In addition, the dataset can be easily opened and changed in Matlab. 

Starting Evalution:
-------------------

The "Phantom Datasets"-folder already contains an example .mat-dataset file that can be evaluated for testing purpose. Therefore open the .m-file "PerformEvaluation". This is set such, that the dataset will be automatically loaded and checked for all quality parameters. The results will be stored in a subfolder in "Phantom Results", along with a copy of the command output and several images visualizing the results. 

Visualization and Interpretation:
---------------------------------

In addition, the package contains several files, that can be used to compare the multiple datasets with each other or to print the results of the specified datasets to an Excel sheet:

See also:

- CreateExcelSheetAcqParam.m
- CreateExcelSheet.m
- PlotResults.m
- PlotSiteOverviewColumns.m

Quality Tests:
--------------

Procedures have been implemented to evaluate the accuracy of all methods based on synthetic images with predefined distortions. The test are performed in the .m-files QT_Test...
Each files stores the results in some .mat files in "QT Results". After all evaluations have been performed, QT_CalculateFinalResults.m can be used to perform the final evalution, i.e. print the mean values and STD as well as the maximal error for each evaluated parameter to the command.


Testdata:
---------
Test data sets are available here:

Davids, M.; Zöllner, F.; Ruttorf, M.; Nees, F.; Flor, H.; Schumann, G.; Schad, L.; the Imagen Consortium, 2019, "Fully-automated quality assurance in multi-center studies using MRI phantom measurements [Dataset]", https://doi.org/10.11588/data/RR5BMF, heiDATA, V1


References:
-----------

If you use this package in your research or work please cite the following paper:

M. Davids, F. Zöllner, M. Ruttorf, F. Nees, H. Flor, G. Schumann and L. Schad and the IMAGEN Consortium.
Fully-automated quality assurance in multi-center studies using MRI phantom measurements.
Magn Reson Imaging, 2014, 32, pp.771-780 
http://dx.doi.org/10.1016/j.mri.2014.01.017

and the DOI to this repository:

[![DOI](https://zenodo.org/badge/531500734.svg)](https://zenodo.org/badge/latestdoi/531500734)
