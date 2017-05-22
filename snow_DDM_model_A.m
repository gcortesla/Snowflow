function [SWE_new,melt_snow, melt_ice, Mpot_snow, Mpot_ice]= ...
                 snow_DDM_model_A(P_snow,Ta,glacier_area,SWE_old,...
                 a_snow,a_ice,T_snowmelt,T_icemelt)

%% Calculate runoff from snow

if Ta > T_snowmelt
    Mpot_snow = a_snow./1000*(Ta - T_snowmelt);%in m/month
else
    Mpot_snow = 0;
end;
SWE = SWE_old + P_snow;
melt_snow = min(SWE, Mpot_snow);

%% Update SWE to account for snowmelt
SWE_new = SWE - melt_snow;

if glacier_area > 0 && Mpot_snow > SWE % Then glacier ice is exposed
    if Ta > T_icemelt
        Mpot_ice = a_ice./1000*(Ta - T_icemelt);%in m/month
    else
        Mpot_ice = 0;
    end;

    melt_ice = Mpot_ice;%min(SWE_new, Mpot_ice);
else
    Mpot_ice = 0;
    melt_ice = 0;
end;





end

