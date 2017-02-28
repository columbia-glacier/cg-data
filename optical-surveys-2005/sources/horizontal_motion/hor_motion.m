clear all
close all



load marker4

t4= marker4(:,1);
x4= marker4(:,2);
y4= marker4(:,3);


%marker 4
n4=length(x4);  %number data
for i=1:n4-1

t_avg4(i)=(t4(i+1)+t4(i))./2;    %average times
disp4(i)=sqrt((x4(i+1)-x4(i)).^2+(y4(i+1)-y4(i)).^2);  %displacements (new vector)
end

delta_t4=diff(t4);   %time intervals between measurements

v4=disp4./delta_t4';  %velocity

tmin=154; tmax=176; 
stepsize=0.5/24; 
winsize=3/24;

[t4_sm,v4_sm]=nonparametric_smooth(t_avg4,v4,tmin,tmax,stepsize,winsize);


figure(1)
subplot(2,1,1);hold on
plot(t_avg4,v4,'k');axis([154 176 8 20])
plot(t4_sm, v4_sm,'r','linewidth',3)


cd ../verticalanalysis
clear all
load marker4
t4= marker4(:,1);
z4= marker4(:,4)- 849.17;

z4quad = (-0.012681.*t4.^2) + (3.6376 .* t4) - 151.13;
z4res = z4-z4quad;

tmin=154; tmax=176; 
stepsize=0.5/24; 
winsize=4/24;
[t4_sm,z4res_sm]=nonparametric_smooth(t4,z4res,tmin,tmax,stepsize,winsize);


subplot(2,1,2);hold on
plot(t4,z4res,'k');axis([152 176 -0.7 .7])
plot(t4_sm, z4res_sm,'r','linewidth',3)


