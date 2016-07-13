function [datax2] = SMS_run_trial_social_V1Beta(window, data, sc, parameters, trial)

    timeout_square = data.parameters.task.timeout_square;
    timeout_stealing = data.parameters.task.timeout_stealing;
    score_ratio = data.parameters.task.score_ratio;
    
    duration_frame = parameters.timing.stim.duration_frame;
    
%% ******************************Real effort*************************
       
    time_start_cross = GetSecs;
    frame_start_cross = round((time_start_cross)/ sc.ifi);

    while(((round(GetSecs/sc.ifi))-frame_start_cross) < duration_frame(trial,1))
        % Draw the fixation cross in white, c.f function FixationCross
        FixationCross(window, sc);
    end
    % Creating the square
    Square(window, sc);
    time_start_square = GetSecs;
    
    Response = 0;
    while ((GetSecs - time_start_square) < timeout_square)
        [Press,time_press, keyCode] = KbCheck;
        Response = Press + 1;
        if keyCode(KbName('return')) && Response == 2
            time_press_square = time_press;
            FixationCross(window, sc, [255,0,0]);
        end
    end 
%         [~,k] = WaitAnyPress(KbName('return'));
%         if k(1,13) == 1
%             time_stop_square = GetSecs;
%             FixationCross(window, sc, [255,0,0]);
%         end
    %Transfo rt into rt rounded  
    rt_raw = (time_press_square - time_start_square) * score_ratio;
    rt_rounded = round(rt_raw,2);
            
    if rt_rounded<=2 %Security if rt if sup to 2 sec because the fction_score matrix goes to 2 sec max hereafter score =0
        
        [~,column_fction_score] = ismembertol(rt_rounded,data.fction_score(1,:),0.001); % Get column corresponding to the rt_rounded
        score = data.fction_score(2,column_fction_score); % Copy-paste from fction_score to Subj matrix
        
    else
        score = 0;
    end
            
%     WaitSecs(1); %Interval between end of real effort and first feedback
            
%% ****************************** First feedback*************************
    

    [total_ranking, rank, Payoff_REffort] = ranking(score,data,trial);

    %**creation text for first feedback**
    text_ownpayoff_fb1 = sprintf('You''re ranked %i and you earned %2.f euros',rank,Payoff_REffort);
    % First feedback
    DrawNoKey(window,sc,text_ownpayoff_fb1,2);
                
%% ***************************Decision's screen*************************
            
if rank == 1
    % Screen when subject is first with no stealing possible
    text_decision_when_first = {'You''re already the first, \n thus you cannot take points from any other participant'};
    DrawNoKey(window,sc,text_decision_when_first{1},2,30);
    rt_decision = 0;
    decision2steal = 0;
    
else % Just stealing from the first
    text_stealing_1 = {'You will be ranked as first in this trial'};
    text_stealing_2 = {' and you will earn nothing'};
    text_stealing_3 = {'If you decide to take some points from the first player, press Enter:'};
    text_stealing_4 = {'If you dont want to take the points, please wait and press no button'};
    
    [rt_decision,decision2steal] = DecisionScreen(window,sc,([text_stealing_3{1},...
    data.text.jump_line{1}, data.text.jump_line{1}, text_stealing_1{1},...
    text_stealing_2{1}, data.text.jump_line{1},text_stealing_4{1}]),30,timeout_stealing);
end
         
    WaitSecs(1) %isi between end of DM (whatever the output) second fb.
    
if rank == 1 || decision2steal == 0
    Final_rank = rank;
    text_ownpayoff_fb2_nthg = sprintf('You''re ranked %i on 5 and you earned %2.f euros',Final_rank,Payoff_REffort);
    Final_Payoff_Stl = Payoff_REffort;
else
    Final_rank = 1;
    text_ownpayoff_fb2_stl = sprintf('You''re ranked %i on 5 and you earned %2.f euros',Final_rank,Payoff_REffort);
    Final_Payoff_Stl = Payoff_REffort;
end

%% ***************************Feedback 2********************************

if rank == 1 || decision2steal == 0
    % Second feedback if no stealing or first one
    DrawNoKey(window,sc,text_ownpayoff_fb2_nthg,2,30);   
else
    % Second feeback after stealing
    DrawNoKey(window,sc,text_ownpayoff_fb2_stl,2,30);
end

%% ***************************Save table format********************************

datax2 = table(time_start_square,time_press_square,rt_raw,rt_rounded,score,...
    rank,Final_rank,rt_decision,decision2steal,Final_Payoff_Stl);
end

function [total_ranking, rank, Payoff_REffort] = ranking(score,data,trial)

    % total_ranking creates a table with, in  the first row the rank, 
    % the second the score and the last the payoff
    total_score = [score, data.run.trial(trial).score_oth];
    total_score_indexed = sort(total_score);
    [data.parameters.task.rank_mat, total_ranking] = sort(total_score_indexed);
    total_ranking = [total_ranking;fliplr(data.parameters.task.rank_mat)];
    total_ranking = [total_ranking;data.parameters.task.Table_payoff];
    
    %**Part to exctract subject 1's payoff**
    [~,rank] = ismembertol(score,total_ranking(2,:),0.001);
    Payoff_REffort = total_ranking(3,rank);
end

function DrawNoKey(window, sc, text, duration, fontsize)
    if nargin <5
        fontsize = 40;
    end
        Screen('TextSize', window, fontsize);
        DrawFormattedText(window,text,'center','center',sc.white);
        Screen('Flip', window);
        WaitSecs(duration);
end

function [rt_decision,decision2steal] = DecisionScreen(window,sc,text,fontsize,timeout_stealing)
    
    decision2steal = 0;
    if nargin <5
        fontsize = 40;
    end
    Screen('TextSize', window, fontsize);
    DrawFormattedText(window,text,'center','center',sc.white);
    Screen('Flip', window);
    time_start_decision = GetSecs;
    decision2steal = 0;
    rt_decision =0;
    
    Response = 0;
    while ((GetSecs - time_start_decision) < timeout_stealing)
        [Press2,time_press2, keyCode2] = KbCheck;
        Response = Press2 + 1;
        if keyCode2(KbName('return')) && Response == 2
            decision2steal = 1;
            time_decision = time_press2;
            FixationCross(window, sc, [255,0,0]);
            rt_decision = time_decision- time_start_decision;
            WaitSecs(timeout_stealing - (time_decision- time_start_decision));
        end
    end   
end
