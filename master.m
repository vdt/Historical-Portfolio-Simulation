function[portfolios, asset_matrix] = master(dates, userweights, mvo_optim_weights, mco_optim_weights)

asset_matrix = import_data(dates);

% --- If there are no weights specified for the user's portfolio, ask the
% user to enter those weights. If the user cancels, return an empty
% portfolio, which should make us quit.

if isempty(userweights)
    userweights = weights_entry(asset_matrix);
    if(isempty(userweights))
        portfolios = [];
    end
end

% --- Create user portfolio.

user_port = create_portfolio('User', asset_matrix, userweights);


% --- Create conventional portfolio.

conv_port = create_portfolio('Conventional', asset_matrix, [0, 0.6, 0.30, 0.05, 0.05, 0]);

% --- Create optimized portfolios

% --- Execute optimization helper function if necessary, otherwise create
% portfolios with weights assigned when 'master' function is called. This
% avoids re-running the optimizer every time the function is called and
% crucially, bases the optimized portfolo off the full-period weights
% instead of changing it every time master is called with a different date
% range.

% Note function arguments: optimize_helper(step, iterations, constraints_low, constraints_high)
% step is the increments in each portfolio, e.g. steps of 5% or 10%.
% iteration is the number of Monte Carlo portfolios to run
% constraints low = minimum weights for each asset
% constrainst high = maximum weights for each asset

if(isempty(mvo_optim_weights))
    [mvo_optim_port,mco_optim_port] = optimize_helper(asset_matrix,0.05,20,[0, 0, 0, 0, 0, 0],[0, 0.8, 0.6, 0.6, 0.6, 0.6]);
end
if(~isempty(mvo_optim_weights))
    mvo_optim_port = create_portfolio('Mean-variance Optimized', asset_matrix, mvo_optim_weights);
    mco_optim_port = create_portfolio('Monte Carlo Optimized', asset_matrix, mco_optim_weights);
end

portfolios = [user_port, conv_port, mvo_optim_port, mco_optim_port];

end
