function [control_params,params] = Snowflow_model_static_and_control_parameters_CH_Portillo(basin, run_sce, scenario, years, flag_SWE, flag_Q, precip_scaling)
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
control_params.toolbox_path = '/Users/gcortes/Dropbox/snowflow/';

% Add path
addpath(genpath(control_params.toolbox_path))

%Specify basin name
control_params.basin = basin;
control_params.run = run_sce;

% Start year of simulation (1988 will start the simulation in Apr 1 1988)            
control_params.start_year = years(1);
% End year of simulation (1990 will end the simulation in March 31 1991)            
control_params.end_year = years(2);
params.band_val = 50;
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

%% Output/Input Filename Specification
%specify input directory
control_params.input_dir = '/Users/gcortes/Dropbox/project_Anpac/';
% Specify output filename
control_params.output_filename = ['/Users/gcortes/Dropbox/project_Anpac/test_outputs/' control_params.basin '_' control_params.scenario '.mat'];
control_params.output_filename_fig = ['/Users/gcortes/Dropbox/project_Anpac/test_outputs/' control_params.basin '_' control_params.scenario '_results.fig'];

%% Specify location of static and glacier data (in meters!!). 
control_params.dem_filename = [control_params.input_dir 'data_dem/data_' control_params.basin '.mat'];

%% Specify location of met. data. This assumes there is one met. station for
% basin and that the time step in the data corresponds to the time step dt 
% specified above. 
% The units for the meteorological inputs are assumed as follows:
% Precipitation:  (mm/day); variable "PPT"
% Air temp.: (C); variable "Tair"

control_params.met_data_filename_Tair = [control_params.input_dir 'data_hydrometeo/data_t/termas_el_flaco_' control_params.scenario '.mat'];
control_params.Ta_gage_elev = 2650;
control_params.met_data_filename_PPT = [control_params.input_dir 'data_hydrometeo/data_precip/pp_la_rufina_' control_params.scenario '.mat'];
control_params.glacier_area = [control_params.input_dir 'data_glacier/glacier_' control_params.basin '.mat'];

%% Specify location of validation data (SWE reanalysis and streamflow)


% Do we want to perform a Monte Carlo simulation?
control_params.Monte_Carlo = 0; % (1 -> yes, 0 -> no)

% SWE parameters have to be determined before soil ones so we need two MC
% simulations, one for SWE first and then one for soil (with SWE parameters
% fixed).
control_params.Monte_Carlo_SWE = 0; 
control_params.n_iter = 100;

% Streamflow (m3/s)
control_params.validation_filename_q = [control_params.input_dir 'data_hydrometeo/data_q/' control_params.basin '.mat'];

% SWE (m)
%control_params.validation_folder_SWE = [control_params.input_dir 'anpac_data/'];
% control_params.validation_folder_SWE = ['/Volumes/elqui_hd3/PROJECTS/SWE_REANALYSIS/ANDES/anpac_data/'];
control_params.validation_folder_SWE = [control_params.input_dir 'data_SWE/' ];
 
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
params.kPET = 1;
params.K_SW     = .5;      % Soil water (rootzone) conductivity (m/day)
params.K_DW     = .5;      % Deep water conductivity (m/day), increased value lowers estiaje streamflow
params.f        = 0.1;           % prefered flow direcion (1 = horz., 0 = ver.) (-)
params.Kc       = 1.1;          % Crop coef. (-)
params.SW       = 2;           % Soil water capacity (m)
params.DW       = 2;            % Deep water capacity (m), the larger, the more damped are flows throuhgout the year.
params.RRF      = 1;        % Runoff resistance factor (-), higher values result in lower streamflow

% Snow model parameters (based on the temperature-index models from
% Pelliciotti et al. (2005) and Monte Carlo simulations)
params.a_snow   = 5;        % Degree-Day-Model coef. (1.3-11.6 mm/day/K)
params.a_ice    = 5;           % Degree-Day-Model coef. (5.5-18.6 mm/day/K)

params.MF           = 0;              % mm/day/K, Pellicciotti et al 0.082 * 24
params.RFsnow       = 0.0350;    % 0.00052 * 24 m^2mm/day/K
params.RFice        = 0.0300;    % 0.00106 * 24 m^2mm/day/K

params.RFsnow_sec   = 0.000;    % 0.00052 * 24 m^2mm/day/K
params.RFice_sec    = 0.000;    % 0.00106 m^2mm/day/K

params.T_snowmelt   = 280;  % Snowmelt temp. (K, corresponds to 1.45 C used by Condom et al. 2011)
params.T_icemelt    = 276;   % Icemelt temp. (K)

params.T_S          = 279;           % Freezing point (K)
params.T_L          = 285;           % Melting point (K) 

% Glacier geometry parameters (-), see Bahr et al. 1997
params.glacier_b    = 1.36;  
params.glacier_c    = 0.048;

end

