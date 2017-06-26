%% Anpac energy calculator wrapper

%% Definition of basin names

basin_names = { 
    'CH_Azufre';...
    'CH_Damas';...
    'CH_Palacios';...
    'CH_Portillo'; ...
    'CH_San_Andres'};

output_dir = '/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/';

DD_p = [0.100	0.070	0.080	0.070	0.090	0.150	0.260	0.790	1.440	0.890	0.720	0.320
    0.360	0.350	0.330	0.340	0.340	0.470	0.760	1.220	0.960	1.050	0.850	0.580
    0.170	0.090	0.090	0.090	0.090	0.130	0.230	0.380	0.300	0.330	0.260	0.100
    4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000
    7.800	7.800	7.800	7.800	7.800	7.800	7.800	7.800	7.800	7.800	7.800	7.800];

DD_e = [0.610	0.770	0.500	0.690	0.720	0.540	1.110	1.480	1.560	2.110	2.010	1.300
    0.440	0.330	0.400	0.330	0.440	0.540	0.760	1.380	2.440	1.570	0.930	0.600
    0.080	0.040	0.080	0.040	0.080	0.110	0.190	0.400	0.770	0.470	0.250	0.130
    4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000	4.000
    0.000	0.000	0.000	0.000	0.000	0.000	0.000	0.520	5.740	6.990	2.210	0.000];

Qeco = [0.110	0.110	0.110	0.110	0.110	0.110	0.110	0.110	0.110	0.110	0.110	0.110
    0.660	0.410	0.360	0.360	0.360	0.360	0.460	0.710	0.710	0.710	0.710	0.710
    0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070	0.070
    0.642	0.642	0.642	0.642	0.642	0.642	0.642	0.642	0.642	0.642	0.642	0.642
    0.472	0.472	0.472	0.472	0.472	0.472	0.472	0.472	0.472	0.472	0.472	0.472];

Qd = [3.0
    4.0
    2.0
    4.1
    4.2];

% Hd = [432.0
%     354.0
%     171.0
%     257.7
%     253.0];

Hd = [457.1
392.8
183.0
280.0
275.0];

FP = [2.8
    2.4
    3.0
    1.3
    1.2];

Ef = [0	0.767426074	0.797958895	0.820981586	0.825278523	0.836379388	0.843282241	0.845946578	0.849987085	0.855460681	0.86052295	0.863299762	0.865709718	0.869694405	0.871465049	0.87391803	0.875166362	0.876197967	0.877043113	0.876768586	0.877331];

%% Calculation of Energy

model_n = [2 3 18];

date_ini = datenum(1985, 4, 1);
date_fin = datenum(2017, 3, 31);
date_vals_calib = date_ini:date_fin;

date_ini = datenum(1985, 4, 1);
date_fin = datenum(2015, 3, 31);
date_vals_hist = date_ini:date_fin;

date_ini = datenum(2020, 4, 1); 
date_fin = datenum(2050, 3, 31);
date_vals_fut = date_ini:date_fin;

clear Egen* E_*
flag = 0; %0 if Qeco = 0 and DD = Inf, 1 for real conditions

%%
for b = 1:length(basin_names);
   
         filename = [output_dir 'new_calib/' basin_names{b} '_observed.mat'];
        load(filename);
        aux = reshape(nansum(Outflow, 1), 366, 33);
        [c, cc] = intersect(date_data, date_vals_calib);
        Q_calib = aux(cc)/86400;
        zero_ind = find(Q_calib == 0);
        Q_calib(zero_ind) = nanmean([Q_calib(zero_ind+1) Q_calib(zero_ind-1)], 2);
        
        [Egen_daily_calib, Pot_daily_calib, Ef_daily_calib, Qgen_daily_calib] ...
            = Anpac_energy(date_data(cc), Q_calib, DD_p(b, :), DD_e(b, :), Qeco(b, :), Qd(b), Hd(b), Ef, FP(b), flag);
        
        E_calib(b) = nanmean(Egen_daily_calib)*365/1000/1000; %GWh, promdio generacion por año      
  
end;

%% Generated energy montecarlo test

b = 3;
filename = [output_dir 'new_calib/' basin_names{b} '_observed.mat'];
load(filename);
aux = reshape(nansum(Outflow, 1), 366, 33);
[c, cc] = intersect(date_data, date_vals_calib);
Q_calib = aux(cc)/86400;
zero_ind = find(Q_calib == 0);
Q_calib(zero_ind) = nanmean([Q_calib(zero_ind+1) Q_calib(zero_ind-1)], 2);

Q_ds = [0.5:0.2:4];
E_calib = nan(length(Q_ds), 1);
flag = 1;

for s = 1:length(Q_ds)
    disp(s);
    [Egen_daily_calib, Pot_daily_calib, Ef_daily_calib, Qgen_daily_calib] ...
        = Anpac_energy(date_data(cc), Q_calib, DD_p(b, :), DD_e(b, :), Qeco(b, :), Q_ds(s), Hd(b), Ef, FP(b), flag);
    
    E_calib(s) = nanmean(Egen_daily_calib)*365/1000/1000; %GWh, promdio generacion por año

end;

plot(Q_ds, E_calib);
grid on;
xlabel('Valor Qd [m^3/s]');
ylabel('E. anual generado [GWh]');
set(gca, 'FontSize', 14)

%%
for b = 1:length(basin_names);
 for n = 1:3;
        disp(n);
        filename = [output_dir 'new_RCP85_fut/' basin_names{b} '_RCP85_fut_model_' num2str(model_n(n)) '.mat'];
        load(filename);
        
        aux = reshape(nansum(Outflow, 1), 366, 34);
        [c, cc] = intersect(date_data, date_vals_fut);
        Q_fut = aux(cc)/86400;
        zero_ind = find(Q_fut == 0);
        Q_fut(zero_ind) = nanmean([Q_fut(zero_ind+1) Q_fut(zero_ind-1)], 2);
        
        [Egen_daily_fut, Pot_daily_fut, Ef_daily_fut, Qgen_daily_fut] ...
            = Anpac_energy(date_data(cc), Q_fut, DD_p(b, :), DD_e(b, :), Qeco(b, :), Qd(b), Hd(b), Ef, FP(b), flag);
        
        E_fut(b, n) = nanmean(Egen_daily_fut)*365/1000/1000; %GWh, promdio generacion por año
        
        filename = [output_dir 'new_RCP85_hist/' basin_names{b} '_RCP85_model_' num2str(model_n(n)) '.mat'];
        load(filename);
        aux = reshape(nansum(Outflow, 1), 366, 33);
        [c, cc] = intersect(date_data, date_vals_hist);
        Q_hist = aux(cc)/86400;
        Q_hist(end) = Q_hist(end-1);
        zero_ind = find(Q_fut == 0);
        Q_hist(zero_ind) = nanmean([Q_hist(zero_ind+1) Q_hist(zero_ind-1)], 2);
        
        [Egen_daily_hist, Pot_daily_hist, Ef_daily_hist, Qgen_daily_hist] ...
            = Anpac_energy(date_data(cc), Q_hist, DD_p(b, :), DD_e(b, :), Qeco(b, :), Qd(b), Hd(b), Ef, FP(b), flag);
        
        E_hist(b, n) = nanmean(Egen_daily_hist)*365/1000/1000; %GWh, promdio generacion por año
        
       
    end;
end;