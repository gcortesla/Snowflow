function [Z2_new, Baseflow] = Z2_update(Z2_old, Percolation, K_DW, DW)

    %% Calculate baseflow
    Baseflow = K_DW*(Z2_old)^2;
    %% -> get new Z2
    Z2_new = (Z2_old*DW + Percolation - Baseflow)/DW;

    if Z2_new<0;
        Z2_new = 0;
    end;
            
end

