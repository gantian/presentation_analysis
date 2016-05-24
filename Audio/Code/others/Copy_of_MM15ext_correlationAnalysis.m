clear;

addpath('./voicebox');

para.commonPath = 'W:/Dataset';
commonPath = sprintf('%s',para.commonPath);
currentPath = pwd;

for iSpeaker = 3:3
    disp(iSpeaker);
    
    pathAudio = sprintf('%s/Audio/Spk_%03d_A_WSS.mp4',commonPath,iSpeaker);
    
    pathKinect = sprintf('./kinect/Spk_%03d_D.mat',iSpeaker);
    dataload = load(pathKinect);
    kinect = dataload.kinect;
    
    pathGoogle= sprintf('%s/Motion/Spk_%03d_M_S.mat',commonPath,iSpeaker);
    dataLoad = load(pathGoogle);
    googledata = dataLoad.data;
        
    %Compute speaking rate feature
    Rate=[];
    syllables = textgrid2v(sprintf('%s/Audio/Spk_%03d_A_WSS.syllables.TextGrid',commonPath,iSpeaker));
    for i=1:floor(max(syllables)/5)
        Rate(i) = sum((syllables<5*i).*(syllables>5*(i-1)));
    end
    Rate=Rate';
    s=floor(max(syllables)/5)-1;
    s=s-1;
    Rate=Rate(1:s,1);
    
    %  Compute Energy feature
    [y,fs]=audioread(pathAudio);
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
    SkeletonFeatureSumWholebody = zeros(s,1);
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
            SkeletonWhole = jointstd(:,2:4)';
                        
            SkeletonFeatureSum(featureNum) = sum(SkeletonLocal(:));
            SkeletonFeatureSumWholebody(featureNum) = sum(SkeletonWhole(:));
        end
    end
        
    SkeletonFeatureSum(emptyindex,:)=[];
    SkeletonFeatureSumWholebody(emptyindex,:)=[];
    
    GoogleFeature(emptyindex,:)=[];
    GoogleFeatureSum(emptyindex,:)=[];
       
    pitchnew(emptyindex,:)=[];
    Rate(emptyindex,:)=[];
    Energy(emptyindex,:)=[];
    
    
    save(sprintf('./data/Spk_%03d_energy.mat',iSpeaker),'Energy');
    save(sprintf('./data/Spk_%03d_pitch.mat',iSpeaker),'pitchnew');
    save(sprintf('./data/Spk_%03d_rate.mat',iSpeaker),'Rate');
        
    save(sprintf('./data/Spk_%03d_GoogleFeature.mat',iSpeaker),'GoogleFeature');
    save(sprintf('./data/Spk_%03d_GoogleFeatureSum.mat',iSpeaker),'GoogleFeatureSum');
    
    save(sprintf('./data/Spk_%03d_gesture.mat',iSpeaker),'SkeletonFeatureSum');
    save(sprintf('./data/Spk_%03d_bodymovement.mat',iSpeaker),'SkeletonFeatureSumWholebody');
    
end