% clear
% close all
% spk_A = load('./feat_proj/spk_23_fea_proj.mat');
% spk_B = load('./feat_proj/spk_49_fea_proj.mat');
% 
% sig_1 = 2;
% sig_2 = 3;
% 
% figure;
% plot(spk_A.featureMatrix_Row(:,sig_1),'r');
% hold on
% plot(spk_A.featureMatrix_Col(:,sig_2),'b');
% ylim([-10,30]);
% 
% figure;
% plot(spk_B.featureMatrix_Row(:,sig_1),'r');
% hold on
% plot(spk_B.featureMatrix_Col(:,sig_2),'b');
% ylim([-10,30]);
% 
% res = zeros(51,32);
% for iSpk = 1:51
%     if iSpk == 3|| iSpk == 4|| iSpk == 47
%         continue;
%     end
%     for i=1:8
%         for j=1:4
%             res(iSpk,(i-1)*4+j) = corrMat{iSpk}(i,j);
%         end
%     end
% end

clear;
res = cell(51,1);

for iSpk = 1:51
    if iSpk == 3|| iSpk == 4|| iSpk == 47
        continue;
    end
   dataLoad = load(sprintf('./feat_proj/spk_%02d_fea_proj.mat',iSpk));
   X = dataLoad.featureMatrix_Row_proj;
   Y = dataLoad.featureMatrix_Col_proj;
%    mX = mean(X);
%    vX = std(X);
%    mY = mean(Y);
%    vY = std(Y);
   
%   res{iSpk} = ((X - ones(length(X),1)*mX).*(Y - ones(length(Y),1)*mY))/(vX*vY);
    res{iSpk} = 
end



iSpk = 43;
dataLoad = load(sprintf('./feat_proj/spk_%02d_fea_proj.mat',iSpk));
rawX = dataLoad.featureMatrix_Row;
rawY = dataLoad.featureMatrix_Col;
X = dataLoad.featureMatrix_Row_proj;
Y = dataLoad.featureMatrix_Col_proj;

figure;
plot(X,'r');
hold on
plot(Y,'b');
hold on
plot(res{iSpk},'g');

mrawX = max(abs(rawX));
mrawY = max(abs(rawY));


rawX = rawX./repmat(mrawX,[size(rawX,1),1]);
rawY = rawY./repmat(mrawY,[size(rawY,1),1]);

for i=1:8
    for j=1:4
        
        
%         mX = mean(rawX(:,i));
%         vX = std(rawX(:,i));
%         mY = mean(rawY(:,j));
%         vY = std(rawY(:,j));
%         plotRes = ((rawX(:,i) - ones(length(rawX(:,i)),1)*mX).*(rawY(:,j) - ones(length(rawY(:,j)),1)*mY))/(vX*vY);
        plotRes = CalculateCorrelation_Seg(rawX(:,i),rawY(:,j));
        cla
%         plot(rawX(:,i),'k');
%         plot(rawY(:,j),'r');
          plot(res{iSpk},'g');
          plot(plotRes+5,'m');
        corr_point = CalculateCorrelation(res{iSpk},plotRes);
 %       corr_point(find(corr_point(:)<0))=0;
        
        corr_Seg = CalculateCorrelation_Seg(res{iSpk},plotRes);
        %corr_Seg(find(corr_Seg(:)<0))=0;
        plot(corr_Seg+15,'b');
        plot(corr_point+20,'r');
        fprintf('i=%d j=%d\n',i,j);
        
        
        
        
        
       pause;
    end
end


