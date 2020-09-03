function ARIMA_Forecast = COVID_19() 
% ===========================================================================================
% ESTIMATION OF COVID DEATHS USING ARIMA MODEL
% The Forecasting of Deaths due to The Corona Virus Pandemic can be done
% by basic ARIMA (Auto Regressive Integration Moving Average) model
% This can be implemented by following steps below
%
% 1. Load Data and abstract its stationary data
% 2. Conduct Hypothesis Test and proceed if succeded
% 3. Generate ACF and PACF that help to find AR and MA range
% 4. Construct an algorithm to find best ARIMA model
% 5. Generate Predictive curve with the selected ARIMA model
% 6. Forecast the future values and compare with real values

% 1.
% Load "Covid_19.xlsx" data and read the required information
Data           = readtable('Covid_19.xlsx','ReadVariableNames',true);
Date           = Data.date;
Death          = Data.dailydeceased;
RealData       = timetable(Date,Death);
tr             = timerange('02-04-2020' , '30-04-2020');
RealData_april = RealData(RealData.Date(tr),:);

% ---------------- Plotting April Data ---------------------------
figure(1),clf
plot(RealData_april.Date,RealData_april.Death,'-k','Linew',2)
set(gcf,'color','white')
title('COVID DEATHS IN APRIL','FontSize',16);
ylabel('no.of Deaths','FontSize',16);
xlabel('Date','FontSize',16);
legend('APRIL','Location','best')
legend('boxoff')
% ------------------- End Plotting -------------------------------

% Transforming Data into Stationary
% Log
RealData_april.DeathLog       = log(RealData_april.Death);
% Remove Linear trend
RealData_april.DeathLogLinear = detrend(RealData_april.Death);
%Perform Differences
DeathLogLinearDifferences     = diff(RealData_april.DeathLogLinear);

% ---------------- Plotting Stationary Data -------------------------------
figure(2),clf
plot(RealData_april.Date,RealData_april.Death,'-k','Linew',2);
hold on
plot(RealData_april.Date,RealData_april.DeathLog,'-r','Linew',2);
plot(RealData_april.Date,RealData_april.DeathLogLinear,'-g','Linew',2);
plot(RealData_april.Date(2:end),DeathLogLinearDifferences,'-b','Linew',2);
hold off
set(gcf,'color','white')
title('Stationary Analysis','FontSize',16);
ylabel('no.of Deaths','FontSize',16);
xlabel('Date','FontSize',16);
legend('Original',...
       '1.Log',...
       '2.DetrendLinear',...
       '3.1st Order Differences',...
       'Location','best')
legend('boxoff')
% ------------------- End Plotting ----------------------------------------

% 2.
% Hypothesis Test
% If Test is valid, h returns 1
% If Test is invalid, h returns 0
[h,~]     = adftest(RealData_april.Death);
count     = 0; %no. of order of differencing
CloseDiff = RealData_april.DeathLogLinear;
% If h returns 1, The differencing is not performed considering order 0
% If h returns 0, The while loop is ran till h returns 1
% The no. of times the loop run is the order of differencing
while h    == 0
 CloseDiff = diff(CloseDiff);   
[h,~]      = adftest(CloseDiff);
count      = count+1;
end
% h appears to be logical 1
display (h)

% 3.
% Plot Auto Correlaion and Partial Auto Correlation of obtained data
% Autocorrelaton function (ACF) determine whether an AR model is appropriate
% and identify significant MA lags for model identification
% Partial ACF (PACF) determine whether an MA model is appropriate
% and identify significant AR lags for model identification.
figure(3),clf
autocorr(CloseDiff)
figure(4),clf
parcorr(CloseDiff)

% 4.
% Checking for best ARIMA model
% ARIMA model with lesser aic, bic values is chosen to be best
a = 10000000;      % Comparative Variable
for i = 1:10       % AR value (validated observing peak in partial correlation)
    for j = count  % order of differencing
        for k= 1:3 % MA value (validated observing peak in auto correlation)
            
            check              = arima(i,j,k);
            [~,~,LoglikehoodE] = estimate(check,RealData_april.Death,'display','off');
            [aicE,bicE]        = aicbic(LoglikehoodE,2,250);
            
            % To find lesser aice valued model
            if aicE < a
                a = aicE;
                b = [i j k];
            else 
            end
            fprintf('ARIMA(%d,%d,%d) = %4.4f, %4.4f\n',i,j,k,aicE,bicE)
                
        end % for k
    end % for j
end % for i

% 5.
% Implementing obtained best ARIMA model
ARIMA_Close                  = arima(b(1),b(2),b(3));
[ARIMA_Close1,~,~] = estimate(ARIMA_Close,RealData_april.Death);
rng(1); 
residual                     = infer(ARIMA_Close1,RealData_april.Death);
prediction                   = RealData_april.Death + residual;

% ---------------- Plotting Predicted Curve ---------------------------
figure(5),clf
plot(RealData_april.Date,RealData_april.Death,'-k','Linew',2);
hold on
plot(RealData_april.Date,prediction,'-r','Linew',2);
hold off
set(gcf,'color','white')
title('COMPARISON OF PREDICTED CURVE TO ORIGINAL','FontSize',16);
ylabel('no.of Deaths','FontSize',16);
xlabel('Date','FontSize',16);
legend('Original','ARIMA SELECTED MODEL','Location','best');
legend('boxoff')
% ------------------- End Plotting -------------------------------------

% 6.
% Forecasting Deaths that occur in MAY 
tr1            = timerange('29-04-2020' , '28-05-2020');
RealData_may   = RealData(RealData.Date(tr1),:);
len            = length(RealData_may.Death);
ARIMA_Forecast = forecast(ARIMA_Close1,len,'Y0',RealData_april.Death);

% ---------------- Plotting Forecasted Curve ---------------------------
figure(6),clf
plot(RealData_april.Date,RealData_april.Death,'k','Linew',2);
hold on
plot(RealData_may.Date,ARIMA_Forecast,'-.>r','Linew',3);
plot(RealData_may.Date,RealData_may.Death,'k','Linew',2);
hold off
set(gcf,'color','white')
title('FORECASTING USING IMPLEMENTED SELECTED ARIMA MODEL','FontSize',16);
ylabel('no.of Deaths','FontSize',16);
xlabel('Dates','FontSize',16);
legend('April','May forecasted','May','Location','best');
legend('boxoff')
% ------------------- End Plotting --------------------------------------
% ===========================================================================================
end