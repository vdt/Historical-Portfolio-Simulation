function[chart] = rolling_correl(dates, asset_matrix, index_1, index_2)

% set up the date range
daterange = [dates(1):(1/12):(dates(2)+1)]';

while length(daterange) > length(asset_matrix(1).histTR)
    daterange(length(daterange)) = [];
end

asset1 = asset_matrix(index_1).histER;
asset2 = asset_matrix(index_2).histER;

ydata = zeros(length(asset_matrix(1).histTR), 1);

for x = 12:length(asset1)
    ydata(x) = corr(asset1(x-11:x), asset2(x-11:x));
end

    
    % create figure
chart = figure('Visible','on',...
      'PaperSize',[6 8]);
  
set(chart,'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',chart,'YScale','linear','YMinorTick','on');
box(axes1,'on');
hold(axes1,'all');

plot1 = plot(daterange,ydata,'Parent',axes1);

% Create xlabel
xlabel('Years');

% Create ylabel
ylabel('12-month correlation between assets');

% Create title
title('Rolling Annual Correlation of Stocks to Bonds');


end
