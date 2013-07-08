function [fg] = fg_matrix(px_high, px_low, px_close,indices)

dim = size(px_close);
n = dim(1);  % number of days of data
d = dim(2); % total number of securities

q = size(indices); % the indices of each fear & greed that will be returned
offset = cumsum(indices - [0 ; indices(1:(q-1))]);

this_fg = zeros(n,1);
fg = zeros(1,1);

for j=1:d
    close = px_close(1:n,j);
    high = px_high(1:n,j);
    low = px_low(1:n,j);
    this_fg = fear_and_greed(high,low,close);
    
    curr_index = 0;
    
    for i=1:q
        curr_index = j + offset(i);
        fg = [fg; this_fg(curr_index)];
    end
    
end

fg = fg(2:(d*q + 1));

