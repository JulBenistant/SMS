%-- Log to txt file
function [] = Write_log(msg,datafile)
if nargin<2
    global data
    if data.debug
        datafile=[];
    else
        datafile=data.datafile;
    end
end
if isempty(datafile)
    fid = 1;
else
    logfile = [ datafile '.log' ];
    fid = fopen(logfile, 'a+t');
end
if fid>2
    fprintf(fid,'%s\t',datestr(now,31));
    fprintf(fid,'%s'  ,msg);
    fprintf(fid,'\n');
end
fprintf(1,'%s\t',datestr(now,31));
fprintf(1,'%s'  ,msg);
fprintf(1,'\n');
if fid>2
    fclose(fid);
end
