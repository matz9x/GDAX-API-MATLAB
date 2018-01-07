function [ frame, dates ] = gdaxfetch(product, start_date, end_date, granularity)
%GDAXFETCH

time_span = seconds(datetime(end_date) - datetime(start_date));
num_entries = time_span / granularity;
max_entries = 350;
num_calls = ceil(num_entries / max_entries);
time_steps = (time_span / ceil(num_calls));

starting = datetime(start_date);
frame = nan(1,6);
while i <= num_calls
    ending = starting + seconds(time_steps);
    rolling_frame = flipud(gdaxapi (product, starting, ending, granularity));
    frame = cat(1, frame, rolling_frame);    
    starting = ending;
    i = i + 1;
    pause(0.5);    
end

frame(1,:) = [];
frame(frame(:,1) > posixtime(datetime(end_date)), :) = [];
dates = datetime(frame(:,1),'ConvertFrom','posixtime');

%% Functions
function [ dataframe ] = gdaxapi (product, start_date, end_date, granularity)
    url1 = 'https://api.gdax.com/products/';
    url4 = '/candles?start=';
    url2 = '&end=';
    url3 = '&granularity=';
    start_date = datestr(start_date, 'yyyy-mm-ddTHH:MM:SS');
    end_date = datestr(end_date, 'yyyy-mm-ddTHH:MM:SS');
    website = strcat(url1,product,url4,start_date,url2,end_date,url3,num2str(granularity));
    dataframe = webread(website);
end
end

