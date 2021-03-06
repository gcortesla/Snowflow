function Snowflow_model_driver(basin, run_sce, scenario, year_data, flag_SWE, flag_Q, precip_scaling, band_choice)

%close all;
addpath(genpath('/Users/gcortes/Dropbox/flowmind/app_snowflow/'));
addpath(genpath('/Users/gcortes/Documents/MATLAB/'));

% Main model driver code for the Matlab implementation of Snowflow two-bucket
% model
% Written by: Elisabeth Baldo (2017)

% This function serves as a wrapper/driver which primarily calls existing
% functions for the various components of the model

% The main input file that needs to be modified is the function:
%
% Snowflow_model_static_and_control_parameters.m
%
% The outputs are stored in the file specified in the
% Snowflow_model_static_and_control_parameters.m file.

%% Load all static/control parameters

eval(['[control_params, params] = Snowflow_model_static_and_control_parameters_' basin '(basin, basin, run_sce, scenario, year_data, flag_SWE, flag_Q, precip_scaling);']);

% Load PET vals
load /Users/gcortes/Dropbox/project_Anpac/evaporation.mat
PET = e_val_interp/1000*params.kPET;

%% Initialize key states, arrays, divide into elevation bands ...

[SWE_reanalysis, Streamflow, forcings, control_params, params, elev_bands, A_band, A_glacier, A_non_glacier, mc, lat, lon, weights, glacier] = ...
    initialize_model(control_params, params, band_choice);

tic
if control_params.Monte_Carlo==1
    n_iter = control_params.n_iter;
else
    n_iter = 1;
end;

%%
for n_sim = 1:n_iter;
    disp(['Running simulation ' num2str(n_sim)]);
    
    if control_params.Monte_Carlo == 1
        %% MONTE CARLO SIMULATION FOR MODEL CALIBRATION
        
        if control_params.Monte_Carlo_SWE == 1
            % SWE parameters
            params.precip_scaling = rand*0.5+1;
            precip_scaling(n_sim) = params.precip_scaling;
            
            if control_params.Snow_Model_Flag == 0;
                params.a_snow = rand*9+1.6;
                a_snow(n_sim) = params.a_snow;
                
                params.a_ice = rand*13.1+5.5;
                a_ice(n_sim) = params.a_ice;
                
                params.MF = 2;
                MF(n_sim) = params.MF;
                
                params.RFsnow = 0.02;
                RFsnow(n_sim) = params.RFsnow;
                
                params.RFice = 0.02;
                RFice(n_sim) = params.RFice;
                
            else
                
                params.a_snow = 6.1;
                a_snow(n_sim) = params.a_snow;
                
                params.a_ice = 12;
                a_ice(n_sim) = params.a_ice;
                
                params.MF = 24*4*rand;
                MF(n_sim) = params.MF;
                
                params.RFsnow = 24*0.02*rand+24*0.01;
                RFsnow(n_sim) = params.RFsnow;
                
                params.RFice = 24*0.02*rand+24*0.01;
                RFice(n_sim) = params.RFice;
                
            end;
            
            params.T_snowmelt = rand*4+271;
            T_snowmelt(n_sim) = params.T_snowmelt;
            
            params.T_icemelt =rand*4+271;
            T_icemelt(n_sim) = params.T_icemelt;
            
            params.T_S = rand*3+273;
            T_S(n_sim) = params.T_S;
            
            params.T_L = rand*3+276;
            T_L(n_sim) = params.T_L;
        else
            % Soil parameters
            params.Z1_init = 0;
            Z1_init(n_sim) = params.Z1_init;
            
            params.Z2_init = 0;
            Z2_init(n_sim) = params.Z2_init;
            
            params.K_SW = rand*2+0.5;
            K_SW(n_sim) = params.K_SW;
            
            params.K_DW = rand*2+0.05;
            K_DW(n_sim) = params.K_DW;
            
            params.f = rand;
            f(n_sim) = params.f;
            
            params.SW = rand*2;
            SW(n_sim) = params.SW;
            
            params.DW = rand*3;
            DW(n_sim) = params.DW;
            
            params.RRF = 3*rand;
            RRF(n_sim) = params.RRF;
        end;
    end;
    
    %% Main time-stepping loop
    for tt = 1:control_params.nt
        
        % Print progress to screen
        if mod(tt,control_params.frq2screen*3) == 0
            disp(['Time step: ' num2str(tt) ' of ' ...
                num2str(control_params.nt) ]);toc
        end
        
        for n = 1:length(elev_bands)
            
            %% Assign/distribute meteorological forcing variables for this time step.
            % Note: This uses the forcing variable at the beginning of the time
            % step to compute the states at the next time step and the fluxes over
            % the time step.
            % This currently assumes a single met. station data mapped to all
            % pixels.
            
            [PPT(n,tt), Ta(n,tt)] = distribute_met_forcings(...
                forcings.PPT(tt),...
                forcings.Ta(tt),...
                elev_bands(n),forcings.Ta_gage_elev,params.LapseRateTair,params.precip_scaling);
            
            %% Initialize state variables
            if tt == 1
                
                % Set SWE to zero at initial time
                SWE_old(n) = 0;
                % Set Z1 at initial time
                Z1_old(n) = params.Z1_init;
                % Set Z2 at initial time
                Z2_old(n) = params.Z2_init;
                
            end
            
            %% Rain/Snow screening
            % Find snowy pixels
            if Ta(n,tt) <= params.T_S
                mc(n, tt) = 0;
            elseif Ta(n, tt) >= params.T_L
                mc(n, tt) = 1;
            elseif Ta(n,tt) < params.T_L && Ta(n,tt) > params.T_S
                mc(n, tt) = (Ta(n, tt) - params.T_S) / (params.T_L - params.T_S);
            end;
            
            P_snow(n, tt) = (1 - mc(n,tt)).*PPT(n,tt);
            P_rain(n, tt) = PPT(n,tt) - P_snow(n,tt);
            
            %% Run the snow model(DDM)function only if snow is on the ground or falling
            
            % Initialize melt
            melt_snow(n,tt) = 0;
            melt_ice(n,tt)  = 0;
            
            if SWE_old(n)>0 || P_snow(n,tt)>0
                if control_params.Snow_Model_Flag == 0
                    % Call snow model A
                    [SWE(n,tt), melt_snow(n,tt), melt_ice(n,tt), Mpot_snow(n,tt), Mpot_ice(n,tt)]= ...
                        snow_DDM_model_A(P_snow(n,tt), Ta(n,tt), A_glacier(n), SWE_old(n),...
                        params.a_snow, params.a_ice, params.T_snowmelt, params.T_icemelt);
                else
                    % Call snow model B
                    [SWE(n,tt), melt_snow(n,tt), melt_ice(n,tt), Mpot_snow(n,tt), Mpot_ice(n,tt), Rs(n, tt)]= ...
                        snow_DDM_model_B(control_params.n_year, tt, P_snow(n,tt),Ta(n,tt), A_glacier(n), SWE_old(n),...
                        lat, lon, params.UTC,params.time_zone_shift,params.MF,params.RFsnow,...
                        params.RFice, params.RFsnow_sec, params.RFice_sec, params.T_snowmelt,params.T_icemelt);
                end;
                melt_ice(n, tt)     = melt_ice(n, tt);
                
                %Melt of ice should consider band area covered by ice otherwise it is too large
                %  melt_snow(n, tt)    = (A_non_glacier(n)/A_band(n)).*melt_snow(n, tt);
                %melt_snow(n, tt)    = (A_non_glacier(n)/A_band(n)).*melt_snow(n, tt);
            else
                SWE(n, tt)          = 0;
                melt_snow(n, tt)    = 0;
                Mpot_snow(n, tt)    = 0;
            end
            
            SWE_model(n_sim, n, tt) = SWE(n, tt).*weights(n);
            
            % Over glacierized area (get total volume)
            VQ_ice_glacier(n, tt)  = (melt_ice(n,tt))*A_glacier(n); % (m^3)
            VQ_snow_glacier(n, tt) = (melt_snow(n,tt))*A_glacier(n); % (m^3)
            VP_rain_glacier(n, tt) = (P_rain(n,tt))*A_glacier(n); % (m^3)
            
            if SWE_old(n)>0 ||  P_snow(n,tt)>0
                V_SWE(n,tt) = SWE(n, tt)*A_band(n); % (m^3)
            else
                V_SWE(n,tt) = SWE_old(n)*A_band(n); % (m^3)
            end;
            
            % Rain over non-glacierized area (we assume that the rain over glacier freezes)
            P_rain(n,tt) =  (A_non_glacier(n)/A_band(n)).*P_rain(n,tt);
            
            %% Call Z1 and Z2 update over non-glacierized part of the elevation band (Bucket #1)
            
            [Z1(n,tt), Surface_runoff(n,tt), Infiltration(n,tt), Interflow(n,tt), Percolation(n,tt), ET(n, tt)] = ...
                Z1_update(Z1_old(n),params.f,...
                params.K_SW,params.RRF,params.k,...
                P_rain(n,tt), melt_snow(n,tt), (A_glacier(n)/A_band(n))*melt_ice(n, tt), params.SW, PET(mod(tt, 366)+1));
            
            [Z2(n,tt), Baseflow(n,tt)] = Z2_update(Z2_old(n), Percolation(n, tt), params.K_DW, params.DW);
            
            %% Calculate total flow volume in m^3
            
            Outflow(n,tt) = ((Surface_runoff(n,tt) + Interflow(n,tt) + Baseflow(n,tt)))*A_non_glacier(n); % (m^3)
            Outflow_model(n_sim,n,tt) = Outflow(n,tt);
            
            %% Perform annual mass balance to calculate changes in glacier volume
            
            if mod(tt, control_params.n_year) == 0
                
                Annual_VQ_ice_glacier(n, tt/control_params.n_year)  = nansum(VQ_ice_glacier(n, tt - (control_params.n_year - 1):tt), 2);
                Annual_VQ_snow_glacier(n, tt/control_params.n_year) = nansum(VQ_snow_glacier(n, tt - (control_params.n_year - 1):tt), 2);
                Annual_VP_rain_glacier(n, tt/control_params.n_year) = nansum(VP_rain_glacier(n, tt - (control_params.n_year - 1):tt), 2);
                
                % liquid water
                delta_V_liq(n, tt/control_params.n_year) = Annual_VP_rain_glacier(n, tt/control_params.n_year) - Annual_VQ_snow_glacier(n, tt/control_params.n_year) - Annual_VQ_ice_glacier(n, tt/control_params.n_year);
                
                % snow phase
                Last_SWE = find(~isnan(V_SWE(n, :)));
                
                delta_V_SWE(n, tt/control_params.n_year) = V_SWE(n, Last_SWE(end));
                SWE(n, tt) = 0;
                %SWE(n, tt) = SWE_old(n)*A_non_glacier(n)/A_band(n); %Reduce SWE by the volume that was transfered to the glacier
                SWE_old(n) = SWE(n, tt);
                % total net accumulation of water over the glacier:
                delta_M_water(n, tt/control_params.n_year) = (delta_V_liq(n, tt/control_params.n_year) + delta_V_SWE(n, tt/control_params.n_year))*params.rho_water*100^3; % (g)
                
                % Change in volume of ice over the elevation band:
                delta_V_ice(n, tt/control_params.n_year) = delta_M_water(n, tt/control_params.n_year)/(params.rho_ice*100^3); % (m^3)
            end;
            
        end % end of elevation band loop
        
        %% Annual glacier geometry evolution
        
        if mod(tt, control_params.n_year) == 0
            
            delta_V_glacier(tt/control_params.n_year) = nansum(delta_V_ice(:, tt/control_params.n_year)); % (m^3)
            
            A_glacier_init = sum(A_glacier(:));
            V_glacier_init = params.glacier_c.*(A_glacier_init/1000000)^(params.glacier_b); %Area must be in km2
            V_glacier_final(tt/control_params.n_year) = V_glacier_init + delta_V_glacier(tt/control_params.n_year)/1000000000; %Volume must be in km3
            
            if V_glacier_final(tt/control_params.n_year) < 0
                V_glacier_final(tt/control_params.n_year) = 0;
            end;
            
            A_glacier_final(tt/control_params.n_year) = ((V_glacier_final(tt/control_params.n_year))/params.glacier_c)^(1/params.glacier_b)*1000000;
            delta_A_glacier(tt/control_params.n_year) = A_glacier_final(tt/control_params.n_year) - A_glacier_init;
            
            G = find(A_glacier>0);
            
            dummy_delta = delta_A_glacier(tt/control_params.n_year);
            
            %GC select only bands that presented extra SWE and that had
            %glaciers?
            %bands_with_glaciers = find(delta_V_SWE(:, tt/control_params.n_year)>0)';
            bands_with_glaciers = find(A_glacier>0); %Distribute among bands that had glaciers during the last iteration
            
            for n = 1:length(elev_bands)
                A_non_glacier_band(n, tt/control_params.n_year) = A_band(n);
                A_glacier_band(n, tt/control_params.n_year) = 0;
            end;
            
            if V_glacier_final>0
                for n = bands_with_glaciers;
                    A_glacier_band(n, tt/control_params.n_year) = A_glacier(n) + A_glacier(n)*dummy_delta./nansum(A_glacier(bands_with_glaciers));
                    
                    if A_glacier_band(n, tt/control_params.n_year) < 0
                        A_glacier_band(n, tt/control_params.n_year) = 0;
                    elseif A_glacier_band(n, tt/control_params.n_year) > A_band(n)
                        A_glacier_band(n, tt/control_params.n_year) = A_band(n);
                    end;
                    
                    A_non_glacier_band(n, tt/control_params.n_year) = A_band(n) - A_glacier_band(n, tt/control_params.n_year);
                    A_glacier(n) = A_glacier_band(n, tt/control_params.n_year);
                    A_non_glacier(n) = A_non_glacier_band(n, tt/control_params.n_year);
                end;
            else
                for n = 1:length(elev_bands)
                    A_glacier(n) = 0;
                    A_non_glacier(n) = A_band(n);
                end;
            end;
        end;
        
        %% Update variables for next time step
        for n = 1:length(elev_bands)
            if SWE_old(n)>0 ||  P_snow(n,tt)>0
                if ~isnan(SWE(n,tt))
                    SWE_old(n) = SWE(n,tt);
                end;
            end;
            if ~isnan(Z1(n,tt))
                Z1_old(n) = Z1(n,tt);
            end;
            if ~isnan(Z2(n,tt))
                Z2_old(n) = Z2(n,tt);
            end;
        end;
    end % end of main time stepping loop
end % end of iterations

disp('Snowflow simulation completed successfully.')

    %% Save key outputs
    date_data = control_params.date;
    if ~exist('A_glacier_band', 'var'); A_glacier_band = 0; A_non_glacier_band = 0; end;
    eval(['save ' control_params.output_filename ' control_params date_data Outflow' ' V_glacier_final' ' A_glacier_final' ' delta_V_glacier' ' delta_A_glacier' ...
        ' delta_V_ice' ' delta_M_water' ' delta_V_SWE' ' delta_V_liq' ' Annual_VQ_ice_glacier' ' Annual_VQ_snow_glacier' ' Annual_VP_rain_glacier' ...
        ' VQ_ice_glacier' ' VQ_snow_glacier' ' VP_rain_glacier' ' V_SWE' ' Z1' ' Z2' ' SWE' ' melt_snow' ' melt_ice' ' P_rain' ' P_snow' ' Surface_runoff' ...
        ' Interflow' ' Baseflow' ' Infiltration' ' Percolation' ' mc' ' Ta' ' PPT' ' Mpot_snow' ' Mpot_ice' ' A_glacier_band' ' A_non_glacier_band' ' Streamflow' ' SWE_reanalysis' ' weights' ' ET' ' Rs' ' glacier'])
    
    disp(['Outputs stored in: '])
    disp([control_params.output_filename])
    
    bands_selec = (A_glacier./A_band)<0.3;
    
    figure(1)
    subplot(3,1, 1);
    plot(date_data, squeeze(nansum(Outflow, 1))/24/3600, 'LineStyle', '-', 'Color', [.4 .4 .4], 'LineWidth', 2);
    hold on;
    datetick;
    if control_params.validation_flag_Q == 1
        plot(date_data, Streamflow, 'r');
    end;
    grid on;
    box on;
    xlabel('Date');
    ylabel('Streamflow [m^3/s]');
    %    legend Simulated Observed
    xlim([datenum(control_params.start_year, 4, 1) datenum(control_params.end_year, 3, 31)]);
    
    %     subplot(1, 2, 2);
    %     plot(date_data, squeeze(nansum(SWE_model(:, bands_selec), 2)),  'LineStyle', '-', 'Color', [.4 .4 .4], 'LineWidth', 2);
    %     hold on;
    %     datetick;
    %
    %     if control_params.validation_flag_SWE == 1
    %         plot(date_data, nansum(SWE_reanalysis(bands_selec, :), 1), 'r');
    %     end;
    %
    %     xlabel('Date');
    %     ylabel('SWE [m]');
    %     legend Simulated Observed
    %     grid on;
    %     box on;
    %     xlim([datenum(control_params.start_year, 4, 1) datenum(control_params.end_year, 3, 31)]);
    
    subplot(3, 1, 2);
    plot(control_params.start_year:control_params.end_year, A_glacier_final/1000000,  'LineStyle', '-', 'Color', [.4 .4 .4], 'LineWidth', 2);
    hold on
    xlabel('Year');
    ylabel('Glacier area [km^2]');
    grid on;
    box on;
    xlim([control_params.start_year control_params.end_year]);
    set(gca, 'XTick', control_params.start_year:2:control_params.end_year);
    if control_params.glacier_data == 1;
        scatter(glacier.year_data+1, glacier.area);
    end;
    
    %     subplot(2, 3, 4);
    %     plot(control_params.start_year:control_params.end_year, delta_V_glacier,  'LineStyle', '-', 'Color', [.4 .4 .4], 'LineWidth', 2);
    %     hold on
    %     xlabel('Year');
    %     ylabel('Delta glacier Volume [m^3]');
    %     grid on;
    %     box on;
    %     xlim([control_params.start_year control_params.end_year]);
    %     set(gca, 'XTick', control_params.start_year:2:control_params.end_year);
    
    if control_params.validation_flag_SWE == 1
        subplot(3, 1, 3);
        n_year_data = length(SWE_model)./366;
        aux_SWE_obs = reshape(nansum(SWE_reanalysis, 1), 366, n_year_data);
        aux_SWE_obs(aux_SWE_obs == 0) = NaN;
        plot(nanmean(aux_SWE_obs, 2), 'r');
        hold on;
        
        aux_SWE_mod = reshape(nansum(SWE_model, 2), 366, n_year_data);
        aux_SWE_mod(isnan(aux_SWE_obs)) = NaN;
        plot(nanmean(aux_SWE_mod, 2),  'LineStyle', '-', 'Color', [.4 .4 .4], 'LineWidth', 2);
        hold on;
    end;
    
    
    %  disp(['savefig(gcf,' control_params.output_filename_fig ');']);
    %   eval(['savefig(gcf,''' control_params.output_filename_fig ''');']);
    
    %     figure(2)
    %     for n = 1:1:length(elev_bands);
    %         plot(squeeze(SWE_model(1, n, :))./weights(n));
    %
    %         hold on;
    %         if control_params.validation_flag_SWE == 1
    %             plot(squeeze(SWE_reanalysis(n, :))./weights(n), '--k');
    %         end;
    %     end;
    %     plot(squeeze(nansum(SWE_model, 2)), 'k', 'LineWidth', 2);
    %
    %     if control_params.validation_flag_SWE == 1
    %         plot(squeeze(nansum(SWE_reanalysis, 1)), '--k', 'LineWidth', 2);
    %     end;

return