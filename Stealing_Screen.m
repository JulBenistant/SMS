function [data] = Stealing_Screen(window, cfg, data, ntrial,First_Payoff)

    if data.Cond == 1 % Monetary
        
        if cfg.mult == 1 && data.Calc(size(data.Calc,1),ntrial) ~= 2
            
            Last_Payoff = cfg.Table_payoff(data.Mult(1,ntrial));
            text_Stl1 = {'Veuillez choisir une des deux actions'};
            text_Stl2 = ['Action 1 \n ', sprintf('Vous gagnez %1.f euros de plus (%1.f en tout)',Last_Payoff-First_Payoff,Last_Payoff), '\n ',...
                sprintf('Le joueur A perd %1.f euros (il gagne donc %1.f)',Last_Payoff-First_Payoff,Last_Payoff)];
            text_Stl3 = ['Action 2 \n ', sprintf('Vous gagnez %1.f euros',First_Payoff), '\n ',...
                sprintf('Le joueur A ne perd rien (il gagne donc %1.f)',Last_Payoff)];
        
        else
                
            text_Stl1 = {'Veuillez choisir une des deux actions'};
            text_Stl2 = ['Action 1 \n ', sprintf('Vous gagnez %1.f euros de plus (%1.f en tout)',20-First_Payoff,20), '\n ',...
                sprintf('Le joueur A perd %1.f euros (il gagne donc %1.f)',20-First_Payoff,First_Payoff)];
            text_Stl3 = ['Action 2 \n ', sprintf('Vous gagnez %1.f euros',First_Payoff), '\n ',...
                sprintf('Le joueur A ne perd rien (il gagne donc %1.f)',20)];
        
        end
        
        DrawFormattedText(window,text_Stl1{1},'center','center',cfg.white);
        DrawFormattedText(window,text_Stl2,cfg.centerX.*0.20,cfg.centerY+200,cfg.white);
        DrawFormattedText(window,text_Stl3,cfg.centerX.*1.15,cfg.centerY+200,cfg.white);
        Screen('TextSize', window, 60);
        Screen('Flip', window);

        time_start_stl = GetSecs;
        time_press_arrow = 0;
        Stealing = 0;
        while ((GetSecs - time_start_stl) < cfg.timeout_stealing)
           [Press,time_press, keyCode] = KbCheck;
           Response = Press + 1;
           if Response == 2 && keyCode(1,37)==1
               Stealing = 1;
               time_press_arrow = time_press;
               FixationCross(window, cfg, [255,0,0]);
           elseif Response == 2 && keyCode(1,39) == 1
               Stealing = 0;
               time_press_arrow = time_press;
               FixationCross(window, cfg, [255,0,0]);
           end
        end

        %Compute new payoff/rank

        if Stealing == 1 && cfg.mult == 1 && data.Calc(size(data.Calc,1),ntrial) ~= 2
            data.Mon(1,ntrial) = Last_Payoff;           
        elseif Stealing == 1
            data.Mon(1,ntrial) = cfg.Table_payoff(1);
        else
            data.Mon(1,ntrial) = cfg.Table_payoff(data.Calc(size(data.Calc,1),ntrial)); 
        end

        data.Mon(2,ntrial) = time_press_arrow-time_start_stl;
        data.Mon(3,ntrial) = Stealing;
        
    elseif data.Cond == 0 % Social
        
        if cfg.mult == 1 && data.Calc(size(data.Calc,1),ntrial) ~= 2
            Last_Payoff = data.Mult(1,ntrial);
            text_Stl1S = {'Veuillez choisir une des deux actions'};
            text_Stl2S = sprintf('Action 1 \n Vous etes classé n°%1.f \n Le joueur A est classé n°%1.f',Last_Payoff,First_Payoff);
            text_Stl3S = sprintf('Action 1 \n Vous etes classé n°%1.f \n Le joueur A est classé n°%1.f',First_Payoff,Last_Payoff);           
        else
            text_Stl1S = {'Veuillez choisir une des deux actions'};
            text_Stl2S = ['Action 1 \n Vous etes classé n°1 \n',...
                sprintf('Le joueur A est classé n°%1.f',First_Payoff)];
            text_Stl3S = ['Action 1 \n', sprintf('Vous etes classé n°%1.f \n',First_Payoff),...
                'Le joueur A est classé n°1'];
        end  

        DrawFormattedText(window,text_Stl1S{1},'center','center',cfg.white);
        DrawFormattedText(window,text_Stl2S,cfg.centerX.*0.20,cfg.centerY+200,cfg.white);
        DrawFormattedText(window,text_Stl3S,cfg.centerX.*1.15,cfg.centerY+200,cfg.white);
        Screen('TextSize', window, 60);
        Screen('Flip', window);

        time_start_stl = GetSecs;
        time_press_arrow = 0;
        Stealing = 1;
        while ((GetSecs - time_start_stl) < cfg.timeout_stealing)
           [Press,time_press, keyCode] = KbCheck;
           Response = Press + 1;
           if Response == 2 && keyCode(1,37)==1
               Stealing = 1;
               time_press_arrow = time_press;
               FixationCross(window, cfg, [255,0,0]);
           elseif Response == 2 && keyCode(1,39) == 1
               Stealing = 0;
               time_press_arrow = time_press;
               FixationCross(window, cfg, [255,0,0]);
           end
        end

        %Compute new payoff/rank

        if Stealing == 1 && cfg.mult == 1 && data.Calc(size(data.Calc,1),ntrial) ~= 2
            data.Soc(1,ntrial) = Last_Payoff;
        elseif Stealing == 1
            data.Soc(1,ntrial) = cfg.rank_mat(1);
        else
            data.Soc(1,ntrial) = cfg.rank_mat(data.Calc(size(data.Calc,1),ntrial)); 
        end

        data.Soc(2,ntrial) = time_press_arrow-time_start_stl;
        data.Soc(3,ntrial) = Stealing;  
    end
end