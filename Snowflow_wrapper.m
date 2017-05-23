% Snowflow wrapper to run several modeling instances at a time and save
% them

precip_coefficient = 1.4;

Snowflow_model_driver('CH_Palacios', 'RCP85', [1989 2015], 1,1)
Snowflow_model_driver('CH_Damas', 'RCP85', [1989 2015], 1,1)
Snowflow_model_driver('CH_San_Andres', 'RCP85', [1989 2015], 1,0)
Snowflow_model_driver('CH_Portillo', 'RCP85', [1989 2015], 1,1)
Snowflow_model_driver('CH_Azufre', 'RCP85', [1989 2015], 1, 1)

precip_coefficient = 1.1;

Snowflow_model_driver('Tinguiririca_Bajo_Briones', 'test', [1989 2015],1,1)
Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'test', [1989 2015],1,1)

Snowflow_model_driver('Pangal_en_Pangal', 'test', [1989 2015],1,1)
Snowflow_model_driver('Cachapoal_Bajo_Cortaderal', 'test', [1989 2015],1,1)
Snowflow_model_driver('Lenas_Antes_Cachapoal', 'test', [1989 2015],1,1)
Snowflow_model_driver('Claro_Nieves', 'test', [1989 2015],1,1)
Snowflow_model_driver('Cortaderal_Antes_Cachapoal', 'test', [1989 2015],1,1)

%% Historical scenario

for m = [2 3 18];
    Snowflow_model_driver('Tinguiririca_Bajo_Briones','historical', ['RCP85_model_' num2str(m)], [1989 2015],0 ,0)
    Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'historical', ['RCP85_model_' num2str(m)], [1989 2015],0,0)
    
    Snowflow_model_driver('CH_Palacios', 'historical', ['RCP85_model_' num2str(m)], [1989 2015], 0, 0)
    Snowflow_model_driver('CH_Damas', 'historical', ['RCP85_model_' num2str(m)], [1989 2015], 0, 0)
    Snowflow_model_driver('CH_San_Andres', 'historical', ['RCP85_model_' num2str(m)], [1989 2015], 0, 0)
    Snowflow_model_driver('CH_Portillo', 'historical', ['RCP85_model_' num2str(m)], [1989 2015], 0 ,0 )
    Snowflow_model_driver('CH_Azufre', 'historical', ['RCP85_model_' num2str(m)], [1989 2015], 0, 0)
end;

%% RCP85 scenarios

for m = [2 3 18];
    Snowflow_model_driver('Tinguiririca_Bajo_Briones','future', ['RCP85_fut_model_' num2str(m)], [2016 2049],0 ,0)
    Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'future', ['RCP85_fut_model_' num2str(m)], [2016 2049],0,0)
    
    Snowflow_model_driver('CH_Palacios', 'future', ['RCP85_fut_model_' num2str(m)], [2016 2049], 0, 0)
    Snowflow_model_driver('CH_Damas', 'future', ['RCP85_fut_model_' num2str(m)], [2016 2049], 0, 0)
    Snowflow_model_driver('CH_San_Andres', 'future', ['RCP85_fut_model_' num2str(m)], [2016 2049], 0, 0)
    Snowflow_model_driver('CH_Portillo', 'future', ['RCP85_fut_model_' num2str(m)], [2016 2049], 0 ,0 )
    Snowflow_model_driver('CH_Azufre', 'future', ['RCP85_fut_model_' num2str(m)], [2016 2049], 0, 0)
end;


