simParameters.TrainRatio      = 0.85; % Define the ratio of training data relative to validation and test data

simParameters.Scenario        = "InF-DH"; % "InF-SL", "InF-DL", "InF-SH", "InF-DH", "InF-HH"
simParameters.HallSize        = [120 60 10]; % Dimensions of hall for InF scenarios: [length width height] in meters
simParameters.ClutterSize     = 2; % Clutter size (m)
simParameters.ClutterHeight   = 6; % Clutter height (m)
simParameters.ClutterDensity  = 0.6; % Clutter density, between 0 and 1

simParameters.BSSeparation    = [20 20]; 
simParameters.BSAntennaHeight = 8;
simParameters.BSNoiseFigure   = 5;

simParameters.UEDrop          = "random"; % UE drop type can be either 'random' or 'grid'
simParameters.NumUEs          = 15; % Number of UE positions; applicable if ueDropType is 'random'
simParameters.UESeparation    = [30 30]; % UE separation in x and y axes in meters; applicable if ueDropType is 'grid'
simParameters.UEAntennaHeight = 1.5; % UE antenna height on the z axis in meters

% Set a random number seed for repeatability
simParameters.Seed = 2000;
rng(simParameters.Seed,"twister");

% Configure and visualize the scenario
simParameters = h5GIndoorFactoryScenario(simParameters);