%% User defined parameters
inputFolder = '/path_to_folder'; 
inputFile = 'videoinfo_atg.csv';
t_videoinfo = readtable(fullfile(inputFolder,inputFile));

%% Plot all
% If you have revised_first_frame and revised_last_frame in your
% videinfo.csv
myfig = figure;
hold on;


t_videoinfo_size = size(t_videoinfo);
a_redWAPct_sum = NaN(max(t_videoinfo.revised_last_frame-t_videoinfo.revised_first_frame+1),t_videoinfo_size(1));
a_greenLBPct_sum = NaN(max(t_videoinfo.revised_last_frame-t_videoinfo.revised_first_frame+1),t_videoinfo_size(1));


for i = 1:t_videoinfo_size(1)
    video_ID = string(t_videoinfo.video_ID(i));
    filename_temp = strcat(video_ID,'_WA_corr_Summary.csv');
    t_data = readtable(fullfile(inputFolder,video_ID,filename_temp));

    revised_first_frame = t_videoinfo.revised_first_frame(i);
    revised_last_frame = t_videoinfo.revised_last_frame(i);

    RedWAPct = t_data.RedWAPct;
    GreenLBPct = t_data.GreenLBPct;

        
    a_redWAPct_sum(1:-revised_first_frame+revised_last_frame+1,i) = RedWAPct(revised_first_frame:revised_last_frame);
    a_greenLBPct_sum(1:-revised_first_frame+revised_last_frame+1,i) = GreenLBPct(revised_first_frame:revised_last_frame);

    FrameNum = t_data.FrameNum;
    plot(FrameNum(1:-revised_first_frame+revised_last_frame+1),RedWAPct(revised_first_frame:revised_last_frame),'ro-','MarkerFaceColor',[1,0,0])
    plot(FrameNum(1:-revised_first_frame+revised_last_frame+1),GreenLBPct(revised_first_frame:revised_last_frame),'go-','MarkerFaceColor',[0,1,0])

end


t_redWAPct_sum = array2table(a_redWAPct_sum);
t_redWAPct_sum.revised_frame_index = transpose(1:max(t_videoinfo.revised_last_frame-t_videoinfo.revised_first_frame+1));
t_greenLBPct_sum = array2table(a_greenLBPct_sum);
t_greenLBPct_sum.revised_frame_index = transpose(1:max(t_videoinfo.revised_last_frame-t_videoinfo.revised_first_frame+1));
t_sum = join(t_redWAPct_sum,t_greenLBPct_sum);


a_redWAPct_mean = mean(a_redWAPct_sum,2);
a_greenLBPct_mean = mean(a_greenLBPct_sum,2);
a_redWAPct_error = std(a_redWAPct_sum,0,2)/sqrt(t_videoinfo_size(1));
a_greenLBPct_error = std(a_greenLBPct_sum,0,2)/sqrt(t_videoinfo_size(1));

t_sum.redWAPct_mean = a_redWAPct_mean;
t_sum.redWAPct_error = a_redWAPct_error;
t_sum.greenLBPct_mean = a_greenLBPct_mean;
t_sum.greenLBPct_error = a_greenLBPct_error;

writetable(t_sum,fullfile(inputFolder,'revised_frames_summarized_data_atg.csv'));

figure; hold on;
errorbar(1:length(a_redWAPct_mean),a_redWAPct_mean,a_redWAPct_error,'Color',[1,0,0])
errorbar(1:length(a_greenLBPct_mean),a_greenLBPct_mean,a_greenLBPct_error,'Color',[0,1,0])
ylim([10,50])

