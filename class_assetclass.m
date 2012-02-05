% George Kalogeropoulos, 2011
% The 'class_assetclass' class contains the properties and methods for
% calculating all the historical performance data and statistics of an
% class_assetclass. The external properties that must be provided are a:
% 
% 1. A Total Return Index for the class_assetclass. It does not matter what date
% the series is indexed to (TRindex).
% 2. The long form, human readable form of the assetclass's name
% (longname).
% 3. The monthly total return of cash (cashTR).
%
% Notes: 
% 
% 1. No date information is stored with the class_assetclass. This is because the
% date range for the entire analysis is determined when the data is
% imported from the data source.
%
% 2. Cash itself is an class_assetclass. When we start the analysis, we always
% define 'cash' as the first assetclass, and then use it's total returns
% (calculated from cash's total return index) to populate 'cashTR' for all
% other asset classes we create.

classdef class_assetclass
    
    % These are the properties we need to provide in order for the rest of
    % the calculations to work. They are described in detail in the
    % comments, lines 6-10.
    
    properties 
        longname % This is a string.
        TRindex % This is a matrix.
        cashTR % This is a matrix.
    end
    
    % The properties below will be calculated based on the information that
    % we have provided. The goal of this class is to be a 'Swiss Army
    % Knife' in the sense that it will calculate and store any information
    % we may need. Because MATLAB only calculates a dependent property when
    % it is directly referenced, defining many properties should not affect
    % performance. 
    
    properties (Dependent) % total return characteristics.
        length_of_data % how long the data is. Pre calcing for speed.
        histTR % historical total returns, monthly. Change in the monthly total return index. This is a matrix.
        histcumTR % historical monthly cumulative total returns ('growth of a dollar'). This is a matrix.
        histaggTR % historical annualized cumulative total return. This is a scalar.
        hist12moTR % historical rolling annual total returns. This is a matrix.
        hwm % high water mark. The maximum value of the 'growth of a dollar' index. Used to calculate drawdowns. This is a matrix.
        drawdowns % the percent loss in value relative to the high water mark. This is a matrix.
    end
    
    properties (Dependent) % excess return characteristics
        histER % historical excess return, monthly. Change in the monthly total return index less cash. This is a matrix.
        histcumER % historical monthly cumulative excess returns. This is a matrix.
        histaggER % historical annualized cumulative excess return. This is a scalar.
        hist12moER % historical rolling annual excess returns. This is a matrix.
    end
    
    properties (Dependent) % volatility characteristics.
        histvol % historical annualized volatility of excess returns. This is a scalar.
        hist12moVol % historical rolling annual volatility of excess returns. This is matrix.
    end
    
    properties (Dependent) % variance, sharpe ratio, skewness and kurtosis.
        seriesvariance % variance of excess returns. This is a scalar.
        histSR % historical annual sharpe ratio. Annualized excess return / annualized volatility. This is a scalar.
        seriesskewness % skewness of excess returns. This is a scalar.
        serieskurtosis % kurtosis of excess returns. This is a scalar.
    end
    
    % Below we use the data entered to calculate all the dependent
    % properties defined above. These methods/functions are in the same
    % order as the properties defined above.
    
    methods % total return calculations.
        
        % Calculate the length of the assetclass data. We use this length
        % often in loops and pre-calcing it speeds up execution
        % significantly over length(class_assetclass.histTR).
        
        function length_of_data = get.length_of_data(class_assetclass)
            length_of_data = length(class_assetclass.TRindex) - 1;
        end
        
        % Calculate the monthly total returns, in percent, of the asset
        % class. We do this by dividing each month's value for the total
        % return index by the previous month's, and subtracting one. So if
        % our index was at 10 last month and is at 15 this month, that
        % represents a 15/10 - 1 = 50% return over the course of the month.
        
        % To perform this calculation, we take the total return index, copy
        % it, and shift the data points in the copy over by one, by
        % inserting a NaN at the beginning of the series. We then divide
        % the original series by the copy and subtract one.
                              
        function histTR = get.histTR(class_assetclass) 
            copy_of_TRindex = [NaN;class_assetclass.TRindex]; 
            copy_of_TRindex(length(copy_of_TRindex)) = []; % trim the final data point so the two matrices will be the same length.
            histTR = class_assetclass.TRindex./copy_of_TRindex - 1; 
            histTR(1,:) = []; % trim first row of histTR as it is a NaN.
        end
        
        % Calculate the cumulative historical total returns. This is
        % also known as the 'growth of a dollar' index, as it represents
        % the return of investing one dollar in the asset class and
        % monitoring the value of that investment over time. This is
        % calculated by applying the monthly change in the total return
        % index to our investment over time. Note that this is the same as
        % reconstructing our initial total return index, but with the
        % series starting at 1.
        
        function histcumTR = get.histcumTR(class_assetclass)
            histcumTR = 1 + class_assetclass.histTR;
            histcumTR = cumprod(histcumTR);
        end
        
        % Calculate the cumulative annualized total return of the asset
        % class. To do this, we take the last data point of the 'growth of
        % a dollar' index calculated above, which represents the return
        % that this asset had over that time period. We then figure out
        % what that return was for each year of the time period, using the
        % function:
        %
        % (1 + last data point of histcumTR)^(1/(Number of Months/12))-1
        
        function histaggTR = get.histaggTR(class_assetclass)
            histaggTR = class_assetclass.histcumTR(class_assetclass.length_of_data) ^ (1/(class_assetclass.length_of_data/12)) - 1;
        end
        
        % Calculate the historical rolling annual total returns. For any
        % point in time, this is the cumulative return over the previous 12
        % months. We do this by isolating the last 12 months of returns, and
        % then calculating how much our dollar would have grown over those
        % 12 months. We do this for each data point for which we have a
        % year's worth of returns (every point after the first 11).
        
        function hist12moTR = get.hist12moTR(class_assetclass)
            histTR = class_assetclass.histTR + 1;
            hist12moTR = zeros(length(histTR),1);
            for x = 1:11
                hist12moTR(x) = NaN;
            end
            rolling_12m_return = 1;
            for x = 12:length(histTR)
                one_year_of_returns = histTR(x-11:x);
                for y = 1:length(one_year_of_returns)
                    rolling_12m_return = rolling_12m_return * one_year_of_returns(y);
                end
                rolling_12m_return = rolling_12m_return - 1;
                hist12moTR(x) = rolling_12m_return;
                rolling_12m_return = 1;
            end    
        end
        
        % Calculate the high water mark of the 'growth of a dollar' index.
        % We do this by copying 'growth of a dollar', and then determining
        % if each point is smaller than its predecessor. If it is, it is
        % assigned the value of its predecessor. If it isn't, we move on to
        % the next data point. This is the same as calculating the maximum
        % over the range from the beginning of the 'growth of a dollar'
        % index until our data point. 
        
        % I think this is faster than using the 'max' funtion because 
        % calculating the maximum would require comparing every
        % data point up to 'x' every time we loop through, instead of only
        % comparing x and x-1. 
        
        function hwm = get.hwm(class_assetclass)
            hwm = class_assetclass.histcumTR;
            for x = 2:length(hwm)
                if hwm(x) < hwm(x-1)
                    hwm(x) = hwm(x-1);
                end
            end
        end
        
        % Calculate the percentage drawdown at any point in time. We do
        % this by comparing the 'growth of a dollar' index to the high
        % water mark index, and then calculating how far below the high
        % water mark each data point on the 'growth of a dollar' index is,
        % as a percentage of the high water mark.
                
        function drawdowns = get.drawdowns(class_assetclass)
            drawdowns = zeros(class_assetclass.length_of_data,1);
            hwm = class_assetclass.hwm;
            histcumTR = class_assetclass.histcumTR;
            for x = 1:length(histcumTR)
                if histcumTR(x) < hwm(x)
                    drawdowns(x) = ((histcumTR(x) - hwm(x)) / hwm(x));
                end                
            end
        end
    end
    
    methods % excess return calculations.
        
        % Calculate the monthly excess returns, in percent, by subtracting
        % the total return of the risk-free investment (cash) from the
        % total returns of the asset class.
        
        function histER = get.histER(class_assetclass) 
           histER = class_assetclass.histTR - class_assetclass.cashTR;
        end
        
        % Calculate the historical cumulative excess return. This is
        % functionally identical to histcumTR, except that it operates on
        % the histER series. Please refer to the notes for the histcumTR
        % method above for more information.
        
        function histcumER = get.histcumER(class_assetclass)            
            histcumER = 1 + class_assetclass.histER;
            histcumER = cumprod(histcumER);
        end
        
        % Calculate the cumulative annualized excess return of the asset
        % class. Computationally identical to the calculation for histaggTR
        % that is one of the 'total returns' methods above. Please refer to
        % histaggTR notes to understand how this works.
        %
        % NOTE: This number IS NOT the same as subtracting the cumulative
        % annualized total return of cash from the cumulative annualized
        % total return of the asset class. The reason for this is that we
        % are not compounding the returns of cash into our excess return
        % calculation here - we are not growing our excess returns on a
        % base that includes cash returns. The approach we take here is
        % consistent with the standard industry approach to calculating
        % value added over benchmark for the purposes of calculating fees.
        
        function histaggER = get.histaggER(class_assetclass)
            histaggER = class_assetclass.histcumER(class_assetclass.length_of_data) ^ (1/(class_assetclass.length_of_data/12)) - 1;
        end
        
        % Calculate the rolling one year excess returns. Computationally
        % identical to hist12moTR method above. See documentation for
        % hist12moTR.
        
        function hist12moER = get.hist12moER(class_assetclass)
            histER = class_assetclass.histER + 1;
            hist12moER = zeros(length(histER),1);
            for x = 1:11
                hist12moER(x) = NaN;
            end
            rolling_12m_return = 1;
            for x = 12:length(histER)
                one_year_of_returns = histER(x-11:x);
                for y = 1:length(one_year_of_returns)
                    rolling_12m_return = rolling_12m_return * one_year_of_returns(y);
                end
                rolling_12m_return = rolling_12m_return - 1;
                hist12moER(x) = rolling_12m_return;
                rolling_12m_return = 1;
            end    
        end
        
    end
    
    methods % volatility calculations. Calculated from excess returns.
        
        % Calculate the historical annualized volatility of the asset
        % class. This is the standard deviation of the data, multiplied by
        % the square root of 12 in order to annualize it.
        
        function histvol = get.histvol(class_assetclass)
            histvol = nanstd(class_assetclass.histER) * sqrt(12);
        end
        
        % Calculate the rolling one year volatility of the asset class.
        % Note that we are taking the standard deviation of 12 data points,
        % and then multiplying that by the square root of 12 in order to
        % annualize it.

        function hist12moVol = get.hist12moVol(class_assetclass)
            histER = class_assetclass.histER + 1;
            hist12moVol = zeros(length(histER),1);
            for x = 1:11
                hist12moVol(x) = NaN;
            end
            for x = 12:length(histER)
                hist12moVol(x) = nanstd(histER(x-11:x)) * sqrt(12);
            end  
        end
        
    end      
    
    methods % variance, sharpe ratio, skewness and kurtosis calculations.
        
        % Calculate the variance of the excess returns using MATLAB's
        % built-in variance function.
        
        function seriesvariance = get.seriesvariance(class_assetclass)
            seriesvariance = var(class_assetclass.histER);
        end
        
        % Calculate the Sharpe ratio - the ratio of annualized excess
        % return to annualized volatility of excess returns.
        
        function histSR = get.histSR(class_assetclass)
            histSR = class_assetclass.histaggER / class_assetclass.histvol;
        end
        
        % Calculate the skewness of the asset class - useful for
        % demonstrating the non-normality of market returns.
        
        function seriesskewness = get.seriesskewness(class_assetclass)
            seriesskewness = skewness(class_assetclass.histER);
        end
        
        % Calculate the kurtosis of the asset class - again, useful for
        % demonstrating non-normality.
        
        function serieskurtosis = get.serieskurtosis(class_assetclass)
            serieskurtosis = kurtosis(class_assetclass.histER);
        end
        
    end
          
end

    
    
        