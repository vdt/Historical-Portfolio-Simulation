function[portfolio_name] = create_portfolio(portfolio_longname, asset_matrix, weights)

% initialize portfolio
portfolio_name = class_portfolio;

% assign portfolio longname
portfolio_name.longname = portfolio_longname;

% assign historical excess return data to portfolios.
for x = 1:length(asset_matrix)
    portfolio_name.datablock(:,x) = asset_matrix(x).histER;
end

% assign historical cash return to portfolios
portfolio_name.cashTR = asset_matrix(1).cashTR;

% assign weights
portfolio_name.assetweights = weights;

end


