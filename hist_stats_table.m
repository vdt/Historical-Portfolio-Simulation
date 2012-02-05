function[stats_table] = hist_stats_table(portfolios, portfolio_index)

% This function builds a table of portfolio statistics: total return,
% excess return, volatility, and Sharpe ratio. It will build the table for
% the portfolio specified in portfolio_index. If portfolio_index is zero,
% it will build a table for all 4 portfolios.

if portfolio_index == 0

data = cell(4);
for x = 1:length(portfolios)
    data(1,x) = cellstr(strcat(num2str(round((portfolios(x).histaggTR * 1000))/10),' %'));
end
for x = 1:length(portfolios)
    data(2,x) = cellstr(strcat(num2str(round((portfolios(x).histaggER * 1000))/10),' %'));
 end
for x = 1:length(portfolios)
    data(3,x) = cellstr(strcat(num2str(round((portfolios(x).histvol * 1000))/10),' %'));
 end
for x = 1:length(portfolios)
    data(4,x) = cellstr(num2str(round(portfolios(x).histSR * 100)/100));
end

cnames = {portfolios(1).longname,portfolios(2).longname,portfolios(3).longname,portfolios(4).longname};
columnwidths = {150, 150, 150, 150};
posn = [0 0 745 94];

end

if portfolio_index ~= 0
    data = cell(4,1);
    data(1) = cellstr(strcat(num2str(round((portfolios(portfolio_index).histaggTR * 1000))/10),' %'));
    data(2) = cellstr(strcat(num2str(round((portfolios(portfolio_index).histaggER * 1000))/10),' %'));
    data(3) = cellstr(strcat(num2str(round((portfolios(portfolio_index).histvol * 1000))/10),' %'));
    data(4) = cellstr(num2str(round(portfolios(portfolio_index).histSR * 100)/100));
    cnames = {portfolios(portfolio_index).longname};    
    columnwidths = {150};
    posn = [0 0 295 94];
end



stats_table = figure('Position',posn,'Visible','on');
set(stats_table,'Color',[1 1 1]);

rnames = {'Total Return','Excess Return','Volatility','Sharpe Ratio'};
t = uitable('Parent',stats_table,'Data',data,'ColumnName',cnames,... 
            'RowName',rnames,'Position',posn,...
            'BackgroundColor',[1 1 1],'ColumnWidth',columnwidths);

end
