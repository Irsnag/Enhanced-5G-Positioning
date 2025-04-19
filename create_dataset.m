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

% Number of different seeds
numSeeds = 3;

% Initialize arrays to hold all the data
allTrainInputs = [];
allTrainLabels = [];

allValInputs = [];
allValLabels = [];

for i = 1:numSeeds
    fprintf("Processing seed %d...\n", i);

    % Set new seed and regenerate scenario
    simParameters.Seed = i;
    rng(simParameters.Seed, "twister");
    
    simParameters = h5GIndoorFactoryScenario(simParameters);
    channels = h38901ChannelSetup(simParameters);
    
    % Generate training and validation datastores
    [dsTrain, dsValidate, ~, ~] = channels2ImageDataset(simParameters, channels);
    
    % --- Accumulate TRAIN data
    reset(dsTrain);
    while hasdata(dsTrain)
        data = read(dsTrain);
        allTrainInputs = cat(4, allTrainInputs, data{1});   % [32 x 32 x 18 x N]
        allTrainLabels = [allTrainLabels; data{2}];         % [N x 3]
    end

    % --- Accumulate VALIDATION data
    reset(dsValidate);
    while hasdata(dsValidate)
        data = read(dsValidate);
        allValInputs = cat(4, allValInputs, data{1});
        allValLabels = [allValLabels; data{2}];
    end
end

% Create ArrayDatastore for inputs and labels
adsTrainX = arrayDatastore(allTrainInputs, 'IterationDimension', 4);
adsTrainY = arrayDatastore(allTrainLabels);

adsValX = arrayDatastore(allValInputs, 'IterationDimension', 4);
adsValY = arrayDatastore(allValLabels);

% Combine into one paired datastore
dataTrain = combine(adsTrainX, adsTrainY);
dataValidate = combine(adsValX, adsValY);