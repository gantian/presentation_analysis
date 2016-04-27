clear;

para = Config_Para();



% clear
% % x = rand(1,10);
% % y = rand(1,10);
% 
% x = [1 3 1 12;-1 -3 1 12;11 12 1223 12; 1 2 3 4];
% y = [-2 -8;2 8 ;1 1;12 3];
% x_2 = x.^2;
% 
% [A, B,r] = cca(x,y');
% 
% [~, ~,r2] = cca(x,x);
% 
% [A2,B2,R,U,V] = canoncorr(x,y);
% 
% disp(r);
% disp(r2);
% disp(R);
% [RHO,PVAL] = corr(x,y);

% 
% clear;
% x = [1 4 3 ;...
%      2 -2 4 ;...
%      1 4 31;...
%      11 2 4;...
%      1  15 2];
% y = [1 3 2 12;...
%      2 2 4 11;...
%      1 21 1 12;...
%      11 2 1 15 ;...
%      1 2 3 17];
%  
% % [A, B,r] = cca(x,y);
% 
% 
% 
% 
%  [A2,B2,R,U,V] = canoncorr(x,y);
%   plot(x(:,3),y(:,3),'x');
%   hold on
%   plot(U(:,3),V(:,3),'*');
%   axis([-1 1 -1 1]);
%   axis square
%  
% [RHO, PVAL] = corr(x,y);
% 
% [RHO2, PVAL2] = corr(x,2*x);
% 
% % clear;
% % x = (1:10)';
% % y = x+3;
% % 
% % plot(x,y);
% % 
% % [RHO, PVAL] = corr(y,x);
% 
% clear;
% x = rand(300,1);
% y = rand(300,1);
% 
% [A,B,r,U,V] = canoncorr(x,y);
% 
% [RHO, PVAL] = corr(x,y);
% 
% 
% [A,B,r,U,V] = canoncorr(x,x.*x);
% [RHO, PVAL] = corr(x,x.*x);
% 
% [A2,B2,r2,U2,V2] = canoncorr(x,x.*x);
