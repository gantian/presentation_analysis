clear;

self=0;other=0;

corr_head_pitch = 0;
corr_head_speakingrate = 0;
corr_head_energy = 0;
corr_gesture_pitch = 0;
corr_bodymovement_pitch = 0;


sSpeaker = 1;
eSpeaker = 51;

nSpeaker = 0;

rSp = zeros(51,1);
rSp_2 = zeros(51,1);
rSp_gest_Pitch= zeros(51,1);
rSp_bm_Pitch= zeros(51,1);

for iSpeaker = sSpeaker:eSpeaker
    if (iSpeaker == 3 || iSpeaker==4)
        continue;
    end
     dataLoad = load(sprintf('./data/Spk_%03d_rate.mat',iSpeaker));
     rate = dataLoad.Rate;
     
     dataLoad = load(sprintf('./data/Spk_%03d_pitch.mat',iSpeaker));
     pitch = dataLoad.pitchnew;
     
     dataLoad = load(sprintf('./data/Spk_%03d_energy.mat',iSpeaker));
     energy = dataLoad.Energy;
     
     dataLoad = load(sprintf('./data/Spk_%03d_gesture.mat',iSpeaker));
     gesture = dataLoad.SkeletonFeatureSum;
     
     dataLoad = load(sprintf('./data/Spk_%03d_bodymovement.mat',iSpeaker));
     bodymovement = dataLoad.SkeletonFeatureSumWholebody;
     
     dataLoad = load(sprintf('./data/Spk_%03d_GoogleFeatureSum.mat',iSpeaker));
     GoogleFeatureSum = dataLoad.GoogleFeatureSum;
     
     
     minLen = min(min(min(length(rate),length(pitch)),length(energy)),length(GoogleFeatureSum));
    
     if minLen<1 
         continue;
     end
     rate = rate(1:minLen,:);
     pitch = pitch(1:minLen,:);
     energy = energy(1:minLen,:);
     GoogleFeatureSum = GoogleFeatureSum(1:minLen,:);
%     if size(rate)>size(GoogleFeatureSum)
%         GoogleFeatureSum=GoogleFeatureSum(1:size(rate),:);
%     else
%         rate=rate(1:size(GoogleFeatureSum),:);
%     end  
    
    %[A,B,r,U,V] = canoncorr(rate,GoogleFeatureSum);
    
    [RHO,PVAL] = corr(pitch,GoogleFeatureSum); 
    rSp(iSpeaker) = RHO;
    %[A,B,RHO,U,V] = canoncorr(GoogleFeatureSum,pitch);
%     RHO = abs(RHO);    
    corr_head_pitch = corr_head_pitch + RHO;
    
    [RHO,PVAL] = corr(GoogleFeatureSum,rate);
    rSp_2(iSpeaker) = RHO;
%     [A,B,RHO,U,V] = canoncorr(GoogleFeatureSum,rate);
%     RHO = abs(RHO);
    corr_head_speakingrate = corr_head_speakingrate + RHO;
    
    [RHO,PVAL] = corr(GoogleFeatureSum,energy);
%     [A,B,RHO,U,V] = canoncorr(GoogleFeatureSum,energy);
%     RHO = abs(RHO);
    corr_head_energy = corr_head_energy + RHO;
    
    
    [RHO,PVAL] = corr(gesture,pitch);
    corr_gesture_pitch = corr_gesture_pitch + RHO;
    
    rSp_gest_Pitch(iSpeaker) = RHO;

    
    [RHO,PVAL] = corr(bodymovement,pitch);
    corr_bodymovement_pitch = corr_bodymovement_pitch + RHO;
    rSp_bm_Pitch(iSpeaker) = RHO;
    
    
    [RHO,PVAL] = corr(SkeletonFeatureSumWholebody,pitchnew);
    [RHO_2,PVAL_2] = corr(SkeletonSum,pitch);
    
    [RHO_2,PVAL_2] = corr(SkeletonSum(1:175),pitch(1:175));
    
    
    
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
    nSpeaker = nSpeaker+1;
end

%nSpeaker = (eSpeaker - sSpeaker + 1);
if nSpeaker<=0, return; end
corr_head_pitch = corr_head_pitch/nSpeaker;
corr_head_speakingrate = corr_head_speakingrate/nSpeaker;
corr_head_energy = corr_head_energy/nSpeaker;


corr_bodymovement_pitch = corr_bodymovement_pitch/nSpeaker;
 corr_gesture_pitch = corr_gesture_pitch/nSpeaker;

