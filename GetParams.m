function [data]=GetParams(data,sc,cond) % cond = 'training' / 'monetary' / 'social'


data.parameters.task.timeout_square = 4;
data.parameters.task.timeout_stealing = 5;

if strcmp(cond , 'training')

elseif strcmp(cond , 'monetary') 
    
    params.timing.stim.duration_ms = randi([300,1500],data.parameters.task.ntrials,1); % Randomize how long last the fixation cross
    for ii = 1 : data.parameters.task.ntrials
        params.timing.stim.duration_frame(ii,1) = round((params.timing.stim.duration_ms(ii,1)/1000) / sc.ifi);  % Transformation from ms to frame
    end
    params.cost_ratio = 0.05;

elseif strcmp(cond , 'social')   
   
    params.timing.stim.duration_ms = randi([300,1500],data.parameters.task.ntrials,1); % Randomize how long last the fixation cross
    for ii = 1 : data.parameters.task.ntrials
        params.timing.stim.duration_frame(ii,1) = round((params.timing.stim.duration_ms(ii,1)/1000) / sc.ifi);  % Transformation from ms to frame
    end
    
end    
        
eval(['data.parameters.task.',cond,' = params ;']);
end