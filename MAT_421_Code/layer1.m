function layer1(epsilon,N)
%layer1(epsilon,N) solves the nonlinear BVP
%       epsilon*y'' + 2*y' + exp(y) = 0, y(0)=0, y(1)=0 
%   using central differences with N dx by Newton iteration.
%   Try: layer1(0.01,1000)

tic
h = 1/N; % h = dx
x = linspace(0,1,N+1);
y = zeros(N-1,1);

e = ones(N-1,1);
D2 = spdiags([e -2*e e],[-1 0 1],N-1,N-1)/h^2;
D1 = spdiags([-e e],[-1 1],N-1,N-1)/(2*h);

normresidual = Inf;
iter = 0;
while normresidual>10^-6 && iter<20
    F = epsilon*D2*y + 2*D1*y + exp(y);
    J = epsilon*D2 + 2*D1 + spdiags(exp(y),0,N-1,N-1);
    
%     y = y - J\F; % MATLAB precompiled tridiagonal solve (very fast!)

%    Jfull = full(J);
%    y = y - solvelinsys(Jfull,F); % full matrix solve 

     a = diag(J,-1);
     b = diag(J);
     c = diag(J,1);
     y = y - tridisolve(a,b,c,F);

    iter = iter + 1;
    normresidual = norm(F,1)/(N-1);
end
y = [0; y; 0];
toc

figure
plot(x,y,'b.')
xlabel('x','FontSize',24)
ylabel('y','FontSize',24)
xlim([0 1])

function x = tridisolve(a,b,c,d)
x = d;
n = length(x);
for j = 1:n-1
    mu = a(j)/b(j);
    b(j+1) = b(j+1) - mu*c(j);
    x(j+1) = x(j+1) - mu*x(j);
end
x(n) = x(n)/b(n);
for j = n-1:-1:1
    x(j) = (x(j)-c(j)*x(j+1))/b(j);
end
end

end