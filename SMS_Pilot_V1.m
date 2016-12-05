
clear all;
close all;

%% -- Prepare functions in memory
Screen('Screens');
KbName('UnifyKeyNames') %-- Unified key names across platforms

%% -- Task parameters
cfg.period_calc = 5; % Nb repetition RE task
cfg.ntrials = 5; % Nb repetition Stl task
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
    write_text(window,'Nous allons demarrer...',cfg.white);
    WaitSecs(2);
    intro_text_RE={'Les trois premiers problèmes ne comptent pas \n\n Appuyez sur Entrée pour continuer'};       
    write_text(window,intro_text_RE{1},cfg.white);

    [data.Calc] = calculusRE(window, cfg);
else
    score = [ 5 3 2 1 2];
    juste = [1 1 1 1 1];
    disp_real = [0 0 0 0 0];
    sum1 = [ 45 25 32; 12 58 63; 12 36 85; 47 8 53; 5 6 6];
    rt_answer = [ 1 1 1 1 1];
    data.Calc = [score;juste;disp_real];
    data.Calc(4:6,:)=sum1';
    data.Calc(7,:) = rt_answer;
end
    write_text(window,'.',cfg.white);                   
    write_text(window,'Nous allons demarrer...',cfg.white);
    WaitSecs(2);
%     intro_text_Stl={'Les deux premières périodes ne comptent pas \n\n Appuyez sur Entrée pour continuer'};       
%     write_text(window,intro_text_Stl{1},cfg.white);


%% ***************** Stealing trials ****************

%% Training %%

% for ii = 1:2
%     
% end

%% Monetary Cond %%

if skipMon == 0
    run_text_Mon = {'Première partie \n Appuyez sur ENTREE pour commencer...'};
    write_text(window,run_text_Mon{1},cfg.white);
    
    [data] = SMS_pilot_trialM_Stealing_V1(window, cfg, data);
end
%% Social Cond

if skipSoc == 0
    run_text_Soc = {'Seconde partie \n Appuyez sur ENTREE pour commencer...'};
    write_text(window,run_text_Soc{1},cfg.white);
        
    [data] = SMS_pilot_trialS_Stealing_V1(window, cfg, data);
end
    

%% ***************** Final Feedback *****************

save('pilot.mat','data');

final_fb1 = sprintf('Pour la première partie vous avez gagné %0.1f \n',data.payoff_final_Mon);
final_fb2 = sprintf('Vous êtes classés numéro %0.1f dans la seconde partie',data.payoff_final_Soc);

write_text(window,[final_fb1,final_fb2],cfg.white);

%% *********End*******
%save('tmp.mat','data');
% Wait for a key press
KbStrokeWait;
% Clear the screen
clean_exit();
sca;





