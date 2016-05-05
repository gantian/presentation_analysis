% clear;
% 
% addpath('./voicebox');
% 
% para.commonPath = 'W:/Dataset';
% commonPath = sprintf('%s',para.commonPath);
% currentPath = pwd;
% 
% %para.lenFeature = 5;
% loaded = load('./spkValidDuration');
% spkValidDuration = loaded.spkValidDuration;
% 
% for iSpeaker = 31:51
%     disp(iSpeaker);
%     
%     %% Load the original data
%     pathAudio = sprintf('%s/Audio/Spk_%03d_A_WSS.mp4',commonPath,iSpeaker);
%     [audioData,fs]=audioread(pathAudio);    
%     duration=floor(size(audioData,1)/fs);    
%     
%     validFlag = ones(duration,1);
%     
%     pathKinect = sprintf('./kinect/Spk_%03d_D.mat',iSpeaker);
%     dataload = load(pathKinect);
%     kinect = dataload.kinect;
%     
%     pathSensor= sprintf('%s/Motion/Spk_%03d_M_S.mat',commonPath,iSpeaker);
%     dataLoad = load(pathSensor);
%     sensorData = dataLoad.data;
%             
%     %% Compute speaking rate feature    
%     % rate
%     syllables = textgrid2v(sprintf('%s/Audio/Spk_%03d_A_WSS.syllables.TextGrid',commonPath,iSpeaker));    
%     lenValidAudio = floor(max(syllables));
%     
%     rate_second = zeros(lenValidAudio,1);
%     for iLenValidAudio = 1:lenValidAudio                
%         rate_second(iLenValidAudio) = sum((syllables>(iLenValidAudio-1)).*(syllables<=iLenValidAudio));    
%     end
%     validFlag(min(lenValidAudio+1,duration),end) = 0;
%    
%     %% Compute energy feature
%     % energy
%     energy_second = sum(buffer(audioData.^2, fs))';        
%     %movingSum = conv(energy_second, ones(1, para.lenFeature));
%     %energy = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);
% 
%     %% Compute pitch feature
%     [pitch_tmp,tx,pv,fv]=fxpefac(audioData,fs,0.1);
%     %% pitch, from 1 to (duration - para.lenFeature+1)
%     pitch_ave_second = mean(buffer(pitch_tmp,10))';
%     pitch_std_second = std(buffer(pitch_tmp,10))';
% %     movingSum = conv(pitch_second, ones(1, para.lenFeature));
% %     pitch = movingSum(para.lenFeature:length(movingSum) - para.lenFeature+1);
%     
%                 
%     %% Compute head movement
%     % headmovement
%     sensor_second = zeros(duration,1);    
%     for iDuration = 1:duration
%         selectedFrames = (iDuration-1)*25+1:iDuration*25;
%         sensor_second_tmp = [sensorData(selectedFrames,9:11) sensorData(selectedFrames,13:15)];
%         
%         numValidFrames = (size(sensor_second_tmp,1) - sum(~all(sensor_second_tmp,2)));
%         
%         if numValidFrames
%             sensor_second(iDuration,:) = (sum(sum(sensor_second_tmp(:,1:3).^2,2))+...
%                 sum(sum(sensor_second_tmp(:,4:6).^2,2)))./numValidFrames;
%         else
%             validFlag(iDuration) = 0;        
%         end                                      
%     end
%     
%     %% Compute body movement & gesture
%     % from 1 to (kinectLen-para.lenFeature+1)
%     kinectLen = floor(size(kinect,1)/25);      
%     wholebody_loc_second = zeros(kinectLen,3*11); %[x1, y1, z1, x2, y2, z2, ..., xn, yn, zn]
%     %gesture_loc_second = zeros(kinectLen,3*11);    
%     for iDuration = 1:kinectLen
%         wholeBody_selection = (2:12);
%         %gesture_selection = (5:12);
% 
%         wholebody_loc_second_tmp = zeros(25,3*length(wholeBody_selection));
%         validFrameInd = zeros(25,3*length(wholeBody_selection));
%         for iFrame = 1:25
%             feat_frame = ReadSkeleton(kinect,(iDuration-1)*25+iFrame);            
%             wholebody_loc_second_tmp(iFrame,:) = reshape(feat_frame(wholeBody_selection,2:4)',3*length(wholeBody_selection),1);            
%             validFrameInd(iFrame,:) = reshape(repmat(feat_frame(wholeBody_selection,1),1,3)',3*length(wholeBody_selection),1);            
%         end     
%         
%         validFrameInd = (validFrameInd==2);
%         numValidFrames = sum(validFrameInd,1);
%         
%         if all(numValidFrames)            
%             wholebody_loc_second(iDuration,:) = sum(wholebody_loc_second_tmp.*validFrameInd,1)./numValidFrames;
%         else
%             validFlag(iDuration) = 0;    
%         end
%     end    
%     gesture_loc_second = wholebody_loc_second(:,3*3+1:end);
%    
%     validFlagLen = min([length(rate_second), length(energy_second), length(pitch_ave_second), ...
%                     length(sensor_second), length(wholebody_loc_second), length(gesture_loc_second)]);
%     
%     validFlagLen = min(validFlagLen,length(spkValidDuration{iSpeaker}));
%     validFlag(1:validFlagLen) = validFlag(1:validFlagLen).*spkValidDuration{iSpeaker}(1:validFlagLen);
%     validFlag(validFlagLen+1:end) = 0;
%     
%     save(sprintf('./feature_second/Spk_%03d_feature_second.mat',iSpeaker),...
%         'rate_second','energy_second','pitch_ave_second','pitch_std_second',...
%         'sensor_second','wholebody_loc_second','gesture_loc_second','validFlag');
%                 
% %                 
% %     rate = rate(validFlag(1:validFlagLen)>0);
% %     energy = energy(validFlag(1:validFlagLen)>0);
% %     pitch = pitch(validFlag(1:validFlagLen)>0);
% %     headmovement = headmovement(validFlag(1:validFlagLen)>0);
% %     wholebodymovement = wholebodymovement(validFlag(1:validFlagLen)>0);
% %     gesture = gesture(validFlag(1:validFlagLen)>0);
% %     
% 
% %     
% %     save(sprintf('./data/Spk_%03d_energy.mat',iSpeaker),'energy');
% %     save(sprintf('./data/Spk_%03d_pitch.mat',iSpeaker),'pitch');
% %     save(sprintf('./data/Spk_%03d_rate.mat',iSpeaker),'rate');
% %         
% %     save(sprintf('./data/Spk_%03d_headmovement.mat',iSpeaker),'headmovement');
% %     save(sprintf('./data/Spk_%03d_wholebodymovement.mat',iSpeaker),'wholebodymovement');    
% %     save(sprintf('./data/Spk_%03d_gesture.mat',iSpeaker),'gesture');    
% %     
% end