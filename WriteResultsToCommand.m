function Parameter = WriteResultsToCommand(Results, References, Parameter)

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
    
    % ===============================================
    
    %Method Description:
    %-------------------
    %write the resulting quality parameters to the command. If set the
    %results are compared with reference values  and printed red if the
    %resulting values exceed the range of valid reference values.

    ResultNames     = fieldnames(Results);
    ReferencesNames = fieldnames(References);
    
    LeftSpace       = 4;
    FixColumn       = 1;
    Status          = {'OK','FAILED!'};
    
    StringCell          = cell(numel(ResultNames), 4); 
    
    for Index = 1 : numel(ResultNames)
        CurrentResultName   = ResultNames{Index};
        if numel(Results.(ResultNames{Index})) == 1 && ... %field is existing...
           isfield(References,ResultNames{Index})          %...and to be printed    

            CurrentValue        = Results.(ResultNames{Index});
            RefIndex            = find(strcmp(ReferencesNames, CurrentResultName));
            if ~isempty(RefIndex)
                CurrentReference    = References.(ReferencesNames{RefIndex});
                %Create CurrentReferenceString
                if isempty(CurrentReference)
                    CurrentReferenceString = '';
                elseif isinf(CurrentReference(1))
                    CurrentReferenceString = ['< ',num2str(CurrentReference(2))];
                elseif isinf(CurrentReference(2))
                    CurrentReferenceString = ['> ',num2str(CurrentReference(1))];
                else
                    CurrentReferenceString = [num2str(CurrentReference(1)),'...',num2str(CurrentReference(2))];
                end
            else
                CurrentReferenceString  = '';  
                CurrentReference        = [];
            end

            %Set String
            StringCell{Index, 1}    = CurrentResultName;
            StringCell{Index, 2}    = num2str(CurrentValue);
            StringCell{Index, 3}    = CurrentReferenceString;

            %Check for Validation
            % --> 1 = valid
            % --> 2 = invalid

            if numel(CurrentReference) == 2
                if CurrentValue >= CurrentReference(1) && ...
                   CurrentValue <= CurrentReference(2) 
                        %Value is in Range
                        StringCell{Index, 4} = 1;
                else
                        %Value is out of Range
                        StringCell{Index, 4} = 2;
                end
            else
                StringCell{Index, 4} = 1;
            end
        end
        
    end

    if FixColumn == 0
        MaxResultLength         = max(cellfun(@length, StringCell(:,1)));
        MaxValueLength          = max(cellfun(@length, StringCell(:,2)));
        MaxReferenceLength      = max(cellfun(@length, StringCell(:,3)));
    else
        MaxResultLength         = 30;
        MaxValueLength          = 12;   
        MaxReferenceLength      = 12;
    end
    
    fprintf(1,' \n');
    for Index = 1 : numel(ResultNames)
        if ~isempty(StringCell{Index,4})
            fprintf(        StringCell{Index,4}, ...        
                          [ Blank(LeftSpace),...
                            Blank(MaxResultLength - length(StringCell{Index,1})),...
                            StringCell{Index,1},...
                            ':',...
                            Blank(4),...
                            StringCell{Index,2},...
                            Blank(MaxValueLength - length(StringCell{Index,2})),...
                            Blank(8),...
                            StringCell{Index,3},...
                            Blank(MaxReferenceLength - length(StringCell{Index,3})),...
                            Blank(8),...
                            '--> ',...
                            Status{StringCell{Index,4}},...
                            '\n']);
            Parameter.GEN.CommandCell = [Parameter.GEN.CommandCell, ...
                            [ Blank(LeftSpace),...
                            Blank(MaxResultLength - length(StringCell{Index,1})),...
                            StringCell{Index,1},...
                            ':',...
                            Blank(4),...
                            StringCell{Index,2},...
                            Blank(MaxValueLength - length(StringCell{Index,2})),...
                            Blank(8),...
                            StringCell{Index,3},...
                            Blank(MaxReferenceLength - length(StringCell{Index,3})),...
                            Blank(8),...
                            '--> ',...
                            Status{StringCell{Index,4}} ]];
        end
    end
    fprintf(1,' \n');
    
