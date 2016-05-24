Path = 'Y:\LiJunnan\Presentation Data New';
DistPath = 'C:\Users\li\Desktop\CCA';
dirlist = dir(DistPath);

for n=3:length(dirlist)
   folder = fullfile(Path,dirlist(n).name);     
   distPath = fullfile(DistPath,dirlist(n).name);

   Pathkinect = fullfile(folder,[dirlist(n).name '_D.mat']);
   Pathgoogle= fullfile(folder,[dirlist(n).name '_M_S.mat']); 
   Pathaudio = fullfile(folder,[dirlist(n).name '_A_WSS.mp4']);   
   dataload = load(Pathkinect);
   kinect = dataload.kinect;
   dataLoad = load(Pathgoogle);
   googledata = dataLoad.data;
   
%Compute speaking rate feature   
   Rate=[];
   sylName = fullfile(DistPath,dirlist(n).name,[[dirlist(n).name] '.syllables.TextGrid']);
   syllables = textgrid2v(sylName);
   for i=1:floor(max(syllables)/5)
       Rate(i) = sum((syllables<5*i).*(syllables>5*(i-1)));
   end
   Rate=Rate';
   s=floor(max(syllables)/5)-1;
   s=s-1;
   Rate=Rate(1:s,1);
   

%  Compute Energy feature
   [y,fs]=audioread(Pathaudio);
   
    y = y.';
    duration=size(y,2)/fs;
    wintype = 'rectwin';
    winlen = 5*fs;
    E = sum(buffer(y.^2, winlen));  
    E=E';
    Energy=E(1:s,:);

   %Compute Pitch
   [pitch,tx,pv,fv]=fxpefac(y,fs,0.1);   
   pitchnew = zeros(s,1);
   for i=1:s
       for j=1:50
           pitchnew(i) = pitchnew(i)+pitch(50*(i-1)+j);
       end
   end
   pitchnew = pitchnew/50;  
       
    
   ept=1;
   emptyindex = [];

   %Compute head movement
   GoogleFeature = zeros(s,13);
   GoogleFeatureSum = zeros(s,1);
   for featureNum=1:s    
            GoogleLocal  = zeros(125,13);
            GooglelocalLess = zeros(125,6);
            for i=1:125
                frame = (featureNum-1)*125+i;
                GoogleLocal(i,:) = [googledata(frame,3:5) googledata(frame,9:11) ...
                    googledata(frame,13:15) googledata(frame,19:22)];
                GooglelocalLess(i,:) = [googledata(frame,9:11) googledata(frame,13:15)];
            end          
            GoogleLocal(all(~GoogleLocal,2), : )=[];
            if size(GoogleLocal,1)>1
                GoogleMean = mean(GoogleLocal);
                GoogleMeanLess = mean(abs(GooglelocalLess));
                GoogleFeature(featureNum,:)=GoogleMean;
                GoogleFeatureSum(featureNum) = sum(GoogleMeanLess(:));
            else   
                emptyindex(ept) = featureNum;
                ept=ept+1; 
            end
   end
  
%   Compute body movement
    SkeletonFeatureSum = zeros(s,1);
    for featureNum=1:s
        featcount=ones(11,1);
        joint={};
        for i=1:125                   
           feat = ReadSkeleton(kinect,(featureNum-1)*125+i);
               for k=1:11  
                   if feat(k+1,1)~=0 
                       joint.(['j' int2str(k)])(featcount(k),:)=feat(k+1,:);
                       featcount(k)=featcount(k)+1;
                   end
               end
        end
        if isempty(joint)
             emptyindex(ept) = featureNum;
             ept=ept+1;  
        else
            jointstd=zeros(11,9);
            for k=1:11               
                jointstd(k,:)=std(joint.(['j' int2str(k)]));
            end
            jointPosStd = jointstd(4:11,2:4);
            SkeletonLocal = jointPosStd(:)';   

            SkeletonFeatureSum(featureNum) = sum(SkeletonLocal(:));
        end
    end  
   
    
    SkeletonFeature(emptyindex,:)=[];
    SkeletonFeatureSum(emptyindex,:)=[];
    GoogleFeature(emptyindex,:)=[];
    GoogleFeatureSum(emptyindex,:)=[];

    pitchnew(emptyindex,:)=[];
    Rate(emptyindex,:)=[];
    Energy(emptyindex,:)=[];
    
    if size(GoogleFeature,1)<50 
        fprintf([dirlist(n).name ' size is' num2str(size(GoogleFeature,1)) '\n']);
    end
    save(fullfile(distPath,'energy.mat'),'Energy');
    save(fullfile(distPath,'pitch.mat'),'pitchnew');
    save(fullfile(distPath,'Rate.mat'),'Rate');    
    save(fullfile(distPath,'Gesture.mat'),'SkeletonFeatureSum');      
    save(fullfile(distPath,'GoogleFeature.mat'),'GoogleFeature');  
    save(fullfile(distPath,'GoogleFeatureSum.mat'),'GoogleFeatureSum');       
    fprintf([dirlist(n).name '\n']);
end