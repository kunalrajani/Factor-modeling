function [x] = conprog(mu,V)
n = size(mu,1);
U = chol(V);
upLim=repmat(.1,n,1);
downLim=repmat(-.1,n,1);
A_eq=ones(1,n);
cvx_begin
    variable x(n);
    variable t(1);
    minimize(t);
    subject to
              A_eq*x ==1;
               x<=upLim;
               x>=downLim;
              {U*x, t,mu'*x-Rf} <In> rotated_lorentz(n);   
    cvx_end