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

%% RCP85 scenarios

Snowflow_model_driver('Tinguiririca_Bajo_Briones', 'RCP85', [1989 2015],0 ,0)
Snowflow_model_driver('Tinguiririca_Bajo_Azufre', 'RCP85', [1989 2015],0,0)

Snowflow_model_driver('CH_Palacios', 'RCP85', [1989 2015], 0, 0)
Snowflow_model_driver('CH_Damas', 'RCP85', [1989 2015], 0, 0)
Snowflow_model_driver('CH_San_Andres', 'RCP85', [1989 2015], 0, 0)
Snowflow_model_driver('CH_Portillo', 'RCP85', [1989 2015], 0 ,0 )
Snowflow_model_driver('CH_Azufre', 'RCP85', [1989 2015], 0, 0)

%% RCP45 scenarios

Snowflow_model_driver('CH_Palacios', 'RCP45', [1989 2015], 0, 0)
Snowflow_model_driver('CH_Damas', 'RCP45', [1989 2015], 0, 0)
Snowflow_model_driver('CH_San_Andres', 'RCP45', [1989 2015], 0, 0)
Snowflow_model_driver('CH_Portillo', 'RCP45', [1989 2015], 0 ,0 )
Snowflow_model_driver('CH_Azufre', 'RCP45', [1989 2015], 0, 0)
