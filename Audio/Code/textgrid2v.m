function [ ret ] = textgrid2v( fName )
    z = textread(fName,'%s','commentstyle','matlab','headerlines',6,'delimiter','\n');
    
    numPoints=sscanf(z{8},'points: size =%d');
    
    if ~isnumeric(numPoints)
        error('%s.TextGrid not right PWS format',fName);
    end
    
    ret = zeros(numPoints,1);
    for iNumPoints = 1:numPoints
        j = 7 + 3*iNumPoints;
        ret(iNumPoints) = sscanf(z{j},'number = %f');
    end
    
    
end

