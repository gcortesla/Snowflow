%% Script to generate the test data for theforecasting toool

load('/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/new_calib/CH_Azufre_observed.mat', 'Outflow');

S = nansum(Outflow, 1)/86400;
S_r = reshape(S, 366, 33);

Q_opt = S_r(:, 9);
Q_pes = S_r(:, 5);
Q_nor = nanmean(S_r, 2);

data_forecast(:, 1) = Q_opt;
data_forecast(:, 2) = Q_nor;
data_forecast(:, 3) = Q_pes;
data_long_term(:, 1) = S;

load('/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/new_calib/CH_Damas_observed.mat', 'Outflow');

S = nansum(Outflow, 1)/86400;
S_r = reshape(S, 366, 33);

Q_opt = S_r(:, 9);
Q_pes = S_r(:, 5);
Q_nor = nanmean(S_r, 2);

data_forecast(:, 4) = Q_opt;
data_forecast(:, 5) = Q_nor;
data_forecast(:, 6) = Q_pes;
data_long_term(:, 2) = S;

load('/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/new_calib/CH_Palacios_observed.mat', 'Outflow');

S = nansum(Outflow, 1)/86400;
S_r = reshape(S, 366, 33);

Q_opt = S_r(:, 9);
Q_pes = S_r(:, 5);
Q_nor = nanmean(S_r, 2);

data_forecast(:, 7) = Q_opt;
data_forecast(:, 8) = Q_nor;
data_forecast(:, 9) = Q_pes;
data_long_term(:, 3) = S;

load('/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/new_calib/CH_Portillo_observed.mat', 'Outflow');

S = nansum(Outflow, 1)/86400;
S_r = reshape(S, 366, 33);

Q_opt = S_r(:, 9);
Q_pes = S_r(:, 5);
Q_nor = nanmean(S_r, 2);

data_forecast(:, 10) = Q_opt;
data_forecast(:, 11) = Q_nor;
data_forecast(:, 12) = Q_pes;
data_long_term(:, 4) = S;

load('/Users/gcortes/Dropbox/project_Anpac/test_outputs_2/new_calib/CH_San_Andres_observed.mat', 'Outflow');

S = nansum(Outflow, 1)/86400;
S_r = reshape(S, 366, 33);

Q_opt = S_r(:, 9);
Q_pes = S_r(:, 5);
Q_nor = nanmean(S_r, 2);

data_forecast(:, 13) = Q_opt;
data_forecast(:, 14) = Q_nor;
data_forecast(:, 15) = Q_pes;
data_long_term(:, 5) = S;

save('/Users/gcortes/Dropbox/Snowflow_app/www/test_data/Q_E_forecast.mat', 'data_forecast');
save('/Users/gcortes/Dropbox/Snowflow_app/www/test_data/Q_E_long_term.mat', 'data_long_term', 'date_data');
