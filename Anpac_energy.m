function [Egen_daily, Pot_daily, Ef_daily, Qgen_daily] = ...
    Anpac_energy(date_data, Q, DD_p, DD_e, Qeco, Qd, Hd, Ef, FP, Qeco_DD_flag)

DD_daily = nan(length(Q), 1);
Qeco_daily = nan(length(Q), 1);
Qgen_daily = Qeco_daily;
Pot_daily = Qgen_daily;
Egen_daily = Pot_daily;
Ef_daily = Egen_daily; 

for i = 1:length(date_data);
    
    [~, m(i), ~] = datevec(date_data(i));
    m(i) = m(i) - 3;
    
    if m(i)<=0; m(i) = m(i) + 12; end;
    
    if  Qeco_DD_flag == 0;
        DD_daily(i) = Qd;
        Qeco_daily(i) = 0;
    else
        DD_daily(i) = DD_e(m(i)) + DD_p(m(i));
        Qeco_daily(i) = Qeco(m(i));
    end;
    
    Qgen_daily(i) = min([max([0 Q(i)-Qeco_daily(i)]) DD_daily(i) Qd]);
    Ef_daily(i) = interp1(0:0.05:1, Ef, Qgen_daily(i)/Qd);
    
    % Pot = 9.8 * Q * Ef * (H - Q^2 * FP)/1000  
    Pot_daily(i) = 9.8 * Qgen_daily(i) * Ef_daily(i) * (Hd - Qgen_daily(i)^2*FP); % [W]
    Egen_daily(i) = Pot_daily(i)*24; % [Wh]
end;

% Assign data from 