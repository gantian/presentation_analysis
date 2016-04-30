clear;

addpath('./voicebox');

para.commonPath = 'W:/Dataset';
commonPath = sprintf('%s',para.commonPath);
currentPath = pwd;

para.lenFeature = 5;

for iSpeaker = 26:51
    disp(iSpeaker);
    
    %% load the original data
    pathAudio = sprintf('%s/Audio/Spk_%03d_A_WSS.mp4',commonPath,iSpeaker);
    [audioData,fs]=audioread(pathAudio);    
    duration=floor(size(audioData,1)/fs);    
    
    validFlag = ones(duration,1);
    
    pathKinect = sprintf('./kinect/Spk_%03d_D.mat',iSpeaker);
    dataload = load(pathKinect);
    kinect = dataload.kinect;
    
    pathGoogle= sprintf('%s/Motion/Spk_%03d_M_S.mat',commonPath,iSpeaker);
    dataLoad = load(pathGoogle);
    sensorData = dataLoad.data;
            
    %% Compute speaking rate feature    
    %% rate, from 1 to (lenValidAudio - para.lenFeature+1)
    syllables = textgrid2v(sprintf('%s/Audio/Spk_%03d_A_WSS.syllables.TextGrid',commonPath,iSpeaker));    
    lenValidAudio = floor(max(syllables));
    
    rate = zeros(lenValidAudio - para.lenFeature+1,1);
    for iLenValidAudio = 1:(lenValidAudio - para.lenFeature+1)
        rate(iLenValidAudio) = sum((syllables<=(syllables>(iLenValidAudio-1)).*(iLenValidAudio-1+para.lenFeature)));
    end
    validFlag(min(lenValidAudio+1,duration),end) = 0;
   
    %% Compute energy feature
    %% energy, from 1 to (lenValidAudio - para.lenFeature+1)    
    energy_second = sum(buffer(audioData.^2, fs))';        
    movingSum = conv(energy_second, ones(1, para.lenFeature));
    energy = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);

    %% Compute pitch feature
    [pitch_tmp,tx,pv,fv]=fxpefac(audioData,fs,0.1);
    %% pitch, from 1 to (duration - para.lenFeature+1)
    pitch_second = sum(buffer(pitch_tmp,10))';
    movingSum = conv(pitch_second, ones(1, para.lenFeature));
    pitch = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);
    
                
    %% Compute head movement
    %% headmovement, from 1 to (duration - para.lenFeature+1)    
    sensor_second = zeros(duration,1);    
    for iDuration = 1:duration
        selectedFrames = (iDuration-1)*25+1:iDuration*25;
        sensor_second_tmp = [sensorData(selectedFrames,9:11) sensorData(selectedFrames,13:15)];
        sensor_second(iDuration) = sum(mean(abs(sensor_second_tmp)));      
        
        % missing data within this second
        if (~all(any(sensor_second_tmp')))
            validFlag(iDuration:min(iDuration+para.lenFeature-1,duration)) = 0;
        end
    end
    movingSum = conv(sensor_second, ones(1, para.lenFeature));
    headmovement = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);
    
    %% Compute body movement & gesture
    % from 1 to (kinectLen-para.lenFeature+1)
    kinectLen = floor(size(kinect,1)/25);
    wholebodymovement = zeros(kinectLen-para.lenFeature+1,1);
    gesture = zeros(kinectLen-para.lenFeature+1,1);
    wholeBodyFeat_secondLoc = zeros(kinectLen,33);
    
    for iDuration = 1:kinectLen
        wholeBody_selection = (2:12);
        %gesture_selection = (5:12);
        wholeBodyFeat_second_X = zeros(25,11);
        wholeBodyFeat_second_Y = zeros(25,11);
        wholeBodyFeat_second_Z = zeros(25,11);
        
        for iFrame = 1:25
            feat_frame = ReadSkeleton(kinect,(iDuration-1)*25+iFrame);
            wholeBodyFeat_second_X(iFrame,:) = feat_frame(wholeBody_selection,2);%Pos_X to Pos_Z              
            wholeBodyFeat_second_Y(iFrame,:) = feat_frame(wholeBody_selection,3);%Pos_X to Pos_Z              
            wholeBodyFeat_second_Z(iFrame,:) = feat_frame(wholeBody_selection,4);%Pos_X to Pos_Z              
        end      
        
        emptySelection = ~any(wholeBodyFeat_second_X');
        wholeBodyFeat_second_X(emptySelection,:) = [];
        wholeBodyFeat_second_Y(emptySelection,:) = [];
        wholeBodyFeat_second_Z(emptySelection,:) = [];
        
        if isempty(wholeBodyFeat_second_X)
            validFlag(iDuration:min(iDuration+para.lenFeature-1,kinectLen)) = 0;
        else
            wholeBodyFeat_secondLoc(iDuration,:) = ...
                [mean(wholeBodyFeat_second_X,1), mean(wholeBodyFeat_second_Y,1),mean(wholeBodyFeat_second_Z,1)];
        end
    end        
    for iDuration = 1:(kinectLen-para.lenFeature)
        sF = iDuration;
        eF = iDuration+para.lenFeature-1;
        wholebodymovement(iDuration) = sum(std(wholeBodyFeat_secondLoc(sF:eF,1:11)))+...
            sum(std(wholeBodyFeat_secondLoc(sF:eF,12:22)))+...
            sum(std(wholeBodyFeat_secondLoc(sF:eF,23:33)));
        
        gesture(iDuration) = sum(std(wholeBodyFeat_secondLoc(sF:eF,4:11)))+...
            sum(std(wholeBodyFeat_secondLoc(sF:eF,15:22)))+...
            sum(std(wholeBodyFeat_secondLoc(sF:eF,26:33)));
    end

    
    validFlagLen = min([length(rate), length(energy), length(pitch), ...
                    length(headmovement), length(wholebodymovement), length(gesture)]);
    
    rate = rate(validFlag(1:validFlagLen)>0);
    energy = energy(validFlag(1:validFlagLen)>0);
    pitch = pitch(validFlag(1:validFlagLen)>0);
    headmovement = headmovement(validFlag(1:validFlagLen)>0);
    wholebodymovement = wholebodymovement(validFlag(1:validFlagLen)>0);
    gesture = gesture(validFlag(1:validFlagLen)>0);
    
    
    
    %validFlag
    
%     SkeletonFeatureSum(emptyindex,:)=[];
%     SkeletonFeatureSumWholebody(emptyindex,:)=[];
%     
%     GoogleFeature(emptyindex,:)=[];
%     GoogleFeatureSum(emptyindex,:)=[];
%        
%     pitchnew(emptyindex,:)=[];
%     Rate(emptyindex,:)=[];
%     Energy(emptyindex,:)=[];
    
    
    save(sprintf('./data/Spk_%03d_energy.mat',iSpeaker),'energy');
    save(sprintf('./data/Spk_%03d_pitch.mat',iSpeaker),'pitch');
    save(sprintf('./data/Spk_%03d_rate.mat',iSpeaker),'rate');
        
    save(sprintf('./data/Spk_%03d_headmovement.mat',iSpeaker),'headmovement');
    save(sprintf('./data/Spk_%03d_wholebodymovement.mat',iSpeaker),'wholebodymovement');    
    save(sprintf('./data/Spk_%03d_gesture.mat',iSpeaker),'gesture');    
    
end