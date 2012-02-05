classdef class_portfolio
    
    % The properties below must be assigned when the class is initialized.
    % They are:
    % 1. The long-form, human readable name of the portfolio.
    % 2. The weights of the assets in the portfolio. There is a specific
    % order that these weights must be in because of our hard-coded
    % expected correlation matrix.
    % 3. A block of the historical excess returns of the assets in the
    % portfolio. These HAVE to be in the same order as the assetweights.
    % 4. The historical monthly total returns of cash.
   
    properties
        longname 
        assetweights
        datablock
        cashTR
    end
    
    % Some general properties of the portfolio. It's leverage and the
    % number of assets in it.
    
    properties (Dependent)
        leverage
        numassets
        length_of_data
    end
        
    % The properties below are calculated for the portfolio from the
    % properties provided above. They are properties based off the
    % historical TOTAL returns of the portfolio.
    
    properties (Dependent) % historical total return properties of portfolio.
        histTR % historical total return, monthly
        histcumTR % historical monthly cumulative excess return ('growth of a dollar')
        histaggTR % historical annualized cumulative total return    
        hist12moTR % historical rolling annual total returns
        hwm % high water mark: maximum value of portfolio
        drawdowns % drawdowns from high water mark, in percent terms
    end
    
    % The properties below are calculated for the portfolio from the
    % properties provided above. They are properties based off the
    % historical EXCESS returns of the portfolio.   
    
    properties (Dependent) % historical excess return properties of portfolio.
        histER % historical excess return, monthly
        histcumER % historical monthly cumulative excess return
        histaggER % annualized number for excess return
        hist12moER % historical rolling annual excess returns
    end
    
    % These are the historical volatility characteristics that we use in
    % our analysis. They are:
    % 1. The historical volatility of the portfolio.
    % 2. The historical rolling annual volatility of the portfolio.
    % 3. Rolling annual annualized volatility of asset classes. Needed for
    % our implementation of Monte Carlo optimization.
    % 4. Rolling annual correlation of the different asset classes to each
    % other. Needed for our implementation of Monte Carlo optimization.
    
    properties (Dependent) % historical volatility characteristics, based off of excess returns.
        histvol
        hist12moVol
        asset12movols
        asset12mocorrels
    end
                  
    properties (Dependent) % variance, sharpe ratio, skewness and kurtosis.
        seriesvariance % variance of excess returns. This is a scalar.
        histSR % historical annual sharpe ratio. Annualized excess return / annualized volatility. This is a scalar.
        seriesskewness % skewness of excess returns. This is a scalar.
        serieskurtosis % kurtosis of excess returns. This is a scalar.
    end
                   
    % The properties below are our forward-looking assumptions. They are:
    % 1. Our assumption for the annual total return of cash. These days,
    % its basically zero. Since 1900, it's been a little less than 4%. For
    % our analysis, we assume a 2% cash rate, though this can easily
    % changed below.
    % 2. The expected forward looking Sharpe ratio for asset classes. For
    % domestic-only investments, we assume a roughly 0.25 Sharpe ratio on
    % an expected basis; in the future, we may want to modify this if we
    % expect a higher Sharpe ratio from international asset classes, or
    % perhaps a forward-looking Sharpe ratio of zero for commodities.
    % 3. The expected correlation matrix for our forward-looking
    % calculations. Because this is hard-coded for the time being, it is
    % important that this matrix, the assetvols, and the assetweights, are
    % in the same order.
    % 4. The expected volatility of the asset classes. This can either be
    % calculated based off the historical data in the eponymous function
    % or set by the optimizer.
    
    properties % Some standard forward-looking assumptions.
        cashexpTR = 0.02; 
        assetexpSR = [0, 0.25, 0.25, 0.25, 0.25, 0.25];
        expcorrelmatrix = [1.0,0.0,0.0,0.0,0.0,0.0;
                           0.0,1.0,0.2,0.2,0.2,-0.2;
                           0.0,0.2,1.0,-0.2,0.2,0.2;
                           0.0,0.2,-0.2,1.0,0.0,0.2;
                           0.0,0.2,0.2,0.0,1.0,0.2;
                           0.0,-0.2,0.2,0.2,0.2,1.0]; 
        assetvols;
    end
    
    % The properties below are needed in order to do portfolio math. They
    % are: 
    % 1. The expected excess returns of each asset class.
    % 2. the historical annualized volatility of each asset class, which
    % will be our forward-looking volatility assumption as well.
    % 3. The historical correlation matrix of the assets in the portfolio.
    % We don't actually use the historical correlation matrix at present,
    % as we are using our own forward-looking correlation assumptions. It
    % is however very easy to swap in the historical figures if we prefer
    % to use those.
    % 4. The covariance matrix for the portfolio. Covariance for each point
    % in the correlation matrix is calculated as correlation * weight of
    % asset 1 * weight of asset 2 * volatility of asset 1 * volatility of
    % asset 2.
    
    properties (Dependent) % properties needed to calculate portfolio expected characteristics.
        assetexpER
        correlmatrix
        covarmatrix
    end
    
    % The properties below are calculated using portfolio math. They are: 
    % 1. The varshare ('risk share') of each asset in the portfolio.
    % 2. the covarshare (risk share taking into account correlation between
    % assets of each asset in the portfolio.
    % 3. The expected annual total return of the portfolio.
    % 4. The expected annual excess return of the portfolio. 
    % 5. The expected annual volatility of the portfolio.
    
    properties (Dependent) % portfolio expected characteristics.
        varshare
        covarshare
        portexpER
        portexpTR
        expvol
        portexpSR
    end
    
    methods % general properties
      
        % Calculate the number of assets in the portfolio. We do this by
        % counting the number of columns in the datablock.
        
        function numassets = get.numassets(class_portfolio)
            numassets = length(class_portfolio.datablock(1,:));
        end
        
        % Calculate leverage. Sum the assetweights excluding the first
        % weight, which is cash.
        
        function leverage = get.leverage(class_portfolio)
            leverage = 0;
            for x = 2:class_portfolio.numassets
            leverage = leverage + class_portfolio.assetweights(x);
            end
        end   
   
        % Calculate the length of the portfolio historical data. We use this length
        % often in loops and pre-calcing it speeds up execution
        % significantly over length(class_portfolio.histTR).
        
        function length_of_data = get.length_of_data(class_portfolio)
            length_of_data = length(class_portfolio.datablock);
        end
        
    end
        
    methods % historical total return calculations
        
        % Calculate the monthly total returns, in percent, of the
        % portfolio by adding the portfolio's excess returns to the cash
        % total return.
                
        function histTR = get.histTR(class_portfolio)
            histTR = class_portfolio.histER + class_portfolio.cashTR;
        end
        
        % Calculate the cumulative historical total returns. This is
        % also known as the 'growth of a dollar' index, as it represents
        % the return of investing one dollar in the portfolio and
        % monitoring the value of that investment over time. This is
        % calculated by applying the monthly change in the total return
        % index to our investment over time. Note that this is the same as
        % reconstructing our initial total return index, but with the
        % series starting at 1.
                        
        function histcumTR = get.histcumTR(class_portfolio)
            histcumTR = 1 + class_portfolio.histTR;
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
                
        function histaggTR = get.histaggTR(class_portfolio)
            histaggTR = class_portfolio.histcumTR(class_portfolio.length_of_data) ^ (1/(class_portfolio.length_of_data/12)) - 1;
        end
        
        % Calculate the historical rolling annual total returns. For any
        % point in time, this is the cumulative return over the previous 12
        % months. We do this by isolating the last 12 months of returns, and
        % then calculating how much our dollar would have grown over those
        % 12 months. We do this for each data point for which we have a
        % year's worth of returns (every point after the first 11).
                
        function hist12moTR = get.hist12moTR(class_portfolio)
            histTR = class_portfolio.histTR + 1;
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
                
        function hwm = get.hwm(class_portfolio)
            hwm = class_portfolio.histcumTR;
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
                
        function drawdowns = get.drawdowns(class_portfolio)
            drawdowns = zeros(class_portfolio.length_of_data,1);
            hwm = class_portfolio.hwm;
            histcumTR = class_portfolio.histcumTR;
            for x = 1:length(histcumTR)
                if histcumTR(x) < hwm(x)
                    drawdowns(x) = ((histcumTR(x) - hwm(x)) / hwm(x));
                end                
            end
        end      
       
    end

    methods % historical excess return calculations
        
        % Calculate the portfolio's historical excess return. We do this by
        % going column by column through the datablock of excess returns
        % and multiplying by the weight assigned to that asset. We then sum
        % the weighted returns of each asset class into one column, our
        % historical excess return.
        
        function histER = get.histER(class_portfolio)
            weighted_returns = class_portfolio.datablock;
            for x = 1:class_portfolio.length_of_data
                weighted_returns(x,:) = class_portfolio.assetweights.*weighted_returns(x,:);             
            end
            histER = zeros(class_portfolio.length_of_data,1);
            for x = 1:class_portfolio.length_of_data
                histER(x) = sum(weighted_returns(x,:));
            end           
        end 
        
        % Calculate the historical cumulative excess return. The
        % calculation is identical to histcumTR. See notes for histcumTR
        % for an explanation of the code.
        %
        % Note: This data is not intuitively meaningful, since it
        % is a 'growth of a dollar' index, but with cash subtracted. This
        % is not a return an investor could ever experience. That said,
        % this calculation is useful because it allows us to calculate the
        % historical cumulative annualized excess return.
                
        function histcumER = get.histcumER(class_portfolio)
            histcumER = 1 + class_portfolio.histER;
            histcumER = cumprod(histcumER);
        end
        
        % Historical cumulative annualized excess return number. This is
        % the industry accepted methodology for calculating this figure,
        % since we are using the last element of the historical cumulative
        % excess return series, which cumulates excess returns, we are not
        % "taking any credit" for cash returns. 
        %
        % Note that for the reason mentioned above the portfolio's
        % histaggER + cash's histaggTR will not equal the portfolio's
        % histaggTR. It will be slightly less, because we are not
        % compounding cash returns into our excess return cumulation. 
        
        function histaggER = get.histaggER(class_portfolio)
            histaggER = class_portfolio.histcumER(class_portfolio.length_of_data) ^ (1/(class_portfolio.length_of_data/12)) - 1;
        end
        
        % Calculate the rolling one year excess returns. Computationally
        % identical to hist12moTR method above. See documentation for
        % hist12moTR.
        
        function hist12moER = get.hist12moER(class_portfolio)
            histER = class_portfolio.histER + 1;
            hist12moER = zeros(length(histER),1);
            for x = 1:11
                hist12moER(x) = NaN;
            end
            f = 1;
            for x = 12:length(histER)
                a = histER(x-11:x);
                for y = 1:length(a)
                    f = f * a(y);
                end
                f = f - 1;
                hist12moER(x) = f;
                f = 1;
            end    
        end
        
    end
    
    methods % historical volatility calculations
        
        % Portfolio's annualized historical volatility. Standard deviation
        % of monthly returns multiplied by the square root of 12.
        
        function histvol = get.histvol(class_portfolio)
            histvol = std(class_portfolio.histER) * sqrt(12);
        end
        
        % Historical rolling annual volatility of the portfolio.
        
        function hist12moVol = get.hist12moVol(class_portfolio)
            histER = class_portfolio.histER + 1;
            hist12moVol = zeros(length(histER),1);
            for x = 1:11
                hist12moVol(x) = NaN;
            end
            for x = 12:length(histER)
                hist12moVol(x) = nanstd(histER(x-11:x)) * sqrt(12);
            end  
        end
    
        % Calculate the rolling annual volatility of the assets in the
        % portfolio. We need this for the Monte Carlo optimizer, which will
        % choose randomly out of this set of volatilities and optimize for
        % these random values.
        %
        % This function is the same computationally as the hist12moVol
        % method in the assetclass class, except that instead of going
        % through only one column it loops through all the columns of
        % 'datablock'. 
        % 
        % This method is redundant in the sense that we could have just
        % taken the hist12moVol property from each instance of the
        % assetclass class. This would have required the user to write a
        % loop to do this when initializing portfolio, so avoid this the
        % function is recreated here.
        
        function asset12movols = get.asset12movols(class_portfolio)
            asset12movols = zeros(class_portfolio.length_of_data,class_portfolio.numassets);
            for y = 1:class_portfolio.numassets
                histER = class_portfolio.datablock(:,y) + 1;
                for x = 1:11
                     asset12movols(x,y) = NaN;
                end
                for x = 12:length(histER)
                    asset12movols(x,y) = std(histER(x-11:x)) * sqrt(12);
                end                
            end  
        end    
        
        % Below we calculate the rolling annual correlations of the
        % different asset classes to each other. First, we initialize a
        % 3-dimensional matrix of NaNs of size (number of assets) * (number
        % of assets) * (length of data). We then 'walk' through the
        % datablock and use corrcoef to populate each correlation matrix.
        
        function asset12mocorrels = get.asset12mocorrels(class_portfolio)
            asset12mocorrels = NaN(class_portfolio.numassets,class_portfolio.numassets,class_portfolio.length_of_data);
            for x = 12:class_portfolio.length_of_data
                asset12mocorrels(:,:,x) = corrcoef(class_portfolio.datablock(x-11:x,:));
            end
        end
    end
    
    methods % variance, sharpe ratio, skewness and kurtosis calculations.
        
        % Calculate the variance of the excess returns using MATLAB's
        % built-in variance function.
        
        function seriesvariance = get.seriesvariance(class_portfolio)
            seriesvariance = var(class_portfolio.histER);
        end
        
        % Calculate the Sharpe ratio - the ratio of annualized excess
        % return to annualized volatility of excess returns.
        
        function histSR = get.histSR(class_portfolio)
            histSR = class_portfolio.histaggER / class_portfolio.histvol;
        end
        
        % Calculate the skewness of the asset class - useful for
        % demonstrating the non-normality of market returns.
        
        function seriesskewness = get.seriesskewness(class_portfolio)
            seriesskewness = skewness(class_portfolio.histER);
        end
        
        % Calculate the kurtosis of the asset class - again, useful for
        % demonstrating non-normality.
        
        function serieskurtosis = get.serieskurtosis(class_portfolio)
            serieskurtosis = kurtosis(class_portfolio.histER);
        end
        
        % Calculate the annualized volatilities of the assets in the portfolio. 
        % Standard deviation of each column of the datablock multiplied by
        % the square root of 12 to annualize it. 
        
        function assetvols = get.assetvols(class_portfolio)
            assetvols = zeros(1,class_portfolio.numassets);
            for x = 1:class_portfolio.numassets
                assetvols(x) = std(class_portfolio.datablock(:,x)) * sqrt(12);
            end
        end
        
    end

    methods % properties needed to calculate portfolio expected characteristics
        
        % Below we calculate the expected excess return of each asset class
        % by multiplying the volatility of that asset class by our standard
        % forward-looking Sharpe ratio of 0.25. 
        
        function assetexpER = get.assetexpER(class_portfolio)
            assetexpER = class_portfolio.assetexpSR.*class_portfolio.assetvols;
        end    
          
        % Below we calculate the historical correlation matrix for the
        % portfolio. 
        %
        % NOTE: We don't actually use this correlation matrix in our
        % forward-looking calculations, as we are using our hard-coded
        % correlation assumptions instead. Should we prefer to use
        % historical correlations rather than forward-looking assumptions,
        % the presence of this function makes it a trivial issue to switch
        % the forward-looking calculation over to this matrix.
        
        function correlmatrix = get.correlmatrix(class_portfolio)
            correlmatrix = corrcoef(class_portfolio.datablock);
        end
        
        % Calculate the covariance matrix. Each element in the correlation
        % matrix is multiplied by the volatilities and weights of the
        % assets in its row and its column, i.e:
        %
        % Covariance Matrix (2,3) = Correlation Matrix (2,3) * Weight(Asset
        % 2) * Weight(Asset 3) * Volatility(Asset 2) * Volatility(Asset 3)
        
        function covarmatrix = get.covarmatrix(class_portfolio)
            covarmatrix = class_portfolio.expcorrelmatrix;
            
            for x = 1:length(covarmatrix)
                covarmatrix(x,:) = class_portfolio.assetvols.*covarmatrix(x,:);
                covarmatrix(x,:) = class_portfolio.assetweights.*covarmatrix(x,:);
                covarmatrix(:,x) = class_portfolio.assetvols'.*covarmatrix(:,x);
                covarmatrix(:,x) = class_portfolio.assetweights'.*covarmatrix(:,x);
            end
            covarmatrix(:, 1) = []; % trim the first column and row - since cash has no ER, the correlation matrix 
            covarmatrix(1, :) = []; % has NaNs in the first column and row.
        end      
    
    end
    
    methods % portfolio expected characteristics.
          
        % The risk share of each asset in the portfolio. 
        %
        % multiply each volatility by its corresponding asset weight,
        % then sum those products into variable 'total', then divide
        % each product by the sum of those products to yield varshare.
        
        function varshare = get.varshare(class_portfolio)
            varshare = class_portfolio.assetvols.*class_portfolio.assetweights;
            total = sum(varshare(:));
            varshare = varshare./total;
        end
        
        % The risk share of each asset in the portfolio, taking into
        % account our expectation of the correlation between that asset and
        % the other assets in the portfolio. 
        %
        % We calculate this by summing each column in the covariance matrix
        % and then dividing each resulting sum by the sum of all the data
        % points in the covariance matrix. 
        %
        % NOTE: We removed the first column and row, cash during the
        % covariance matrix calculation. This is because cash, by
        % definition, has no excess return (so the volatility of its excess
        % returns is zero). This would produce NaNs in the covariance
        % matrix calculation, so we removed the row and column
        % corresponding to cash.
        
        function covarshare = get.covarshare(class_portfolio)
            covarshare = sum(class_portfolio.covarmatrix);
            covarshare = covarshare./sum(class_portfolio.covarmatrix(:));
            covarshare = [0,covarshare]; % reinsert zero at the beginning for cash, which has no covar share.
        end
        
        % The expected excess return of the portfolio. The sum of the
        % weights of each asset multiplied by its expected return.
        
        function portexpER = get.portexpER(class_portfolio)
            portexpER = class_portfolio.assetexpER.*class_portfolio.assetweights;
            portexpER = sum(portexpER(:));
        end
        
        % The expected total return of the portfolio. The expected excess
        % return, with the expected cash return added.
        
        function portexpTR = get.portexpTR(class_portfolio)
            portexpTR = class_portfolio.portexpER + class_portfolio.cashexpTR;
        end        
        
        % The expected volatility of the portfolio. Portfolio math tells us
        % this the sqrt of the sum of all the elements in the covariance
        % matrix. For more, see Markowitz's thesis on Portfolio Theory.
        
        function expvol = get.expvol(class_portfolio)
            expvol = sqrt(sum(class_portfolio.covarmatrix(:)));
        end

        % The expected Sharpe ratio of the portfolio. The expected excess
        % return divided by the expected volatility.
        %
        % NOTE: This is what our optimization functions will maximize, with
        % no regard for the resulting volatility of the portfolio. This is
        % because one of our core assumptions is that we want to design the
        % optimal portfolio (highest expected unit of return per unit of
        % expected risk) and can then use cheap leverage to increase the
        % level of risk of the portfolio to our desired volatility.

        function portexpSR = get.portexpSR(class_portfolio)
            portexpSR = class_portfolio.portexpER / class_portfolio.expvol;
        end

    end
       
end
