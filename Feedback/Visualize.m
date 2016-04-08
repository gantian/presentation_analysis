function Visualize    
    %addpath('../');
    para = config_Para();
    anno_convert = load(sprintf('%s/taskAssignment',para.ResultPath));
    showList = anno_convert.taskAssignment.showList;    
    
    close all;    
    hValue = figure('Visible', 'on');
    hPi = figure('Visible', 'on');
    loaded = load(sprintf('%s/result_label.mat',para.ResultPath));
    
    res = [loaded.label.c01_speaking_rate,...1
        loaded.label.c02_fluency,...2
        loaded.label.c03_liveness,...3
        loaded.label.c04_bodymovement,...4
        loaded.label.c05_gesture,...5
        loaded.label.c06_audience,...6
        loaded.label.c07_wbORscreen,...7
        loaded.label.c08_com,...8
        loaded.label.c09_scr,...9
        loaded.label.c10_other,...10
        loaded.label.c11_att,...11
        loaded.label.c12_all,...12
        loaded.label.c14_engagement_1,...13
        loaded.label.c16_engagement_2,...14
        loaded.label.c17_pre_state];...15
        
    for iSpeaker=1:1
        idx = find(showList(:,3)==iSpeaker);
        show = res(idx,:);
        ShowStat(show,hValue,hPi);
        
        set(0,'CurrentFigure',hValue);
        saveFileName = sprintf('./Imgs/S%02d_value.jpg',iSpeaker);
        saveas(gcf,saveFileName);     
        set(0,'CurrentFigure',hPi);
        saveFileName = sprintf('./Imgs/S%02d_pi.jpg',iSpeaker);
        %saveas(gcf,saveFileName);     
    end                
end
function ShowStat( data,hValue,hPi )
    opt = {'Linewidth',3};  
    optFont = {'fontsize',12};
    con_textL = GetConceptTextL;
        
    set(0,'CurrentFigure',hValue);
    cla
    subplot_tight(4,1,1,[0.05, 0.03]);
    for iConcept = 1:3        
        concept = data(:,iConcept);        
        concept(concept==-1|concept==0|isnan(concept)) = 2;
        
        ydata = [1:9];ylabels = {'A','B','C','A','B','C','A','B','C'};        
        set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);
        axis([1 length(concept) 0 10]); hold on;                
        plot(concept+(iConcept-1)*3,opt{:},'Color','k');                
        
        h=text(0,1.5+(iConcept-1)*3,con_textL{iConcept},optFont{:});
        set(h,'Rotation',90);        
    end
    
%     for iConcept = 1:3        
%         concept = data(:,iConcept);        
%         concept(concept==-1|concept==0|isnan(concept)) = 2;
%         
%         set(0,'CurrentFigure',hPi);
%         subplot_tight(3,3,iConcept,[0.05, 0.03]);
%         DrawPiGraph(concept,con_textL{iConcept});
%     end
    
    set(0,'CurrentFigure',hValue);
    subplot_tight(4,1,2,[0.05, 0.03]);
    cla;
    for iConcept = 4:5
        concept = data(:,iConcept);        
        concept(concept==-1|concept==0|isnan(concept)) = 2;
        
        ydata = (1:6);ylabels = {'A','B','C','A','B','C'};hold on        
        set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);axis([1 length(concept) 0 7]); 
                        
        plot(concept+(iConcept-4)*3,opt{:},'Color','k');                
        
        h=text(-3,1.5+(iConcept-4)*3,con_textL{iConcept},optFont{:});
        set(h,'Rotation',90);
        
%         set(0,'CurrentFigure',hPi);
%         subplot_tight(3,3,iConcept,[0.05, 0.03]);        
%         DrawPiGraph(concept,con_textL{iConcept});
    end
    
    optL = {'r.','k.','c.','g.','m.'};    
    set(0,'CurrentFigure',hValue);
    subplot_tight(3,3,6,[0.05, 0.03]);
    cla;hold on;
    ydata = [1:6];ylabels = {'A','B','C','D','E',' '};
    set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);
    %     set(gca,'xtick',[],'ytick',[]);
    title('Attention','fontsize',15);
    
%     set(0,'CurrentFigure',hPi);
%         subplot_tight(3,3,6,[0.05, 0.03]);        
%         DrawPiGraph(concept,con_textL{iConcept});
    cla;
    concept_Other = zeros(size(data(:,6)));
    for iConcept = 6:10   
        concept = data(:,iConcept);       
        concept(concept ~= 1) = nan; 
        
        if iConcept==10
            concept = double(~concept_Other);
            concept(concept ~= 1) = nan; 
        else
            concept_Other(concept == 1) = 1;
        end
        
        set(0,'CurrentFigure',hValue);
        axis([1 length(concept) 1 6]);
        hold on;
               
        %for iOff = 0:0.001:0.02
        for iOff = 0:0.01:0.5
            plot(concept+(iConcept-6)+(iOff),optL{iConcept-5});            
        end                
    end
    %% Occupation Map
    %     binSZ = 26;
    %     offset = 5;
    %     numS = 5;
    %     occup = ones(binSZ*numS,length(data(:,6)));
    %     for iConcept = 6:10
    %         binIdx = iConcept-5;
    %         %tmpdata = data(:,iConcept);
    %         idxActive = (data(:,iConcept)==1);
    %         tmpdata = ones(size(data(:,iConcept)));
    %         tmpdata(idxActive) = 0;
    %         occup((binIdx-1)*binSZ+1+offset:binIdx*binSZ-offset,:) = (tmpdata*ones(1,binSZ-offset*2))';
    %         %a(3*binSZ+1:4*binSZ,105:210) = 1;
    %     end
    %     imshow(occup);
    %     for iConcept = 6:10
    %         text(-40,binSZ*(iConcept-5)-binSZ/2,con_textL{iConcept});
    %     end

    for iConcept = 13:15
        concept = data(:,iConcept);       
        concept(concept==-1|concept==0|isnan(concept)) = 2;
        
        set(0,'CurrentFigure',hValue);
        subplot_tight(3,3,iConcept-6,[0.05, 0.03]);
        cla;hold on;
        %axis([1 90 0 4]);set(gca,'xtick',[],'ytick',[]);        
        ydata = [1:3];ylabels = {'A','B','C'};        
        set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);axis([1 length(concept) 0 4]);
        
        
        
        if iConcept==15
            concept(concept==3) = 2;
            ydata = [1:2];ylabels = {'A','B'};        
            set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);
            axis([1 length(concept) 0 3]);
        end
        plot(concept,opt{:},'Color','k');        
        title(con_textL{iConcept},'fontsize',15);  
              
        set(0,'CurrentFigure',hPi);
        subplot_tight(3,3,iConcept-6,[0.05, 0.03]);
        DrawPiGraph(concept,con_textL{iConcept});

    end
    %
    %     subplot_tight(3,3,[9-iszAccuSzSel+1],[0.05,0.05]);
    %     pie(accuData{iszAccuSzSel});
    
end
function DrawPiGraph(concept,titleText)    
    concept(concept==-1) = [];
    concept(concept==0) = [];
    concept(isnan(concept)) = [];
    if length(concept)<1
        return;
    end
    sampleL = unique(concept);
    numValue = zeros(length(sampleL),1);
    for iNumValue = 1:length(sampleL)
        numValue(iNumValue) = sum(concept==sampleL(iNumValue));
    end
    pie(numValue);
    labels = {'A','B','C'};
    labelsShow = cell(1,length(sampleL));
    for i=1:length(sampleL)
        labelsShow{i} = labels{sampleL(i)};
    end
    legend(labelsShow,'Location','bestoutside','Orientation','vertical')
    title(titleText);
end
function con_textL = GetConceptTextL
    con_textL ={...
        'Speaking Rate',...1
        'Fluency',...2
        'Liveness',...3
        'Body Movement',...4
        'Gesture',...5
        'Audience',...6
        'Screen',...7
        'Computer',...8
        'Script',...9
        'Other',...10
        'Nil',...11
        'Nil',...12
        'Audience1 Attention',...13
        'Audience2 Attention',...14
        'Presentation State'...15
        };
    %Leg_textL = {{'slow','moderate','fast'}};
end