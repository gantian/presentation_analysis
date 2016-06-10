clear;

flag_obtain_proj_mat = false;
flag_save_proj_feat = true;

validLenArray = zeros(51,1);

featureMatrix_Row_all = zeros(0,4);
featureMatrix_Col_all = zeros(0,2);
corrMat_proj = zeros(51,1);

ccaSel = load(sprintf('./feature_cca/ccaSel.mat'));
if flag_save_proj_feat
    proj_mat = load(sprintf('./feature_cca/projection_matrix.mat'));
end

thres = 6;

for iSpeaker = 1:51
    tic;
    
    if (iSpeaker ==3 || iSpeaker==4 || iSpeaker ==47)
        continue;
    end
    disp(iSpeaker);
    
    data = load(sprintf('./feature_cca/Spk_%03d_feature_cca',iSpeaker));    

    featureMatrix_Row = data.featureMatrix_Row(:,:);
    featureMatrix_Col = data.featureMatrix_Col(:,1:2);
    validFlag_seg = data.validFlag_seg;
    
    if flag_obtain_proj_mat
        
        %% sliding window
        ccaSelInd =  ccaSel.speakerCCASel{iSpeaker}>=thres;
        valSelInd = ccaSelInd & validFlag_seg;
        
        featureMatrix_Row_all = [featureMatrix_Row_all;featureMatrix_Row(ccaSelInd,:)];
        featureMatrix_Col_all = [featureMatrix_Col_all;featureMatrix_Col(ccaSelInd,1:2)];
    end
    
    validLenArray(iSpeaker) = size(featureMatrix_Col,1);
    
    if flag_save_proj_feat
        
        featureMatrix_Row_proj = featureMatrix_Row*proj_mat.A(:,1);
        featureMatrix_Col_proj = featureMatrix_Col*proj_mat.B(:,1);
        corrMat_proj(iSpeaker) = corr(featureMatrix_Row_proj,featureMatrix_Col_proj);      
        
        save(sprintf('./feature_cca_proj/spk_%02d_fea_proj.mat',iSpeaker),'featureMatrix_Row_proj','featureMatrix_Col_proj',...
                                                                    'featureMatrix_Row','featureMatrix_Col','validFlag_seg');
    end       
    toc; 
end

if flag_obtain_proj_mat
    [A,B,rCCA,U,V] = canoncorr(featureMatrix_Row_all(:,1:4),featureMatrix_Col_all(:,1:2)) ;    
    save(sprintf('./feature_cca/projection_matrix'),'A','B','rCCA','U','V','validLenArray');
end