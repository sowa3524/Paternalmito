%% User defined parameters, video for each embryo should be stored in seperate folder, for example, atg-1, atg-2
inputFolder = '/path_to_folder/atg-1'; 
outputFolder ='/path_to_folder/atg-1'; 
inputFile = 'atg-1.avi';
% Set the Background line, below which the data will be discarded 
Const_Red_Bkg_pct = 0.29;
Const_Green_Bkg_pct = 0.25;

%% Import Video data
obj = VideoReader(fullfile(inputFolder,inputFile));
vid = read(obj);
% Number of frames
frame_num = obj.NumFrames;
for x = 1 : frame_num
    %Create a filename
    outputBaseFileName = sprintf('atg-1-%4.4d.tif', x);
    outputFullFileName = fullfile(outputFolder, outputBaseFileName);
    imwrite(vid(:,:,:,x), outputFullFileName, 'tif');
end


%% Calculate Intensity Weighted x Poistion Average of the Red and the Green Channels
Red_WA = zeros(frame_num,1);
Green_WA = zeros(frame_num,1);
for i = 1:frame_num
    t = Tiff(fullfile(outputFolder,['atg-1-',sprintf('%4.4d',i),'.tif']),'r');
    imageData = read(t);


    x_coordination = 1:700;

    Red_Channel = imageData(:,:,1);
    Red_sum = sum(Red_Channel);
    Red_bkgl = (max(Red_sum)-min(Red_sum))*Const_Red_Bkg_pct + min(Red_sum);
    Red_sum_m = max(zeros(1,length(Red_sum)),Red_sum-Red_bkgl);
    Red_WA(i) = sum(x_coordination.*Red_sum_m)/sum(Red_sum_m);
    
    
    
    Green_Channel = imageData(:,:,2);
    Green_sum = sum(Green_Channel);
    Green_bkgl = (max(Green_sum)-min(Green_sum))*Const_Green_Bkg_pct+ min(Green_sum);
    Green_sum_m = max(zeros(1,length(Green_sum)),Green_sum-Green_bkgl);    
    Green_WA(i) = sum(x_coordination.*Green_sum_m)/sum(Green_sum_m);

    %Blue_Channel = imageData(:,:,3);
    %Blue_sum = sum(Blue_Channel);
    %Blue_WA = sum(x_coordination.*Blue_sum)/sum(Blue_sum);    
    
    myfig = figure;
    subplot(2,1,1)
    imshow(imageData)
    title(['Frame ',num2str(i)])
    %subplot(3,1,2)    
    %contour(Green_Channel)
    subplot(2,1,2)
    hold on;
    box on;
    plot(1:700,Red_sum,'r-')
    %plot(1:700,Blue_sum*mean(Red_sum(400:500)./Blue_sum(400:500)),'r--')
    line([1 700],[Red_bkgl Red_bkgl],'Color','red','LineStyle','--')
    scatter(Red_WA(i),mean(Red_sum),20,'MarkerFaceColor',[1,0,0])
    
    plot(1:700,Green_sum,'g-')
    scatter(Green_WA(i),mean(Green_sum),20,'MarkerFaceColor',[0,1,0])
    line([1 700],[Green_bkgl Green_bkgl],'Color','green','LineStyle','--')

    %scatter(Blue_WA,mean(Blue_sum),20,'MarkerFaceColor',[0,0,1])
    %plot(1:700,Blue_sum,'b-')    
    
    
    saveas(myfig,fullfile(outputFolder,[inputFile(1:end-4),'WA_corr',sprintf('%4.4d',i)]))
    pause(0.01)
    close(myfig)
end


%% Output Summary Data and Figure
myfig = figure;
hold on;
box on;
colororder({'r','g'})
yyaxis left
plot(1:frame_num,Red_WA,'ro-');
xlabel('Frame')
ylabel('Red WA Inices')
yyaxis right
axes_r = plot(1:frame_num,Green_WA,'go-');
ylabel('Green WA Inices')

ta = table();
ta.FrameNum = transpose(1:frame_num);
ta.RedWA = Red_WA;
ta.GreenWA = Green_WA;
writetable(ta,fullfile(outputFolder,[inputFile(1:end-4),'_WA_corr_Summary.csv']))
saveas(myfig,fullfile(outputFolder,[inputFile(1:end-4),'_WA_corr_Summary.fig']))


