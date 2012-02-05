function[weights] = weights_entry(asset_matrix)

% This function asks the user to enter the portfolio weights, and sanity
% checks the user's input.

% Errors will return empty weights, which should cause our main script to
% close.

% First let's extract the asset class names from asset_matrix so that we
% can construct the dialog box.

names = {};
for x = 1:length(asset_matrix)
    names(x) = asset_matrix(x).longname;
end

% default weight is equally weighting the risky assets (0% to cash)

weights={'0.00','0.20','0.20','0.20','0.20','0.20'};

% create the dialog box

info = inputdlg(names, 'Enter decimals.', 1, weights);

%see if user hit cancel

if isempty(info)              
    warndlg('User cancelled. Exiting...');
    weights = [];
    return;
end

% see if the user at least entered numbers

try weights=cellfun(@str2num,info)';
catch
    warndlg('Invalid entry. Please enter weights as decimals. Exiting...');
    weights = [];
    return;
end

% test if exposures sum to less than 100%

if sum(weights(:)) < 1 
    string1 = 'Exposures sum to less than 100%. Assuming input error & exiting. ';
    string2 = 'Assign any exposures that do not fit into the input categories to Cash and run again.';
    string = strcat(string1,string2);
    warndlg(string);
    weights = [];
    return;
end

% test if portfolio is levered more than 1000%. Probably a data error in
% that case.

if sum(weights(:)) > 10
    string1 = 'Sum of asset weights is greater than 1000%';
    string2 = 'Please enter weights as decimals. Exiting...';
    string = strcat(string1,string2);
    warndlg(string);
    weights = [];
    return;
end

end