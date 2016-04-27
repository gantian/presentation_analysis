Path = 'C:\Users\li\Desktop\CCA';
dirlist = dir(Path);
self=0;other=0;
for n=3:length(dirlist)
    folder = fullfile(Path,dirlist(n).name);  
    pitch = load(fullfile(folder,'pitch.mat'),'pitchnew');
    pitch = pitch.pitchnew;
    
    SkeletonSum = load(fullfile(folder,'SkeletonSum.mat'),'SkeletonFeatureSum');  
    SkeletonSum = SkeletonSum.SkeletonFeatureSum;
    
    
    if size(pitch)>size(SkeletonSum)
        SkeletonSum=SkeletonSum(1:size(pitch),:);
    else
        pitch=pitch(1:size(SkeletonSum),:);
    end  
    [A,B,r,U,V] = canoncorr(pitch,SkeletonSum);
    
% PLOT

%     if A<0
%         U=-U;
%     end
%     if B<0
%         V=-V;
%     end
%     figure; hold all
% 
%     plot(0:5:size(U,1)*5-5,U(:,1), 'LineWidth',1.5);
%     plot(0:5:size(U,1)*5-5,V(:,1), 'LineWidth',1.5);
%     legend('Pitch','Body Movement');
%     xlabel('Time (sec)');
%     ax=gca;
%     ax.YTickLabel='';
    
    
    fprintf([dirlist(n).name ' ' num2str(r) ]);
    spk = 3:length(dirlist);
    spk(find(spk==n))=[];
    corr_other = 0;
    for m=1:length(spk)
        folder = fullfile(Path,dirlist(spk(m)).name); 
        SkeletonSum = load(fullfile(folder,'SkeletonSum.mat'),'SkeletonFeatureSum');  
        SkeletonSum = SkeletonSum.SkeletonFeatureSum;
     
    
        if size(SkeletonSum,1)>size(pitch,1)
            SkeletonSum = SkeletonSum(1:size(pitch,1),:);
        else
            pitch = pitch(1:size(SkeletonSum,1),:);            
        end
        
        [A,B,r0,U,V] = canoncorr(pitch,SkeletonSum);
        corr_other = corr_other+r0;
    end
    corr_other = corr_other/length(spk);
    fprintf([' ' num2str(corr_other) '\n']);  
    
    self = self+r;
    other = other+corr_other;
end
self = self/length(dirlist);
other = other/length(dirlist);
fprintf(['  ' num2str(self) ' ' num2str(other) '\n']);  
