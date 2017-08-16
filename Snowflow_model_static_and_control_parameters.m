function [control_params, params] = Snowflow_model_static_and_control_parameters(project, basin, run_sce, scenario, years, flag_SWE, flag_Q, precip_scaling)
% Description: This function contains all static/control parameters needed for a 
% simulation.

% Parameters are stored in two structured arrays:
% "control_params" -- related to simulation parameters
% "params" -- related to physical properties
%
% The control_parameters structured array specifies key inputs (i.e. 
% timestep, number of days to simulate. input/output files, etc.).
%
% The params structured array contains most of the static physical parameters of the 
% model.

% Specify path to root directory for the WEAP functions
control_params.toolbox_path = '/Users/gcortes/Dropbox/flowmind/app_snowflow/';
control_params.input_dir = '/Users/gcortes/Dropbox/flowmind/datasets/';
control_params.project = project; 
control_params.basin = basin;
control_params.run = run_sce;
control_params.scenario = scenario;

% Specify output filename
control_params.output_filename = [control_params.input_dir control_params.project '/' control_params.basin '_' control_params.scenario '.mat'];
control_params.output_filename_fig = [control_params.input_dir  control_params.project '/' control_params.basin '_' control_params.scenario '_results.fig'];

% Add path
addpath(genpath(control_params.toolbox_path))

%% Specify location of met. data. This assumes there is one met. station for
% basin and that the time step in the data corresponds to the time step dt 
% specified above. 
% The units for the meteorological inputs are assumed as follows:
% Precipitation:  (mm/day); variable "PPT"
% Air temp.: (C); variable "Tair"

control_params.validation_filename_q = [control_params.input_dir '/projects/' control_params.project '/data_hydrometeo/data_q/' control_params.basin '.mat'];
control_params.dem_filename = [control_params.input_dir '/projects/' control_params.project '/matlab/' control_params.basin '.mat'];
control_params.met_data_info = [control_params.input_dir '/projects/' control_params.project '/data_hydrometeo/station_data.mat'];
load(control_params.met_data_info);

control_params.validation_folder_SWE = [control_params.input_dir '/projects/' control_params.project '/data_SWE/' ];
control_params.met_data_filename_Tair = [control_params.input_dir '/projects/' control_params.project '/data_hydrometeo/tair_' control_params.scenario '.mat'];
control_params.Ta_gage_elev = station_data.tair_elev;
control_params.met_data_filename_PPT = [control_params.input_dir '/projects/' control_params.project '/data_hydrometeo/precip_' control_params.scenario '.mat'];
control_params.glacier_area = [control_params.input_dir '/projects/' control_params.project '/data_glacier/glacier_' control_params.basin '.mat'];

%% Start year of simulation (1988 will start the simulation in Apr 1 1988)      

control_params.start_year = years(1);
% End year of simulation (1990 will end the simulation in March 31 1991)            
control_params.end_year = years(2);
params.band_val = 50; %Meters of each band
control_params.validation_flag_SWE = flag_SWE; %(0 -> no data available)
control_params.validation_flag_Q = flag_Q;
control_params.glacier_data = 1;
control_params.scenario = scenario;

%% Simulation control parameters specification in "control_params" structured array

% Timestep (daily)            
control_params.dt = 1;
% Set the starting day in the forcing file 
control_params.start_day = 1; 
% number of time steps
control_params.n_day = length(control_params.start_year:control_params.end_year)*366.;  
% number of time steps in a year
control_params.n_year = 366; 
% Specify frequency of output to screen
control_params.frq2screen = 366; % Output to display will occur every time step divisible by frq2screen

%% Initialize dates

count = 1;
for y = control_params.start_year:control_params.end_year;
    for dowy = 1:control_params.n_year;
        if dowy <= 276
            DOY = dowy + 90;
            [year_aux, month_aux, day_aux] = jd2cal(doy2jd(y, DOY));
            date_data(count) = datenum(year_aux, month_aux, day_aux);
        else
            DOY = dowy - 276;
            [year_aux, month_aux, day_aux] = jd2cal(doy2jd(y + 1, DOY));
           date_data(count) = datenum(year_aux, month_aux, day_aux);
        end;
        count = count + 1;
    end;
end;

control_params.date = date_data;

%% Specify location of validation data (SWE reanalysis and streamflow)

% Do we want to perform a Monte Carlo simulation?
control_params.Monte_Carlo = 0; % (1 -> yes, 0 -> no)

% SWE parameters have to be determined before soil ones so we need two MC
% simulations, one for SWE first and then one for soil (with SWE parameters
% fixed).
control_params.Monte_Carlo_SWE = 0; 
control_params.n_iter = 100;

%% Compute additional control parameters

% number of time steps
control_params.nt = 1./control_params.dt*control_params.n_day;
% Set index to initialize forcings
control_params.start_time = control_params.start_day./control_params.dt;

% Snow model choice (0 -> A (simple DDF) and 1 -> B (DDF + incoming clear sky SW))
control_params.Snow_Model_Flag = 1;

%% Specify static parameters in "params" structured array

params.time_zone_shift = -5;
params.UTC = 0-params.time_zone_shift:23-params.time_zone_shift;

%params.n_band = 100 ;

% Air properties 
params.LapseRateTair = -5.2;    % Air temperature lapse rate (K/km) for mountainuous regions
params.precip_scaling = precip_scaling;    % Precipitation scaling coefficient

% Water properties
params.rho_water = 1; % liquid water density (g/cm^3);
params.rho_ice = 0.917; % liquid water density (g/cm^3);

% Soil properties 
% Parameters below are assumed homogeneous
params.Z1_init  = 0;     % Initial Z1 (-)
params.Z2_init  = 0;     % Initial Z2 (-)
params.k        = 1;          % Loss coefficient
params.K_SW     = .5;      % Soil water (rootzone) conductivity (m/day)
params.K_DW     = .05;      % Deep water conductivity (m/day)
params.f        = 0.2;           % prefered flow direcion (1 = horz., 0 = ver.) (-)
params.Kc       = 1.1;          % Crop coef. (-)
params.SW       = 1;           % Soil water capacity (m)
params.DW       = 3;            % Deep water capacity (m), the larger, the more damped are flows throuhgout the year.
params.RRF      = 1;        % Runoff resistance factor (-), higher values result in lower streamflow

% Snow model parameters (based on the temperature-index models from
% Pelliciotti et al. (2005) and Monte Carlo simulations)
params.a_snow   = 5;        % Degree-Day-Model coef. (1.3-11.6 mm/day/K)
params.a_ice    = 5;           % Degree-Day-Model coef. (5.5-18.6 mm/day/K)

params.MF           = 0;              % mm/day/K, Pellicciotti et al 0.082 * 24
params.RFsnow       = 0.0250;    % 0.00052 * 24 m^2mm/day/K
params.RFice        = 0.0200;    % 0.00106 * 24 m^2mm/day/K

params.RFsnow_sec   = 0.000;    % 0.00052 * 24 m^2mm/day/K
params.RFice_sec    = 0.000;    % 0.00106 m^2mm/day/K

params.T_snowmelt   = 279;  % Snowmelt temp. (K, corresponds to 1.45 C used by Condom et al. 2011)
params.T_icemelt    = 275;   % Icemelt temp. (K)

params.T_S          = 279;           % Freezing point (K)
params.T_L          = 285;           % Melting point (K) 

% Glacier geometry parameters (-), see Bahr et al. 1997
params.glacier_b    = 1.36;  
params.glacier_c    = 0.048;

end

