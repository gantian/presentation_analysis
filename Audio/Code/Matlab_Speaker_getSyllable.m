clear;
path_praatExe = 'praatcon.exe';
path_script = 'getSyllable.psc';

commonPath = '..';%sprintf('%s',para.labelPath);
currentPath = pwd;

src_speaker = sprintf('%s/Data/S*',commonPath);
loadSrc_speaker = dir(src_speaker);

for iSpeaker = 1:length(loadSrc_speaker)
    folderName = loadSrc_speaker(iSpeaker).name;
    
    src = sprintf('%s/Data/%s',commonPath,folderName);    
    cmd = sprintf('%s %s %s',path_praatExe,path_script,src);
    [status,result] = system(cmd);
    
    disp(iSpeaker);

end
cd(currentPath);

speaker = cell(length(loadSrc_speaker),1);
for iSpeaker = 1:length(loadSrc_speaker)
    folderName = loadSrc_speaker(iSpeaker).name;
    
    src = sprintf('%s/Data/%s',commonPath,folderName);
    loadSyl = dir(sprintf('%s/*.TextGrid',src));
    speaker{iSpeaker} = cell(length(loadSyl),1);
    
    for iSyl = 1:length(loadSyl)
        sylName = sprintf('%s/%s',src,loadSyl(iSyl).name);
        speaker{iSpeaker}{iSyl} = textgrid2v(sylName);
    end

    disp(iSpeaker);
end
cd(currentPath);
save(sprintf('%s/Data/feature_syllables',commonPath),'speaker');

return;

% %
% % ret1 = textgrid2v('res1.syllables');
% % ret2 = textgrid2v('res2.syllables');
% %figure;
% no = zeros(51,10);
% xo = zeros(51,10);
% table = zeros(51,200);
% for i=1:51
%     ret = speaker{i}{11};
%     [no(i,:),xo(i,:)] = hist(ret,10);
% %     plot(no);
% %     pause
% %     hold on;
% end
% a = sum(no,2);
% % [no1,xo1] = hist(ret1,20);
% % [no2,xo2] = hist(ret2,20);
% 
% 
% % figure; 
% % plot(no1);
% % hold on;
% % plot(no2,'color','r');
% syl = zeros(51,200);
% ave = zeros(51,1);
% for i=1:51
%     duration = length(speaker{i});
%     for iD = 1:duration
%         syl(i,iD) = length(speaker{i}{iD});
%     end
%     ave(i) = sum(syl(i,1:duration))/duration;
% end
