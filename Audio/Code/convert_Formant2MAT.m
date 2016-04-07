function convert_Formant2MAT
    
    commonPath = sprintf('..');
    currentPath = pwd;
    
    src_speaker = sprintf('%s/Data/S*',commonPath);
    loadSrc_speaker = dir(src_speaker);
    
    speaker = cell(length(loadSrc_speaker),1);
    for iSpeaker = 1:length(loadSrc_speaker)
        folderName = loadSrc_speaker(iSpeaker).name;
        
        src = sprintf('%s/Data/%s',commonPath,folderName);
        loadAudio = dir(sprintf('%s/*_formant.txt',src));
        speaker{iSpeaker} = cell(length(loadAudio),1);
        
        for iAudio = 1:length(loadAudio)
            formantName = sprintf('%s/%s',src,loadAudio(iAudio).name);
            speaker{iSpeaker}{iAudio} = textFormant2v(formantName);
        end
        
        disp(iSpeaker);
    end
    cd(currentPath);
    save(sprintf('%s/Data/feature_formant',commonPath),'speaker');
    
    return;
end

% ret1 = textgrid2v('res1.syllables');
% ret2 = textgrid2v('res2.syllables');
% figure;