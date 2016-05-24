%clear;

para.segLen = 10;
featCorrMat = zeros(51,32);
para.corLen = 20;
corrSeq = cell(51,1);

corrMat = cell(51,1);
rCCA = cell(51,1);

flag_diff = true;

for iSpeaker = 1:51
    tic;
   % pause
   if (iSpeaker~=27)
       continue;
   end
    
%     if (iSpeaker ==3 || iSpeaker==4 || iSpeaker ==47)
%         continue;
%     end
    disp(iSpeaker);
    
    data = load(sprintf('./feature_second/Spk_%03d_feature_second',iSpeaker));
    
    %% Compute speaking rate feature
    % rate
    
    if flag_diff
        data.rate_second = diff(data.rate_second);
    end
    movingSum = conv(data.rate_second,ones(1,para.segLen));
    rate_ave_seg = movingSum(para.segLen:length(movingSum));
    rate_std_seg = movingstd(data.rate_second,para.segLen,'forward');
        
    %% Compute energy feature
    % energy
    if flag_diff
        data.energy_second = diff(data.energy_second);
    end
    movingSum = conv(data.energy_second,ones(1,para.segLen));
    energy_ave_seg = movingSum(para.segLen:length(movingSum));
    energy_std_seg = movingstd(data.energy_second,para.segLen,'forward');

    %% Compute pitch feature
    % pitch_ave, pitch_std
    if flag_diff
        data.pitch_ave_second = diff(data.pitch_ave_second);
    end
    movingSum = conv(data.pitch_ave_second,ones(1,para.segLen));
    pitch_a_ave_seg = movingSum(para.segLen:length(movingSum));
    pitch_a_std_seg = movingstd(data.pitch_ave_second,para.segLen,'forward');
    
    movingSum = conv(data.pitch_std_second,ones(1,para.segLen));
    pitch_s_ave_seg = movingSum(para.segLen:length(movingSum));
    pitch_s_std_seg = movingstd(data.pitch_std_second,para.segLen,'forward');
            
    %% Compute head movement
    % headmovement
    if flag_diff
        data.sensor_second = diff(data.sensor_second);
    end
    movingSum = conv(data.sensor_second,ones(1,para.segLen));
    sensor_ave_seg = movingSum(para.segLen:length(movingSum));
    sensor_std_seg = movingstd(data.sensor_second,para.segLen,'forward');
    
    %% Compute body movement & gesture    
    if flag_diff
        data.wholebody_loc_second = diff(data.wholebody_loc_second);
        data.gesture_loc_second = diff(data.gesture_loc_second);   
    end
    
    wholebody_std_seg = zeros(size(data.wholebody_loc_second,1),1);
    for iJoint = 1:size(data.wholebody_loc_second,2)
        wholebody_std_seg = wholebody_std_seg+ movingstd(data.wholebody_loc_second(:,iJoint),para.segLen,'forward');
    end
    
    gesture_std_seg = zeros(size(data.gesture_loc_second,1),1);
    for iJoint = 1:size(data.gesture_loc_second,2)
        gesture_std_seg = gesture_std_seg+ movingstd(data.gesture_loc_second(:,iJoint),para.segLen,'forward');
    end
           
    validFlagLen = min([length(rate_ave_seg), length(energy_ave_seg), length(pitch_a_ave_seg), ...
                    length(sensor_ave_seg), length(wholebody_std_seg), length(gesture_std_seg)]);
    validFlag_seg = data.validFlag(1:validFlagLen);    
    pivot = 1;    
    while pivot<=validFlagLen
        if validFlag_seg(pivot)==0
            validFlag_seg(pivot:min(pivot+para.segLen,validFlagLen)) = 0;
            pivot = pivot+para.segLen+1;
        else
            pivot = pivot + 1;
        end        
    end
    
    corrSeq{iSpeaker} = zeros(validFlagLen,1);
    %
    
%     featureMatrix_Row = zeros(validFlagLen,8);
%     featureMatrix_Col = zeros(validFlagLen,4);
    
    
%     featureMatrix_Row(:,1) = rate_ave_seg(1:validFlagLen);
%     featureMatrix_Row(:,2) = rate_std_seg(1:validFlagLen);
%     featureMatrix_Row(:,3)  = energy_ave_seg(1:validFlagLen);
%     featureMatrix_Row(:,4)  = energy_std_seg(1:validFlagLen);
%     featureMatrix_Row(:,5)  = pitch_a_ave_seg(1:validFlagLen);
%     featureMatrix_Row(:,6)  = pitch_a_std_seg(1:validFlagLen);
%     featureMatrix_Row(:,7)  = pitch_s_ave_seg(1:validFlagLen);
%     featureMatrix_Row(:,8) =  pitch_s_std_seg(1:validFlagLen);
%     
%     featureMatrix_Col(:,1)  = sensor_ave_seg(1:validFlagLen);
%     featureMatrix_Col(:,2)   = sensor_std_seg(1:validFlagLen);
%     featureMatrix_Col(:,3)  =  wholebody_std_seg(1:validFlagLen);
%     featureMatrix_Col(:,4)   = gesture_std_seg(1:validFlagLen);
%     
%     for iCorrS = para.corLen:validFlagLen
%         selSeq = iCorrS-para.corLen+1:iCorrS;
%         if all( validFlag_seg(selSeq))
%             corrSeq{iSpeaker}(iCorrS) = corr(featureMatrix_Row(selSeq,1),featureMatrix_Col(selSeq,1) );
%         else
%             corrSeq{iSpeaker}(iCorrS) = inf;
%         end
%         %corrSeq{iSpeaker}(iCorrS
%     end
    
    featureMatrix_Row = zeros(sum(validFlag_seg),8);
    featureMatrix_Col = zeros(sum(validFlag_seg),4);
    %featureMatrix_Col = zeros(sum(validFlag_seg),2);
    
    featureMatrix_Row(:,1) = rate_ave_seg(validFlag_seg>0);
    featureMatrix_Row(:,2) = rate_std_seg(validFlag_seg>0);
    featureMatrix_Row(:,3)  = energy_ave_seg(validFlag_seg>0);
    featureMatrix_Row(:,4)  = energy_std_seg(validFlag_seg>0);
    featureMatrix_Row(:,5)  = pitch_a_ave_seg(validFlag_seg>0);
    featureMatrix_Row(:,6)  = pitch_a_std_seg(validFlag_seg>0);
    featureMatrix_Row(:,7)  = pitch_s_ave_seg(validFlag_seg>0);
    featureMatrix_Row(:,8) =  pitch_s_std_seg(validFlag_seg>0);
    
    featureMatrix_Col(:,1)  = sensor_ave_seg(validFlag_seg>0);
    featureMatrix_Col(:,2)   = sensor_std_seg(validFlag_seg>0);
    featureMatrix_Col(:,3)  =  wholebody_std_seg(validFlag_seg>0);
    featureMatrix_Col(:,4)   = gesture_std_seg(validFlag_seg>0);
    %
    %
    corrMat{iSpeaker} = zeros(8,4);
    for iRow = 1:8
        for iCol = 1:4
            corrMat{iSpeaker}(iRow,iCol) = corr(featureMatrix_Row(:,iRow),featureMatrix_Col(:,iCol));
        end
    end
    
    [A,B,rCCA{iSpeaker},U,V] = canoncorr(featureMatrix_Row(:,1:8),featureMatrix_Col(:,1:4)) ;
    
    cla;plot(U(:,1)); hold on;plot(V(:,1),'r');
    rCCA{iSpeaker}
    pause(0.1);
    
%     a = 1; b = 1;
%     signal_A = featureMatrix_Row(:,a)/norm(featureMatrix_Row(:,a));
%     signal_B = featureMatrix_Col(:,b)/norm(featureMatrix_Col(:,b));
%     
%     corr(signal_A,signal_B)    
%     cla;plot(signal_A,'b'); hold on;plot(signal_B,'r');
    
    
    
    
    
    %%
%     featureMatrix_Col = rand(100,1);
%     featureMatrix_Row = featureMatrix_Col+0.01*rand(100,1);
%     [A2,B2,r2,U2,V2] = canoncorr(featureMatrix_Col,featureMatrix_Row) ;
%     
%     corMatrix = zeros(size(featureMatrix_Row,1),1);
%     for iC = 2:size(featureMatrix_Row,1)    
%         
%         corMatrix(iC) = corr(featureMatrix_Row(1:iC,1) , featureMatrix_Col(1:iC,1) );
%     end
    
%     %plot(corrSeq{iSpeaker},'r.','markersize',20);
%     for iPos = 1:1
%         %         plot(iPos:validFlagLen+iPos-1,corrSeq{iSpeaker},'r.','markersize',20);
%         %         hold on;
%         plot(iPos:validFlagLen+iPos-1,corrSeq{iSpeaker},'r');
%         hold on;
%     end
%     axis([0,validFlagLen,-1,1]);
    
    
%     cla;
%      plot(corMatrix,'r.','markersize',20);
%      axis([0,50,-1,1])
%     
    %figure;
%     cla
%     plot(U(:,1),'r');
%     hold on;
%     plot(V(:,1),'k');
%     axis square
    
   
%     A = featureMatrix_Row;
%     normA = max(A) - min(A);               % this is a vector
%     normA = repmat(normA, [length(A) 1]);  % this makes it a matrix
%     % of the same size as A
%     normalizedA = (A-repmat(min(A), [length(A) 1]))./normA;  % your normalized matrix    
%     featureMatrix_Row = normalizedA;
%     
%     A = featureMatrix_Col;
%     normA = max(A) - min(A);               % this is a vector
%     normA = repmat(normA, [length(A) 1]);  % this makes it a matrix
%     % of the same size as A
%     normalizedA = (A-repmat(min(A), [length(A) 1]))./normA;  % your normalized matrix    
%     featureMatrix_Col = normalizedA;
    
    %corrMatabcd(iSpeaker) = corr(featureMatrix_Row(:,1),featureMatrix_Row(:,4));
%     for iRow = 1:8
%         for iCol = 1:4
%             corrMat(iRow,iCol) = corr(featureMatrix_Row(:,iRow),featureMatrix_Col(:,iCol));
%         end
%     end
    
%     corrMat
    %corrMat_tmp = corrMat';
%     featCorrMat(iSpeaker,:) = corrMat(:);
%     disp(iSpeaker);
    toc;
    
%     save(sprintf('./feature_second/Spk_%03d_feature_second.mat',iSpeaker),...
%         'rate_second','energy_second','pitch_ave_second','pitch_std_second',...
%         'sensor_second','wholebody_loc_second','gesture_loc_second','validFlag');
                
%                 
%     rate = rate(validFlag(1:validFlagLen)>0);
%     energy = energy(validFlag(1:validFlagLen)>0);
%     pitch = pitch(validFlag(1:validFlagLen)>0);
%     headmovement = headmovement(validFlag(1:validFlagLen)>0);
%     wholebodymovement = wholebodymovement(validFlag(1:validFlagLen)>0);
%     gesture = gesture(validFlag(1:validFlagLen)>0);
%     

%     
%     save(sprintf('./data/Spk_%03d_energy.mat',iSpeaker),'energy');
%     save(sprintf('./data/Spk_%03d_pitch.mat',iSpeaker),'pitch');
%     save(sprintf('./data/Spk_%03d_rate.mat',iSpeaker),'rate');
%         
%     save(sprintf('./data/Spk_%03d_headmovement.mat',iSpeaker),'headmovement');
%     save(sprintf('./data/Spk_%03d_wholebodymovement.mat',iSpeaker),'wholebodymovement');    
%     save(sprintf('./data/Spk_%03d_gesture.mat',iSpeaker),'gesture');    
%     
end

