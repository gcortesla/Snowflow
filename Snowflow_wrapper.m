% Snowflow wrapper to run several modeling instances at a time and save
% them

Snowflow_model_driver('CH_Palacios', 'historical', 'observed',  [1984 2016], 1, 1, 1.7)
Snowflow_model_driver('CH_Damas', 'historical', 'observed', [1984 2016], 1, 1, 1.4)
Snowflow_model_driver('CH_San_Andres', 'historical', 'observed', [1984 2016], 1, 0, 1.5)
Snowflow_model_driver('CH_Portillo','historical', 'observed', [1984 2016], 1, 1, 1.7)
Snowflow_model_driver('CH_Azufre', 'historical', 'observed', [1984 2016], 1, 1, 1.9)

% Snowflow_model_driver('Tinguiririca_Bajo_Briones','historical', 'observed',  [1989 2016], 0, 1, 1.1)
% Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'historical', 'observed',  [1989 2016], 1, 1, 1.2)
% Snowflow_model_driver('Pangal_en_Pangal', 'historical', 'observed',  [1989 2016], 1, 1 , 1.1)
% Snowflow_model_driver('Cachapoal_Bajo_Cortaderal', 'historical', 'observed',  [1989 2016], 1, 1, 1.2)
% Snowflow_model_driver('Lenas_Antes_Cachapoal', 'historical', 'observed',  [1989 2016], 1, 1, 1.1)
% Snowflow_model_driver('Claro_Nieves', 'historical', 'observed',  [1989 2016], 1, 1, 1.4)
% Snowflow_model_driver('Cortaderal_Antes_Cachapoal', 'historical', 'observed',  [1989 2016], 1, 1, 1.2)

%% Historical scenario RCP

for m = [2 3 18];
       
    Snowflow_model_driver('CH_Palacios', 'historical', ['RCP85_model_' num2str(m)],  [1989 2016], 0, 0, 1.6)
    Snowflow_model_driver('CH_Damas', 'historical', ['RCP85_model_' num2str(m)], [1989 2016], 0, 0, 1.4)
    Snowflow_model_driver('CH_San_Andres', 'historical', ['RCP85_model_' num2str(m)], [1989 2016], 0, 0, 1.4)
    Snowflow_model_driver('CH_Portillo','historical', ['RCP85_model_' num2str(m)], [1989 2016], 0, 0, 1.6)
    Snowflow_model_driver('CH_Azufre', 'historical', ['RCP85_model_' num2str(m)], [1989 2016], 0, 0, 1.7)
    
%     Snowflow_model_driver('Tinguiririca_Bajo_Briones','historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0, 1.1)
%     Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0, 1.2)
%     Snowflow_model_driver('Pangal_en_Pangal', 'historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0 , 1.1)
%     Snowflow_model_driver('Cachapoal_Bajo_Cortaderal', 'historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0, 1.2)
%     Snowflow_model_driver('Lenas_Antes_Cachapoal', 'historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0, 1.1)
%     Snowflow_model_driver('Claro_Nieves', 'historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0, 1.4)
%     Snowflow_model_driver('Cortaderal_Antes_Cachapoal', 'historical', ['RCP85_model_' num2str(m)],  [1989 2015], 0, 0, 1.2)

end;

%% RCP85 scenarios

for m = [2 3 18];
    Snowflow_model_driver('CH_Palacios', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.6)
    Snowflow_model_driver('CH_Damas', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.4)
    Snowflow_model_driver('CH_San_Andres', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.4)
    Snowflow_model_driver('CH_Portillo', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.6)
    Snowflow_model_driver('CH_Azufre', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.7)
    
%     Snowflow_model_driver('Tinguiririca_Bajo_Briones', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.1)
%     Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.2)
%     Snowflow_model_driver('Pangal_en_Pangal', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0 , 1.1)
%     Snowflow_model_driver('Cachapoal_Bajo_Cortaderal', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.2)
%     Snowflow_model_driver('Lenas_Antes_Cachapoal', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.1)
%     Snowflow_model_driver('Claro_Nieves', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.4)
%     Snowflow_model_driver('Cortaderal_Antes_Cachapoal', 'future', ['RCP85_fut_model_' num2str(m)],  [2016 2049], 0, 0, 1.2)

end;


