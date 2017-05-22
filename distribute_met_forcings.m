function [PPT, Ta]=distribute_met_forcings(...
            forcings_PPT, forcings_Ta, elev_bands, Ta_gage_elev, LapseRateTair, scaling_coef)
        
PPT = forcings_PPT*scaling_coef;%in m/month already

Ta = forcings_Ta+273.16 + LapseRateTair*(elev_bands - Ta_gage_elev)/1000;

end

