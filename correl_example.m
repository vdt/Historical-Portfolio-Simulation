function[chart] = correl_example()

a = ones(16,1);
b = ones(16,1);
c = ones(16,1);

for x = 1:length(c)
    c(x) = x;
end

for x = 1:2:length(a)
    a(x) = 0.5;
    a(x+1) = -0.5;
end

for x = 1:2:length(b)
    b(x) = 0.5;
    b(x+1) = -0.1;
end

a = a + 1;
b = b + 1;
a = cumprod(a);
b = cumprod(b);

% create figure
chart = figure('Visible','on',...
      'PaperSize',[6 8]);
  
set(chart,'Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',chart,'YScale','linear','YMinorTick','on');
box(axes1,'on');
hold(axes1,'all');

plot1 = plot(c,a,c,b);
title('Correlation can be misleading');
ylabel('Growth of a Dollar');
xlabel('Time');

end
