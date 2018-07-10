
%This defines the function we want to minimise (i.e. the least squares
%difference between the simulation with the estimated parameters, and the
%actual data

function objective_function_ICs_too=logged_logisticfitfunction(parameters,timepoints,OD)

    r=parameters(1);
    Kstar=parameters(2); %this is carrying capacity scaled with initial value

simulation_points=log2(abs(Kstar)*exp(abs(r)*timepoints)./(abs(Kstar)+(exp(abs(r)*timepoints)-1)));
    
objective_function_ICs_too=norm((simulation_points-OD));



    
