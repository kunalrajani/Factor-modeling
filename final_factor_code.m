
clear all;
load clean_data_num_mom.mat;

% to limit the values and strip the outliers to 95pct and 5 pct
for k = 9:22
    for i=1:335:14405
        low_bound = prctile(data(i:(i+334),k),5);
        high_bound = prctile(data(i:(i+334),k),95);
        for j = i:(i+334)
            if (data(j,k) < low_bound)
                data(j,k) = low_bound;
            else if (data(j,k) > high_bound)
                    data(j,k) = high_bound;
                end
            end
        end
    end
end

% to correct for -ve earnings in P/E.
for i=1:335:14405
    high_bound = prctile(data(i:(i+334),15),95);
    for j = i:(i+334)
        if (data(j,15) <= 0)
            data(j,15) = high_bound;
        end
    end
end


%defining the variables
Y_fwd = data(:,12); %returns in the next period
Value_factors = data(:,13:15);   %P/E, B/M, P/S
Profit_factors = data(:,16:19); %ROE, ROA and changes in them
health_factor = data(:,20); %D/E
mom_factor = data(:,22);    %FnG
no_of_hist=20;
d=0.5;                      %decay factor
first = 10051-335*8; %10051 is 2008Q1 (Earliest is 2001Q1)
last = 14405;      %14405 is 2011Q1

for i=1:no_of_hist
    disct_fact(i) = d^(no_of_hist-i);    
end

%running the regression and getting the final wealth
X_data = [mom_factor(:,:) Value_factors(:,:) Profit_factors(:,:) health_factor(:,:)];
ret = [];
for j = first:335:last
    b_final = [];
    resid = [];
    pval = [];
    Rsq = [];
    for i =j-335*no_of_hist:335:j-1
        X = [X_data(i:i+334,:) ones(335,1)];
        [b,~,r,~,stats] = regress(Y_fwd(i:i+334),X);
        b_final = [b_final b];  %the factor premia
        resid = [resid; r'];      %the residuals
        pval = [pval stats(3)]; %p-value
        Rsq = [Rsq stats(1)];   %R-sq for each regression
    end
    b_final = b_final';
    beta = X_data(j:j+334,:);
%obtaining the covariance matrix using the new factor loadings for each
%stock and adding the unsystematic variance from residual matrix
    covar = beta*cov(b_final(:,1:end-1))*beta';
    covar = covar + diag(diag(cov(resid)),0);  
%computing a weighted avg of the factor premia and the return vector
    mu = b_final(:,1:end-1).*repmat(disct_fact',1,size(b_final,2)-1);
    mu = sum(mu,1)./repmat(sum(disct_fact),1,size(b_final,2)-1);
    mu = beta*mu';
    sum(mu)
%now we pass on the mu and covar to the optimization program
    weights = conprog(mu,covar);   %should be a row vector
%Y_fwd is the actual return. hence ret is the realized return based on the
%weights obtained from the optimization program
    ret = [ret [data(j,1); weights'*Y_fwd(j:j+334)]];
end                             


%%%%%%%%%%%%%%%%%%%% Significance Analysis %%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%% Bootstrapping to check for sample bias  %%%%%
B = 1000;

X_data = [mom_factor Value_factors(:,:) Profit_factors(:,:) health_factor(:,:)];
bsample = [];
bboot_mean = [];

b_boot = [];
for k = 1:B
    sample = randsample(14405,14405,true);  %obtaining samples with replacement
    X = [X_data(sample,:) ones(14405,1)];
    b = regress(Y_fwd(sample),X);           %obtaining estimates for each sample
    b_boot = [b_boot b];  %the factor premia
end

% b_boot is a 9X1000 matrix containing the factor premia estimated for each
% factor for each sample

