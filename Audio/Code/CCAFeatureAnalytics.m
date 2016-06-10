clear;
res = cell(51,1);
corrMat = cell(51,1);

for iSpk = 1:51
    if iSpk == 3|| iSpk == 4|| iSpk == 47
        continue;
    end
    dataLoad = load(sprintf('./feature_cca_proj/spk_%02d_fea_proj.mat',iSpk));
    validFlag_seg = dataLoad.validFlag_seg;
    X = dataLoad.featureMatrix_Row_proj;
    Y = dataLoad.featureMatrix_Col_proj;
    mX = mean(X);
    vX = std(X);
    mY = mean(Y);
    vY = std(Y);
    
    corrMat{iSpk} = CalculateCorrelation_Seg(X,Y,10);
    corrMat{iSpk}(validFlag_seg<=0) = inf;
    %    disp(iSpk);
    % end
    % %
    % % return;
    %
    % for iSpk = 1:51
    
    disp(iSpk);
    %     if iSpk == 3|| iSpk == 4|| iSpk == 47
    %         continue;
    %     end
    
    %     dataLoad = load(sprintf('./feature_cca_proj/spk_%02d_fea_proj.mat',iSpk));
    %     rawX = dataLoad.featureMatrix_Row;
    %     rawY = dataLoad.featureMatrix_Col;
    %     X = dataLoad.featureMatrix_Row_proj;
    %     Y = dataLoad.featureMatrix_Col_proj;
    
    
    
    maxX = max(abs(X));
    maxY = max(abs(Y));
        
    X = X./repmat(maxX,[size(X,1),1]);
    Y = Y./repmat(maxY,[size(Y,1),1]);
    
    X(validFlag_seg<=0) = inf;
    Y(validFlag_seg<=0) = inf;
    
    % figure;
    cla
    plot(X,'r');
    hold on
    plot(Y+2,'b');
    hold on
    plot(corrMat{iSpk}+4,'g');
    pause;
end

return;
mrawX = max(abs(rawX));
mrawY = max(abs(rawY));


rawX = rawX./repmat(mrawX,[size(rawX,1),1]);
rawY = rawY./repmat(mrawY,[size(rawY,1),1]);

% for i=1:4
%     for j=1:2
%
% %         mX = mean(rawX(:,i));
% %         vX = std(rawX(:,i));
% %         mY = mean(rawY(:,j));
% %         vY = std(rawY(:,j));
% %         plotRes = ((rawX(:,i) - ones(length(rawX(:,i)),1)*mX).*(rawY(:,j) - ones(length(rawY(:,j)),1)*mY))/(vX*vY);
%         plotRes = CalculateCorrelation_Seg(rawX(:,i),rawY(:,j));
%         cla
% %         plot(rawX(:,i),'k');
% %         plot(rawY(:,j),'r');
%           plot(res{iSpk},'g');
%           plot(plotRes+5,'m');
%         corr_point = CalculateCorrelation(res{iSpk},plotRes);
%  %       corr_point(find(corr_point(:)<0))=0;
%
%         corr_Seg = CalculateCorrelation_Seg(res{iSpk},plotRes);
%         %corr_Seg(find(corr_Seg(:)<0))=0;
%         plot(corr_Seg+15,'b');
%         plot(corr_point+20,'r');
%         fprintf('i=%d j=%d\n',i,j);
%
%        pause;
%     end
% end


