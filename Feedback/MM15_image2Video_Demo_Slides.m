clear;

iSessionID = 7;
%% Configuration
addpath('../');
para = config_Para(iSessionID);
paraIdx = load(sprintf('%s/sessionSpeaker2PId',para.AnnotPath));
FFMpegPath = para.FFMpegPath;
commonPath = sprintf('%s/data',para.commonPath);
saveCommonPath = sprintf('%s',para.DemoPath);
currentPath = pwd;

opt.addAudio = para.addAudio;
opt.KinectReady = para.KinectReady;

%% ffmpeg processing
cd(FFMpegPath);

frameRateI = 25;
frameRateO = 25;

folderName = para.cams;

timing = load(sprintf('%s/../timing.txt',commonPath));
noSpeaker = size(timing,1);

if opt.addAudio
    audioData = load(sprintf('%s/data_audio.mat',commonPath));
end

if opt.KinectReady
    KinectFolderName = '6_Kinect';
else
    KinectFolderName = folderName{2};
end

tic;

for iNoSpeaker = 5%1:noSpeaker
    
    pID = paraIdx.sessionSpeaker2PId(iSessionID,iNoSpeaker);
    
    startFrame = (timing(iNoSpeaker,1)*60+timing(iNoSpeaker,2))*frameRateI;
    endFrame = (timing(iNoSpeaker,3)*60+timing(iNoSpeaker,4))*frameRateI;
    
    speakerID = timing(iNoSpeaker,5);audience1ID = 4;audience2ID = 5;
    if speakerID==4
        audience1ID = 3;
    elseif speakerID==5
        audience2ID = 3;
    end
    
    offset = 0;
    f_s = startFrame+6000;
    f_e = f_s+4000;
    %f_e = endFrame;
    duration = floor((f_e-f_s+1)/25);
    
    if opt.addAudio
        audio_Idx = timing(iNoSpeaker,5);
        %cams = {'2_GoPro','3_Grey','4_Red','5_White'};
        aRT = 48000;
        a_s = f_s/frameRateI*aRT;
        a_e = (f_e+1)/frameRateI*aRT-1;
        audiowrite(strcat(commonPath,'/audio_trim.mp4'),audioData.audio_all(a_s:a_e,audio_Idx),aRT);
        audioOpt1 = sprintf(' -i %s/audio_trim.mp4',commonPath);
        audioOpt2 = sprintf(' -c:a copy -shortest');
    else
        audioOpt1 = '';
        audioOpt2 = '';
    end
    
    commandStr =strcat(sprintf('ffmpeg'),...
        ...% Speaker
        sprintf(' -r %d',frameRateI),...
        sprintf(' -start_number %d',startFrame(1)+offset),...
        sprintf(' -i %s/%s/cam_%s_%%06d.jpg',commonPath,folderName{speakerID},folderName{speakerID}(1)),...        
        ...% Kinect Sensor
        sprintf(' -r %d',frameRateI),...
        sprintf(' -start_number %d',startFrame(1)+offset),...
        sprintf(' -i %s/%s/cam_%s_%%06d.jpg',commonPath,KinectFolderName,KinectFolderName(1)),...        
        ...
        sprintf('%s',audioOpt1),...
        sprintf(' -filter_complex "nullsrc=size=640x720 [base];'),...
        ...sprintf(' [0:v] setpts=PTS-STARTPTS, scale=640x360 [u_1];'),...
        sprintf(' [0:v] scale=640x360 [u_1];'),...
        sprintf(' [1:v] scale=640x480,hflip [u_2];'),...        
        sprintf(' [base][u_2] overlay=shortest=1:y=-100 [tmp1];'),...        
        sprintf(' [tmp1][u_1] overlay=shortest=1:y=360'),...        
        sprintf('"'),...
        sprintf(' -c:v libx264'),...
        sprintf('%s',audioOpt2),...
        sprintf(' -r %d -t %d',frameRateO,duration),...
        sprintf(' %s/slides_%d.mp4',saveCommonPath,pID));
    dos(commandStr);
    
    cd(currentPath);
end
