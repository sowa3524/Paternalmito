figure()
hold on;

n_max = 30;
Y_mean=[];
Y_error=[];
%Y_sum = zeros(1,n_max);
%Y_num = zeros(1,n_max);
rawdata = cell(1,n_max);

sheetname = {'WT embryo1','WT embryo2','WT embryo3',...
    'WT embryo4','WT embryo5','WT embryo6','WT embryo7','WT embryo8',...
    'WT embryo9','WT embryo10','WT embryo11','WT embryo12','WT embryo13',...
    'WT embryo14','WT embryo15'};

for j = 1:length(sheetname)
    t=readtable('/path_to_folder/measurement.xlsx',...
        'sheet',sheetname{j},'VariableNamingRule','preserve');
    
    size_of_table = size(t);

    for i = 1:size_of_table(2)
        s = table2array(t(2:end,i));
        ss = s(~isnan(s));  %get rid of NaN
        rawdata{1,i} = [rawdata{1,i};ss];
        %Y_sum(i) = Y_sum(i)+sum(ss);
        %Y_num(i) = Y_num(i)+length(ss);
    end
end

%Y_mean = Y_sum ./ Y_num;
for i=1:n_max
    if ~isempty(rawdata{i})
        Y_mean(i) = mean(rawdata{i});
        Y_error(i) = std(rawdata{i})/sqrt(length(rawdata{i}));
    end
end

y1 = errorbar(1:length(Y_mean),Y_mean,Y_error,'o-','Linewidth',2,...
         'Color',[3,191,196]/255,...
         'MarkerFaceColor',[3,191,196]/255);
xticks(0:5:25)
yticks(4:2:20)
xlim([0,25])
ylim([4,20])

Y_mean=[];
Y_error=[];
rawdata = cell(1,n_max);

sheetname = {'atg-7 embryo1','atg-7 embryo2','atg-7 embryo3',...
    'atg-7 embryo4','atg-7 embryo5','atg-7 embryo6','atg-7 embryo7',...
    'atg-7 embryo8','atg-7 embryo9','atg-7 embryo10','atg-7 embryo11','atg-7 embryo12',...
    'atg-7 embryo13','atg-7 embryo14','atg-7 embryo15'};

for j = 1:length(sheetname)
    t=readtable('/path_to_folder/measurement.xlsx',...
        'sheet',sheetname{j},'VariableNamingRule','preserve');
    
    size_of_table = size(t);

    for i = 1:size_of_table(2)
        s = table2array(t(2:end,i));
        ss = s(~isnan(s));  %get rid of NaN
        rawdata{1,i} = [rawdata{1,i};ss];
    end
end

for i=1:n_max
    if ~isempty(rawdata{i})
        Y_mean(i) = mean(rawdata{i});
        Y_error(i) = std(rawdata{i})/sqrt(length(rawdata{i}));
    end
end

y2 = errorbar(1:length(Y_mean),Y_mean,Y_error,'o-','Linewidth',2,...
        'Color',[249,118,109]/255,...
         'MarkerFaceColor',[249,118,109]/255);
xticks(0:5:25)
yticks(4:2:20)
xlim([0,25])
ylim([4,20])
legend({'WT','atg-7'},'Location','best');
box on;
fontsize(gca,18,"pixels")
xlabel('Time (min)')
ylabel('Distance to MTOC(\mum)')
% xticks(0:2:24)
% yticks(0:3:30)
% xlim([0,24])
% ylim([0,30])

