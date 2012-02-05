% --- Set up the optimization. The following function takes the steps in
% which we want to vary our allocations (e.g. steps of 5%, or 10%) and the
% constraints we want to put around each asset class (e.g. no less than 20%
% or more than 70% in equities and % returns the universe of all possible 
% portfolios with weights that sum to % 1 and whose individual weights 
% change by the value of 'step'. The amount % of time this function takes 
% increases dramatically as we shrink the steps % in which we allocate 
% capital (e.g. going in increments of 2% vs 5%), and as we add assets.

function [possible_portfolios] = genweights(step,constraints_high,constraints_low)

% for now, this function only works for a six asset portfolio. This is
% because as the number of assets increases, the mathematical complexity of
% the function increases so dramatically as to make it impossible to
% compute.

numassets = 6;

% We have no way of pre-calculating the size requirements of the
% possible_portfolios matrix, so we pre-allocate plenty of space, and fill
% it with zero. We will trim the extra rows at the end.

possible_portfolios = zeros(10^5,numassets); 

% Below we create a matrix of the possible weights we want to evaluate. The
% number of rows is set at (1 / step + 1), so if step is 10, we will have
% 11 rows (0.0 through 1.0 in steps of 0.1). The number of columns is fixed
% at numassets.

weights = ones(((1/step)+1),numassets);

for x = 1:length(weights(1,:))
    weights(:,x) = [0:step:1]';
end

% Counter is the variable we will use to increment through the
% possible_portfolios matrix.

counter = 1;

% the code below isolates the possible portfolios, based on the constraint
% that the asset weights must sum to 100% and the individual asset
% constraints stored in constraints_low and constraints_high. This is
% pre-calced and stored in a file.

for x = constraints_low(1):step:constraints_high(1)
    for y = constraints_low(2):step:constraints_high(2)
        for z = constraints_low(3):step:constraints_high(3)
            for aa = constraints_low(4):step:constraints_high(4)
                for bb = constraints_low(5):step:constraints_high(5)
                    for cc = constraints_low(6):step:constraints_high(6)
                        sumwt = weights(uint8(x/step+1),1)+weights(uint8(y/step+1),1)+weights(uint8(z/step+1),1)+weights(uint8(aa/step+1),1)+weights(uint8(bb/step+1),1)+weights(uint8(cc/step+1),1);
                        if sumwt == 1
                            possible_portfolios(counter,:) = [x, y, z, aa, bb, cc];
                            counter = counter + 1;    
                        end                    
                    end
                end
            end
        end
    end
end

% The code below eliminates the rows of the variable possible_portfolios
% that are zero and left over from when we pre-allocated plenty of space.

temp = [];

for x = 1:length(possible_portfolios)
    if sum(possible_portfolios(x,:)) ~= 0
        temp(x,:) = possible_portfolios(x,:);
    end
end

possible_portfolios = temp;

end
