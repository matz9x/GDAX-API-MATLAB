function [ frame_table ] = gdaxfetch(product, start_date, end_date, granularity)
%GDAXFETCH
    start_date_u = posixtime(datetime(start_date));
    end_date_u = posixtime(datetime(end_date));

    time = (start_date_u:granularity:end_date_u)';

    time_span = seconds(datetime(end_date) - datetime(start_date));
    num_entries = time_span / granularity;
    max_entries = 348;
    num_calls = ceil(num_entries / max_entries);
    time_steps = (time_span / ceil(num_calls));

    starting = datetime(start_date);
    frame = nan(1,6);

    i = 1;
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

    new_frame = nan(length(time)-1, 6);
    k = 1;
    for i = 1:length(time)-1
        if frame(k,1) == time(i,1)
            new_frame(i,:) = [time(i,1) frame(k,2:end)];
            k = k + 1;
        else
            new_frame(i) = time(i,1);
        end
    end

    dates = datetime(new_frame(:,1),'ConvertFrom','posixtime');
    frame_table = [array2table(dates) array2table(new_frame, ...
        'VariableName', {'timestamp', 'low', 'high', 'open', 'close', 'volume'})];
    frame_table = fillmissing(frame_table, 'spline');

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