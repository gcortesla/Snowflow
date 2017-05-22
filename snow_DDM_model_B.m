function [SWE_new, melt_snow, melt_ice, Mpot_snow, Mpot_ice]= ...
    snow_DDM_model_B(n_year, day, P_snow, Ta, glacier_area, SWE_old,...
    lat, lon, UTC, time_zone_shift, MF, RFsnow, RFice, RFsnow_sec, RFice_sec, T_snowmelt, T_icemelt)

%% Grab DOY from time step:
dowy = mod(day, n_year);
if dowy <= 276
    DOY = dowy + 90;
else
    DOY = dowy - 276;
end;

%% Calculate clear-sky incoming SW

[RsTOA, ~, ~, ~, ~, ~, ~] = TOA_incoming_solar(DOY, UTC, time_zone_shift, lat, lon);
Rs = nanmean(RsTOA);

%% Calculate runoff from snow

if Ta > T_snowmelt
    Mpot_snow = (MF./1000 + RFsnow./1000*Rs)*(Ta - T_snowmelt);%in m/month
else
    Mpot_snow = RFsnow_sec./1000*Rs;
end;
SWE = SWE_old + P_snow;
melt_snow = min(SWE, Mpot_snow);

%% Update SWE to account for snowmelt
SWE_new = SWE - melt_snow;

if glacier_area > 0% Mpot_snow > SWE % Then glacier ice is exposed, GC removed the Mpot_snow condition, it should check if SWE>0 not 
    if Ta > T_icemelt
        Mpot_ice = (MF./1000 + RFice./1000*Rs)*(Ta - T_icemelt);%in m/month
    else
        Mpot_ice = RFice_sec./1000*Rs;
    end;
    
    melt_ice = Mpot_ice;%min(SWE_new, Mpot_ice);
else
    Mpot_ice = 0;
    melt_ice = 0;
end;


end

