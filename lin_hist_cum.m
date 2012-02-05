function[chart] = lin_hist_cum(dates, portfolios)

% set up the date range
daterange = [dates(1):(1/12):(dates(2)+1)]';

while length(daterange) > portfolios(1).length_of_data
    daterange(length(daterange)) = [];
end

% populate the data to be plotted
ydata = [];
for x = 1:length(portfolios)
    ydata = [ydata,portfolios(x).histcumTR];
end

% create figure
chart = figure('Visible','off',...
      'PaperSize',[6 8]);
  
set(chart,'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',chart,'YScale','linear','YMinorTick','on');
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input
plot1 = plot(daterange,ydata,'Parent',axes1);

for x = 1:length(portfolios)
    set(plot1(x),'DisplayName',portfolios(x).longname);
end

% Create xlabel
xlabel('Years');

% Create ylabel
ylabel('Cumulative Excess Returns');

% Create title
title('Historical Cumulative Excess Return at Same Risk');

% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.150 0.705 0.464 0.19])


end
