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
output_dir = '/Users/gcortes/Dropbox/project_Anpac/test_outputs/';
years_sel = 4:34;

for b = 1:length(basin_names);
    clf;
    subplot(3, 1, 1);
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
    
    aux = reshape(nansum(Outflow, 1), 366, 27);
    mean_daily_flow_hist = nanmean(aux/86400, 2);
    std_daily_flow_hist = nanstd(aux/86400, [], 2);
    aux2 = aux(:)/86400;
    aux2(aux2>Q_design(b)) = Q_design(b);
    Q_med_generado_hist = nanmean(aux2(:));
    
    boundedline(1:366, mean_daily_flow_hist, [std_daily_flow_hist std_daily_flow_hist], 'k', 'alpha');
    hold on;
    boundedline(1:366, mean_daily_flow_RCP85, [std_daily_flow_RCP85 std_daily_flow_RCP85], 'r', 'alpha');
    line([0 366], [Q_design(b) Q_design(b)], 'Color', 'k', 'LineStyle', '--');
    xlabel('Day of the Water Year');
    ylabel('Streamflow [m^3/s]');
    legend 'Historic range' 'Historic mean' 'RCP85 range' 'RCP85 mean'
    title([names{b} ': Qmedhist = ' num2str(Q_med_generado_hist) ', QmedRCP = ' num2str(Q_med_generado_RCP) ]);
    set(gca, 'Fontsize', 14);
    set(gcf, 'Color', [1 1 1]);
    ylim([0 max(mean_daily_flow_hist + std_daily_flow_hist*1.5)]);
    box on;
    grid on;
    xlim([1 365]);

    subplot(3, 1, 2);
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
    
    subplot(3, 1, 3);
    plot(1:366, cumsum(mean_daily_flow_hist), 'k');
    hold on;
    plot(1:366, cumsum(mean_daily_flow_RCP85), 'r');
    xlabel('Day of the Water Year');
    ylabel('Cumulative streamflow [m^3/s]');
    xlim([1 365]);
    grid on;
    box on;
    set(gca, 'Fontsize', 14);
    pause;
end;

%% Monthly values

month_indices = [1 31 62 92 123 154 184 215 245 276 307 335 365];
model_val = [2 3 18];
clear month_vals_hist month_vals_fut;
for b = 1:5;
    month_vals_fut(b).data = nan(18, 34, 12);
    month_vals_hist(b).data = nan(18, 27, 12);
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
        aux = reshape(nansum(Outflow, 1), 366, 27);
        for y = 1:27;
            for m = 1:length(month_indices)-1;
                A = aux(month_indices(m):month_indices(m+1), y);
                month_vals_hist(b).data(model_val(mm), y, m) = nanmean(A(:));
            end;
        end;
        
    end;
    
end;

%% Weibull
names = {
    'CH Portillo';...
    'CH Azufre';...
    'CH Damas';...
    'CH San Andres'; ...
    'CH Palacios'};

t_retorno_hist = (27+1)./(27:-1:1);
p_exc_hist = 1./t_retorno*100;
t_retorno_fut = (34+1)./(34:-1:1);
p_exc_fut = 1./t_retorno*100;

p_exc_nec = 5:5:95;

b = 4;

    aux_val = month_vals_hist(b).data;
    vals_sorted = sort(aux_val, 2);
    vals_mean_hist = squeeze(nanmean(vals_sorted, 1))/86400;
    vals_mean_mean_hist = nanmean(vals_mean_hist(2:end, :), 1)'
    
    aux_val = month_vals_fut(b).data;
    vals_sorted = sort(aux_val, 2);
    vals_mean_fut = squeeze(nanmean(vals_sorted, 1))/86400;
     vals_mean_mean_fut = nanmean(vals_mean_fut(2:end, :), 1)'
    
    for m = 1:12;
        [vals_pexc_hist(:, m)] = interp1(p_exc_hist, vals_mean_hist(:, m), p_exc_nec);
        [vals_pexc_fut(:, m)] = interp1(p_exc_fut, vals_mean_fut(:, m), p_exc_nec);
    end;
    