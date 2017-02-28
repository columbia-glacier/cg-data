clear all
close all
addpath('..\..\..\..\MatlabUtilities')
data = load('mk111.txt'); %loads output file from xcel. mk/x/y/z/t
data2 = load('mk222.txt'); %loads output file from xcel. mk/x/y/z/t
data3 = load('mk333.txt'); %loads output file from xcel. mk/x/y/z/t
data4 = load('mk444.txt'); %loads output file from xcel. mk/x/y/z/t

t=data(:,5);%mk111
x=data(:,2);
y=data(:,3);
z=data(:,4);

t2=data2(:,5);%mk222
x2=data2(:,2);
y2=data2(:,3);
z2=data2(:,4);


t3=data3(:,5);%mk333
x3=data3(:,2);
y3=data3(:,3);
z3=data3(:,4);

t4=data4(:,5);%mk444
x4=data4(:,2);
y4=data4(:,3);
z4=data4(:,4);


n=length(x);  %number data
for i=1:n-1

t_avg(i)=(t(i+1)+t(i))./2;    %average times
disp(i)=sqrt((x(i+1)-x(i)).^2+(y(i+1)-y(i)).^2);  %displacements (new vector)
end

delta_t=diff(t);   %time intervals between measurements

v=disp./delta_t';  %velocity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2=length(x2);  %number data
for i=1:n2-1

t_avg2(i)=(t2(i+1)+t2(i))./2;    %average times
disp2(i)=sqrt((x2(i+1)-x2(i)).^2+(y2(i+1)-y2(i)).^2);  %displacements (new vector)
end

delta_t2=diff(t2);   %time intervals between measurements

v2=disp2./delta_t2';  %velocity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n3=length(x3);  %number data
for i=1:n3-1

t_avg3(i)=(t3(i+1)+t3(i))./2;    %average times
disp3(i)=sqrt((x3(i+1)-x3(i)).^2+(y3(i+1)-y3(i)).^2);  %displacements (new vector)
end

delta_t3=diff(t3);   %time intervals between measurements

v3=disp3./delta_t3';  %velocity


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n4=length(x4);  %number data
for i=1:n4-1

t_avg4(i)=(t4(i+1)+t4(i))./2;    %average times
disp4(i)=sqrt((x4(i+1)-x4(i)).^2+(y4(i+1)-y4(i)).^2);  %displacements (new vector)
end

delta_t4=diff(t4);   %time intervals between measurements

v4=disp4./delta_t4';  %velocity

% FILTER using HPs non-parametric filter ===========

%Specific Times: 257.5 to 258.75

%Survey interval 0.007 day = 10 minutes

%Dec Day: 0.1 hr = 0.00417

%         0.2 hr = 0.0083

%         0.5 hr = 0.02083

%         1.0 hr = 0.04166

%         4.0 hr = 0.1667

tmin=153.94; tmax=166.511; 

stepsize=1/24; %output data spacing

%winsize=[0.04166, 0.0833, 0.125]; %1hr , 2hr, 6hr
winsize=[1/24]%, 0.0833, 0.125]; %1hr , 2hr, 6hr
color='krg';

%T IS TIME, V IS THE SIGNAL
%%%%%%%%%%%MARKER 1%%%%%%%%%%%%%%%%%%%
%for i=1:3

  %[tmod,vmod]=nonparametric_smooth(t_avg,v,tmin,tmax,stepsize,winsize(i));
  [tmod,vmod]=nonparametric_smooth(t_avg,v,tmin,tmax,stepsize,winsize);
  
figure(1);subplot(2,1,1);
plot(t_avg,v,'*','markersize',2);hold on
%h=plot(tmod,vmod,color(i)); set(h,'linewidth',3); title('Horizontal Velocity, Marker 1'); hold on

h=plot(tmod,vmod); set(h,'linewidth',3); title('Horizontal Velocity, Marker 1'); hold on
subplot(2,1,2);plot(t,z,'-+');title('Vertical Displacement, Marker 1');
%end
%%%%%%%%%%%%%%%%%MArker 2%%%%%%%%%%%%%%%%%%%%%%%
figure(2);subplot(2,1,1);hold on
plot(t_avg2,v2,'r-*');hold on
subplot(2,1,2);plot(t2,z2,'r-*')

%%%%%%%%%%%%%%marker 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmin3=153.9482639; tmax3=167.9586806; 
%for i=1:3

  %[tmod3,vmod3]=nonparametric_smooth(t_avg3,v3,tmin3,tmax3,stepsize,winsize(i));
  [tmod3,vmod3]=nonparametric_smooth(t_avg3,v3,tmin3,tmax3,stepsize,winsize);
  
figure(3);subplot(2,1,1);
plot(t_avg3,v3,'*','markersize',2);hold on
%h=plot(tmod3,vmod3,color(i)); set(h,'linewidth',3); title('Horizontal Velocity'); hold on
h=plot(tmod3,vmod3); set(h,'linewidth',3); title('Horizontal Velocity'); hold on
subplot(2,1,2);plot(t3,z3,'-+');title('Vertical Displacement, Marker 3');
%end

%%%%%%%%%%%%%%marker 4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmin4=159.5336; tmax4=175.2503; 
%for i=1:3

  %[tmod4,vmod4]=nonparametric_smooth(t_avg4,v4,tmin4,tmax4,stepsize,winsize(i));
  [tmod4,vmod4]=nonparametric_smooth(t_avg4,v4,tmin4,tmax4,stepsize,winsize);
  
figure(4);subplot(2,1,1);
plot(t_avg4,v4,'*','markersize',2);hold on
%h=plot(tmod4,vmod4,color(i)); set(h,'linewidth',3); title('Horizontal Velocity'); hold on
h=plot(tmod4,vmod4); set(h,'linewidth',3); title('Horizontal Velocity'); hold on
subplot(2,1,2);plot(t4,z4,'-+');title('Vertical Displacement, Marker 4');
%end

%%%%%%%%%%%%%do some fft's
%%%%MARKER 4
ind = find(isnan(vmod4));
vmod4(ind) = [];

%M4 = fft(v4); %unsmoothed
M4 = fft(vmod4); %smoothed to 1 hr
N = length(M4);
M4(1) = [];
power4 = abs(M4(1:N/2)).^2;
nyquist = 1/2;
freq = (1:N/2)/(N/2)*nyquist;
period = 1./freq;
figure(5);hold on
semilogx(period,power4), axis([0 100 0 3e4]), grid on
ylabel('Power')
xlabel('Period (hours/Cycle)')
%%%%%%%%%%%%%%%%Marker 1
ind2 = find(isnan(vmod));
vmod(ind2) = [];
%M1 = fft(v);%unsmoothed
M1 = fft(vmod); %smoothed to 1 hr intervals
N = length(M1);
M1(1) = [];
power1 = abs(M1(1:N/2)).^2;
nyquist = 1/2;
freq = (1:N/2)/(N/2)*nyquist;
period = 1./freq;
semilogx(period,power1,'r'), axis([0 100 0 3e4]), grid on







