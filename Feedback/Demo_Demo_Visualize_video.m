function Demo_Demo_Visualize_video(speakerIdx)
    
    warning('off','all');
    addpath('../');
    para = config_Para;
    if 1
        anno_convert = load(sprintf('%s/taskAssignment',para.AnnotPath));
    else
        anno_convert = load(sprintf('./taskAssignment'));
    end
    showList = anno_convert.taskAssignment.showList;
    
    close all;
    hPi = figure('Visible', 'off');
    hValue = figure('Visible', 'off');
    
    loaded = LoadDataFunc;%load('result_label.mat');
    
    res = [ 
        loaded.label.c01_speaking_rate,...1
        loaded.label.c02_fluency,...2
        loaded.label.c03_liveness,...3
        loaded.label.c04_bodymovement,...4
        loaded.label.c05_gesture,...5
        loaded.label.c06_audience,...6
        loaded.label.c07_wbORscreen,...7
        loaded.label.c08_com,...8
        loaded.label.c09_scr,...9
        loaded.label.c10_other,...10
        loaded.label.c14_engagement_1,...loaded.label.c11_att,...11
        loaded.label.c14_engagement_1,...loaded.label.c12_all,...12
        loaded.label.c14_engagement_1,...13
        loaded.label.c16_engagement_2,...14
        loaded.label.c17_pre_state];...15
        
    %       sList = [27,34];
    %     for iiSp = 2:2
    %         iSpeaker = sList(iiSp);
    for iSpeaker= speakerIdx %4:4
        idx = find(showList(:,3)==iSpeaker);
        low = min(idx);
        up = max(idx);
        
        show = res((low-1)*10+1:up*10,:);
        
        totalLen = size(show,1);
        con_showLen = 40;
        for iTotalLen = 1:totalLen
            disp(iTotalLen);
            showData_snapshot = show(max(iTotalLen-con_showLen+1,1):iTotalLen,:);
            showData_accum = show(1:iTotalLen,:);
            ShowStat(showData_snapshot,showData_accum,hValue,hPi);
            
            if 1
                set(0,'CurrentFigure',hValue);
                saveFileName = sprintf('./Demo/S%02d_value_%02d.png',iSpeaker,iTotalLen);
                saveas(gcf,saveFileName);
                set(0,'CurrentFigure',hPi);
                saveFileName = sprintf('./Demo/S%02d_pi_%02d.png',iSpeaker,iTotalLen);
                saveas(gcf,saveFileName);
            end
            
            %pause(0.2);
        end
        
        if 0
            set(0,'CurrentFigure',hValue);
            saveFileName = sprintf('./Result/S%02d_value.pdf',iSpeaker);
            saveas(gcf,saveFileName);
            set(0,'CurrentFigure',hPi);
            saveFileName = sprintf('./Result/S%02d_pi.pdf',iSpeaker);
            saveas(gcf,saveFileName);
        end
    end
    
    return;
    
    pID = taskAssignment.taskInfo_pID;
    pID = pID';
    pID = pID(:);
    
    gt(isnan(gt)) = [];
    gt(gt==-1) = [];
    gt(gt==0) = [];
    cla;
    plot(gt,'*','linewidth',3);
    %axis([1 90 0 4]);
    
    for iSpeaker = 1:51
        speakerIdx = find(pID==iSpeaker);
        showGT = gt(speakerIdx);
        cla;
        plot(showGT,'*','linewidth',5);
        hold on;
        title(iSpeaker);
        axis([1 length(showGT) 0 4]);
        
        
    end
    warning('on','all');
end
function ShowStat( data_snapshot,data_accum,hValue,hPi )
    opt = {'Linewidth',3};
    optFont = {'fontsize',16};
    con_textL = GetConceptTextL;
    
    replaceNan = 2;
    numRow = 10;
    numCol = 1;
    
    for iConcept = 1:5
        concept = data_snapshot(:,iConcept);
        concept(concept==-1|concept==0|isnan(concept)) = replaceNan;
        concept_accum = data_accum(:,iConcept);
        concept(concept_accum==-1|concept_accum==0|isnan(concept_accum)) = replaceNan;
        
        set(0,'CurrentFigure',hValue);
        subplot_tight(numRow,numCol,iConcept,[0.05, 0.03]);
        cla;hold on
        
        ydata = [1:3];ylabels = {'A','B','C'};
        set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);
        %axis([1 length(concept) 0 4]);
        axis([1 40 0 4]);
        
        plot(concept,opt{:},'Color','k');
        title(con_textL{iConcept},'fontsize',15);
        h=text(1,5,con_textL{iConcept},optFont{:});
        %set(h,'Rotation',90);
        set(gca, 'visible', 'off') ;
        DrawPresentationState(data_snapshot(:,15));
        
        set(0,'CurrentFigure',hPi);
        subplot_tight(3,3,iConcept,[0.05, 0.03]);
        
        DrawPiGraph(concept_accum,con_textL{iConcept});
        %saveas(gca,'hi.jpg');
    end
    
    set(0,'CurrentFigure',hValue);
    
    optL = {'r.','r.','r.','r.','r.'};    set(0,'CurrentFigure',hValue);
    subplot_tight(numRow,numCol,[6 8],[0.03, 0.03]);
    
    cla;set(gca, 'visible', 'off') ;
    concept_att_cnt = zeros(5,1);
    concept_Other_accum = zeros(size(data_accum(:,6)));
    concept_Other = zeros(size(data_snapshot(:,6)));
    gapSize = 1.5;
    
    for iConcept = 6:10
        concept = data_snapshot(:,iConcept);  concept(concept ~= 1) = nan;
        
        concept_accum = data_accum(:,iConcept); concept_accum(concept_accum ~= 1) = nan;
        
        if iConcept==10,concept_accum = double(~concept_Other_accum);concept_accum(concept_accum ~= 1) = nan;
        else concept_Other_accum(concept_accum == 1) = 1; end
        
        if iConcept==10,concept = double(~concept_Other);concept(concept ~= 1) = nan;
        else concept_Other(concept == 1) = 1; end
        
        concept_att_cnt(iConcept-5) = sum(concept_accum==1);
        
        set(0,'CurrentFigure',hValue);
        %axis([1 length(concept) 3.5 18]);hold on;
        axis([1 40 3.5 18]);hold on;
        
        %         cla;
        if mod(iConcept,2),conceptColor = 'y';
        else conceptColor = 'y'; end
        offC = (iConcept-5)*(1.5+gapSize);
        p=patch([0 length(concept) length(concept) 0],[-0.5 -0.5 1 1]+offC+gapSize,conceptColor);
        set(p,'FaceAlpha',0.2,'EdgeColor','none');
        for iConDraw = 1:length(concept)
            spos = concept(iConDraw)+(iConcept-6)*(1.5+gapSize)+3.5;
            if ~isnan(concept(iConDraw))
                %plot([iConDraw iConDraw],[spos-0.5 spos+1],'Color','r','LineWidth',40);
                %plot([iConDraw-0.5 iConDraw-0.5],[spos-0.5 spos+1],'Color','r','LineWidth',40);
                p=patch([iConDraw-1 iConDraw iConDraw iConDraw-1],[-0.5 -0.5 1 1]+offC+gapSize,'r');
                set(p,'FaceAlpha',0.8,'EdgeColor','none');
            end
        end
        %         plot([5 5],[spos spos+2],'Color','r','LineWidth',40);
        %         for iOff = 0:0.01:0.5, plot(concept+(iConcept-6)*(1.5+gapSize)+(iOff)+3.5,optL{iConcept-5});end
        
        %for iOff = 0:0.01:1, plot(concept+(iConcept-6)*(1.5+gapSize)+(iOff)+3.5,'ro');end
        
        h=text(1,(iConcept-4.2)*(1.5+gapSize)+0.6,con_textL{iConcept},optFont{:});
    end
    
    
    
    set(0,'CurrentFigure',hPi);
    subplot_tight(3,3,6,[0.1, 0.1]);
    cla;
    bar(concept_att_cnt./length(concept_Other_accum)*100,'FaceColor',[155 170 243]./255);
    axis([0 6 0 100]);
    xdata = [0:6];xlabels = {' ','Aud','Scre','Com','Scri','Oth',' '};
    Ydata = [0:25:100];
    set(gca,'Xtick', xdata, 'XtickLabel', xlabels,'Ytick',Ydata,'FontSize',9);
    %     h = get(gca,'xlabel');
    %     set(gca,'XtickLabel', xlabels,'FontSize',8);
    ylabel('Percentage (%)');
    %title('Attention','FontSize',16);
    text(2,135,'Attention','Fontsize',16);
    %DrawPiGraph(concept,con_textL{iConcept});
    
    
    for iConcept = 13:14
        concept = data_snapshot(:,iConcept);
        concept(concept==-1|concept==0|isnan(concept)) = replaceNan;
        
        set(0,'CurrentFigure',hValue);
        subplot_tight(numRow,numCol,iConcept-4,[0.05, 0.03]);
        cla;hold on;
        
        %axis([1 90 0 4]);set(gca,'xtick',[],'ytick',[]);
        ydata = [1:3];ylabels = {'A','B','C'};
        set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);
        %axis([1 length(concept) 0 4]);
        axis([1 40 0 4]);
        
        if iConcept==15
            concept(concept==3) = 2;
            ydata = [1:2];ylabels = {'A','B'};
            set(gca,'xtick',[],'Ytick', ydata, 'YtickLabel', ylabels);
            %axis([1 length(concept) 0 3]);
            axis([1 40 0 3]);
        end
        plot(concept,opt{:},'Color','k');
        title(con_textL{iConcept},'fontsize',15);
        h=text(1,5,con_textL{iConcept},optFont{:});
        set(gca, 'visible', 'off') ;
        DrawPresentationState(data_snapshot(:,15));
        
        %DrawPresentationState(concept)
        
        set(0,'CurrentFigure',hPi);
        subplot_tight(3,3,iConcept-6,[0.05, 0.03]);
        
        concept_accum = data_accum(:,iConcept);
        %DrawPiGraph(concept_accum,con_textL{iConcept});
        
        DrawPiGraph(concept_accum,con_textL{iConcept},iConcept);
        
    end
    
    for iConcept = 15
        concept = data_snapshot(:,iConcept);
        concept(concept==-1|concept==0|isnan(concept)) = replaceNan;
        concept(concept==3) = 2;
        
        concept_accum = data_accum(:,iConcept);
        concept_accum(concept_accum==-1|concept_accum==0|isnan(concept_accum)) = replaceNan;
        concept_accum(concept_accum==3) = 2;
        
        set(0,'CurrentFigure',hPi);
        subplot_tight(3,3,iConcept-6,[0.05, 0.03]);
        
        DrawPiGraph(concept_accum,con_textL{iConcept},iConcept);
        %DrawPiGraph(concept,con_textL{iConcept},iConcept);
    end
    
    set(0,'CurrentFigure',hValue);
    loc = length(concept)-1-0.1;
    for iText = -100:100
        text(loc,iText,'|','fontsize',36,'color','c');
        text(loc+1,iText,'|','fontsize',36,'color','c');
    end
    
end
function DrawPresentationState(concept)
    preState = concept(1);
    if preState==1
        pColor = 'r';
    elseif preState==2 ||preState==3
        pColor = 'b';
    else
        pColor = 'w';
    end
    preLocation = 0;
    for i=1:length(concept)
        if concept(i)~=preState
            if preState==1
                pColor = 'r';
            elseif preState==2 ||preState==3
                pColor = 'b';
            else
                pColor = 'w';
            end
            p=patch([preLocation i i preLocation],[0 0 4 4],pColor);
            set(p,'FaceAlpha',0.2,'EdgeColor','none');
            preState = concept(i);
            preLocation = i;
        end
    end
    if preState==1
        pColor = 'r';
    elseif preState==2 ||preState==3
        pColor = 'b';
    else
        pColor = 'w';
    end
    p=patch([preLocation i i preLocation],[0 0 4 4],pColor);
    set(p,'FaceAlpha',0.2,'EdgeColor','none');
    
end
function DrawPiGraph(concept,titleText,iConcept)
    if nargin<3,iConcept = 1;end
    concept(concept==-1) = [];
    concept(concept==0) = [];
    concept(isnan(concept)) = [];
    if length(concept)<1
        return;
    end
    sampleL = unique(concept);
    %numValue = zeros(length(sampleL),1);
    numValue = zeros(3,1);
    %     for iNumValue = 1:length(sampleL)
    %         numValue(iNumValue) = sum(concept==sampleL(iNumValue));
    %     end
    %
    for iNumValue = 1:3
        numValue(iNumValue) = sum(concept==iNumValue);
    end
    
    %colorScheme = {[143 239 191]./255,[223 239 143]./255,[143 159 239]./255};
    colorScheme = {[155 243 199]./255,[228 243 155]./255,[155 170 243]./255};
    %ax = axes('Parent', fig);
    hPieComponentHandles = pie(numValue);
    colorIdx = find(numValue>0);
    %     for iCCC = 2:3
    %         colorIdx(iCCC) = colorIdx(iCCC) +colorIdx(iCCC-1);
    %     end
    for iColor = 1:sum(numValue>0)
        set(hPieComponentHandles(iColor*2-1), 'FaceColor', colorScheme{colorIdx(iColor)});
    end
    
    labels = {'In','Norm','Ex'};
    if iConcept == 15
        labels = {'Presentation','Q&A'};
    elseif iConcept == 13||iConcept == 14
        labels = {'No Att','Att','Att with F'};
    end
    
    legend(labels{numValue>0},'Location','southoutside'...
        ,'Orientation','horizontal');
    
    title(titleText,'Fontsize',16);
    %
end
function con_textL = GetConceptTextL
    con_textL ={...
        'Speaking Rate',...1
        'Fluency',...2
        'Liveliness',...3
        'Body Movement',...4
        'Gesture',...5
        'Att:audience',...6
        'Att:screen',...7
        'Att:computer',...8
        'Att:script',...9
        'Att:others',...10
        'Nil',...11
        'Nil',...12
        'Audience1 Engagement',...13
        'Audience2 Engagement',...14
        'Presentation State'...15
        };
    %Leg_textL = {{'slow','moderate','fast'}};
end
function loaded = LoadDataFunc
    filesList = dir('./data/*.mat');
    tmpData = cell(length(filesList),1);
    for i=1:length(filesList)
        tmpData{i} = load(sprintf('./data/%s',filesList(i).name));
    end
    %
    loaded.label.c01_speaking_rate =tmpData{1}.result;
    loaded.label.c02_fluency=tmpData{2}.result;
    loaded.label.c03_liveness=tmpData{3}.result;
    loaded.label.c04_bodymovement=tmpData{4}.result;
    loaded.label.c05_gesture=tmpData{5}.result;
    loaded.label.c06_audience=tmpData{6}.result;
    loaded.label.c07_wbORscreen=tmpData{7}.result;
    loaded.label.c08_com=tmpData{8}.result;
    loaded.label.c09_scr=tmpData{9}.result;
    loaded.label.c10_other=tmpData{10}.result;
    loaded.label.c14_engagement_1=tmpData{11}.result;
    loaded.label.c16_engagement_2=tmpData{12}.result;
    loaded.label.c17_pre_state=tmpData{13}.result;
end