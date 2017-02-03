function [] = FixationCross(window, sc, color)

if nargin<3
    color = sc.white;
end
[xCenter, yCenter] = RectCenter(sc.windowRect); % Get the centre coordinate of the window
fixCrossDimPix = 40; % Here we set the size of the arms of our fixation cross

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 4; % Set the line width for our fixation cross

Screen('DrawLines', window, allCoords,...
    lineWidthPix, color, [xCenter yCenter], 2);
% Flip to the screen
Screen('Flip', window);

end
