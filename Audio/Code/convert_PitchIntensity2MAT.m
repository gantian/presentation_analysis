function convert_PitchIntensity2MAT    
    
    commonPath = sprintf('..');
    currentPath = pwd;
    
    src_speaker = sprintf('%s/Data/S*',commonPath);
    loadSrc_speaker = dir(src_speaker);
    
    speaker = cell(length(loadSrc_speaker),1);
    for iSpeaker = 1:length(loadSrc_speaker)
        folderName = loadSrc_speaker(iSpeaker).name;
        
        src = sprintf('%s/Data/%s',commonPath,folderName);
        loadAudio = dir(sprintf('%s/*_pitch_intensity.txt',src));
        speaker{iSpeaker} = cell(length(loadAudio),1);
        
        for iAudio = 1:length(loadAudio)
            formantName = sprintf('%s/%s',src,loadAudio(iAudio).name);
            speaker{iSpeaker}{iAudio} = textPitchIntensity2v(formantName);
        end
        disp(iSpeaker);
    end
    cd(currentPath);
    save(sprintf('%s/Data/feature_pitchIntensity',commonPath),'speaker');
    
function [ ret ] = textPitchIntensity2v( fName )
    z = textread(fName,'%s','commentstyle','matlab','headerlines',1,'delimiter','\n');
    
    numPoints=sscanf(z{1},'''numInterv''\t %d');
    
    if ~isnumeric(numPoints)
        error('Error %s.',fName);
    end
    
    ret = zeros(numPoints,3);
    for iNumPoints = 1:numPoints
        j =1+iNumPoints;
        ret_tmp = strsplit(' ',z{j});
        ret_value = nan(1,3);
        for i=1:3
            if ~strcmp(ret_tmp{i*2-1},'--undefined--')
                ret_value(i) = str2num(ret_tmp{i*2-1});
            end
        end
        ret(iNumPoints,:) =  ret_value;
    end
