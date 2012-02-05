function[chart] = exp_pies(portfolio)

chart = figure();
set(chart,'Color',[1 1 1]);

subplot(1,3,1); pie2(portfolio.assetweights);
title('Capital Weights','FontWeight','Bold');
subplot(1,3,2); pie2(portfolio.varshare);
title('Risk Share','FontWeight','Bold');
subplot(1,3,3); pie2(portfolio.covarshare);
title(['Risk Share',sprintf('\n'),'(Factoring Correlations)'],'FontWeight','Bold');

names = {'Large Cap Equities'; 'Nominal Govt Bonds'; 'Commodities'; 'Corporate Bonds'; 'Inflation-Linked Bonds'};

legend1 = legend(names);
set(legend1,'Position',[0.313 0.060 0.33 0.233]);

% Create textbox
txtbox = annotation(chart,'textbox',[0.247 0.831 0.469 0.114],'String',portfolio.longname);
set(txtbox, 'FontSize', 20, 'HorizontalAlignment', 'center', 'LineStyle', 'none');

end

