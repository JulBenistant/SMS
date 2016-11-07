function model_sabotage

clear all;
close all;
%%DATA%%

reward_all(1,1) = 16;reward_all(1,2) = 12;reward_all(1,3) = 8;reward_all(1,4) = 4;
rank(1,1) = 2;rank(1,2) =3 ;rank(1,3) = 4;rank(1,4) = 5;

%%%% n = 10 per conditions

%Creation parameters, alpha first line and beta second line
   % First column Beta = Inv temperaature
   % Second column Alpha
params = [0.85, 0.85, 0.85 ; 0.95,0.8,0.5];
ntrial = 40;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following loop creates 1000 times the same values !!! You have to create some variability in the rewards series in you want to be able to estimate anything %  

for aa = 1: 3 % Loop over parameters couple
    for trial = 1:ntrial  % Loop over trials

     param(aa).reward(trial,1) = reward_all(1,randi([1 4],1,1)); %%%%%%%%%%% select one reward or one rank at random   
     param(aa).reward(trial,2) = 20;                             %%%%%%%%%%% reward when stealing

     param(aa).EU_Mon_NoCost(trial,:) = compute_val_monetary(params(:,aa), param(aa).reward(trial,:));
     [H, param(aa).Proba(trial,:)] = LogLL(params(:,aa),trial,param(aa).EU_Mon_NoCost(trial,:));
     
     R=rand; % Outcome drawn from the proba of the two actions
         if R<param(aa).Proba(trial,1)
             param(aa).outcome(1,trial) =0; % No stealing
         else
             param(aa).outcome(1,trial) =1; % Stealing
         end
    end
end

%% Default mode %%

%a being the payoff no stealing and b with
%(exp(x(2)*x(1)*a));
%exp(x(2)*(x(1)*b)-((1-x(1))*(b-a)));

%denominateur%
%(exp(x(2)*x(1)*a)+exp(x(2)*(x(1)*b)-((1-x(1))*(b-a))));

% D = [16;12;8;4];
% E = [20;20;20;20];

%%Norm model%%

options=optimset('Display','off','MaxIter',10000,'TolX',10^-13,'TolFun',10^-13);

lb = [0;0]; %bound for alpah (not for beta)
ub = [1;100];

% for i = 1: 4
%     r(1,1) = D(i,1);
%     b(1,2) = E(i,1);
% for sim = 1:1000
    y = param(3).outcome;
    r = param(3).reward;
    param_pre_est = params(:,3);
%     for ii = 1:10
        init = rand(2,1);
        [param_post_est(:,sim),likli(1,sim),exit(1,sim)] = ...
            fmincon(@(x) LogLL1(param_pre_est, r,ntrial),init,[],[],[],[],lb,ub,[],options);  % r can be reward or rank
%     end
% end
% end
end

function value = compute_val_monetary(parameter, reward)

value(1,1) =  parameter(2)*reward(1,1);% EU when no stealing
value(1,2) =  parameter(2)*reward(1,1)-((1-parameter(2))*(reward(1,2)-reward(1,1)));% EU when stealing

end

function value = compute_val_rank(parameter, rank)

value(1,1) = parameter(2)*rank(:,1);% EU when no stealing
value(1,2) = (parameter(2)*5)-((1-parameter(2))*(5-rank(:,1)));% EU when stealing

end

function [TotLL, P] = LogLL(parameter, trial, V)

[LogLik, P] = softmax_Home(V, parameter(1));
TotLL = sum(LogLik);

end


function [H, proba] = softmax_Home(V, temperature)
%% compute probabilities

% solve case for which exp(beta*V) cannot be computed
% look for cases where V value exceed 700  =~ 709 which is the max value for which matlab provides an exponnential
betaV = temperature*V;
if max(betaV)>700  || max(betaV)<-700
    betaV = betaV - max(betaV) + 700;  % substract the max value to all values
end

%% compute probabilities
proba(1,1) = exp(betaV(1,1))/sum(exp(betaV)); % Proba No stealing
proba(1,2) = exp(betaV(1,2))/sum(exp(betaV)); % PRoba Stealing
% H = log(proba)
% or, to avoid problem due to log(0)=-Inf

H = betaV - log(sum(exp(betaV)));  % equivalent to H = log(proba)
end

function [TotLL, P] = LogLL1(parameter, reward, ntrial)

 for t=1:ntrial     % for each round
    V(t,:) = compute_val_monetary(parameter, reward(t,:));
    [LogLik, P] = softmax_Home(V(t,:), parameter(1));
 end
TotLL = sum(LogLik);
end







