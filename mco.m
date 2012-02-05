function[weights] = mco(possible_portfolios, iterations, mco_optim_port)

% This is a Monte Carlo optimization. 'Monte Carlo' is a somewhat broad
% term, which basically means that we are going to vary the inputs in order
% to account for the inherent uncertainty in using specific numbers when
% conducting an optimization.
%
% In order to calculate the expected return, risk and sharpe
% ratio, of a given portfolio of assets, we use the following assumptions:
%
% 1. correlation between assets in portfolio
% 2. volatilities of assets in portfolio
% 3. Excess return of assets in the portfolio
%
% The ideal would be to vary all three of these assumptions and then
% calculate every permutation of each of these inputs, and then arrive at
% some sort of average of the mco_optim_port portfolios. Given the number of
% possible permutations of those inputs, that is computationally
% unfeasible.
%
% This implementation takes a normal distribution around our expected
% correlation and Sharpe ratio and a random sampling of the historical
% rolling 1 yr volatilities of the asset classes. It then calculates a mean
% variance optimization for each of those scenarios. We then average the
% best portfolios for each scenarios to arrive at the optimized portfolio.
%
% NOTE: If we so chose, we could use a random sampling of the
% historical rolling one year correlations between asset classes as this is
% calculated by the portfolio class.

% -- create matrix of volatilities

volatilities = zeros(length(mco_optim_port.asset12movols),mco_optim_port.numassets);

for x = 1:mco_optim_port.numassets
    temp = zeros(length(mco_optim_port.asset12movols),2);
    temp(:,1) = randperm(length(mco_optim_port.asset12movols))';
    temp(:,2) = mco_optim_port.asset12movols(:,x);
    temp = sortrows(temp);
    volatilities(:,x) = temp(:,2);
end

% below we trim the volatilities down to length 'iteration', but only if
% they are longer than iterations. The 'if' statement exists because there's a
% chance that the user specified a date range that yields fewer than 'iteration' data points.

if length(volatilities) > iterations
    volatilities = volatilities(1:iterations,:);
end

% -- end matrix of volatilities

% -- create correlation scenarios

% create a 3 dimensional matrix of size (number of assets) * (number of
% assets) * (iterations). Fill it with a random normal distribution
% centered around our expected forward looking correlation. 

correlations = zeros(mco_optim_port.numassets,mco_optim_port.numassets,iterations);

for x = 1:mco_optim_port.numassets
    for y = 1:mco_optim_port.numassets
        rand_dist = (randn(iterations,1)+1) * mco_optim_port.expcorrelmatrix(x,y);
        for z = 1:iterations
            
            % the nested if below checks if our random number exceeds 1.0
            % or is less than -1.0, which are invalid values for a
            % correlation. If it does, it just sets that particular data
            % point to the center of our distribution.
            
            if or(rand_dist(z) > 1, rand_dist(z) < -1)
                rand_dist(z) = mco_optim_port.expcorrelmatrix(x,y);
            end
            
            correlations(x,y,z) = rand_dist(z);
            
            % if x = y then we are looking at the correlation of an assets
            % to itself, and that should always be 1.
            
            if x == y
                correlations(x,y,z) = 1;
            end
        end
    end
end

% -- end correlation scenarios

% -- create sharpe ratio scenarios

sharperatios = zeros(iterations,mco_optim_port.numassets);

for x = 1:mco_optim_port.numassets
    sharperatios(:,x) = (1 + randn(iterations,1))*mco_optim_port.assetexpSR(x);
end

% -- end sharpe ratio scenarios

% -- begin optimization

best_portfolios = zeros(iterations,mco_optim_port.numassets);

h = waitbar(0,'Monte Carlo optimization in progress. Please wait...');
for x = 1:iterations
    best_portfolios(x,:) = mvo(possible_portfolios,mco_optim_port,volatilities(x,:),correlations(:,:,x),sharperatios(x,:));
    waitbar(x / iterations);
end

for x = 1:mco_optim_port.numassets
    weights(x) = mean(best_portfolios(:,x));
end

close(h);

% -- end optimization

end