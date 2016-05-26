clear;

for iSpeaker = 1:51
    disp(iSpeaker);

    pathKinect = sprintf('./kinect/Spk_%03d_D.mat',iSpeaker);
    dataload = load(pathKinect);
    kinect = dataload.kinect;

    %% Compute body movement & gesture
    % from 1 to (kinectLen-para.lenFeature+1)
    kinectLen = floor(size(kinect,1)/25);      
    wholebody_loc_second = zeros(kinectLen,3*11); %[x1, y1, z1, x2, y2, z2, ..., xn, yn, zn]
    wholebody_loc_std_second = zeros(kinectLen,3*11); %[x1, y1, z1, x2, y2, z2, ..., xn, yn, zn]
    %gesture_loc_second = zeros(kinectLen,3*11);    
    for iDuration = 1:kinectLen
        wholeBody_selection = (2:12);
        %gesture_selection = (5:12);

        wholebody_loc_second_tmp = zeros(25,3*length(wholeBody_selection));
        validFrameInd = zeros(25,3*length(wholeBody_selection));
        for iFrame = 1:25
            feat_frame = ReadSkeleton(kinect,(iDuration-1)*25+iFrame);            
            wholebody_loc_second_tmp(iFrame,:) = reshape(feat_frame(wholeBody_selection,2:4)',3*length(wholeBody_selection),1);            
            validFrameInd(iFrame,:) = reshape(repmat(feat_frame(wholeBody_selection,1),1,3)',3*length(wholeBody_selection),1);            
        end     
        
        validFrameInd = (validFrameInd==2);
        numValidFrames = sum(validFrameInd,1);
        
        if all(numValidFrames)            
            wholebody_loc_second(iDuration,:) = sum(wholebody_loc_second_tmp.*validFrameInd,1)./numValidFrames;
            wholebody_loc_std_second(iDuration,:) = std(wholebody_loc_second,1);                     
        end
    end    
    gesture_loc_second = wholebody_loc_second(:,3*3+1:end);
    gesture_loc_std_second = wholebody_loc_std_second(:,3*3+1:end);

    save(sprintf('./feature_second/Spk_%03d_feature_kinect_second.mat',iSpeaker),...
        'wholebody_loc_std_second','gesture_loc_std_second');
%     
end