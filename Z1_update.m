function [Z1_new,Surface_runoff, Infiltration, Interflow, Percolation, ET]= ...
                 Z1_update(Z1_old, f, K_SW, RRF, k, Pl, melt_snow, melt_ice, SW, PET)
                     
    %% Calculate surface runoff 
    Surface_runoff = k*(Pl + melt_snow + melt_ice) * (Z1_old)^RRF;
    Infiltration = k*(Pl + melt_snow + melt_ice)-Surface_runoff;
    
    %% Calculate interflow
    Interflow = (f*K_SW)*(Z1_old)^2;

    %% Calculate deep percolation 
    Percolation = K_SW*(1-f)*(Z1_old)^2;

    %% Calculate evaporation
    
    ET = PET * (5*Z1_old - 2*Z1_old^2)/3;
    
    %% -> get new Z1        
    Z1_new = (Z1_old*SW + Infiltration - Interflow - Percolation - ET)/SW;       

    if Z1_new < 0;
        Z1_new = 0;
    end;
end

