function [Result_AP, Parameter] = MeasureAcquisitionParameters( Dataset, Parameter )


    %   Copyright (C) 2013 Heidelberg University 
    %   
    %   Developed at CKM (Computerunterstützte Klinische Medizin),
    %   Medical Faculty Mannheim, Heidelberg University, Mannheim, 
    %   Germany
    %   
    %   
    %   LICENCE
    %   
    %   CKM PhM Software Library, Release 1.0 (c) 2013, Heidelberg 
    %   University (the "Software")
    %   
    %   The Software remains the property of Heidelberg University ("the
    %   University").
    %   
    %   The Software is distributed "AS IS" under this Licence solely for
    %   non-commercial use in the hope that it will be useful, but in order
    %   that the University as a charitable foundation protects its assets for
    %   the benefit of its educational and research purposes, the University
    %   makes clear that no condition is made or to be implied, nor is any
    %   warranty given or to be implied, as to the accuracy of the Software,
    %   or that it will be suitable for any particular purpose or for use
    %   under any specific conditions. Furthermore, the University disclaims
    %   all responsibility for the use which is made of the Software. It
    %   further disclaims any liability for the outcomes arising from using
    %   the Software.
    %   
    %   The Licensee agrees to indemnify the University and hold the
    %   University harmless from and against any and all claims, damages and
    %   liabilities asserted by third parties (including claims for
    %   negligence) which arise directly or indirectly from the use of the
    %   Software or the sale of any products based on the Software.
    %   
    %   No part of the Software may be reproduced, modified, transmitted or
    %   transferred in any form or by any means, electronic or mechanical,
    %   without the express permission of the University. The permission of
    %   the University is not required if the said reproduction, modification,
    %   transmission or transference is done without financial return, the
    %   conditions of this Licence are imposed upon the receiver of the
    %   product, and all original and amended source code is included in any
    %   transmitted product. You may be held legally responsible for any
    %   copyright infringement that is caused or encouraged by your failure to
    %   abide by these terms and conditions.
    %   
    %   You are not permitted under this Licence to use this Software
    %   commercially. Use for which any financial return is received shall be
    %   defined as commercial use, and includes (1) integration of all or part
    %   of the source code or the Software into a product for sale or license
    %   by or on behalf of Licensee to third parties or (2) use of the
    %   Software or any derivative of it for research with the final aim of
    %   developing software products for sale or license to a third party or
    %   (3) use of the Software or any derivative of it for research with the
    %   final aim of developing non-software products for sale or license to a
    %   third party, or (4) use of the Software to provide any service to an
    %   external organisation for which payment is received. If you are
    %   interested in using the Software commercially, please contact 
    %   Prof. Dr. Lothar Schad (lothar.schad@medma.uni-heidelberg.de).
    %
    %Method Description:
    %-------------------
    %This method checks the whole acquisition for correct parameters of the
    %sequenz, the diameter of the phantom (multiple versions of the phantom)
    
    %predefinition of output parameters
    Result_AP.PhantomDiameter           = [];
    Result_AP.PhantomDiameterVector     = [];
    
    Result_AP.PixelBandwidth            = [];
    Result_AP.PixelBandwidthCell        = [];
    
    Result_AP.PixelSpacingX             = [];
    Result_AP.PixelSpacingY             = [];
    Result_AP.PixelSpacingXCell         = [];
    Result_AP.PixelSpacingYCell         = [];
    
    Result_AP.FOVX                      = [];
    Result_AP.FOVXCell                  = [];
    Result_AP.FOVY                      = [];
    Result_AP.FOVYCell                  = [];
    
    Result_AP.Width                     = [];
    Result_AP.Height                    = [];
    Result_AP.WidthCell                 = [];
    Result_AP.HeightCell                = [];
    
    Result_AP.BitDepth                  = [];
    Result_AP.BitDepthCell              = [];
    
    Result_AP.Weighting                 = [];
    Result_AP.WeightingCell             = [];
    Result_AP.Sequence                  = [];
    Result_AP.SequenceCell              = [];
    
    %AcquisitionMatrix
    % --> frequency rows\frequency columns\phase rows\phase columns
    Result_AP.FrequencyRows         = [];
    Result_AP.FrequencyColumns      = [];
    Result_AP.PhaseRows             = [];
    Result_AP.PhaseColumns          = [];
    
    Result_AP.FrequencyRowsCell     = [];
    Result_AP.FrequencyColumnsCell  = [];
    Result_AP.PhaseRowsCell         = [];
    Result_AP.PhaseColumnsCell      = [];
    
    
    Result_AP.NumberOfSlices            = numel(Dataset.Image);
    
    Result_AP.SliceThickness            = [];
    Result_AP.SliceThicknessCell        = [];
    
    Result_AP.SpacingBetweenSlices      = [];
    Result_AP.SpacingBetweenSlicesCell  = [];
    
    Result_AP.TE                        = [];
    Result_AP.TECell                    = [];
    
    Result_AP.TR                        = [];
    Result_AP.TRCell                    = [];
    
    Result_AP.MagneticFieldStrength     = [];
    
    NumOfSlices     = numel(Dataset.Info);
    
    PixelBandwidthCell                  = cell(1,NumOfSlices);
    PixelSpacingXCell                   = cell(1,NumOfSlices);
    PixelSpacingYCell                   = cell(1,NumOfSlices);
    PhantomDiameterVector               = nan(1,NumOfSlices);
    FOVXCell                            = cell(1,NumOfSlices);
    FOVYCell                            = cell(1,NumOfSlices);
    WidthCell                           = cell(1,NumOfSlices);
    HeightCell                          = cell(1,NumOfSlices);
    BitDepthCell                        = cell(1,NumOfSlices);
    WeightingCell                       = cell(1,NumOfSlices);
    SequenceCell                        = cell(1,NumOfSlices);
    SliceThicknessCell                  = cell(1,NumOfSlices);
    SpacingBetweenSlicesCell            = cell(1,NumOfSlices);
    TECell                              = cell(1,NumOfSlices);
    TRCell                              = cell(1,NumOfSlices);
    MagneticFieldStrengthCell           = cell(1,NumOfSlices);
    FrequencyRowsCell                   = cell(1,NumOfSlices);
    FrequencyColumnsCell                = cell(1,NumOfSlices);
    PhaseRowsCell                       = cell(1,NumOfSlices);
    PhaseColumnsCell                    = cell(1,NumOfSlices);
    
    %in addition, calculate the tilt along the axes to ensure, that the
    %phantom is correctly aligned. Throw a warning, if its not
    NumOfImages         = numel(Dataset.Image);
    CenterX_vec         = nan(NumOfImages,1);
    CenterY_vec         = nan(NumOfImages,1);
    Radius_vec          = nan(NumOfImages,1);
    SliceLocation_vec 	= nan(NumOfImages,1);
    
    for SliceIndex = 1 : NumOfSlices
        
        Image   = Dataset.Image{SliceIndex};
        Info    = Dataset.Info{SliceIndex};

        PixelSpacingXCell{SliceIndex} = Info.PixelSpacing(1);
        PixelSpacingYCell{SliceIndex} = Info.PixelSpacing(2);

        if PixelSpacingXCell{SliceIndex} ~= PixelSpacingXCell{SliceIndex}
            Error('WARNING: PixelSpacings are inconsistent')
        else
            try
                %if LOC slice is processed, also determine tilt angle to be
                %used later
                if SliceIndex == Dataset.Index_LOC
                    [CenterX, CenterY, Radius  , TiltAngle, ~] 	= GetPhantomCenter( Image,  Parameter, 1, 0, 0 );
                else
                    [CenterX, CenterY, Radius  , ~, ~] 	= GetPhantomCenter( Image,  Parameter, 0, 0, 0 );
                end
                    
                CenterX_vec(SliceIndex)         = CenterX;
                CenterY_vec(SliceIndex)         = CenterY;
                Radius_vec(SliceIndex)          = Radius;
                SliceLocation_vec(SliceIndex)   = Dataset.Info{SliceIndex}.SliceLocation;
                
            catch exception
                disp(exception)
                Radius = nan;
            end
            PhantomDiameterVector(SliceIndex)    = 2 * Radius * PixelSpacingXCell{SliceIndex};
        end
        
        PixelBandwidthCell{SliceIndex}          = Info.PixelBandwidth;
        WidthCell{SliceIndex}                   = Info.Width;
        HeightCell{SliceIndex}                  = Info.Height;
        BitDepthCell{SliceIndex}                = Info.BitDepth;
        WeightingCell{SliceIndex}               = Info.ProtocolName;
        SequenceCell{SliceIndex}                = Info.ScanningSequence;
        SliceThicknessCell{SliceIndex}          = Info.SliceThickness;
        SpacingBetweenSlicesCell{SliceIndex}    = Info.SpacingBetweenSlices;
        TECell{SliceIndex}                      = Info.EchoTime;
        TRCell{SliceIndex}                      = Info.RepetitionTime;
        MagneticFieldStrengthCell{SliceIndex}   = Info.MagneticFieldStrength;
        FOVXCell{SliceIndex}                    = WidthCell{SliceIndex} * PixelSpacingXCell{SliceIndex};
        FOVYCell{SliceIndex}                    = HeightCell{SliceIndex} * PixelSpacingXCell{SliceIndex};
        FrequencyRowsCell{SliceIndex}           = Info.AcquisitionMatrix(1);
        FrequencyColumnsCell{SliceIndex}        = Info.AcquisitionMatrix(2);
        PhaseRowsCell{SliceIndex}               = Info.AcquisitionMatrix(3);
        PhaseColumnsCell{SliceIndex}            = Info.AcquisitionMatrix(4);
        
    end
    
    Bool = nan(15,1);

    Result_AP.PhantomDiameter       = mean(PhantomDiameterVector(~isnan(PhantomDiameterVector)));
    Result_AP.PhantomDiameterVector = PhantomDiameterVector;
    [Result_AP.PixelSpacingX,           Bool( 1  ),  Result_AP.PixelSpacingXCell        ]   = CheckConsistency( PixelSpacingXCell );
    [Result_AP.PixelSpacingY,           Bool( 2  ),  Result_AP.PixelSpacingYCell        ]   = CheckConsistency( PixelSpacingYCell );
    [Result_AP.Width,                   Bool( 3  ),  Result_AP.WidthCell                ]   = CheckConsistency( WidthCell );
    [Result_AP.Height,                  Bool( 4  ),  Result_AP.HeightCell               ]   = CheckConsistency( HeightCell );
    [Result_AP.BitDepth,                Bool( 5  ),  Result_AP.BitDepthCell             ]   = CheckConsistency( BitDepthCell );
    [Result_AP.Weighting,               Bool( 6  ),  Result_AP.WeightingCell            ]   = CheckConsistency( WeightingCell );
    [Result_AP.Sequence,                Bool( 7  ),  Result_AP.SequenceCell             ]   = CheckConsistency( SequenceCell );
    [Result_AP.SliceThickness,          Bool( 8  ),  Result_AP.SliceThicknessCell       ]   = CheckConsistency( SliceThicknessCell );
    [Result_AP.SpacingBetweenSlices,    Bool( 9  ),  Result_AP.SpacingBetweenSlicesCell ]   = CheckConsistency( SpacingBetweenSlicesCell );
    [Result_AP.TE,                      Bool( 10 ),  Result_AP.TECell                   ]   = CheckConsistency( TECell );
    [Result_AP.TR,                      Bool( 11 ),  Result_AP.TRCell                   ]   = CheckConsistency( TRCell );
    [Result_AP.MagneticFieldStrength,   Bool( 12 ),  Result_AP.MagneticFieldStrengthCell]   = CheckConsistency( MagneticFieldStrengthCell );
    [Result_AP.FOVX,                    Bool( 13 ),  Result_AP.FOVXCell                 ]   = CheckConsistency( FOVXCell );
    [Result_AP.FOVY,                    Bool( 14 ),  Result_AP.FOVYCell                 ]   = CheckConsistency( FOVYCell );
    [Result_AP.PixelBandwidth,          Bool( 15 ),  Result_AP.PixelBandwidthCell       ]   = CheckConsistency( PixelBandwidthCell );
    [Result_AP.FrequencyRows,           Bool( 16 ),  Result_AP.FrequencyRowsCell        ]   = CheckConsistency( FrequencyRowsCell );
    [Result_AP.FrequencyColumns,        Bool( 17 ),  Result_AP.FrequencyColumnsCell     ]   = CheckConsistency( FrequencyColumnsCell );
    [Result_AP.PhaseRows,               Bool( 18 ),  Result_AP.PhaseRowsCell         	]   = CheckConsistency( PhaseRowsCell );
    [Result_AP.PhaseColumns,            Bool( 19 ),  Result_AP.PhaseColumnsCell     	]   = CheckConsistency( PhaseColumnsCell );
    
    %% determine tilt along axes
    %remove nans
    CenterX_vec(isnan(CenterX_vec))             = [];
    CenterY_vec(isnan(CenterY_vec))             = [];
    SliceLocation_vec(isnan(SliceLocation_vec))	= [];
    
    %tilt in X
    [pX, kX] = PolynomInterpolation(SliceLocation_vec/PixelSpacingXCell{1}, CenterX_vec, 'linear');
    %tilt in Y
    [pY, kY] = PolynomInterpolation(SliceLocation_vec/PixelSpacingYCell{1}, CenterY_vec, 'linear');
    
    %only for testing purpose
%     figure
%     subplot(2,1,1)
%     plot(SliceLocation_vec,CenterX_vec,'-*r')
%     grid on
%     xlabel('z','Fontweight','bold')
%     ylabel('x','Fontweight','bold')
%     subplot(2,1,2)
%     plot(SliceLocation_vec,CenterY_vec,'-*r')
%     grid on
%     xlabel('z','Fontweight','bold')
%     ylabel('y','Fontweight','bold')
    
    %print to command
    fprintf('X tilt (abs.): %.2f°\n',abs(atan(kX(2)))/pi*180)
    fprintf('Y tilt (abs.): %.2f°\n',abs(tan(kY(2)))/pi*180)
    fprintf('Z tilt (abs.): %.2f°\n',abs(TiltAngle)/pi*180)
    
    if max([abs(atan(kX(2)))/pi*180, ...
            abs(tan(kY(2)))/pi*180, ...
            abs(TiltAngle)/pi*180]) > Parameter.LOC.MaxTiltAngle
        warning('WarnTests:convertTest','The phantom seems to be badly aligned; the results of the quality evaluation might be inaccurate! (Threshold is %.1f°)',Parameter.LOC.MaxTiltAngle)
    end

    if min(Bool) == 0
       Error('WARNING: AcqParams seem to be inconsistent!') 
    end
    
