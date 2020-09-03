# Forecasting-spread-of-COVID19
Forecasting the spread of COVID-19 epedemic over India Region using ARIMA (p,d,q) model
The Forecasting helps to take appropriate measures by Indian Government to control virus pandemic. 
The Forecasting of Deaths due to The Corona Virus Pandemic can be done by basic ARIMA (Auto Regressive Integration Moving Average) model. This can be implemented by following.
    1.	Load Data and abstract its stationary data. If the data isn’t stationary, perform differencing until the data gets stationary
    2.	Conduct Hypothesis Test and proceed if succeeded (h = logical 1)
    3.	Generate Auto Correlation and Partial Auto Correlation that help to find AR and MA range
    4.	Construct an algorithm to find best ARIMA model
    5.	Generate Predictive curve with the selected ARIMA model and compare with original data
    6.	Forecast the future values and compare with real values
