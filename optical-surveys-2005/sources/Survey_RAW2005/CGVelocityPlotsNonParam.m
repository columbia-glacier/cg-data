close all
clear all

%Modified 26 Februatry 2006
%Day number error corrected in mat files
%CG333TrajectoryData
%and
%CG111TrajectoryData
%But possible 3-hr offset in camera time
%not yet resolved

%Input data is averaged (F&R) direct coordinates from gun.
%Reference drift and noise not corrected 
k=5; 

load CG05E_5June10AM_6June6PM.mat
l333 = size(CG333TrajectoryData);
l111 = size(CG111TrajectoryData);
%111 data
t111=CG111TrajectoryData(1:l111,1);
Nc111=CG111TrajectoryData(1:l111,2);
Ec111=CG111TrajectoryData(1:l111,3);
Zc111=CG111TrajectoryData(1:l111,4);

%333 data
t333=CG333TrajectoryData(1:l333,1);
Nc333=CG333TrajectoryData(1:l333,2);
Ec333=CG333TrajectoryData(1:l333,3);
Zc333=CG333TrajectoryData(1:l333,4);


%----------- Toggle these by comment -------------------
%Do 111
% t = t111;
% nn = Nc111;
% ee = Ec111;
% zz = Zc111;
% n=l111;  

%Do 333 
t = t333;
nn = Nc333;
ee = Ec333;
zz = Zc333;
n=l333;  
%-------------------------------------------------

%Difference Times and Coordinates
k=1;
for i=1:n-k
delta_t(i)=t(i+k)-t(i);
t_avg(i)=(t(i+k)+t(i))./2;    %average times
hdisp(i)=sqrt((nn(i+k)-nn(i)).^2+(ee(i+k)-ee(i)).^2);%displacements (new vector)
vdisp(i)=zz(i+k)-zz(i);
end

vh=hdisp./delta_t;  %horizontal velocity
vz=vdisp./delta_t;
% fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
figure(1); clf
plot(t_avg,vh,'.','MarkerSize', 20)
hold on
%Plot Horizontal velocity
% ----------------------------------------------
% now plot non-parametric density estimate 
%
%Dec Day: 0.5 hr = 0.02083
%         1.0 hr = 0.04166
%         4.0 hr = 0.1667
%         6.0 hr = 0.25
%        12.0 hr = 0.5
tmin=min(t_avg); tmax=max(t_avg); 
stepsize=0.001; 
winsize=[0.01 0.02 0.05];

color='krb'
for i=1:3
  [tmod,vmod]=nonparametric_smooth(t_avg,vh,tmin,tmax,stepsize,winsize(i));
  h=plot(tmod,vmod,color(i)); set(h,'linewidth',1);
end

xlabel('Dec day')
ylabel('Horizontal Velocity (m/d)')

plot(t_avg,vh,'.','MarkerSize', 20)
hold on
% fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
figure(2);
plot(t_avg,vz,'.','MarkerSize', 20)
hold on

% ----------------------------------------------
% now plot non-parametric density estimate 
%
%Dec Day: 0.5 hr = 0.02083
%         1.0 hr = 0.04166
%         4.0 hr = 0.1667
%         6.0 hr = 0.25
%        12.0 hr = 0.5
tmin=min(t_avg); tmax=max(t_avg); 
stepsize=0.001; 
winsize=[0.01 0.02 0.05];

color='kgy'
for i=1:3
  [tmod,vmod]=nonparametric_smooth(t_avg,vz,tmin,tmax,stepsize,winsize(i));
  h=plot(tmod,vmod,color(i)); set(h,'linewidth',1);
end

%legend('measured signal','NPDE, winsize=0.0125 s','NPDE, winsize=0.0250 s','NPDE, winsize=0.0500 s')
xlabel('Dec day')
ylabel('Vertical Velocity (m/d)')
% fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

