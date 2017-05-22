%% Sscript to generate mean daily, monthly flows in different scenarios

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

output_dir = '/Users/gcortes/Dropbox/project_Anpac/test_outputs/';

for b = 1:length(basin_names);
    clf;
    subplot(3, 1, 1);
    filename = [output_dir basin_names{b} '_RCP85.mat'];
    load(filename);
    
    aux = reshape(nansum(Outflow, 1), 366, 27);
    aux2 = aux(:)/86400;
    aux2(aux2>Q_design(b)) = Q_design(b);
    Q_med_generado_RCP = nanmean(aux2(:));
    
    mean_daily_flow_RCP85 = nanmean(aux/86400, 2);
    std_daily_flow_RCP85 = nanstd(aux/86400, [], 2);
    
    filename = [output_dir basin_names{b} '_test.mat'];
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
    plot(1:366, 100*(mean_daily_flow_RCP85 - mean_daily_flow_hist)./mean_daily_flow_hist, 'k');
    xlabel('Day of the Water Year');
    ylabel('% difference w/r to historic');
    ylim([-50 50]);
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



