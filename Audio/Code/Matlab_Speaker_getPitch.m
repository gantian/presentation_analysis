clear;

path_praatExe = 'praatcon.exe';
path_script = 'getPitch.psc';

%% Configuration
commonPath = sprintf('..');
currentPath = pwd;

src_speaker = sprintf('%s/Data/S*',commonPath);
loadSrc_speaker = dir(src_speaker);

loadGender = load(sprintf('%s/Data/gender.txt',commonPath));
for iSpeaker = 1:length(loadSrc_speaker)
    folderName = loadSrc_speaker(iSpeaker).name;
    
    src = sprintf('%s/Data/%s',commonPath,folderName);
    %src = 'F:\Code\praat5404_win64';
    cmd = sprintf('%s %s %s 100 0.01 %d',path_praatExe,path_script,src,loadGender(iSpeaker));
    [status,result] = system(cmd);

    disp(iSpeaker);
end
cd(currentPath);

convert_PitchIntensity2MAT;

return;

% %% #########################################################
% %% process feature
% 
% addpath('./../../');
% para = config_Para();
% commonPath = sprintf('%s',para.labelPath);
% currentPath = pwd;
% 
% src_speaker = sprintf('%s/pureAudio/S*',commonPath);
% loadSrc_speaker = dir(src_speaker);
% 
% speaker = cell(length(loadSrc_speaker),1);
% for iSpeaker = 1:length(loadSrc_speaker)
%     folderName = loadSrc_speaker(iSpeaker).name;
%     
%     src = sprintf('%s/pureAudio/%s',commonPath,folderName);
%     loadSyl = dir(sprintf('%s/*.TextGrid',src));
%     speaker{iSpeaker} = cell(length(loadSyl),1);
%     
%     for iSyl = 1:length(loadSyl)
%         sylName = sprintf('%s/%s',src,loadSyl(iSyl).name);
%         speaker{iSpeaker}{iSyl} = textgrid2v(sylName);
%     end
% 
%     disp(iSpeaker);
% end
% cd(currentPath);
% save(sprintf('%s/pureAudio/syllables',commonPath),'speaker');
% 
% return;

%
% ret1 = textgrid2v('res1.syllables');
% ret2 = textgrid2v('res2.syllables');
%figure;

