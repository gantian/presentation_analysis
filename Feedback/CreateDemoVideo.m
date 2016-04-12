function CreateDemoVideo
    %% Tutorial
    % https://trac.ffmpeg.org/wiki/Create%20a%20mosaic%20out%20of%20several%20input%20videos
    % ffmpeg
    % 	-i 1.avi -i 2.avi -i 3.avi -i 4.avi
    % 	-filter_complex "
    % 		nullsrc=size=640x480 [base];
    % 		[0:v] setpts=PTS-STARTPTS, scale=320x240 [upperleft];
    % 		[1:v] setpts=PTS-STARTPTS, scale=320x240 [upperright];
    % 		[2:v] setpts=PTS-STARTPTS, scale=320x240 [lowerleft];
    % 		[3:v] setpts=PTS-STARTPTS, scale=320x240 [lowerright];
    % 		[base][upperleft] overlay=shortest=1 [tmp1];
    % 		[tmp1][upperright] overlay=shortest=1:x=320 [tmp2];
    % 		[tmp2][lowerleft] overlay=shortest=1:y=240 [tmp3];
    % 		[tmp3][lowerright] overlay=shortest=1:x=320:y=240
    % 	"
    % 	-c:v libx264 output.mkv
    
    %%  Configuration
    FFMpegPath = 'D:/ffmpeg';    
    currentPath = pwd;
    frameRateO = 25;
    cd(FFMpegPath);
    
    
    videosTmp = dir(sprintf('%s/Videos/feedback_spk_*.mp4',currentPath));
    for iV = 1:length(videosTmp)

        videoName = cell(2,1);    
        
        %dataPath = sprintf('%s/%s/')'F:/GitHub/projects/Navigation/dataPreProcess';
        videoName{1} =sprintf('%s/Videos/%s',currentPath,videosTmp(iV).name);
        videoName{2} = sprintf('W:/Research/Data/Demo/demo_cam_only_%s',videosTmp(iV).name(end-5:end));
        
        if ~(exist(videoName{1},'file')&& exist(videoName{2},'file')) continue;end
        
        commandStrSeg = strcat(sprintf('ffmpeg'),...
            ...sprintf(' -accurate_seek -ss %s',startTime{1}),...
            sprintf(' -i %s',videoName{1}),...  % audio source
            sprintf(' -i %s',videoName{2}),...
            sprintf(' -filter_complex "nullsrc=size=1920x1080 [base];'),...
            sprintf(' [0:v] setpts=PTS-STARTPTS, scale=1920x720 [down];'),...
            sprintf(' [1:v] setpts=PTS-STARTPTS, scale=1920x360 [up];'),...
            sprintf(' [base][up] overlay=shortest=1 [tmp1];'),...
            sprintf(' [tmp1][down] overlay=shortest=1:y=361'),...
            sprintf('"'),...
            sprintf(' -profile:v main -level 3.1 -ar 44100 -ab 128k'),...
            sprintf(' -s 2560x1440 -vcodec h264 -acodec libvo_aacenc '),...
            sprintf(' -r %d -t 5',frameRateO),...
            sprintf(' %s/Demo/Demo_%s',currentPath,videosTmp(iV).name(end-5:end)));
        dos(commandStrSeg);
    end
    
    cd(currentPath);
end