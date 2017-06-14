%% Script to generate mean daily, monthly flows in different scenarios

basin_names = { 
    'CH_Portillo';...
    'CH_Azufre';...
    'CH_Damas';...
    'CH_San_Andres'; ...
    'CH_Palacios'};

names = {
    'CH Portillo';...
    'CH Azufre';...
    'CH Damas';...
    'CH San Andres'; ...
    'CH Palacios'};

Q_design = [8 3 4 8 2];
model_n = 2;
output_dir = '/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/';
years_sel = 4:34;
q_dir = '/Users/gcortes/Dropbox/project_Anpac/data_hydrometeo/data_q/';

%%

for b = 1:length(basin_names);
    clf;
    subplot(2, 1, 1);
    filename = [output_dir 'RCP85_fut/' basin_names{b} '_RCP85_fut_model_' num2str(model_n) '.mat'];
    load(filename);
    
    aux = reshape(nansum(Outflow, 1), 366, 34);
    aux = aux(:, years_sel);
    aux2 = aux(:)/86400;
    aux2(aux2>Q_design(b)) = Q_design(b);
    Q_med_generado_RCP = nanmean(aux2(:));
    
    mean_daily_flow_RCP85 = nanmean(aux/86400, 2);
    std_daily_flow_RCP85 = nanstd(aux/86400, [], 2);
    
    filename = [output_dir 'RCP85_hist/' basin_names{b} '_RCP85_model_' num2str(model_n) '.mat'];
    load(filename);
    
    aux = reshape(nansum(Outflow, 1), 366, 28);
    mean_daily_flow_hist = nanmean(aux/86400, 2);
    std_daily_flow_hist = nanstd(aux/86400, [], 2);
    aux2 = aux(:)/86400;
    aux2(aux2>Q_design(b)) = Q_design(b);
    Q_med_generado_hist = nanmean(aux2(:));
    
    filename = [output_dir 'calib/' basin_names{b} '_observed.mat'];
    load(filename);
    
    aux = reshape(nansum(Outflow, 1), 366, 28);
    mean_daily_flow_obs = nanmean(aux/86400, 2);
    std_daily_flow_obs = nanstd(aux/86400, [], 2);
    
    boundedline(1:366, mean_daily_flow_hist, [std_daily_flow_hist std_daily_flow_hist], 'k', 'alpha');
    hold on;
    boundedline(1:366, mean_daily_flow_RCP85, [std_daily_flow_RCP85 std_daily_flow_RCP85], 'r', 'alpha');
    boundedline(1:366, mean_daily_flow_obs, [std_daily_flow_obs std_daily_flow_obs], 'b', 'alpha');
    
    line([0 366], [Q_design(b) Q_design(b)], 'Color', 'k', 'LineStyle', '--');
    xlabel('Day of the Water Year');
    ylabel('Streamflow [m^3/s]');
    legend 'Historic range' 'Historic mean' 'RCP85 range' 'RCP85 mean' 'Observed range' 'Observed mean'
    title([names{b} ': Qmedhist = ' num2str(Q_med_generado_hist) ', QmedRCP = ' num2str(Q_med_generado_RCP) ]);
    set(gca, 'Fontsize', 14);
    set(gcf, 'Color', [1 1 1]);
    ylim([0 max(mean_daily_flow_hist + std_daily_flow_hist*1.5)]);
    box on;
    grid on;
    xlim([1 365]);

    subplot(2, 1, 2);
    vals = 100*(mean_daily_flow_RCP85 - mean_daily_flow_hist)./mean_daily_flow_hist;
    vals(vals>0) = 0;
    area(1:366, vals, 'FaceColor', 'r');
    hold on;
    vals = 100*(mean_daily_flow_RCP85 - mean_daily_flow_hist)./mean_daily_flow_hist;
    vals(vals<0) = 0;
    area(1:366, vals, 'FaceColor', 'b');
    xlabel('Day of the Water Year');
    ylabel('% difference w/r to historic');
    ylim([-150 150]);
    xlim([1 365]);
    grid on;
    box on;
    set(gca, 'Fontsize', 14);
pause;

%     subplot(3, 1, 3);
%     plot(1:366, cumsum(mean_daily_flow_hist), 'k');
%     hold on;
%     plot(1:366, cumsum(mean_daily_flow_RCP85), 'r');
%     xlabel('Day of the Water Year');
%     ylabel('Cumulative streamflow [m^3/s]');
%     xlim([1 365]);
%     grid on;
%     box on;
%     set(gca, 'Fontsize', 14);
%     pause;
end;

%% Monthly values

month_indices = [1 31 62 92 123 154 184 215 245 276 307 335 365];
model_val = [2 3 18];
clear month_vals_hist month_vals_fut month_vals_obs;

for b = 1:5;
    month_vals_fut(b).data = nan(18, 34, 12);
    month_vals_hist(b).data = nan(18, 28, 12);
    month_vals_obs(b).data = nan(28, 12);
    month_vals_obs(b).obs = nan(28, 12);
end;

for b = 1:length(basin_names);
    filename = [output_dir 'calib/' basin_names{b} '_observed.mat'];
    load(filename);
    aux = reshape(nansum(Outflow, 1), 366, 28);
    
    if b~=4    
        aux2 = reshape(Streamflow, 366, 28);
    else
        aux2 = nan(366, 28);
    end;
    
    for y = 1:28;
        for m = 1:length(month_indices)-1;
            A = aux(month_indices(m):month_indices(m+1), y);
            A2 = aux2(month_indices(m):month_indices(m+1), y);
            month_vals_obs(b).data(y, m) = nanmean(A(:));
            month_vals_obs(b).obs(y, m) = nanmean(A2(:));
        end;
    end;
end;
        
for mm = 1:3
    disp(mm);
    for b = 1:length(basin_names);
        
        filename = [output_dir 'RCP85_fut/' basin_names{b} '_RCP85_fut_model_' num2str(model_val(mm)) '.mat'];
        load(filename);
        aux = reshape(nansum(Outflow, 1), 366, 34);
        for y = 1:34;
            for m = 1:length(month_indices)-1;
                A = aux(month_indices(m):month_indices(m+1), y);
                month_vals_fut(b).data(model_val(mm), y, m) = nanmean(A(:));
            end;
        end;

        filename = [output_dir 'RCP85_hist/' basin_names{b} '_RCP85_model_' num2str(model_val(mm)) '.mat'];
        load(filename);
        aux = reshape(nansum(Outflow, 1), 366, 28);
        for y = 1:28;
            for m = 1:length(month_indices)-1;
                A = aux(month_indices(m):month_indices(m+1), y);
                month_vals_hist(b).data(model_val(mm), y, m) = nanmean(A(:));
            end;
        end;
        
    end;
    
end;

%% Validation plots
    
basin_names = {
    'CH_Portillo';...
    'CH_San_Andres'; ...
    'CH_Azufre';...
    'CH_Damas';...
    'CH_Palacios'; ...
    'Tinguiririca_Bajo_Briones'; ...
    'Tinguiririca_Bajo_Azufre'; ...
    'Pangal_en_Pangal'; ...
    'Cachapoal_Bajo_Cortaderal'; ...
    'Lenas_Antes_Cachapoal'; ...
    'Claro_Nieves'; ...
    'Cortaderal_Antes_Cachapoal'; ...
    };

figure(1);
clf;
b = 1;
filename = [output_dir 'calib/' basin_names{b} '_observed.mat'];
load(filename);
A1 = nansum(Outflow, 1)/86400;
S = Streamflow;
b = 2;
filename = [output_dir 'calib/' basin_names{b} '_observed.mat'];
load(filename);
A2 = nansum(Outflow, 1)/86400;
C = A1+A2;
C(C ==0) = NaN;

plot(date_data, S, 'Color', [1 .4 .4], 'LineWidth', 3);
hold on;
plot(date_data, C, 'k')

box on;
grid on;
datetick;
ylabel('Streamflow [m^3/s]');
xlabel('Water Year');
title('CH Portillo + CH San Andrés (La Confluencia)');
legend  'Observed' 'Simulated';
set(gca,'Fontsize', 14);
xlim([datenum(1989, 4, 1) datenum(2017, 3, 30)]);
ylim([0 max(C)]);
pause;

figure(2);
clf;
scatter(S, C, 'o', 'MarkerFaceColor', [.8 .8 1], 'MarkerEdgeColor', 'k');
box on;
grid on;
xlabel('Observed daily streamflow [m^3/s]');
ylabel('Simulated daily streamflow [m^3/s]');
set(gca,'FontSize', 20)
axis square;
refline(1, 0);
xlim([0 max(S)]);
ylim([0 max(S)]);

pause;
disp(basin_names{b})
corr(C', S', 'rows', 'complete')

for b = 3:length(basin_names);
    figure(1);
    clf;
    filename = [output_dir 'calib/' basin_names{b} '_observed.mat'];
    load(filename);
    C = nansum(Outflow, 1)/86400;
    S = Streamflow;
    C(C ==0) = NaN;
    
    plot(date_data, S, 'Color', [1 .4 .4], 'LineWidth', 3);
    hold on;
    plot(date_data, C, 'k')
    box on;
    grid on;
    datetick;
    ylabel('Streamflow [m^3/s]');
    xlabel('Water Year');
    title(basin_names{b});
    legend  'Observed' 'Simulated';
    set(gca,'Fontsize', 14);
    xlim([datenum(1989, 4, 1) datenum(2017, 3, 30)]);
    ylim([0 max(C)]);
    if b == 3 || b == 4 || b ==5 ;
        filename = [q_dir basin_names{b} '_aforos.mat'];
        load(filename);
        scatter(vals_date_matlab, vals_q, 1500, '.', 'MarkerFaceColor', [1 0 0]);
    end;
    figure(2);
    clf;
    scatter(S, C, 'o', 'MarkerFaceColor', [.8 .8 1], 'MarkerEdgeColor', 'k');
    box on;
    grid on;
    xlabel('Observed daily streamflow [m^3/s]');
    ylabel('Simulated daily streamflow [m^3/s]');
    set(gca,'FontSize', 20)
    axis square;
    refline(1, 0);
    xlim([0 max(S)]);
    ylim([0 max(S)]);
    disp(basin_names{b})
    corr(C', S', 'rows', 'complete')
    
    pause;
    
end;

%% Validation SWE

for b = 1:length(basin_names);
    figure(1);
    clf;
    filename = [output_dir 'calib/' basin_names{b} '_observed.mat'];
    load(filename);
    C = nansum(SWE_reanalysis', 2);
    S = SWE'*weights';
    C(C ==0) = NaN;
    
    plot(date_data, S, 'Color', [1 .4 .4], 'LineWidth', 3);
    hold on;
    plot(date_data, C, 'k')
    box on;
    grid on;
    datetick;
    ylabel('SWE [m]');
    xlabel('Water Year');
    title(basin_names{b});
    legend  'Observed' 'Simulated';
    set(gca,'Fontsize', 14);
    xlim([datenum(1989, 4, 1) datenum(2017, 3, 30)]);
    ylim([0 max(C)]);
    
    figure(2);
    clf;
    scatter(S, C, 'o', 'MarkerFaceColor', [.8 .8 1], 'MarkerEdgeColor', 'k');
    box on;
    grid on;
    xlabel('Observed daily SWE [m]');
    ylabel('Simulated daily SWE [m]');
    set(gca,'FontSize', 20)
    axis square;
    refline(1, 0);
    xlim([0 max(S)]);
    ylim([0 max(S)]);
    disp(basin_names{b})
    corr(C, S, 'rows', 'complete')
    title(basin_names{b});
    pause;
end;

%% Monthly comparison with other studies
clf;
plot(1:12, data(:, 1), 'Color', [0 0 .8], 'LineWidth', 2);
hold on;
plot(1:12, data(:, 3), 'Color', [.5 .5 .8], 'LineWidth', 2);
plot(1:12, data(:, 4), 'Color', [.8 0 0], 'LineWidth', 3, 'LineStyle', '--');

xlabel('Mes del año hidrológico');
ylabel('QMM [m^3/s]');
box on;
grid on;
xlim([.5 12.5]);
set(gca, 'XTick', 1:12,'XTickLAbel', {'A';'M';'J';'J';'A';'S';'O';'N';'D';'E';'F';'M'});
title('CH Palacios');
legend 'Norconsult' 'Parot' 'UCLA'
set(gca,'FontSize', 14);

%% Weibull

names = {
    'CH Portillo';...
    'CH Azufre';...
    'CH Damas';...
    'CH San Andres'; ...
    'CH Palacios'};

t_retorno_hist = (27+1)./(27:-1:1);
p_exc_hist = 1./t_retorno_hist*100;
t_retorno_fut = (33+1)./(33:-1:1);
p_exc_fut = 1./t_retorno_fut*100;

p_exc_nec = 5:5:95;

b = 5;

aux_val = month_vals_hist(b).data;
aux_val2 = squeeze(nanmean(aux_val, 1));
hist = nanmean(aux_val2(2:end, :), 1)'/86400
vals_sorted = sort(aux_val, 2);
vals_mean_hist = squeeze(nanmean(vals_sorted, 1))/86400;

aux_val = month_vals_fut(b).data;
aux_val2 = squeeze(nanmean(aux_val, 1));
fut = nanmean(aux_val2(2:end, :), 1)'/86400
vals_sorted = sort(aux_val, 2);
vals_mean_fut = squeeze(nanmean(vals_sorted, 1))/86400;

aux_val = month_vals_obs(b).data;
obs = nanmean(aux_val(2:end, :), 1)'/86400
vals_sorted = sort(aux_val, 1)/86400;

for m = 1:12;
    [vals_pexc_hist(:, m)] = interp1(p_exc_hist, vals_mean_hist(:, m), p_exc_nec);
    [vals_pexc_fut(:, m)] = interp1(p_exc_fut, vals_mean_fut(:, m), p_exc_nec);
    [vals_pexc_obs(:, m)] = interp1(p_exc_hist, vals_sorted(:, m), p_exc_nec);
end;
