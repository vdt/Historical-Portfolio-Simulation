function[portfolios] = vol_ret_adjust(type,target,portfolios)

if strcmp(type,'vol')
    for x = 1:length(portfolios)
        if portfolios(x).histvol < target
            while portfolios(x).histvol < target
                portfolios(x).assetweights = portfolios(x).assetweights * 1.001;
            end
        end
        if portfolios(x).histvol > target
            while portfolios(x).histvol > target
                portfolios(x).assetweights = portfolios(x).assetweights * 0.999;
            end
        end
    end
end

if strcmp(type,'ret')
    for x = 1:length(portfolios)
        if portfolios(x).histaggTR < target
            while portfolios(x).histaggTR < target
                portfolios(x).assetweights = portfolios(x).assetweights * 1.001;
            end
        end
        if portfolios(x).histaggTR > target
            while portfolios(x).histaggTR > target
                portfolios(x).assetweights = portfolios(x).assetweights * 0.999;
            end
        end
    end
end

end
