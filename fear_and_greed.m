% Given a price history of High, Low, and Closing prices for times t_0..t_n
% this function calculates the Fear & Greed index for times t_70..t_N
function [fg_index]= fear_and_greed(high,low,close)
n = length(close);

% TRAILING DATA (10-day)
% - - - - - - - - - - - -
%   Calculates the minimum and maximum of the 10-day trailing price
%   history and then uses that information to calculate the 10-day
%   true range for each time t>10
min_10 = zeros(n,1);
max_10 = zeros(n,1);
TR_10_inc = zeros(n,1);
TR_10_dec = zeros(n,1);
for t= 10:n
    min_10(t) = min(low(t-9:t));
    max_10(t) = max(high(t-9:t));
    a = max_10(t)-min_10(t);
    b = abs(max_10(t)-close(t-9));
    c = abs(min_10(t)-close(t-9));
    tr_10 = max(max(a,b),c);
    % TR value is stored in TR_10_inc(t) if the close price has increased in 
    % the past ten days. TR_10_dec(t) keeps its intial value of 0.
    if (close(t) > close(t-9))
        TR_10_inc(t) = tr_10;
    % Otherwise, the value is stored in TR_10_dec(t) and TR_10_inc(t)=0.     
    else
        TR_10_dec(t) = tr_10;
    end
end


% SHORT TERM (20-day) 
% - - - - - - - - - - 
%   Weights for the 20-day exponential moving average (alpha = 90%)
     p_20 = 1:20;
     raw_20 = 0.9.^p_20;
     wt_20 = raw_20/sum(raw_20);
%   Exponential Moving Average of the increasing & decreasing 
%   TR arrays, including any zeros.  Then the difference is calculated.
     EMAvg20_TR_inc = filter(wt_20,1,TR_10_inc);
     EMAvg20_TR_dec = filter(wt_20,1,TR_10_dec);
     diff_20 = EMAvg20_TR_inc - EMAvg20_TR_dec;

     
% LONG TERM (50-day)
% - - - - - - - - - -
%   Weights for the 50-day exponential moving average (alpha = 96%)
     p_50 = 1:50;
     raw_50 = 0.96.^p_50;
     wt_50 = raw_50/sum(raw_50);
%   Exponential Moving Average of the increasing & decreasing 
%   TR arrays, including any zeros.  Then the difference is calculated.
    EMAvg50_TR_inc = filter(wt_50,1,TR_10_inc);
    EMAvg50_TR_dec = filter(wt_50,1,TR_10_dec);
    diff_50 = EMAvg50_TR_inc - EMAvg50_TR_dec;

    
% INDEX CALCULATION
% - - - - - - - - -
%  The index is based on the spread of the short-term difference to the
%  long-term difference from 9 days prior (raw_fg) plus some smoothing.
    raw_fg = zeros(n,1);
%  Initialize the index at t_70 using the fg_raw from t_69 and t_70.
    raw_fg(69) = diff_20(69) - diff_50(60);
    raw_fg(70) = diff_20(70) - diff_50(61);
    fg_index = zeros(n,1);
    fg_index(70) = (raw_fg(69)+raw_fg(70))/2;
%  For t_71..t_n, the index is calculated by taking 2/3 the current raw_fg
%  with 1/3 of yesterday's Fear & Greed Value (for smoothing).
for t=71:n
    raw_fg(t) = diff_20(t) - diff_50(t-9);
    fg_index(t) = (2/3)*raw_fg(t) + (1/3)*fg_index(t-1);
end













