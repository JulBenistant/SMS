function [k] = write_text(window, text, color, keys)
Screen('TextSize', window, 40);

if nargin < 3
    color = white;
end

Screen('Flip', window);
DrawFormattedText(window, text,'center','center',color);
Screen('Flip', window);

if nargin<4
    [rt,k]=WaitAnyPress(KbName('return'));
else
    [rt,k]=WaitAnyPress(keys);
end
Screen('Flip',window);
k=find(k);
