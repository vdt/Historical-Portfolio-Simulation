function[dates] = date_entry();

% This function asks the user to enter dates for the analysis and sanity
% checks user input.

default_dates={'1900','2011'};
labels={'Analysis Start Year:';'Analysis End Year:'};

% Create the input dialog box.
dates = inputdlg(labels, 'Enter dates', 1, default_dates);

% If user leaves default values, assign default dates to 'dates' variable. 
if isempty(dates)
    dates=cellfun(@str2num,default_dates);
end

% Try converting the dates entered to numbers. If this fails, the user
% entered invalid dates. Show a warning dialog box explaining what
% happened and makes 'dates' blank, which will cause our main script to
% exit.

try dates=cellfun(@str2num,dates)';
catch
    warndlg('Invalid entry. Please enter years only (e.g. 1933, or 2009). Exiting...');
    dates = [];
    return;
end

% One more check: Are the dates valid? If not, show warning and return
% empty array, which will make our main script exit.

if or(dates(1) > dates(2),or(dates(1) < 1900,or(dates(1) > 2011,or(dates(2) < 1900,dates(2) > 2011))))
    warndlg('Invalid entry. Years must be between 1900 and 2011, and the start date must be before the end date. Exiting...');
    dates = [];
    return;
end

end