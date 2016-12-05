function data = score2rank(data)

all = size(data.Calc,1);
all2 = size(data.Calc,2);
[~,B] = sort(data.Calc(1,:));
data.Calc = data.Calc(:,B);
data.Calc(all+1,:) = [ones(1,all2/5)*5,ones(1,all2/5)*4,ones(1,all2/5)*3,...
    ones(1,all2/5)*2,ones(1,all2/5)];
end