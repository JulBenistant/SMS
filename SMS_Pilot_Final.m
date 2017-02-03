
clear all;
close all;

%% -- Prepare functions in memory
Screen('Screens');
KbName('UnifyKeyNames') %-- Unified key names across platforms

%% Participant Code
data.time.start = GetSecs;
data.participant.code=input('Participant code (leave empty for testing): ', 's');
data.datafile = datestr(data.time.start,30);

%% -- Task parameters
cfg.period_calc = 50; % Nb repetition RE task
cfg.ntrials = 50; % Nb repetition Stl task
cfg.rank_mat = [1,2,3,4,5]; % Matrice contenant les rangs/
cfg.Table_payoff = [20,16,12,8,4];
cfg.jump_line = {'\n'};
cfg.timeout_calculus = 4;
cfg.timeout_stealing = 7;
cfg.social_fb{1,1} = ' premier';
cfg.social_fb{1,2} = ' deuxième';
cfg.social_fb{1,3} = ' troisième';
cfg.social_fb{1,4} = ' quatrième';
cfg.social_fb{1,5} = ' dernier';
skipRE = input('Skip RE (1 or 0)?'); 
skipMon = input('Skip Mon (1 or 0)?');
skipSoc = input('Skip Soc (1 or 0)?');
cfg.mult = input('Mult ttt (1 or 0)?');
order = input('order (1 or 0)?');

%% -- Psychtoolbox Graphics

ListenChar(2);              %-- "Ecouter le clavier ON" (0 = stop)
priorityLevel = 2;          %-- Ideally : priorityLevel = MaxPriority(data.frame.ptr,'KbCheck');
Priority(priorityLevel);
HideCursor;                 %-- Hide mouse cursor

% Display PTB à changer avec ASFX ??

PsychDefaultSetup(2); % Here we call some default settings for setting up Psychtoolbox
screens = Screen('Screens'); % Get the screen numbers
screenNumber = max(screens); % Draw to the external screen if avaliable

% Define black and white
cfg.white = WhiteIndex(screenNumber);
cfg.black = BlackIndex(screenNumber);

% Screen('Preference', 'SkipSyncTests', 2);
% [window, cfg.windowRect] = PsychImaging('OpenWindow', screenNumber, cfg.black,[200 200  600 600]); % Small size window for test
[window, cfg.windowRect] = PsychImaging('OpenWindow', screenNumber, cfg.black); % Open an on screen window
[cfg.screenXpixels, cfg.screenYpixels] = Screen('WindowSize', window); % Get the size of the on screen window
[cfg.centerX, cfg.centerY] = WindowCenter(window); % Get screen center
cfg.ifi = Screen('GetFlipInterval', window); % Query the frame duration
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
KbName('UnifyKeyNames');

%% -- Beginning of run : time
    data.t0 = GetSecs;
    % Initiate data
    data.Calc = [];
    data.Mon = [];
    data.Soc = [];
%% ***************** Calculus Real-Effort ****************

if skipRE == 0
    %% -- Get ready
    write_text(window,'.',cfg.white);                   
    write_text(window,'Nous allons démarrer...',cfg.white);
    WaitSecs(2);
    intro_text_RE={'Les trois premiers problèmes ne comptent pas \n\n Appuyez sur Entrée pour continuer'};       
    write_text(window,intro_text_RE{1},cfg.white);

    [data.Calc] = calculusRE(window, cfg);
    save('Calc.mat','data','cfg','-v7.3');
else
    score = randi([0 1000],cfg.ntrials,1)';
    juste = randi([0 1],cfg.ntrials,1)';
    disp_real = randi([0 1],cfg.ntrials,1)';
    sum1 = [randi([1 100],cfg.ntrials,1),randi([1 100],cfg.ntrials,1),randi([1 100],cfg.ntrials,1)];
    rt_answer = rand(cfg.ntrials,1)';
    data.Calc = [score;juste;disp_real];
    data.Calc(4:6,:)=sum1';
    data.Calc(7,:) = rt_answer;
end
    write_text(window,'.',cfg.white);                   
    write_text(window,'Nous allons demarrer...',cfg.white);
    WaitSecs(3);

%% ***************** Stealing trials ****************

if order == 1 % Order == 1 if monetary cond come first
    if skipMon == 0
        run_text_Mon = {'Première sous-partie \n Appuyez sur ENTREE pour commencer...'};
        write_text(window,run_text_Mon{1},cfg.white);

        [data] = SMS_pilot_trialM_Stealing_V1(window, cfg, data);
        save('first.mat','data','cfg','-v7.3');
    end
    
    % Social Cond
    if skipSoc == 0
        run_text_Soc = {'Seconde sous-partie \n Appuyez sur ENTREE pour commencer...'};
        write_text(window,run_text_Soc{1},cfg.white);

        [data] = SMS_pilot_trialS_Stealing_V1(window, cfg, data);
        save('second.mat','data','cfg','-v7.3');
    end
    
elseif order == 0 % Order == 0 if social cond come first
    if skipSoc == 0
        run_text_Soc = {'Première sous-partie \n Appuyez sur ENTREE pour commencer...'};
        write_text(window,run_text_Soc{1},cfg.white);

        [data] = SMS_pilot_trialS_Stealing_V1(window, cfg, data);
        save('first.mat','data','cfg','-v7.3');
    end
    
    if skipMon == 0
        run_text_Mon = {'Seconde sous-partie \n Appuyez sur ENTREE pour commencer...'};
        write_text(window,run_text_Mon{1},cfg.white);

        [data] = SMS_pilot_trialM_Stealing_V1(window, cfg, data);
        save('second.mat','data','cfg','-v7.3');
    end
end

%% ***************** Final Feedback *****************

final_fb1 = sprintf('Pour la première partie la période n°%d a été sélectionnée \n Vous avez gagné %0.1f \n',...
    data.selec_trial_Mon,data.payoff_final_Mon);
final_fb2 = sprintf('Pour la première partie la période n°%d a été sélectionnée \n Vous êtes classé numéro %0.1f sur 5 dans la seconde partie',...
    data.selec_trial_Soc,data.payoff_final_Soc);

write_text(window,[final_fb1,final_fb2],cfg.white);
data.time.end = GetSecs;
%% *********End*******

save(data.datafile,'data','cfg');
% Wait for a key press
KbStrokeWait;
% Clear the screen
clean_exit();
sca;





