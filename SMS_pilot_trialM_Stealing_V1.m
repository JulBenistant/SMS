function [data] = SMS_pilot_trialM_Stealing_V1(window, cfg, data)
        
    data.Cond = 1; % Indicate for function Stealing_Screen that we are in Monetary Reward
    ntrial = cfg.ntrials;
%% ******************************Computation rank or payoff *************************  
    
    DrawWaitScreen(window,cfg);
    % Computation of rank according to algorithm/score
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
        text_period = sprintf('Période n°%d',...
            nb);
        First_Payoff = cfg.Table_payoff(data.Calc(size(data.Calc,1),nb));
        %**creation text for first feedback**
        text_ownpayoff_fb1 = sprintf('Pour le problème sélectionné vous avez gagnez %d euros',...
            First_Payoff);
        % First feedback
        DrawNoKey(window,cfg,text_ownpayoff_fb1,3,40,text_period);
    
        % ISI (! Text and not a fixing cross and no precise duration)
%         FixationCross(window,cfg);
        
        if data.Calc(size(data.Calc,1),nb) == 1
            text_NoStl = {'Vous avez gagnez le montant maxium pour cette période'};
            DrawNoKey1(window,cfg,text_NoStl{1},3);
            data.Mon(1,nb) = cfg.Table_payoff(1);
        else
            %Stealing screen
            data = Stealing_Screen(window, cfg, data, nb, First_Payoff);
            
            % ISI (! Text and not a fixing cross and no precise duration)
%             FixationCross(window,cfg);

            %**creation text for second feedback**
            text_ownpayoff_fb2 = sprintf('Vous avez gagnez, pour cette période, %d euros',...
                data.Mon(1,nb));

            % Second feedback
            DrawNoKey(window,cfg,text_ownpayoff_fb2,4,40,text_period);
        end
        % Write in data.Mon the primary payoff (before stealing decision)
        data.Mon(4,nb)= First_Payoff;
        % Inter-round wait screen (! Text and not a fixing cross)
        FixationCross(window,cfg);
        WaitSecs(2);
    
    end
    %% Trial selection
    
    data.selec_trial_Mon = randi([1 ntrial],1);
    data.payoff_final_Mon = data.Mon(1,data.selec_trial_Mon);
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
