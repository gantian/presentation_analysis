clear;

para.segLen = 10;
featCorrMat = zeros(51,32);
para.corLen = 20;
corrSeq = cell(51,1);

corrMat = cell(51,1);
rCCA = cell(51,1);

flag_diff = true;
flag_obtain_proj_mat = false;
flag_save_proj_feat = false;

validLenArray = zeros(51,1);

featureMatrix_Row_all = zeros(0,8);
featureMatrix_Col_all = zeros(0,4);
corrMat_proj = zeros(51,1);

proj_mat = load('./projection_matrix.mat');


for iSpeaker = 1:51
    tic;

    if (iSpeaker ==3 || iSpeaker==4 || iSpeaker ==47)
        continue;
    end
    disp(iSpeaker);
    
    data = load(sprintf('./feature_second/Spk_%03d_feature_second',iSpeaker));
    
    %% Compute speaking rate feature
    % rate
    
    
%     if flag_diff
%         data.rate_second = diff(data.rate_second);
%     end
    rate_seg = data.rate_second;
%     movingSum = conv(data.rate_second,ones(1,para.segLen));
%     rate_ave_seg = movingSum(para.segLen:length(movingSum));
%     rate_std_seg = movingstd(data.rate_second,para.segLen,'forward');
        
    %% Compute energy feature
%     % energy
%     if flag_diff
%         data.energy_second = diff(data.energy_second);
%     end
    engergy_seg = data.energy_second;
   

    %% Compute pitch feature
    % pitch_ave, pitch_std
%     if flag_diff
%         data.pitch_ave_second = diff(data.pitch_ave_second);
%     end

    pitch_ave = data.pitch_ave_second;
    pitch_std = data.pitch_std_second;
%     movingSum = conv(data.pitch_ave_second,ones(1,para.segLen));
%     pitch_a_ave_seg = movingSum(para.segLen:length(movingSum));
%     pitch_a_std_seg = movingstd(data.pitch_ave_second,para.segLen,'forward');
%     
%     movingSum = conv(data.pitch_std_second,ones(1,para.segLen));
%     pitch_s_ave_seg = movingSum(para.segLen:length(movingSum));
%     pitch_s_std_seg = movingstd(data.pitch_std_second,para.segLen,'forward');
            
    %% Compute head movement
    % headmovement
%     if flag_diff
%         data.sensor_second = diff(data.sensor_second);
%     end
%     movingSum = conv(data.sensor_second,ones(1,para.segLen));
%     sensor_ave_seg = movingSum(para.segLen:length(movingSum));
%     sensor_std_seg = movingstd(data.sensor_second,para.segLen,'forward');
    sensor_second = data.sensor_second
    
    %% Compute body movement & gesture    
%     if flag_diff
%         data.wholebody_loc_second = diff(data.wholebody_loc_second);
%         data.gesture_loc_second = diff(data.gesture_loc_second);   
%     end
    
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
 
    
    featureMatrix_Row = zeros(sum(validFlag_seg),8);
    featureMatrix_Col = zeros(sum(validFlag_seg),4);
    
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
    
    if flag_obtain_proj_mat
        featureMatrix_Row_all = [featureMatrix_Row_all;featureMatrix_Row];
        featureMatrix_Col_all = [featureMatrix_Col_all;featureMatrix_Col];
    end
    
    validLenArray(iSpeaker) = size(featureMatrix_Col,1);
    
    if flag_save_proj_feat
        
        featureMatrix_Row_proj = featureMatrix_Row*proj_mat.A(:,1);
        featureMatrix_Col_proj = featureMatrix_Col*proj_mat.B(:,1);
        corrMat_proj(iSpeaker) = corr(featureMatrix_Row_proj,featureMatrix_Col_proj);      
        
        save(sprintf('./feat_proj/spk_%02d_fea_proj.mat',iSpeaker),'featureMatrix_Row_proj','featureMatrix_Col_proj',...
                                                                    'featureMatrix_Row','featureMatrix_Col');
    end
    
    corrMat{iSpeaker} = cell(8,4);
    for iRow = 1:8
        for iCol = 1:4
            corrMat{iSpeaker}{iRow,iCol} = CalculateCorrelation_Seg(featureMatrix_Row(:,iRow),featureMatrix_Col(:,iCol),10);
            %corr(featureMatrix_Row(:,iRow),featureMatrix_Col(:,iCol));
        end
    end

    toc;

end

if flag_obtain_proj_mat
    [A,B,rCCA,U,V] = canoncorr(featureMatrix_Row_all(:,1:8),featureMatrix_Col_all(:,1:4)) ;
    save('projection_matrix','A','B','rCCA','U','V');
end