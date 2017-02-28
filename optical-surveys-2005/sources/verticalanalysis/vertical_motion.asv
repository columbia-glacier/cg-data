%vertical survey data reduction

clear all
close all


load marker1 %[t x y z]
load marker3
load marker4

t1= marker1(:,1);
z1= marker1(:,4)- 849.17; %constant offset UTM- local

t3= marker3(:,1);
z3= marker3(:,4)- 849.17;

t4= marker4(:,1);
z4= marker4(:,4)- 849.17;


%quadratics fit nicely to each record, remove and plot residuals
z1quad = (-0.027447.*t1.^2) + (8.3823 .* t1) - 538.19;
z1res = z1-z1quad;

z3quad = (-0.044806.*t3.^2) + (14.354 .* t3) - 1053.9;
z3res = z3-z3quad;

z4quad = (-0.012681.*t4.^2) + (3.6376 .* t4) - 151.13;
z4res = z4-z4quad;



%%%vertical velocity%%%
len = length(t1);
dt1 = diff(t1);
dz1 = diff(z1);
dz1dt=dz1./dt1;
for i = 1:len-1
    t1_avg(i) = t1(i) + (t1(i+1)-t1(i))/2;
end
t1_avg = t1_avg';

len = length(t3);
dt3 = diff(t3);
dz3 = diff(z3);
dz3dt=dz3./dt3;
for i = 1:len-1
    t3_avg(i) = t3(i) + (t3(i+1)-t3(i))/2;
end
t3_avg = t3_avg';


len = length(t4);
dt4 = diff(t4);
dz4 = diff(z4);
dz4dt=dz4./dt4;
for i = 1:len-1
    t4_avg(i) = t4(i) + (t4(i+1)-t4(i))/2;
end
t4_avg = t4_avg';

%smooth residuals
tmin=154; tmax=176; 
stepsize=0.5/24; 
winsize=4/24;

[t1_sm,z1res_sm]=nonparametric_smooth(t1,z1res,tmin,tmax,stepsize,winsize);
[t3_sm,z3res_sm]=nonparametric_smooth(t3,z3res,tmin,tmax,stepsize,winsize);
[t4_sm,z4res_sm]=nonparametric_smooth(t4,z4res,tmin,tmax,stepsize,winsize);


figure(1);subplot(3,1,1);  %plot raw data
plot(t1,z1);axis([152 176 96 102.5]);hold on; plot(t1,z1quad,'c--');legend('data','fit');
subplot(3,1,2);
plot(t3,z3,'r');axis([152 176 92 96]);hold on; plot(t3,z3quad,'m--');
subplot(3,1,3);
plot(t4,z4,'k');axis([152 176 95 107.8]);hold on; plot(t4,z4quad,'g--');


figure(2);subplot(3,1,1);hold on  %plot quadratic residuals
plot(t1,z1res);axis([152 176 -0.3 0.3])
plot(t1_sm, z1res_sm,'r','linewidth',3)
subplot(3,1,2);hold on
plot(t3,z3res,'g');axis([152 176 -0.7 .7])
plot(t3_sm, z3res_sm,'r','linewidth',3)
subplot(3,1,3);hold on
plot(t4,z4res,'k');axis([152 176 -0.7 .7])
plot(t4_sm, z4res_sm,'r','linewidth',3)


figure(3);subplot(3,1,1);  %plot vertical velocity data
plot(t1_avg,dz1dt);axis([152 176 -10 10])
subplot(3,1,2);
plot(t3_avg,dz3dt,'r');axis([152 176 -10 10])
subplot(3,1,3);
plot(t4_avg,dz4dt,'k');axis([152 176 -10 10])