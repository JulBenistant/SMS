function [data] = SMS_pilot_trialS_Stealing_V1(window, cfg, data)
        
    data.Cond = 0; % Indicate for function Stealing_Screen that we are in Social Reward
    rank_mat = cfg.rank_mat;
    ntrial = cfg.ntrials;
    text_ownpayoff_fb = {' sur cinq'};
    
    % Load image
%     Medal(1).IMG = imread('Medaille1.png');Medal(2).IMG = imread('Medaille2.png');
%     Medal(3).IMG = imread('Medaille3.png');Medal(4).IMG = imread('Medaille4.png');
%     Medal(5).IMG = imread('Medaille5.png');
    
    % Coordinate medal
    
    yPos = cfg.centerY - 350;
    xPos = cfg.centerX;
    baseRect = [0 0 200 200];
    cfg.distRects(:,1) = CenterRectOnPointd(baseRect,xPos,yPos);
    
%% ******************************Computation rank or payoff *************************  
    
    DrawWaitScreen(window,cfg);
    % Computation of rank according to algorithm/scoreY
	data = score2rank(data);
    
    %randperm of the column of data.Calc each of them corresponding to a
    %RE trial with an associate rank given by the previous function
    data.Calc = data.Calc(:, randperm(size(data.Calc,2)));
    
        if cfg.mult == 1
            data.Mult = [];a=1;b=1;c=1;
            all_5th = randi([1 4],ntrial/5,1)';
            all_4th = randi([1 3],ntrial/5,1)';
            all_3th = randi([1 2],ntrial/5,1)';
            for ii = 1:ntrial
                if data.Calc(size(data.Calc,1),ii) == 5
                   data.Mult(1,ii) = all_5th(1,a);
                   a = a+1;
                elseif data.Calc(size(data.Calc,1),ii) == 4
                    data.Mult(1,ii) = all_4th(1,b);
                    b = b+1;
                elseif data.Calc(size(data.Calc,1),ii) == 3
                    data.Mult(1,ii) = all_3th(1,c);
                    c=c+1;
                else 
                    data.Mult(1,ii) = 1;
                end
            end
        end
%% ****************************** Feedback*************************
    for nb = 1:ntrial
        
        text_period = sprintf('Période n°%d',nb);
        First_Rank= rank_mat(data.Calc(size(data.Calc,1),nb));
        text_ownpayoff_fb1={'Pour le problème sélectionné vous êtes classé'};
        
        % First feedback
%         ImgNoKey(window,cfg,[text_ownpayoff_fb1{1}, cfg.social_fb{1,First_Rank}, text_ownpayoff_fb{1}],3,...
%             Medal(First_Rank).IMG,cfg);
        DrawNoKey(window,cfg,[text_ownpayoff_fb1{1}, cfg.social_fb{1,First_Rank}, text_ownpayoff_fb{1}],4,40,text_period);
        % ISI (! Text and not a fixing cross and no precise duration)
        FixationCross(window,cfg);
        
        if data.Calc(size(data.Calc,1),nb) == 1
            text_NoStl = {'Vous avez le rang le plus élevé pour cette période'};
            DrawNoKey1(window,cfg,text_NoStl{1},3);
            data.Soc(1,nb) = rank_mat(1);
        else
            %Stealing screen
            data = Stealing_Screen(window, cfg, data, nb,First_Rank);
            
            % ISI (! Text and not a fixing cross and no precise duration)
            FixationCross(window,cfg);

            %**creation text for second feedback**
            text_ownpayoff_fb2 = {'Pour cette période vous êtes classé'};
            
            % Second feedback
            DrawNoKey(window,cfg,[text_ownpayoff_fb2{1}, cfg.social_fb{1,data.Soc(1,nb)}, text_ownpayoff_fb{1}],4,40,text_period);
        end
        % Write in data.Mon the primary payoff (before stealing decision)
        data.Soc(4,nb)= First_Rank;
        % Inter-round wait screen (! Text and not a fixing cross)
        FixationCross(window,cfg);
        WaitSecs(2);
    
    end
    %% Trial selection
    
    data.selec_trial_Soc = randi([1 ntrial],1);
    data.payoff_final_Soc = data.Soc(1,data.selec_trial_Soc);
end


function ImgNoKey(window, sc, text, duration,img,cfg, fontsize)
    if nargin < 7
        fontsize = 40;
    end
        Screen('TextSize', window, fontsize);
        imageTexture = Screen('MakeTexture', window, img);
        Screen('DrawTexture', window, imageTexture, [] ,cfg.distRects);
        DrawFormattedText(window,text,'center','center',sc.white);
        Screen('Flip', window);
        WaitSecs(duration);
end

function DrawNoKey(window, sc, text, duration, fontsize, text_period)
    if nargin < 6
        text_period = {};
    end
    
%     if nargin < 5
%     fontsize = 40;
%     end

        Screen('TextSize', window, fontsize);
        DrawFormattedText(window,text,'center','center',sc.white);
        DrawFormattedText(window,text_period,[],[],sc.white);
        Screen('Flip', window);
        WaitSecs(duration);
end

function DrawNoKey1(window, sc, text, duration, fontsize)
   
    if nargin < 5
    fontsize = 40;
    end
    Screen('TextSize', window, fontsize);
    DrawFormattedText(window,text,'center','center',sc.white);
    Screen('Flip', window);
    WaitSecs(duration);
end
function DrawWaitScreen(window, sc, fontsize)
    if nargin < 3
        fontsize = 40;
    end	
		text = 'Veuillez patienter';
        Screen('TextSize', window, fontsize);
        DrawFormattedText(window,text,'center','center',sc.white);
        Screen('Flip', window);
end
