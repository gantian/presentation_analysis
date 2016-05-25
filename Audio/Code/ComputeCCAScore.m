clear;

%body movement 1
%gesture 2
%head movement 3

%pitch 1
%speaking rate 2
%voice 3

corr_matrix = zeros(3,3);
details = zeros(9,100);

sSpeaker = 1;
eSpeaker = 1;

nSpeaker = 0;

commonPath = './data';

for iSpeaker = sSpeaker:eSpeaker
    if (iSpeaker == 3 || iSpeaker==4 || iSpeaker==47)
        continue;
    end
     dataLoad = load(sprintf('%s/Spk_%03d_rate.mat',commonPath,iSpeaker));
     rate = dataLoad.rate;
     
     dataLoad = load(sprintf('%s/Spk_%03d_pitch.mat',commonPath,iSpeaker));
     pitch = dataLoad.pitch;
     
     dataLoad = load(sprintf('%s/Spk_%03d_energy.mat',commonPath,iSpeaker));
     energy = dataLoad.energy;
     
     dataLoad = load(sprintf('%s/Spk_%03d_gesture.mat',commonPath,iSpeaker));
     gesture = dataLoad.gesture;
     
     dataLoad = load(sprintf('%s/Spk_%03d_wholebodymovement.mat',commonPath,iSpeaker));
     bodymovement = dataLoad.wholebodymovement;
     
     dataLoad = load(sprintf('%s/Spk_%03d_headmovement.mat',commonPath,iSpeaker));
     GoogleFeatureSum = dataLoad.headmovement;
     
     
     minLen = min([length(rate),length(pitch),length(energy),...
              length(gesture),length(bodymovement),length(GoogleFeatureSum)]);
         
     if minLen<1 
         continue;
     end
     
     bodymovement = bodymovement(1:minLen,:);
     gesture = gesture(1:minLen,:);     
     GoogleFeatureSum = GoogleFeatureSum(1:minLen,:);
                    
     pitch = pitch(1:minLen,:);
     rate = rate(1:minLen,:);
     energy = energy(1:minLen,:);
     
     %%
     [RHO,PVAL] = corr(bodymovement,pitch); 
     corr_matrix(1,1) = corr_matrix(1,1)+RHO;
     details(1,iSpeaker) = RHO;
     
     [RHO,PVAL] = corr(bodymovement,rate); 
     corr_matrix(1,2) = corr_matrix(1,2)+RHO;
     details(2,iSpeaker) = RHO;
     
     [RHO,PVAL] = corr(bodymovement,energy); 
     corr_matrix(1,3) = corr_matrix(1,3)+RHO;
     details(3,iSpeaker) = RHO;
     
     %%
     [RHO,PVAL] = corr(gesture,pitch); 
     corr_matrix(2,1) = corr_matrix(2,1)+RHO;
     details(4,iSpeaker) = RHO;
     
     [RHO,PVAL] = corr(gesture,rate); 
     corr_matrix(2,2) = corr_matrix(2,2)+RHO;
     details(5,iSpeaker) = RHO;
     
     [RHO,PVAL] = corr(gesture,energy); 
     corr_matrix(2,3) = corr_matrix(2,3)+RHO;
     details(6,iSpeaker) = RHO;
     
     %%
     [RHO,PVAL] = corr(GoogleFeatureSum,pitch); 
     corr_matrix(3,1) = corr_matrix(3,1)+RHO;
     details(7,iSpeaker) = RHO;
     
     [RHO,PVAL] = corr(GoogleFeatureSum,rate); 
     corr_matrix(3,2) = corr_matrix(3,2)+RHO;
     details(8,iSpeaker) = RHO;
     
     [RHO,PVAL] = corr(GoogleFeatureSum,energy); 
     corr_matrix(3,3) = corr_matrix(3,3)+RHO;
     details(9,iSpeaker) = RHO;

    nSpeaker = nSpeaker+1;
end

if nSpeaker<=0, return; end

corr_matrix = corr_matrix./nSpeaker;
details = details';

corr_matrix