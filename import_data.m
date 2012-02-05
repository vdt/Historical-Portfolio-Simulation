function[asset_matrix] = import_data(dates)

codes = {'cash'; 'lrgeq'; 'govtfi'; 'comm'; 'corp'; 'il'};
names = {'Cash'; 'Large Cap Equities'; 'Nominal Govt Bonds'; 'Commodities'; 'Corporate Bonds'; 'Inflation-Linked Bonds'};

% Read total return indices from Excel file into 'data' matrix.
[data, ] = xlsread('data.xlsx', 'Data');

% count the number of assets by counting the columns in the 'data' matrix
numassets = length(data(1,:));

% establish the row numbers for the start and end date.
offsets = [];
offsets(1,1) = (dates(1) - 1900) * 12;
offsets(1,2) = (dates(2) + 1 - 1900) * 12; 

% trim all the data past the second offset out of the 'data' matrix.
for x = offsets(1,2)+1:length(data)+1
    data(offsets(1,2),:) =[];
end

% trim all the data before the first offset out of the 'data' matrix.
for x = 1:offsets(1,1)-1
    data(1,:) = [];
end

% Loop through the asset classes defined by 'codes', create an instance of
% class_assetclass for each, assign it's totretindex parameter from 'data',
% assign its historical cash return parameter from the assetclass instance
% of 'cash', assign the 'longname' parameter from 'names', and store all of
% this in a matrix of assetclass instances called 'asset_matrix'.

asset_matrix = class_assetclass;

for x = 1:numassets
    eval([char(codes(x)) '= class_assetclass;']);
    eval([strcat(char(codes(x)),'.TRindex') '= data(:,x);']);
    eval([strcat(char(codes(x)),'.cashTR') '= cash.histTR;']);
    eval([strcat(char(codes(x)),'.longname') '= names(x);']);
    asset_matrix(x) = eval([char(codes(x))]);
end

end