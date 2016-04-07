function [ ret ] = textFormant2v( fName )
z = textread(fName,'%s','commentstyle','matlab','headerlines',1,'delimiter','\n');

numPoints=sscanf(z{1},'''numInterv''\t %d');

if ~isnumeric(numPoints)
  error('Error %s.',fName);
end

ret = zeros(numPoints,3);
for iNumPoints = 3:numPoints-2
    j =1+iNumPoints;
    ret(iNumPoints,:) = sscanf(z{j},'%f %f %f');    
end 
end
