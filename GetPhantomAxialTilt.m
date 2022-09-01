%function [a,b] = GetPhantomAxialTilt( Dataset, Parameter)


NumOfImages     = numel(Dataset.Image);
CenterX_vec     = nan(NumOfImages,1);
CenterY_vec     = nan(NumOfImages,1);
Radius          = nan(NumOfImages,1);

%iterate over all images, get center values and slice position
for k = 1 : NumOfImages
    [CenterX, CenterY, Radius, ~, ~] = GetPhantomCenter( Dataset.Image{k}, Parameter, 0, 0, 0 );
    
    
    
end