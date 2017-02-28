clear all
close all


%% Plot June 2008 Columbia Survey Data
DataHome = '/Users/shad/Documents/glaciers/Icy_bay/yahtse_optical_june2010/plots';
cd(DataHome);


load marker222_6_2010.txt

%% Separate variables

%marker 222
T2 = marker222_6_2010(:,2);
E2 = marker222_6_2010(:,3);
N2 = marker222_6_2010(:,4);
Z2 = marker222_6_2010(:,5);

dE2 = diff(E2);
dN2 = diff(N2);
dT2 = diff(T2);

n2=length(T2);  %number data
for i=1:n2-1

t_avg2(i)=(T2(i+1)+T2(i))./2;    %average times
 
end

v2 = (sqrt((dE2.^2) + (dN2.^2)))./dT2;


%% Plot trajectories
figure(1);
plot(E2,N2); hold on

xlabel('Easting [m]'); ylabel('Northing [m]')
title('Marker trajectories in local reference frame')


figure(2)
plot(T2,E2-mean(E2))
hold on

xlabel('Time [d]'); ylabel('Easting')

figure(3)
plot(T2,N2-mean(N2))
hold on
plot(T2,N2-mean(N2),'g')

xlabel('Time [d]'); ylabel('Northing')

figure(4)
plot(T2,Z2-mean(Z2),'bx-')
hold on


xlabel('Time [d]'); ylabel('Elevation')



figure(5);
plot(t_avg2,v2,'b')
hold on

xlabel('Time [d]'); ylabel('Horizontal speed')

%Dec Day: 0.1 hr = 0.00417

%         0.2 hr = 0.0083

%         0.5 hr = 0.02083

%         1.0 hr = 0.04166

%         4.0 hr = 0.1667

tmin=152.0759; tmax=162.5212; 

stepsize=0.02083; 

winsize=[0.04166, 0.25 0.5];

color='krg';

%T IS TIME, V IS THE SIGNAL

for i=1:3

  [tmod,vmod]=nonparametric_smooth(t_avg2,v2',tmin,tmax,stepsize,winsize(i));
figure(5);
  h=plot(tmod,vmod,color(i)); set(h,'linewidth',3); 

end


for i=1:3
Z2_star = Z2-mean(Z2);
  [tmod,zmod]=nonparametric_smooth(T2,Z2_star,tmin,tmax,stepsize,winsize(i));
figure(4);
  h=plot(tmod,zmod,color(i)); set(h,'linewidth',3); 

end


