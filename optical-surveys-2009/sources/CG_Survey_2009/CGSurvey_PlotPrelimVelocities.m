%% Plot preliminary data from May 2009 CG Survey
clear all
cd C:\MyFiles\Columbia\Field_2009\CG_Survey_2009
load CGSurveyMay2009_PrelimData
%% Calculate velocities
Time = data(2:end,1);
Ve = (data(2:end,2)-data(1:end-1,2))./(data(2:end,1)-data(1:end-1,1));
Vn = (data(2:end,3)-data(1:end-1,3))./(data(2:end,1)-data(1:end-1,1));
Vh = (Ve.*Ve + Vn.*Vn).^0.5;
Vz = (data(2:end,4)-data(1:end-1,4))./(data(2:end,1)-data(1:end-1,1));
%% Plot the data
figure(1); clf
subplot(3,1,1)
plot(Time, Vh)
subplot(3,1,2)
plot(Time, Vz)
subplot(3,1,3)
plot(Time,data(2:end,4))