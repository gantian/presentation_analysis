function y = ReadSkeleton(data,frameNum)

jointFeatureSZ = 9;
numJoint = 20;

feat = zeros(numJoint,jointFeatureSZ);
row = data(frameNum,:);

if row(3)~=0 
   for iNumJoint = 1:numJoint
       feat(iNumJoint,:) = row(4+(iNumJoint-1)*jointFeatureSZ:...
            4+(iNumJoint)*jointFeatureSZ-1);
   end                

end

y=feat;

end