function[weights] = mvo(possible_portfolios, optim_port,volatilities,correlations,sharperatios)

% this function performs a mean-variance optimization. It loops through all
% the possible portfolios that meet our constraints (defined by
% possible_portfolios) and looks for the set of asset weights which yield
% the highest Sharpe ratio.

% The if statement is there to determine if this function was called by the
% monte carlo optimizer, in which case we need to assign the values that
% the monte carlo optimizer passed us.

if(~isempty(volatilities))
    optim_port.assetvols = volatilities;
    optim_port.expcorrelmatrix = correlations;
    optim_port.assetexpSR = sharperatios;
end

weights = [];
maxratio = 0;

for x = 1:length(possible_portfolios(:,1))
   optim_port.assetweights = possible_portfolios(x,:);
   if optim_port.portexpSR > maxratio;
       maxratio = optim_port.portexpSR;
       weights = possible_portfolios(x,:);
   end
end

end




