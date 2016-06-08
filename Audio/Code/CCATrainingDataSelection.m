clear;

dataLoad = load('seg_corr_ana_re');
corrMat = dataLoad.corrMat;
corrMatValid = dataLoad.corrMatValid;

noSpeaker = 51;

speakerCCASel = cell(noSpeaker,1);
thres = 0;

for iNoSpeaker = 1:noSpeaker
    corrData = corrMat{iNoSpeaker};   
    if isempty(corrData)
        continue;
    end
    corrDataAna = zeros(4*2,length(corrData{1}));
    
    for i = 1:4
        for j = 1:2            
            dataPlot = corrData{i,j};
            corrDataAna((i-1)*2+j,:) = dataPlot;                                               
        end
    end    
    
    corrDataAna_tmp = corrDataAna;
    corrDataAna(corrDataAna_tmp<thres) = 0;
    corrDataAna(corrDataAna_tmp>=thres) = 1;
        
    validFlag_seg = corrMatValid{iNoSpeaker};
    pivot = 1;
    para.segLen = 10;
    validFlagLen = length(validFlag_seg);
    while pivot<=validFlagLen
        if validFlag_seg(pivot)==0
            validFlag_seg(pivot:min(pivot+para.segLen-1,validFlagLen)) = 0;
            validFlag_seg(max(pivot-para.segLen+1,1):pivot) = 0;
            pivot = pivot+para.segLen+1;
        else
            pivot = pivot + 1;
        end
    end
    
    %corrDataAna(corrMatValid{iNoSpeaker}<=0) = 0;
    corrDataAna(validFlag_seg<=0) = 0;
    
    
    speakerCCASel{iNoSpeaker} = sum(corrDataAna,1)';
end

selThres = 6;
cnt = 0;
tot = 0;
for iNoSpeaker = 1:noSpeaker
    tot = tot + length(speakerCCASel{iNoSpeaker});
    cnt = cnt + sum(speakerCCASel{iNoSpeaker}>=selThres);
end
cnt/tot

save(sprintf('./feature_cca/ccaSel.mat'),'speakerCCASel');
