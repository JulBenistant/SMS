
%%DATA%%

reward(1,1) = 16;reward(1,2) = 12;reward(1,3) = 8;reward(1,4) = 4;reward(1,5) = 20;
rank(1,1) = 2;rank(1,2) =3 ;rank(1,3) = 4;rank(1,4) = 5;

%%%% n = 10 per conditions

%Creation parameters, alpha first line and beta second line
   % First column Alpha = 0.8,0.2,0.5
   % Second column 1-alpha = 0.2,0.8,0.5
params = [0.7,0.3,0.5;0.3,0.7,0.5];

%temperature equal to 0.85
for aa = 1: 3 % Loop over parameters couple
    for yy = 1 : 4 % Loop over ranks
        for ii = 1:1000 % Loop over trials
            
         param(aa).rank(1,yy).EU_Mon_NoCost(1,ii) = params(1,aa)*reward(1,yy);% EU when no stealing
         param(aa).rank(1,yy).EU_Mon_NoCost(2,ii) = (params(1,aa)*reward(1,1))-(params(2,aa)*(reward(1,5)-reward(1,yy)));% EU when stealing
         
         param(aa).rank(1,yy).Proba_NoStl(1,ii) = exp(0.85*param(aa).rank(1,yy).EU_Mon_NoCost(1,ii))/...
             (exp(0.85*param(aa).rank(1,yy).EU_Mon_NoCost(1,ii))+exp(0.85*param(aa).rank(1,yy).EU_Mon_NoCost(2,ii)));
         
         param(aa).rank(1,yy).EU_Social(1,ii) = params(1,aa)*rank(1,yy);% EU when no stealing
         param(aa).rank(1,yy).EU_Social(2,ii) = (params(1,aa)*5)-(params(2,aa)*(5-rank(1,yy)));% EU when stealing
         
         param(aa).rank(1,yy).Proba_NoStl(2,ii) = exp(0.85*param(aa).rank(1,yy).EU_Social(1,ii))/...
             (exp(0.85*param(aa).rank(1,yy).EU_Social(1,ii))+exp(0.85*param(aa).rank(1,yy).EU_Social(2,ii)));    
         
         %Compute outcome (decision to steal or not according to previously computed proba)
         R=rand;
         if R<param(aa).rank(1,yy).Proba_NoStl(1,ii)
             param(aa).rank(1,yy).outcome(1,ii) =0;
         else
             param(aa).rank(1,yy).outcome(1,ii) =1;
         end
        end
    end
end

%% Default mode %%

%a being the payoff no stealing and b with
%(exp(x(2)*x(1)*a));
%exp(x(2)*(x(1)*b)-((1-x(1))*(b-a)));

%denominateur%
%(exp(x(2)*x(1)*a)+exp(x(2)*(x(1)*b)-((1-x(1))*(b-a))));

softmax_default = @(x,a,b) (log((exp(x(2)*x(1)*a))/(exp(x(2)*x(1)*a)+exp(x(2)*((x(1)*b)-((1-x(1))*(b-a)))))));

D = [16;12;8;4];
E = [20;20;20;20];

%%Norm model%%

options=optimset('Display','off','MaxIter',10000,'TolX',10^-14,'TolFun',10^-14);

lb = [0;0]; %bound for alpah (not for beta)
ub = [1;100];

for i = 1: 4
    a = D(i,1);
    b = E(i,1);
    y = param(2).rank(1,i).outcome;
    for ii = 1:10
        task(i).init = rand(2,1);
        [task(i).test(ii).parameter,task(i).test(ii).likli(1,ii),task(i).test(ii).exit(1,ii)] = fmincon(@(x) softmax_default(x,a,b),task(i).init,[],[],[],[],lb,ub,[],options);
    end
end
