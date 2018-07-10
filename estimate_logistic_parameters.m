clear
%this code fits a modified logistic model (scaled with initial value and
%log base 2 taken, see preprocess.ipynb) to the scaled and transformed growth curve data

%read in data

inputdatafile='data.csv';
inputmetafile='meta.csv';
outputfilename='estimates_PA01-acetic.csv';

scaled_data=xlsread(inputdatafile);
meta_data=xlsread(inputmetafile);

%number of replicates (this may vary for each data set) (if some conditions
%have fewer repeats, need to add empty columns in relevant place to the excel sheet)
no_rep=6;

%create variables of timepoints, concentrations and pHs
time=scaled_data(2:end,1);
concs=meta_data(1:end,6);
pHs=meta_data(1:end,7);

%establish unique, ordered pH and concentration vectors, and calculate
%numbers of each
pH_vector=flipud(unique(pHs));
number_pH=size(pH_vector,1);

conc_vector=unique(concs);
number_concentrations=size(conc_vector,1);

%OD data
scaled_OD=scaled_data(2:end,2:end);
no_expts=size(scaled_OD,2);

%quick test to make sure you've read in the right amount of data in each case
test=no_expts~=size(pHs,1);
test2=no_expts~=size(concs,1);

if test==1, disp('error')
end
if test2==1, disp('error')
end

%establish number of distinct experimental conditions
no_conditions=size(pH_vector,1)*size(conc_vector,1);

%number of timepoints
no_time=size(time,1);

%convert pH values into string for figure labels
pH_string=num2str(pHs);
for r=1:no_expts,if pH_string(r,1:2)=='  ', pH_string(r,1:2)='__'; end, end
for r=1:no_expts,if pH_string(r,2)=='.', pH_string(r,2)='_'; end, end

%%

%ESTIMATE PARAMETERS

%initialise vectors of estimated growth rates and carrying capacities
growth_rate_vector=zeros(no_expts,1);
carrying_cap_scaled_vector=zeros(no_expts,1);

%cycle through conditions
for m=1:no_expts
    
    %identify correct data, pH and concentration
    expt_OD_scaled=scaled_OD(:,m);
    expt_pH=pHs(m);
    expt_conc=concs(m);

    %parameter initial guesses (r is normal growth rate, carrying_capacity
    %scaled is final OD value divided by initial condition)
    growth_rate_guess=0.5;
    carrying_capacity_scaled_guess=(2.^expt_OD_scaled(end));
    
    parameter_guesses=[growth_rate_guess carrying_capacity_scaled_guess];
    
    %estimate parameters
    [estimated_parameters, error, exitflag]=fminsearch(@(par) logged_logisticfitfunction(par,time,expt_OD_scaled),parameter_guesses);

    %store NaN if fitting fails
    if exitflag==0
            estimated_growth_rate=NaN;
            estimated_carrying_capacity_scaled=NaN;
        else
            estimated_growth_rate=abs(estimated_parameters(1));
            estimated_carrying_capacity_scaled=abs(estimated_parameters(2));
    end
    
    %otherwise store parameter estimates
    growth_rate_vector(m,1)=estimated_growth_rate;
    carrying_cap_scaled_vector(m,1)=estimated_carrying_capacity_scaled;
        
end


%%

%PLOT FITTED CURVES AGAINST INDIVIDUAL LOGGED DATA
t=linspace(0,25);

for l=1:5
    figure(l)
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
        for k=1:24
            p=k+(l-1)*24;
    
            expt_OD_scaled=scaled_OD(:,p);
            expt_pH=pHs(p);
            expt_conc=concs(p);
            r=growth_rate_vector(p,1);
            Kstar=carrying_cap_scaled_vector(p,1);
            subplot(4,6,k),plot(time,expt_OD_scaled,'r*'),hold on
            plot(t,log2(Kstar*exp(r*t)./(Kstar+(exp(r*t)-1))),'b')
            xlim([0 25])
            title(['pH = ' num2str(pHs(p)) ', ' num2str(concs(p)) 'mM']);
            xlabel('Hours')
            ylabel('log_2(OD/OD_0)')
    
        end


    saveas(gcf,['acetic_PA01_pH' pH_string(p,:)],'jpeg')
    saveas(gcf,['acetic_PA01_pH' pH_string(p,:)])

end


%%

%calculate mean anad standard deviation of the estimates

%initialise vectors
%growth rate
growth_rate_mean_vector=zeros(no_conditions,1);
growth_rate_SD_vector=zeros(no_conditions,1);
%carrying capacity scaled with initial condition
cc_scaled_mean_vector=zeros(no_conditions,1);
cc_scaled_SD_vector=zeros(no_conditions,1);
%carrying capacity scaled with initial condition and log base 2 taken
cc_mean_scaled_logged_vector=zeros(no_conditions,1);

for n=1:no_conditions
    
    growth_rate_mean_vector(n)=nanmean(growth_rate_vector((1+(n-1)*no_rep):n*no_rep,1));
    growth_rate_SD_vector(n)=nanstd(growth_rate_vector((1+(n-1)*no_rep):n*no_rep,1));
    
    cc_scaled_mean_vector(n)=nanmean(carrying_cap_scaled_vector((1+(n-1)*no_rep):n*no_rep,1));
    cc_scaled_SD_vector(n)=nanstd(carrying_cap_scaled_vector((1+(n-1)*no_rep):n*no_rep,1));
    
    cc_mean_scaled_logged_vector(n)=log2(cc_scaled_mean_vector(n));
    
end

%%

%plot averaged data against averaged fits

figure(100)
set(gcf,'units','normalized','outerposition',[0 0 1 1])

%calculate data averages
averaged_data=zeros(no_time,no_conditions);
for p=1:no_conditions
    for q=1:size(time)
        averaged_data(q,p)=nanmean(scaled_OD(q,(p-1)*no_rep+1:(p-1)*no_rep+no_rep));
    end
end

%calculate standard error of the mean
SEM=zeros(no_time,no_conditions);
for p=1:no_conditions
    for q=1:size(time)
        SEM(q,p)=std(scaled_OD(q,(p-1)*no_rep+1:(p-1)*no_rep+no_rep))/sqrt(no_rep);
    end
end

%plot data (with error bars) and model fit
for w=1:no_conditions
    r=growth_rate_mean_vector(w,1);
    Kstar=cc_scaled_mean_vector(w,1);
    subplot(5,4,w)
    errorbar(time,averaged_data(:,w),SEM(:,w),'r*'),hold on
    plot(t,log2(Kstar*exp(r*t)./(Kstar+(exp(r*t)-1))),'b')
    xlabel('Hours')
    ylabel('log_2(OD/OD_0)')
    title(['pH = ' num2str(pHs(w*no_rep)) ', ' num2str(concs(w*no_rep)) 'mM']);
end

saveas(gcf,'acetic_PA01_averages','jpeg')

%%
%calculate errors for the averaged fits

errors=zeros(no_conditions,1);
for w=1:no_conditions
    r=growth_rate_mean_vector(w,1);
    Kstar=cc_scaled_mean_vector(w,1);
    simulation_points=log2(Kstar*exp(r*time)./(Kstar+(exp(r*time)-1)));
    errors(w,1)=norm(simulation_points-averaged_data(:,w));    
end

%%

%save estimates

%create headings
xlswrite(outputfilename,{'pH'},1,'A1')
xlswrite(outputfilename,{'conc'},1,'B1')
xlswrite(outputfilename,{'mean growth rate'},1,'D1')
xlswrite(outputfilename,{'std growth rate'},1,'E1')
xlswrite(outputfilename,{'interpreted mean growth rate'},1,'F1')
xlswrite(outputfilename,{'mean scaled carrying capacity (K/IC)'},1,'H1')
xlswrite(outputfilename,{'std carrying capacity'},1,'I1')
xlswrite(outputfilename,{'logged,scaled carrying capacity (log2(K/IC)'},1,'J1')
xlswrite(outputfilename,{'error (L2 norm)'},1,'L1')

pH_column=zeros(no_conditions,1);
conc_column=zeros(no_conditions,1);
    
    for z=1:no_conditions
        pH_column(z,1)=pHs(z*no_rep);
        conc_column(z,1)=concs(z*no_rep);
    end
    
%re-interpret growth rates where growth is negative (i.e. growth rate
%should be negative)
growth_rate_mean_vector_reinterpreted=zeros(no_conditions,1);
for z=1:no_conditions
    if cc_scaled_mean_vector(z,1)<1
        growth_rate_mean_vector_reinterpreted(z,1)=-growth_rate_mean_vector(z,1);
    else
        growth_rate_mean_vector_reinterpreted(z,1)=growth_rate_mean_vector(z,1);
    end
end

%store estimates
xlswrite(outputfilename,pH_column,'A2:A21')
xlswrite(outputfilename,conc_column,'B2:B21')

xlswrite(outputfilename,growth_rate_mean_vector,'D2:D21')
xlswrite(outputfilename,growth_rate_SD_vector,'E2:E21')
xlswrite(outputfilename,growth_rate_mean_vector_reinterpreted,'F2:F21')

xlswrite(outputfilename,cc_scaled_mean_vector,'H2:H21')
xlswrite(outputfilename,cc_scaled_SD_vector,'I2:I21')
xlswrite(outputfilename,cc_mean_scaled_logged_vector,'J2:J21')

xlswrite(outputfilename,errors,'L2:L21')
    
   



