function snowflow_plot(basin_name, years, model_outflow, model_swe, streamflow, swe)

%snowflow_plot('Pangal',1985:1990,Outflow,SWE,Streamflow,SWE_reanalysis)

%% Generate monthly time series from daily snowflow model outputs

set(0, 'DefaultAxesXGrid','on','DefaultAxesYGrid','on',...
    'DefaultAxesXminortick','on','DefaultAxesYminortick','on',...
    'DefaultLineLineWidth',2,'DefaultLineMarkerSize',6,...
    'DefaultAxesFontName','Arial','DefaultAxesFontSize',14,...
    'DefaultAxesFontWeight','bold',...
    'DefaultTextFontWeight','normal','DefaultTextFontSize',14)

% 1- Monthly time series
% Start by summing over elevation bands
Outflow = nansum(model_outflow/24/3600, 1);
SWE_total = nansum(swe, 1);
SWE_model_total = nansum(model_swe, 1);

if ischar(streamflow);
    Streamflow_dummy = nan(366, length(years));
else
    Streamflow_dummy = reshape(streamflow, 366, length(years));
end;
Outflow_dummy = reshape(Outflow, 366, length(years));

if ischar(swe);
    SWE_dummy = nan(366, length(years));
else
    SWE_dummy = reshape(SWE_total, 366, length(years));
end;

SWE_model_dummy = reshape(SWE_model_total,366,length(years));

for y = 1:length(years)
    SWE_model_month(1,y) = nanmean(SWE_model_dummy(1:30,y)); % April
    SWE_model_month(2,y) = nanmean(SWE_model_dummy(31:61,y)); % May
    SWE_model_month(3,y) = nanmean(SWE_model_dummy(62:91,y)); % June
    SWE_model_month(4,y) = nanmean(SWE_model_dummy(92:122,y)); % July
    SWE_model_month(5,y) = nanmean(SWE_model_dummy(123:153,y)); % August
    SWE_model_month(6,y) = nanmean(SWE_model_dummy(154:183,y)); % September
    SWE_model_month(7,y) = nanmean(SWE_model_dummy(184:214,y)); % October
    SWE_model_month(8,y) = nanmean(SWE_model_dummy(215:244,y)); % November
    SWE_model_month(9,y) = nanmean(SWE_model_dummy(245:275,y)); % December
    SWE_model_month(10,y) = nanmean(SWE_model_dummy(276:306,y)); % January
    if isnan(SWE_model_dummy(end,y))% then common year
        SWE_model_month(11,y) = nanmean(SWE_model_dummy(307:334,y)); % February
        SWE_model_month(12,y) = nanmean(SWE_model_dummy(335:365,y)); % March
    else % then leap year
        SWE_model_month(11,y) = nanmean(SWE_model_dummy(307:335,y)); % February
        SWE_model_month(12,y) = nanmean(SWE_model_dummy(336:366,y)); % March
    end;
    
    SWE_month(1,y) = nanmean(SWE_dummy(1:30,y)); % April
    SWE_month(2,y) = nanmean(SWE_dummy(31:61,y)); % May
    SWE_month(3,y) = nanmean(SWE_dummy(62:91,y)); % June
    SWE_month(4,y) = nanmean(SWE_dummy(92:122,y)); % July
    SWE_month(5,y) = nanmean(SWE_dummy(123:153,y)); % August
    SWE_month(6,y) = nanmean(SWE_dummy(154:183,y)); % September
    SWE_month(7,y) = nanmean(SWE_dummy(184:214,y)); % October
    SWE_month(8,y) = nanmean(SWE_dummy(215:244,y)); % November
    SWE_month(9,y) = nanmean(SWE_dummy(245:275,y)); % December
    SWE_month(10,y) = nanmean(SWE_dummy(276:306,y)); % January
    if isnan(SWE_model_dummy(end,y))% then common year
        SWE_month(11,y) = nanmean(SWE_dummy(307:334,y)); % February
        SWE_month(12,y) = nanmean(SWE_dummy(335:365,y)); % March
    else
        SWE_month(11,y) = nanmean(SWE_dummy(307:335,y)); % February
        SWE_month(12,y) = nanmean(SWE_dummy(336:366,y)); % March
    end;
    
    Outflow_month(1,y) = nanmean(Outflow_dummy(1:30,y)); % April
    Outflow_month(2,y) = nanmean(Outflow_dummy(31:61,y)); % May
    Outflow_month(3,y) = nanmean(Outflow_dummy(62:91,y)); % June
    Outflow_month(4,y) = nanmean(Outflow_dummy(92:122,y)); % July
    Outflow_month(5,y) = nanmean(Outflow_dummy(123:153,y)); % August
    Outflow_month(6,y) = nanmean(Outflow_dummy(154:183,y)); % September
    Outflow_month(7,y) = nanmean(Outflow_dummy(184:214,y)); % October
    Outflow_month(8,y) = nanmean(Outflow_dummy(215:244,y)); % November
    Outflow_month(9,y) = nanmean(Outflow_dummy(245:275,y)); % December
    Outflow_month(10,y) = nanmean(Outflow_dummy(276:306,y)); % January
    if isnan(SWE_model_dummy(end,y))% then common year
        Outflow_month(11,y) = nanmean(Outflow_dummy(307:334,y)); % February
        Outflow_month(12,y) = nanmean(Outflow_dummy(335:365,y)); % March
    else
        Outflow_month(11,y) = nanmean(Outflow_dummy(307:335,y)); % February
        Outflow_month(12,y) = nanmean(Outflow_dummy(336:366,y)); % March
    end;
    
    Streamflow_month(1,y) = nanmean(Streamflow_dummy(1:30,y)); % April
    Streamflow_month(2,y) = nanmean(Streamflow_dummy(31:61,y)); % May
    Streamflow_month(3,y) = nanmean(Streamflow_dummy(62:91,y)); % June
    Streamflow_month(4,y) = nanmean(Streamflow_dummy(92:122,y)); % July
    Streamflow_month(5,y) = nanmean(Streamflow_dummy(123:153,y)); % August
    Streamflow_month(6,y) = nanmean(Streamflow_dummy(154:183,y)); % September
    Streamflow_month(7,y) = nanmean(Streamflow_dummy(184:214,y)); % October
    Streamflow_month(8,y) = nanmean(Streamflow_dummy(215:244,y)); % November
    Streamflow_month(9,y) = nanmean(Streamflow_dummy(245:275,y)); % December
    Streamflow_month(10,y) = nanmean(Streamflow_dummy(276:306,y)); % January
    if isnan(SWE_model_dummy(end,y))% then common year
        Streamflow_month(11,y) = nanmean(Streamflow_dummy(307:334,y)); % February
        Streamflow_month(12,y) = nanmean(Streamflow_dummy(335:365,y)); % March
    else
        Streamflow_month(11,y) = nanmean(Streamflow_dummy(307:335,y)); % February
        Streamflow_month(12,y) = nanmean(Streamflow_dummy(336:366,y)); % March
    end;
end;

for y = 1:length(years)
    dummy = num2str(years(y));
    xdisplay_label(y,:) = ['Apr ' dummy(end-1:end)];
end;

figure
plot(reshape(Streamflow_month, 1,12*length(years)), '--k', 'LineWidth', 1);
hold on;
plot(reshape(Outflow_month,1,12*length(years)), '-k', 'LineWidth', 2);
legend('Obs.','Model')
ylabel('Streamflow [m^3/s]');
xlabel('Date');
title(['Monthly timeseries for ' basin_name ' basin'])
set(gca, 'XTick', 1:12:12*length(years), 'XTickLabel', xdisplay_label);
xlim([0 12*length(years)])

figure
plot(reshape(SWE_month, 1, 12*length(years)), 'r');
hold on;
plot(reshape(SWE_model_month, 1, 12*length(years)), 'b');
legend('Obs.','Model')
ylabel('SWE (m)');
xlabel(['April ' num2str(years(1)) ' to March ' num2str(years(end))]);
title(['Monthly timeseries for ' basin_name ' basin'])
set(gca,'XTick', 1:12:12*length(years),'XTickLabel',xdisplay_label);
xlim([0 12*length(years)])

% 2- Monthly model vs. obs

figure
scatter(Streamflow_month(:),Outflow_month(:));
xlabel('Observed streamflow [m^3/s]')
ylabel('Simulated streamflow [m^3/s]')
title([basin_name]);
box on;
xlim([0 max(Outflow_month(:))]);
ylim([0 max(Outflow_month(:))]);
box on;

figure
scatter(SWE_month(:), SWE_model_month(:));
xlabel('Observed SWE [m]')
ylabel('Simulated SWE [m]')
title([basin_name]);


% 3- Annual time series

Streamflow_annual = nanmean(reshape(streamflow,366,length(years)),1);
Outflow_annual = nanmean(reshape(Outflow,366,length(years)),1);
SWE_annual = nanmean(reshape(SWE_total,366,length(years)),1);
SWE_model_annual = nanmean(reshape(SWE_model_total,366,length(years)),1);

figure
plot(years, Streamflow_annual, 'LineStyle', '-', 'Color', [.3 .3 .3]);
hold on;
plot(years,Outflow_annual, 'LineStyle', '--', 'Color', [.3 .3 .3]);
legend('Observed','Simulated')
ylabel('Streamflow [m^3/s]');
xlabel('Water Years');
title(['Annual timeseries for ' basin_name])
grid on

figure
plot(years, SWE_annual, 'LineStyle', '-', 'Color', [.3 .3 .3]);
hold on;
plot(years,SWE_model_annual, 'LineStyle', '--', 'Color', [.3 .3 .3]);
legend('Obs.','Model')
ylabel('SWE [m]');
xlabel('Water Years');
title(['Annual timeseries for ' basin_name])
grid on

return