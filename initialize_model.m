function [SWE, Streamflow,forcings,control_params,params,elev_bands,A_band,A_glacier,A_non_glacier,mc,lat,lon, weights, glacier]= ...
    initialize_model(control_params, params)

%% Static data first
load(control_params.dem_filename);

if control_params.glacier_data == 1;
    load(control_params.glacier_area);
    glacier.area = glacier_area;
    glacier.years = years_vals;
else
    glacier.area = NaN;
    glacier.years = NaN;
end;

dem = dem.*mask;
res = abs(northing(2)-northing(1)); % should be 30 m

% Extract mean latitude and longitude vectors
X = nanmean(easting);
Y = nanmean(northing);
[lat, lon] = minvtran(utmstruct,X,Y);

band_val = params.band_val;
%n_bands = params.n_band;
elev_dif = max(dem(:)) - min(dem(:));
n_bands = floor(elev_dif/band_val);
elev_threshold = min(dem(:)):band_val:max(dem(:));

for n = 1:n_bands
    elev_bands(n) = (elev_threshold(n)+elev_threshold(n+1))*0.5;
end;

for n = 1:n_bands
    A = find(mask(:) == 1 & dem(:) > elev_threshold(n) & dem(:) <= elev_threshold(n+1));
    A_band(n) = length(A)*res^2; % m^2
    
    if strcmp(control_params.scenario, 'observed');
        G = find(glacier_ini(A) > 0);
    else
        G = find(glacier_fin(A) > 0);
    end;
    
    A_glacier(n) = length(G)*res^2;
    A_non_glacier(n) = A_band(n) - A_glacier(n);
    
    if A_glacier(n)/(A_glacier(n)+A_non_glacier(n))<0.01;
        A_glacier(n) = 0;
        A_non_glacier(n) = A_band(n);
    end;
end;

%% Met forcing (Tair and PPT) 

mc = NaN.*ones(5, 366*((control_params.end_year - (control_params.start_year))));

Tair = NaN.*ones(366,(control_params.end_year - (control_params.start_year)));
eval(['load ' control_params.met_data_filename_Tair ' vals_date_matlab vals_tmax vals_tmin']);
Ta = (vals_tmax + vals_tmin)./2;
Ta_dates = vals_date_matlab;
Ta(isnan(Ta)) = 0;

PPT = NaN.*ones(366,(control_params.end_year - (control_params.start_year)));
eval(['load ' control_params.met_data_filename_PPT ' vals_date_matlab vals_precip']);
Precip = vals_precip;
Precip(isnan(vals_precip)) = 0;
Precip_dates = vals_date_matlab;

Years = control_params.start_year:control_params.end_year+1;
for y = 1:length(Years)-1
    
    Start = datenum(['04/01/' num2str(Years(y))]);
    End = datenum(['03/31/' num2str(Years(y+1))]);
  
    Ta_start = find(Ta_dates == Start);
    Ta_end = find(Ta_dates == End);
    
    Tair(1:length((Ta_start:Ta_end)),y) = Ta(Ta_start:Ta_end);
    
    Precip_start = find(Precip_dates == Start);
    Precip_end = find(Precip_dates == End);
    
    PPT(1:length(Precip_start:Precip_end),y) = Precip(Precip_start:Precip_end);

end;

forcings.PPT = reshape(PPT,1,366*(length(control_params.start_year:control_params.end_year)))./1000; % -> m/day
forcings.Ta = reshape(Tair,1,366*(length(control_params.start_year:control_params.end_year)));
forcings.Ta_gage_elev = control_params.Ta_gage_elev; 

%% Streamflow measurements and SWE reanalysis for model calibration

if control_params.validation_flag_Q ==1
    Q = NaN.*ones(366,length(control_params.start_year:control_params.end_year));
    eval(['load ' control_params.validation_filename_q ' vals_date_matlab vals_q']);
    q = vals_q;
    q_dates = vals_date_matlab;

    for y = 1:length(Years)-1
        Start = datenum(['04/01/' num2str(Years(y))]);
        End = datenum(['03/31/' num2str(Years(y+1))]);
        
        q_formal = Start:1:End;
        q_common = q_dates(find(q_dates >= Start & q_dates <=End));
        
        if ~isempty(q_common);
            Q(find(q_formal==q_common(1)):find(q_formal==q_common(end)),y) = q(find(q_dates >= Start & q_dates <=End));
        else
            Q(1:366, y) = NaN;
        end;
    end;
    
    Streamflow = reshape(Q, 1, 366*(length(control_params.start_year:control_params.end_year)));
    
else
    Streamflow = 'No validation data available';
end;

weights = A_band./nansum(A_band);

if control_params.validation_flag_SWE == 1
    SWE = NaN.*ones(n_bands,366,length(control_params.start_year:control_params.end_year));
    for y = 1:length(Years)-1
        tic
        disp(['Processing SWE data for ' num2str(Years(y))]);
        
        if exist([control_params.validation_folder_SWE '/SWE_' control_params.basin '_WY_' num2str(Years(y)) '.mat'], 'file')
        eval(['load ' control_params.validation_folder_SWE '/SWE_' control_params.basin '_WY_' num2str(Years(y)) '.mat SWE_val']);
        
        for n = 1:n_bands
            %   disp(n);
            
            % A = find(mask(:) == 1 & dem(:) > elev_threshold(n) & dem(:) <= elev_threshold(n+1));
            A = double(mask == 1 & dem > elev_threshold(n) & dem <= elev_threshold(n+1));
            B = SWE_val(:, A == 1);
            [aux_day, ~] = size(B);
            SWE(n, 1:aux_day, y) = nanmean(B, 2).*weights(n);
            %for d = 1:size(SWE_val,1)
            %    dummy = squeeze(SWE_val(d,:,:));
            %    SWE(n,d,y) = nanmean(dummy(A));
            %end;
        end;
        
        else
            SWE(n, :, y) = nan;
        end;
        
        % clear SWE_val
        toc
    end;
    
    SWE = reshape(SWE,n_bands,366*(length(control_params.start_year:control_params.end_year)));
else
    
    SWE = 'No validation data available';
end;

  
  
end

