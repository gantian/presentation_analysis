clear;

dataLoad = load('seg_corr_ana');
corrMat = dataLoad.corrMat;

spkID = 43;
corrData = corrMat{spkID};

cla;
corrDataAna = zeros(4*2,length(corrData{1}));
for i = 1:4
    for j = 1:2
        offset = (i-1)*3+j;
        dataPlot = corrData{i,j};
        corrDataAna((i-1)*2+j,:) = dataPlot;
        dataPlot(dataPlot<0.1) = inf;        
        plot(dataPlot+offset*1);
        
        hold on
    end
end

thres = 0;
corrDataAna_tmp = corrDataAna;
corrDataAna(corrDataAna_tmp<thres) = 0;
corrDataAna(corrDataAna_tmp>=thres) = 1;

cla
for i = 1:4
    for j = 1:2
        offset = (i-1)*2+j;             
        plot(corrDataAna((i-1)*2+j,:)+offset*1.5);        
        hold on
    end
end

corrDataAna_sum = sum(corrDataAna,1)';
figure
a = hist(corrDataAna_sum);


% 
% featureMatrix_Row(:,1) = rate(validFlag_seg>0);
% featureMatrix_Row(:,2) = engergy(validFlag_seg>0);
% featureMatrix_Row(:,3)  = pitch_ave(validFlag_seg>0);
% featureMatrix_Row(:,4)  = pitch_std(validFlag_seg>0);
% 
% 
% featureMatrix_Col(:,1)  = sensor_second(validFlag_seg>0);
% featureMatrix_Col(:,2)   = wholebody(validFlag_seg>0);
% featureMatrix_Col(:,3)  =  gesture(validFlag_seg>0);

cnt = 0;
for iSpeaker = 1:51
    individualData = corrMat{iSpeaker};
    if isempty(individualData)
        continue;
    end
    indMat = individualData{1};
    len = size(indMat,1);
    cnt = cnt+len;
end