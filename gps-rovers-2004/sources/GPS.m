%given t,X,Y,Z file for GPS coordinates of a rx on a glacier, this script
%gives the average postion for plotting on a location map, then gives
%velocity, horizontal velocity and plots these as a function of time.
clear all
close all

load positions.txt; %columbia 2004 positions in UTM NAD27 local time
t = positions(:,1);
x = positions(:,3);
y = positions(:,2);
z = positions(:,4);

Emean = mean(x)-490000
Nmean = mean(y)-6700000

len = length(t);

dx = diff(x);
dy = diff(y);
dz = diff(z);
dt = diff(t);

dist = sqrt(dx.^2 + dy.^2 +dz.^2);
Hdist = sqrt(dx.^2 +dy.^2);
v = dist./dt;
Hv = Hdist./dt;


for j = 1:len-1
    avgt(j) = t(j) +dt(j);
end

figure(1); hold on
%plot(avgt,Hv)
plot(avgt,v,'r -x','markersize',3)
xlabel('Julian Day 2004'); ylabel('Ice Speed (m d^{-1})')
figure(2); plot(t,z)
