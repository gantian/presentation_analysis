clear;

addpath('./voicebox');

para.commonPath = 'W:/Dataset';
commonPath = sprintf('%s',para.commonPath);
currentPath = pwd;

para.lenFeature = 5;

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
    %Rate=[];
    syllables = textgrid2v(sprintf('%s/Audio/Spk_%03d_A_WSS.syllables.TextGrid',commonPath,iSpeaker));
    
    lenAudio = floor(max(syllables));
    rate = zeros(lenAudio - para.lenFeature+1,1);
    for iLenAudio = 1:(lenAudio - para.lenFeature+1)
        rate(iLenAudio) = sum((syllables<=(iLenAudio-1+para.lenFeature).*(syllables>(iLenAudio-1))));
    end
   
    %%  Compute Energy feature
    [audioData,fs]=audioread(pathAudio);    
    duration=floor(size(audioData,1)/fs);    
    
    energy_second = sum(buffer(audioData.^2, fs))';        
    movingSum = conv(energy_second, ones(1, para.lenFeature));
    energy = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);

    %Compute Pitch
    [pitch_tmp,tx,pv,fv]=fxpefac(audioData,fs,0.1);
    
    pitch_second = sum(buffer(pitch_tmp,10))';
    movingSum = conv(pitch_second, ones(1, para.lenFeature));
    pitch = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);
    
        
    ept=1;
    emptyindex = [];
    
    %% Compute head movement
    sensor_second = zeros(duration,1);
    for iDuration = 1:duration
        selectedFrames = (iDuration-1)*25+1:iDuration*25;
        sensor_second_tmp = [googledata(selectedFrames,9:11) googledata(selectedFrames,13:15)];
        sensor_second(iDuration) = sum(mean(abs(sensor_second_tmp)));        
    end
    
    %% Compute body movement
    kinect_second = zeros(duration,6);
    kinect_gesture = zeros(duration,1);
    kinect_wholeBody = zeros(duration,1);
    
    for iDuration = 1:duration
        wholeBody_selection = (2:12);
        %gesture_selection = (5:12);
        wholeBodyFeat_tmp = zeros(25,3);
        for iFrame = 1:25
            feat_frame = ReadSkeleton(kinect,(iDuration-1)*25+iFrame);
            wholeBodyFeat_tmp(iFrame,:) = feat_frame(wholeBody_selection,2:4);%Pos_X to Pos_Z            
        end
        
        
        wholeBodyFeat_secondLoc = mean(wholeBodyFeat_tmp);
    end
    
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
    
    
    GoogleFeature = zeros(duration,13);
    GoogleFeatureSum = zeros(duration,1);
    for featureNum=1:duration
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