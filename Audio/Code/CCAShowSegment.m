%%  Configuration
FFMpegPath = 'C:\Program Files (x86)\ffmpeg-20160202-git-0ab25da-win64-static\bin';
loadDirCommon = sprintf('.');
currentPath = pwd;

fileName = 'Spk_039_V_AM2.mp4';
cd(FFMpegPath)

%% ffmpeg processing
% ffmpeg -ss START_TIME -i INPUT_FILENAME -t DURATION -r 30 -vcodec mpeg4 -an -b 5M OUTPUT_FILENAME
cur_time = datenum('00:03:20');
duration = 100;

startTimeStr = datestr(cur_time,'HH:MM:SS');
commandStrSeg =  strcat(sprintf('ffmpeg'),...
    sprintf(' -ss %s',startTimeStr),...
    sprintf(' -i %s/%s',currentPath,fileName),...
    sprintf(' -t %d',duration),...
    sprintf(' -r 25 -vcodec mpeg4 -b 5M'),... %-an disable audio
    sprintf(' %s/cca_videoseg/%s_seg.mp4',currentPath,fileName));
dos(commandStrSeg);

cd(currentPath);
