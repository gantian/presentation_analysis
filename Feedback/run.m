% clear;
s = 36;
e = 47;

for iSpeaker = s:e
    %printf('Speaker %02d',iSpeaker);
%     value_graph = false;
%     pi_graph = true;
%     Visualize_feedback(iSpeaker,value_graph,pi_graph);
    
    Feedback2Video(iSpeaker);
    CreateDemoVideo(iSpeaker);
end

%CreateDemoVideo();