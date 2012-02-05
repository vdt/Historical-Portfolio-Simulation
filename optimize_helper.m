% This function calls the genweights function which gives us the universe
% of possible portfolios based on the step and iteration values we passed
% to this function. It then creates the Mean Variance and Monte Carlo
% optimized portfolios, and calls the 'mvo' (Mean Variance Optimizer) and
% 'mco' (Monte Carlo Optimizer) functions to determine the portfolio
% weights of these two optimized portfolios.

function[mvo_optim_port,mco_optim_port] = optimize_helper(asset_matrix, step, iterations, constraints_low, constraints_high)

possible_portfolios = genweights(step,constraints_high,constraints_low);

mvo_optim_port = create_portfolio('Mean-Variance Optimized', asset_matrix, zeros(1,6));

mco_optim_port = create_portfolio('Monte Carlo Optimized', asset_matrix, zeros(1,6));

mvo_optim_port.assetweights = mvo(possible_portfolios, mvo_optim_port,[],[],[]);

mco_optim_port.assetweights = mco(possible_portfolios, iterations, mco_optim_port);

end

