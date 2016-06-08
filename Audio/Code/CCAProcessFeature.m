clear;

for iSpeaker = 1:51
    tic;

    if (iSpeaker ==3 || iSpeaker==4 || iSpeaker ==47)
        continue;
    end
    disp(iSpeaker);
    
    data = load(sprintf('./feature_second/Spk_%03d_feature_second',iSpeaker));
    dataKinect = load(sprintf('./feature_second/Spk_%03d_feature_kinect_second',iSpeaker));
    
    %% Compute speaking rate feature
    rate = data.rate_second;
        
    %% Compute energy feature
    engergy = data.energy_second;
   
    %% Compute pitch feature
    pitch_ave = data.pitch_ave_second;
    pitch_std = data.pitch_std_second;
            
    %% Compute head movement
    sensor_second = data.sensor_second;
    
    %% Compute body movement & gesture        
    wholebody = dataKinect.wholebody_loc_std_second;
    gesture = dataKinect.gesture_loc_std_second;
           
    validFlagLen = min([length(rate), length(engergy), length(pitch_ave), ...
                    length(sensor_second), length(wholebody), length(gesture)]);
    validFlag_seg = data.validFlag(1:validFlagLen);       
    
    %% wrong
%     featureMatrix_Row = zeros(sum(validFlag_seg),4);
%     featureMatrix_Col = zeros(sum(validFlag_seg),3);
%     
%     featureMatrix_Row(:,1) = rate(validFlag_seg>0);
%     featureMatrix_Row(:,2) = engergy(validFlag_seg>0);
%     featureMatrix_Row(:,3)  = pitch_ave(validFlag_seg>0);
%     featureMatrix_Row(:,4)  = pitch_std(validFlag_seg>0);
%    
%     
%     featureMatrix_Col(:,1)  = sensor_second(validFlag_seg>0);
%     featureMatrix_Col(:,2)   = wholebody(validFlag_seg>0);
%     featureMatrix_Col(:,3)  =  gesture(validFlag_seg>0);   

    featureMatrix_Row = zeros(validFlagLen,4);
    featureMatrix_Col = zeros(validFlagLen,3);
    
    featureMatrix_Row(:,1) = rate(1:validFlagLen);
    featureMatrix_Row(:,2) = engergy(1:validFlagLen);
    featureMatrix_Row(:,3)  = pitch_ave(1:validFlagLen);
    featureMatrix_Row(:,4)  = pitch_std(1:validFlagLen);
    
    
    featureMatrix_Col(:,1)  = sensor_second(1:validFlagLen);
    featureMatrix_Col(:,2)   = wholebody(1:validFlagLen);
    featureMatrix_Col(:,3)  =  gesture(1:validFlagLen);

    save(sprintf('./feature_cca/Spk_%03d_feature_cca.mat',iSpeaker),...
        'featureMatrix_Row','featureMatrix_Col','validFlag_seg');
    toc;
end

