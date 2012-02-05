function[chart] = plot_dd(dates, portfolios)

% set up the date range
daterange = [dates(1):(1/12):(dates(2)+1)]';

while length(daterange) > portfolios(1).length_of_data
    daterange(length(daterange)) = [];
end

% populate the data to be plotted
ydata = [];
ydata = [portfolios(2).drawdowns, portfolios(3).drawdowns];


ydata = ydata * 100;

% create figure
chart = figure('Visible','on','PaperSize',[6 10]);
set(chart,'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',chart,'YScale','Linear','YMinorTick','on');
box(axes1,'on');
hold(axes1,'all');

plot1 = plot(daterange,ydata,'Parent',axes1);

set(plot1(1),'DisplayName',portfolios(2).longname);
set(plot1(2),'DisplayName',portfolios(3).longname);

% Create xlabel
xlabel('Years');

% Create ylabel
ylabel('Percent Drawdown');

% Create title
title('Historical Drawdowns at Same Return');

% Create legend
legend1 = legend(axes1,'show');
set(legend1,'Position',[0.407738095238095 0.143650793650795 0.4625 0.1]);




end

