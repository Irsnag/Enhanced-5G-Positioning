function simParameters = h5GIndoorFactoryScenario(simParameters,opts)
%h5GIndoorFactoryScenario Generate the InF scenario
%   simParameters = h5GIndoorFactoryScenario(simParameters,varargin)
%   returns the set of TR 38.901-defined environment parameters
%   (SIMPARAMETERS) that will be used in the rest of the simulations by
%   extending the user-defined parameters (SIMPARAMETERS). The environment
%   will be visualized if PLOTENV is set to true.

%   Copyright 2023-2024 The MathWorks, Inc.

% Check if the environment plotting flag is provided by the user
arguments
    simParameters
    opts.plotEnv {mustBeNonnegative} = true;
end

% The Indoor Factory with Dense Clutter and High Base Station (InF-DH). The
% simulation assumptions are based on the RAN1 #109-e meeting and have been
% modified from TR 38.857 Table 6.1-1.
simParameters.ScenarioExtents = [0 0 simParameters.HallSize(1) simParameters.HallSize(2)];

% Base station (BS) parameters
simParameters.PowerBSs = 24; % dBm
deltaBS = simParameters.BSSeparation; % Baseline BS spacing
xGridBS = deltaBS(1)/2:deltaBS(1):simParameters.HallSize(1)-deltaBS(1)/2;
yGridBS = deltaBS(2)/2:deltaBS(2):simParameters.HallSize(2)-deltaBS(2)/2;
[xBS,yBS] = meshgrid(xGridBS,yGridBS);
simParameters.Pos2BS = [xBS(:) yBS(:)]; % 2D BS position grid
simParameters.Pos3BS = [simParameters.Pos2BS...
  simParameters.BSAntennaHeight*ones(size(simParameters.Pos2BS,1),1)]; % 3D BS position grid

simParameters.NumBSs = size(simParameters.Pos2BS,1);

% Only Frequency Range 1 (FR1) for UL SLS based channel estimation is
% supported
simParameters.FrequencyRange  = 'FR1';
simParameters.CenterFrequency = 3.5e9; % in Hz
txArray = struct();
txArray.Size = [4 4 2 1 1]; % [M N P Mg Ng]
txArray.ElementSpacing = [0.5 0.5 0 0]; % [dV dH dgV dgH]
txArray.PolarizationAngles = [45 -45]; % in degrees
txArray.Element = 'isotropic'; % 1-sector
txArray.PolarizationModel = 'Model-2';
simParameters.TransmitAntennaArray = txArray;

% User equipment (UE) parameters
simParameters.NumReceiveAntennas = 1; % Number of UE transmit antennas
simParameters.TxPowerUE = 23; % in dBm
simParameters.MobilityUE = 3; % km/h

% Generate the UE position grid
simParameters.Pos2UE = []; % 2D UE position grid
simParameters.Pos3UE = []; % 3D UE position grid
ueDrop = simParameters.UEDrop;
dUE = simParameters.UESeparation;
numUEs = simParameters.NumUEs;
if strcmp(ueDrop,'grid')
    if all(simParameters.BSSeparation == simParameters.UESeparation) && simParameters.BSAntennaHeight == simParameters.UEAntennaHeight
        warning("In a grid UE distribution, the distance between the BS and UE cannot be equal to the antenna height.")
    end
    xGridUE = (dUE(1)/2):dUE(1):simParameters.HallSize(1)-(dUE(1)/2); % in meters
    yGridUE = (dUE(2)/2):dUE(2):simParameters.HallSize(2)-(dUE(2)/2); % in meters
    [xUE,yUE] = meshgrid(xGridUE,yGridUE);
    simParameters.Pos2UE = [xUE(:) yUE(:)];
    simParameters.Pos3UE = [simParameters.Pos2UE simParameters.UEAntennaHeight*ones(size(simParameters.Pos2UE,1),1)];
elseif strcmp(ueDrop,'random') % UEs are distributed within the whole area
    for i = 1:numUEs
      uePos = [(simParameters.HallSize(1)-2*eps)*rand(1,1)+eps (simParameters.HallSize(2)-2*eps)*rand(1,1)+eps];
      simParameters.Pos2UE = cat(1,simParameters.Pos2UE,uePos);
      simParameters.Pos3UE = cat(1,simParameters.Pos3UE,[uePos simParameters.UEAntennaHeight]);
    end
else
    error("Unknown UE drop type.")
end
simParameters.NumUEs = size(simParameters.Pos3UE,1);

% FR1
simParameters.NodeSiz = [simParameters.NumBSs 1 simParameters.NumUEs]; % Single sector

if ~strcmpi(simParameters.Scenario,'InF-HH') && (simParameters.UEAntennaHeight > simParameters.ClutterHeight)
    warning('UE antenna is higher than the clutter, which is inconsistent with LOS probability equations in TR 38.901. Limiting UE antenna height to clutter height.')
    simParameters.UEAntennaHeight = simParameters.ClutterHeight;
end

if opts.plotEnv && numUEs < 2000
    % Plot scenario geometry. Plotting will occur if the number of UEs is
    % less than 2000 for computational efficiency
    f = figure;
    ax = axes(f);
    colorLine = 'k';
    widthLine = 1.5;
  
    % Draw the floor
    plot3(ax,[0 simParameters.HallSize(1)],[0 0],[0 0],colorLine,'LineWidth',widthLine)
    hold on
    plot3(ax,[0 simParameters.HallSize(1)],[simParameters.HallSize(2) simParameters.HallSize(2)],[0 0],colorLine,'LineWidth',widthLine)
    plot3(ax,[0 0],[0 simParameters.HallSize(2)],[0 0],colorLine)
    plot3(ax,[simParameters.HallSize(1) simParameters.HallSize(1)],[0 simParameters.HallSize(2)],[0 0],colorLine,'LineWidth',widthLine)
  
    % Draw the ceiling
    plot3(ax,[0 simParameters.HallSize(1)],[0 0],[simParameters.HallSize(3) simParameters.HallSize(3)],...
      colorLine,'LineWidth',widthLine)
    plot3(ax,[0 simParameters.HallSize(1)],[simParameters.HallSize(2) simParameters.HallSize(2)],[simParameters.HallSize(3) simParameters.HallSize(3)],...
      colorLine,'LineWidth',widthLine)
    plot3(ax,[0 0],[0 simParameters.HallSize(2)],[simParameters.HallSize(3) simParameters.HallSize(3)],...
      colorLine,'LineWidth',widthLine)
    plot3(ax,[simParameters.HallSize(1) simParameters.HallSize(1)],[0 simParameters.HallSize(2)],[simParameters.HallSize(3) simParameters.HallSize(3)],...
      colorLine,'LineWidth',widthLine)
    
    % Draw the side walls
    plot3(ax,[0 0],[0 0],[0 simParameters.HallSize(3)],colorLine,'LineWidth',widthLine)
    plot3(ax,[simParameters.HallSize(1) simParameters.HallSize(1)],[0 0],[0 simParameters.HallSize(3)],colorLine,'LineWidth',widthLine)
    plot3(ax,[0 0],[simParameters.HallSize(2) simParameters.HallSize(2)],[0 simParameters.HallSize(3)],colorLine,'LineWidth',widthLine)
    plot3(ax,[simParameters.HallSize(1) simParameters.HallSize(1)],[simParameters.HallSize(2) simParameters.HallSize(2)],[0 simParameters.HallSize(3)],...
      colorLine,'LineWidth',widthLine)
    scatter3(ax,simParameters.Pos3BS(:,1),simParameters.Pos3BS(:,2),simParameters.Pos3BS(:,3),...
      'b^','LineWidth',1)
    scatter3(ax,simParameters.Pos3UE(:,1),simParameters.Pos3UE(:,2),simParameters.Pos3UE(:,3),...
      'rx','LineWidth',1)
  
    hold off
    xlabel(ax,'Length (m)')
    ylabel(ax,'Width (m)')
    zlabel(ax,'Height (m)')
    axis(ax,"equal")
    title(ax,['Density: ',num2str(round(length(simParameters.Pos3UE)/(simParameters.HallSize(1)*simParameters.HallSize(2)),4)),' UEs/m$^2$'],'Interpreter','latex')
    legend(ax,'','','','','','','','','','','','','TRPs','UE Positions','Location','best')
    view([25.20 30.05])
    drawnow
end
end