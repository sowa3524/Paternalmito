%% Analysize data and save the result to csv files
addpath('/path_to_folder/trackmate and matlab data')
const_time_interval = 17; %Time interval between frames in seconds;
const_average_range = 2; %PIV data average range in integal, starting from 0;
const_total_video_num = 12; %total video number

opts = detectImportOptions('atg-1spot.csv');
opts.DataLines = 5; % Data start from the fifth line
for j=1:const_total_video_num
    spotData = readtable(['atg-',num2str(j),'spot.csv'],opts);
    PIVData = load(['atg',num2str(j),'_PIVlab.mat']);
    
    ResultData = table();

    MITO_U = zeros(length(spotData.TRACK_ID),1);
    MITO_V = zeros(length(spotData.TRACK_ID),1);
    MITO_velocity = zeros(length(spotData.TRACK_ID),1);
    MITO_theta = zeros(length(spotData.TRACK_ID),1);

    for i = 1:length(spotData.TRACK_ID)
        if i == 1
            MITO_U(i) = NaN;
            MITO_V(i) = NaN;
            MITO_velocity(i) = NaN;
            MITO_theta(i) = NaN;
        else
            if spotData.TRACK_ID(i-1) == spotData.TRACK_ID(i)
                MITO_U(i) = (spotData.POSITION_X(i)-spotData.POSITION_X(i-1))/(const_time_interval*(spotData.FRAME(i)-spotData.FRAME(i-1)));
                MITO_V(i) = (spotData.POSITION_Y(i)-spotData.POSITION_Y(i-1))/(const_time_interval*(spotData.FRAME(i)-spotData.FRAME(i-1)));
                [MITO_theta(i),MITO_velocity(i)] = cart2pol(MITO_U(i),MITO_V(i));
            else
                MITO_U(i) = NaN;
                MITO_V(i) = NaN;
                MITO_velocity(i) = NaN;
                MITO_theta(i) = NaN; 
            end
        end 
    end

    ResultData.TRACK_ID = spotData.TRACK_ID;
    ResultData.FRAME = spotData.FRAME;
    ResultData.MITO_X = spotData.POSITION_X;
    ResultData.MITO_Y = spotData.POSITION_Y;
    ResultData.MITO_U = MITO_U*60; % convert the unit from per s to per min
    ResultData.MITO_V = MITO_V*60;
    ResultData.MITO_velocity = MITO_velocity*60;
    ResultData.MITO_theta =  MITO_theta*180/pi(); % convert angle from rad to deg


    idx_ini_PIV_t = zeros(length(spotData.TRACK_ID),1);
    idx_fin_PIV_t = zeros(length(spotData.TRACK_ID),1);
    idx_ini_PIV_x = zeros(length(spotData.TRACK_ID),1);
    idx_fin_PIV_x = zeros(length(spotData.TRACK_ID),1);
    idx_ini_PIV_y = zeros(length(spotData.TRACK_ID),1);
    idx_fin_PIV_y = zeros(length(spotData.TRACK_ID),1);
    
    for i = 1:length(ResultData.TRACK_ID)
        if ResultData.FRAME(i) == 0 || isnan(ResultData.MITO_U(i)) || isnan(ResultData.MITO_V(i))
            idx_ini_PIV_t(i) = NaN;
            idx_fin_PIV_t(i) = NaN;
            idx_ini_PIV_x(i) = NaN;
            idx_fin_PIV_x(i) = NaN;
            idx_ini_PIV_y(i) = NaN;
            idx_fin_PIV_y(i) = NaN;   
        else

            idx_ini_PIV_t(i) = ResultData.FRAME(i);
            idx_fin_PIV_t(i) = ResultData.FRAME(i);

            temp = PIVData.x{idx_ini_PIV_t(i)};
            temp = temp(1,:);
            n = ResultData.MITO_X(i-1)*1e-6;
            [~,idx]=min(abs(temp-n));
            idx_ini_PIV_x(i) = idx;

            temp = PIVData.x{idx_fin_PIV_t(i)}; 
            temp = temp(1,:);
            n = ResultData.MITO_X(i)*1e-6;
            [~,idx]=min(abs(temp-n)); 
            idx_fin_PIV_x(i) = idx;

            temp = PIVData.y{idx_ini_PIV_t(i)};
            temp = temp(:,1);
            n = ResultData.MITO_Y(i-1)*1e-6;
            [~,idx]=min(abs(temp-n));        
            idx_ini_PIV_y(i) = idx;

            temp = PIVData.y{idx_fin_PIV_t(i)};
            temp = temp(:,1);
            n = ResultData.MITO_Y(i)*1e-6;
            [~,idx]=min(abs(temp-n));        
            idx_fin_PIV_y(i) = idx;
        end
    end

    ResultData.idx_ini_PIV_t = idx_ini_PIV_t;
    ResultData.idx_fin_PIV_t = idx_fin_PIV_t;
    ResultData.idx_ini_PIV_x = idx_ini_PIV_x;
    ResultData.idx_fin_PIV_x = idx_fin_PIV_x;
    ResultData.idx_ini_PIV_y = idx_ini_PIV_y;
    ResultData.idx_fin_PIV_y = idx_fin_PIV_y;



    PIV_U_ini = zeros(length(spotData.TRACK_ID),1);
    PIV_U_fin = zeros(length(spotData.TRACK_ID),1);
    PIV_V_ini = zeros(length(spotData.TRACK_ID),1);
    PIV_V_fin = zeros(length(spotData.TRACK_ID),1);

    for i = 1:length(ResultData.TRACK_ID)
        if isnan(ResultData.idx_ini_PIV_t(i))||isnan(ResultData.idx_fin_PIV_t(i))
            PIV_U_ini(i) = NaN;
            PIV_U_fin(i) = NaN;
            PIV_V_ini(i) = NaN;
            PIV_V_fin(i) = NaN;        
        else
            temp = PIVData.u_original{ResultData.idx_ini_PIV_t(i)};
            size_temp = size(temp);
            mean_ini_u = nanmean(nanmean(...
                temp(max(1,ResultData.idx_ini_PIV_y(i)-const_average_range):min(size_temp(1),ResultData.idx_ini_PIV_y(i)+const_average_range),...
                max(1,ResultData.idx_ini_PIV_x(i)-const_average_range):min(size_temp(2),ResultData.idx_ini_PIV_x(i)+const_average_range))));

            temp = PIVData.u_original{ResultData.idx_fin_PIV_t(i)};
            size_temp = size(temp);       
            mean_fin_u = nanmean(nanmean(...
                temp(max(1,ResultData.idx_fin_PIV_y(i)-const_average_range):min(size_temp(1),ResultData.idx_fin_PIV_y(i)+const_average_range),...
                max(1,ResultData.idx_fin_PIV_x(i)-const_average_range):min(size_temp(2),ResultData.idx_fin_PIV_x(i)+const_average_range))));

            PIV_U_ini(i) = mean_ini_u;
            PIV_U_fin(i) = mean_fin_u;

            temp = PIVData.v_original{ResultData.idx_ini_PIV_t(i)};
            size_temp = size(temp);
            mean_ini_v = nanmean(nanmean(...
                temp(max(1,ResultData.idx_ini_PIV_y(i)-const_average_range):min(size_temp(1),ResultData.idx_ini_PIV_y(i)+const_average_range),...
                max(1,ResultData.idx_ini_PIV_x(i)-const_average_range):min(size_temp(2),ResultData.idx_ini_PIV_x(i)+const_average_range))));

            temp = PIVData.v_original{ResultData.idx_fin_PIV_t(i)};
            size_temp = size(temp);       
            mean_fin_v = nanmean(nanmean(...
                temp(max(1,ResultData.idx_fin_PIV_y(i)-const_average_range):min(size_temp(1),ResultData.idx_fin_PIV_y(i)+const_average_range),...
                max(1,ResultData.idx_fin_PIV_x(i)-const_average_range):min(size_temp(2),ResultData.idx_fin_PIV_x(i)+const_average_range))));

            PIV_V_ini(i) = mean_ini_v;
            PIV_V_fin(i) = mean_fin_v;
        end
    end

    ResultData.PIV_U_ini = PIV_U_ini*6e7;
    ResultData.PIV_U_fin = PIV_U_ini*6e7;
    ResultData.PIV_V_ini = PIV_V_ini*6e7;
    ResultData.PIV_V_fin = PIV_V_ini*6e7;
    
    
    Angle_ini = (180/pi)*acos((MITO_U.*PIV_U_ini+MITO_V.*PIV_V_ini)./sqrt(MITO_U.*MITO_U+MITO_V.*MITO_V)./sqrt(PIV_U_ini.*PIV_U_ini+PIV_V_ini.*PIV_V_ini));
    ResultData.Angle_ini = Angle_ini;
    Angle_fin = (180/pi)*acos((MITO_U.*PIV_U_fin+MITO_V.*PIV_V_fin)./sqrt(MITO_U.*MITO_U+MITO_V.*MITO_V)./sqrt(PIV_U_fin.*PIV_U_fin+PIV_V_fin.*PIV_V_fin));
    ResultData.Angle_fin = Angle_fin;
    writetable(ResultData,['atg',num2str(j),'_ResultData','.csv'])
    ResultDataStats = grpstats(ResultData,'FRAME','mean','DataVars',{'MITO_U','MITO_V','MITO_velocity','MITO_theta'});
    for i = 1:length(ResultDataStats.FRAME)
        ii = ResultDataStats.FRAME(i);
        if ii == 0
            ResultDataStats.mean_PIV_U(i) = NaN;
            ResultDataStats.mean_PIV_V(i) = NaN;
            ResultDataStats.mean_PIV_velocity(i) = NaN;
            ResultDataStats.mean_PIV_theta(i) = NaN;
        else
            ResultDataStats.mean_PIV_U(i) = nanmean(PIVData.u_original{ii,1}(:))*6e7;
            ResultDataStats.mean_PIV_V(i) = nanmean(PIVData.v_original{ii,1}(:))*6e7;
            [ResultDataStats.mean_PIV_theta(i),ResultDataStats.mean_PIV_velocity(i)] = cart2pol(ResultDataStats.mean_PIV_U(i),ResultDataStats.mean_PIV_V(i));
            ResultDataStats.mean_PIV_theta(i) = ResultDataStats.mean_PIV_theta(i)*180/pi();
        end
    end
    writetable(ResultDataStats,['atg',num2str(j),'_ResultStatsData','.csv'])

end


%% Correlation of velocity by track & frame
figure; 
subplot(3,2,1);
hold on;
subplot(3,2,2);
hold on;
subplot(3,2,3);
hold on;
subplot(3,2,4);
hold on;
subplot(3,2,5);
hold on;
subplot(3,2,6);
hold on;

for j = 1:const_total_video_num
    TempData = readtable(['atg',num2str(j),'_ResultData','.csv']);
    subplot(3,2,1);
    scatter(TempData.MITO_U,TempData.PIV_U_ini);
    subplot(3,2,2);
    scatter(TempData.MITO_V,TempData.PIV_V_ini);
    subplot(3,2,3);
    scatter(TempData.MITO_U,TempData.PIV_U_fin);
    subplot(3,2,4);
    scatter(TempData.MITO_V,TempData.PIV_V_fin);
    subplot(3,2,5);
    scatter(sqrt(TempData.MITO_U.^2+TempData.MITO_V.^2),sqrt(TempData.PIV_U_ini.^2+TempData.PIV_V_ini.^2));
    subplot(3,2,6);
    scatter(sqrt(TempData.MITO_U.^2+TempData.MITO_V.^2),sqrt(TempData.PIV_U_fin.^2+TempData.PIV_V_fin.^2));
end


subplot(3,2,1);
%xlim([0,10]);ylim([0,10])
xlabel('MITO u (\mum/min)');
ylabel('flow u ini (\mum/min)');

subplot(3,2,2);
%xlim([0,10]);ylim([0,10])
xlabel('MITO v (\mum/min)');
ylabel('flow v ini (\mum/min)');

subplot(3,2,3);
%xlim([0,10]);ylim([0,10])
xlabel('MITO u (\mum/min)');
ylabel('flow u fin (\mum/min)');

subplot(3,2,4);
%xlim([0,10]);ylim([0,10])
xlabel('MITO v (\mum/min)');
ylabel('flow v fin (\mum/min)');

subplot(3,2,5);
xlim([0,10]);ylim([0,10])
xlabel('MITO velocity (\mum/min)');
ylabel('flow velocity ini (\mum/min)');

subplot(3,2,6);
xlim([0,10]);ylim([0,10])
xlabel('MITO velocity (\mum/min)');
ylabel('flow velocity fin (\mum/min)');


%% Mean for each frame
GC_threshold = 5; %Group count threshold
figure; 
title('Correlation of average velocity by frame')
subplot(2,2,1);
hold on
subplot(2,2,2);
hold on
subplot(2,2,3);
hold on
subplot(2,2,4);
hold on
for j = 1:const_total_video_num
    TempData = readtable(['atg',num2str(j),'_ResultStatsData','.csv']);
    TempIndex = TempData.GroupCount > GC_threshold;
    subplot(2,2,1);
    scatter(TempData.mean_MITO_U(TempIndex),TempData.mean_PIV_U(TempIndex))
%     if max(TempData.mean_PIV_U)>1e3
%         msgbox(num2str(j))
%     end
    subplot(2,2,2);
    scatter(TempData.mean_MITO_V(TempIndex),TempData.mean_PIV_V(TempIndex))  
    subplot(2,2,3);
    scatter(TempData.mean_MITO_velocity(TempIndex),TempData.mean_PIV_velocity(TempIndex)) 
    subplot(2,2,4);
    scatter(TempData.mean_MITO_theta(TempIndex),TempData.mean_PIV_theta(TempIndex)) 
end


subplot(2,2,1);
%xlim([0,10]);ylim([0,10])
xlabel('MITO U (\mum/min)');
ylabel('PIV U (\mum/min)');


subplot(2,2,2);
%xlim([0,10]);ylim([0,10])
xlabel('MITO V (\mum/min)');
ylabel('PIV V (\mum/min)');


subplot(2,2,3);
%xlim([0,10]);ylim([0,10])
xlabel('MITO velocity (\mum/min)');
ylabel('PIV velocity (\mum/min)');


subplot(2,2,4);
%xlim([0,10]);ylim([0,10])
xlabel('MITO theta (deg)');
ylabel('flow theta (deg)');

%% Angle Analysis
Angle_ini_All = [];
Angle_fin_All = [];
for j = 1:const_total_video_num
    TempData = readtable(['atg',num2str(j),'_ResultData','.csv']);
    Angle_ini_All = [Angle_ini_All; TempData.Angle_ini];
    Angle_fin_All = [Angle_fin_All; TempData.Angle_fin];   
end

figure;
title('Distribution of Angles between MITO Velocity and PIV Initial Velocity')
hold on;
h = histogram(Angle_ini_All,18);
counts = h.Values;
theta = (1:18)*10-5;
p = polyfit(theta,log(counts),1);
plot(1:180,exp(polyval(p,1:180)),'b--')
text(80,300,['Fitting with n = n_{0} exp(- \theta/ \theta_{0})',newline,'n_{0} = ',num2str(exp(p(2))),', \theta_{0} = ',num2str(-1/p(1))])
xlabel('\theta');ylabel('n');

figure;
title('Distribution of Angles between MITO Velocity and PIV Final Velocity')
hold on;
h = histogram(Angle_fin_All,18);
counts = h.Values;
theta = (1:18)*10-5;
p = polyfit(theta,log(counts),1);
plot(1:180,exp(polyval(p,1:180)),'b--')
text(80,300,['Fitting with n = n_{0} exp(- \theta/ \theta_{0})',newline,'n_{0} = ',num2str(exp(p(2))),', \theta_{0} = ',num2str(-1/p(1))])
xlabel('\theta');ylabel('n');

%%
% hold on;
% max_track_num = max(ResultData.TRACK_ID);
% 
% for i = 0:max_track_num
%     tempX = ResultData.MITO_X(ResultData.TRACK_ID == i);
%     tempY = ResultData.MITO_Y(ResultData.TRACK_ID == i);    
%     plot(tempX,tempY,'o-')
% end

Data = [];
for j = 1:const_total_video_num
    TempData = readtable(['atg',num2str(j),'_ResultStatsData','.csv']);
    Data(j,1) = nanmean(TempData.mean_MITO_U);
    Data(j,2) = nanmean(TempData.mean_PIV_U);
end
