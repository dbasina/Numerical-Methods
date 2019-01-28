function RK2dyn2(w0,t0,tf)
%RK2dyn2(w0,t0,tf) [verbose version] solves dw/dt = f(w) from t0 to tf
%   with the column vector of ICs w(t0) = w0 
%   using second-order Runge-Kutta with a dynamic timestep.
%   The function f(w) is implemented below for N first-order ODEs.
%   For (damped) harmonic oscillator: RK2dyn2([1; -0.05],0,8*pi)
%   For van der Pol oscillator: RK2dyn2([1; 0],0,50)
%   For erf, RK2dyn2([0; 0],0,2)
%   TO SEE SINGULARITY FOR y' = y^2, y(0) = 1: RK2dyn2(1,0,2)

tic
t = t0;
dt_max = (tf-t0)/10;
dt_min = 16*eps*(tf-t0); 
nmax = 200000; % max number of timesteps
EPSILON_REL = 10^-3; EPSILON_ABS = 10^-6;
p = 0.05; omega2 = 1; % for damped harmonic oscillator

w = w0(:);
wsol = transpose(w);
tsol = t;

% calculate initial dt
norm_solution = norm(w,1);
norm_f = norm(f(w),1);
tbar = (EPSILON_REL*norm_solution+EPSILON_ABS)/ ...    
    (EPSILON_REL*norm_f+EPSILON_ABS);
dt = EPSILON_REL^(1/3)*tbar; % since e_l ~ dt^3
dt = min(dt, dt_max);
fprintf('dt0 = %g\n',dt)

n = 0;
while t<tf && n<nmax % timestep loop
    n = n+1;
    r = Inf;
    redo = 0;
    while r>2
        redo = redo+1;
        if 1.1*dt >= tf-t
            dt = tf-t;
        end
        tnew = t+dt;
        w1 = w + dt*f(w+dt*f(w)/2); % RK2
        wmid = w + dt*f(w+dt*f(w)/4)/2; % first dt/2 for 2*RK2
        wnew = wmid + dt*f(wmid+dt*f(wmid)/4)/2; % second dt/2 for 2*RK2
        norm_solution = norm(w,1);
        e_l = (4/3)*norm(wnew-w1,1);
        r = e_l/(EPSILON_REL*norm_solution+EPSILON_ABS);
        if redo>1
            fprintf('REDOING TIMESTEP %d\n',n)
        end
        fprintf('n = %d, r = %g, dt = %g\n',n,r,dt)
        dt = min(min(2*dt,dt/r^(1/3)),dt_max);
        if dt < dt_min
            warning('MATLAB:dt_min', ...
                'possible singularity: dt = %e < dt_min at t = %e.\n',...
                dt,t); 
            n = nmax; r = 0; % to exit from while loops
        end
    end
    t = tnew;
    w = wnew;
    tsol(end+1,1) = t;
    wsol(end+1,:) = transpose(w);
end
toc
fprintf('\nNumber of steps = %d\n',n)

figure
% plot(tsol,wsol(:,1),'r-',tsol,wsol(:,1),'b.','MarkerSize',12,'LineWidth',2)
% For damped harmonic oscillator, use:
plot(tsol,exp(-p*tsol).*cos(sqrt((-p^2+omega2))*tsol),'r-',...
    tsol,wsol(:,1),'b.',...
    'MarkerSize',24,'LineWidth',2)
legend('exact','RK2','Location','NorthEast')
%
% For erf(t), use:
% plot(tsol,erf(tsol),'r-',tsol,wsol(:,1),'b.',...
%    'MarkerSize',24,'LineWidth',2)
% legend('erf','RK2','Location','NorthWest')

xlim([t0 tf])
xlabel('t','FontSize',24)
ylabel('y','FontSize',24)

figure % comment out for singularity problem
plot(wsol(:,1),wsol(:,2),'b-',wsol(1,1),wsol(1,2),'r.',...
    'MarkerSize',24,'LineWidth',2)
axis square
xlabel('y','FontSize',24)
ylabel('dy/dt','FontSize',24)
title('attractor','FontSize',24)

    function wprime = f(w)
    % wprime = [w(2); -w(1)]; % harmonic oscillator
    % wprime = [w(2); -omega2*w(1)-2*p*w(2)]; % damped harmonic oscillator
    % wprime = [w(2); -w(1)+(4-w(1)^2)*w(2)]; % van der Pol oscillator
    % wprime = w(1)^2; % y' = y^2, y(0) = 1: exact y(t) = 1/(1-t)
    wprime = [2*exp(-w(2)^2)/sqrt(pi); 1]; % erf(t)
    end

end