%% User defined parameters
inputFolder = '/path_to_folder/N2a'; 
inputFile = 'videoinfo_WT.csv';

t_videoinfo = readtable(fullfile(inputFolder,inputFile));
Constant_rel_dis_btw_WA_LB = 0; % a number between 0 and 1, when taken 0 LB = WA, when taken 1 RB = WA 


%% Plot each with unit as percent of egg length
t_videoinfo_size = size(t_videoinfo);
for i = 1:t_videoinfo_size(1)

    video_ID = string(t_videoinfo.video_ID(i));
    filename_temp = strcat(video_ID,'_WA_corr_Summary.csv');
    t_data = readtable(fullfile(inputFolder,video_ID,filename_temp));
    l_boundary = t_videoinfo.l_boundary(i);
    r_boundary = t_videoinfo.r_boundary(i);
    RedWA = t_data.RedWA;
    RedWAPct =  (RedWA+350-l_boundary)/(r_boundary-l_boundary)*100;
    t_data.RedWAPct = RedWAPct;
    GreenWA = t_data.GreenWA;
    x = Constant_rel_dis_btw_WA_LB;
    GreenLBPct = ((GreenWA- x*r_boundary)/(1-x)+350-l_boundary)/(r_boundary-l_boundary)*100;
    t_data.GreenLBPct = GreenLBPct;
    writetable(t_data,fullfile(inputFolder,video_ID,filename_temp))

    %plot(optional)
    myfig = figure;
    hold on;
    FrameNum = t_data.FrameNum;
    plot(FrameNum,RedWAPct,'ro-')
    plot(FrameNum,GreenLBPct,'go-')
    ylabel('precent of cell length')
    xlabel('frame number')
    pause(0.5)
    saveas(myfig,fullfile(inputFolder,video_ID,strcat(video_ID,'_WA_corr_pct_Summary.fig')))
    close(myfig)

end


