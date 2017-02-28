%plot target paths
close all
clear all

load bounds.txt
xbound = bounds(:,1) - 490000.0;
ybound = bounds(:,2) -6770000.0;

load terminus_178_04.txt; %note plotting 2004 terminus!!  no 2005 data avail.

xterm = terminus_178_04(:,1)-490000.0;
yterm = terminus_178_04(:,2)-6770000.0;
Gn = 6775852.739-6770000.0; %gun coords
Ge =  497126.859- 490000.0;

load marker1_UTM %[t x y z]
load marker3_UTM
load marker4_UTM

t1= marker1(:,1); %time
t3= marker3(:,1);
t4= marker4(:,1);

%%
figure(1); hold on;box on;grid on
plot(xbound,ybound,'k.'); axis equal %([3000 9000 3000 9000]);
plot(xterm,yterm,'b-')
plot(marker1(:,2)-490000.0,marker1(:,3)-6770000.0,'o')
plot(marker3(:,2)-490000.0,marker3(:,3)-6770000.0,'o r')
plot(marker4(:,2)-490000.0,marker4(:,3)-6770000.0,'o g')
plot(marker4(252,2)-490000.0,marker4(252,3)-6770000.0,'k*') %major calving, slope changes in other markers; where is this one?
%plot(Ge,Gn,'x k')
legend('margin','terminus', 'm1','m3','m4')
%%
m1C = complex(marker1(:,2),marker1(:,3));
m3C = complex(marker3(:,2),marker3(:,3));
m4C = complex(marker4(:,2),marker4(:,3));

m1dist = cumsum([0;abs(diff(m1C))]);
m3dist = cumsum([0;abs(diff(m3C))]);
m4dist = cumsum([0;abs(diff(m4C))]);

y1 = 12.214.*t1 -1881.5; %linear regression
m1res = m1dist - y1;

y3 = 12.073.*t3 -1859.8; %linear regression
m3res = m3dist - y3;

y4 = 12.441.*t4 -1991.1; %linear regression
m4res = m4dist - y4;

%%
figure(2); hold on
plot(t1,m1res,'.')
plot(t3,m3res,'r.')
plot(t4,m4res,'g.')
box on
load big_calves_lines.txt

N = length(big_calves_lines(:,1));

for i = 1:2:N
plot(big_calves_lines(i:i+1,1),big_calves_lines(i:i+1,2))
end
axis([153 176 -5 7]);




z1= marker1(:,4)- 849.17; %constant offset UTM- local
z3= marker3(:,4)- 849.17;
z4= marker4(:,4)- 849.17;

%quadratics fit nicely to each record, remove and plot residuals
z1quad = (-0.027447.*t1.^2) + (8.3823 .* t1) - 538.19;
z1res = z1-z1quad;

z3quad = (-0.044806.*t3.^2) + (14.354 .* t3) - 1053.9;
z3res = z3-z3quad;

z4quad = (-0.012681.*t4.^2) + (3.6376 .* t4) - 151.13;
z4res = z4-z4quad;


figure(3); hold on
plot(t1,z1res,'.')
plot(t3,z3res,'r.')
plot(t4,z4res,'g.')
box on
load big_calves_lines.txt

N = length(big_calves_lines(:,1));

for i = 1:2:N
plot(big_calves_lines(i:i+1,1),big_calves_lines(i:i+1,2))
end
axis([153 176 -2 2]);




%Lets look at the seismics
load survey_seis %time series of hourly trigger durations
cum_seis = cumsum(survey_seis(:,2)); %integrate it to resemble the motion
ycalve = 4594.85.*survey_seis(:,1) - 706455.1611;
res_seis = cum_seis - ycalve;


figure(5); plot(survey_seis(:,1),res_seis,'.')

%%
figure(10); subplot(2,1,1);hold on
plot(t1,m1res,'.')
plot(t3,m3res,'r .')
plot(t4,m4res,'g .')
box on
load big_calves_lines.txt

N = length(big_calves_lines(:,1));

for i = 1:2:N
plot(big_calves_lines(i:i+1,1),big_calves_lines(i:i+1,2),'k:')
end
ylabel('Along Flow Coordinate [m]');
title('Surface Motion')
axis([150 180 -5 7]);

subplot(2,1,2); hold on; box on
plot(survey_seis(:,1),res_seis)

N = length(big_calves_lines(:,1));

for i = 1:2:N
plot(big_calves_lines(i:i+1,1),big_calves_lines(i:i+1,2),'k:')
end
axis([150 180 -7000 15000]);
xlabel('Time DOY 2005'); ylabel('Cumulative Trigger Duration [s]')
title('Cumulative 1-3 Hz Seismicity')
%%

figure(20); subplot(2,1,1);hold on
plot(t1,z1res,'.')
plot(t3,z3res,'r .')
plot(t4,z4res,'g .')
box on
load big_calves_lines.txt

N = length(big_calves_lines(:,1));

for i = 1:2:N
plot(big_calves_lines(i:i+1,1),big_calves_lines(i:i+1,2),'k:')
end
ylabel('Vertical Coordinate [m]');
title('Surface Motion')
axis([150 180 -1 1]);

subplot(2,1,2);hold on; box on
plot(survey_seis(:,1),res_seis)

N = length(big_calves_lines(:,1));
axis([150 180 -7000 15000]);
for i = 1:2:N
plot(big_calves_lines(i:i+1,1),big_calves_lines(i:i+1,2),'k:')
end

xlabel('Time DOY 2005'); ylabel('Cumulative Trigger Duration [s]')
title('Cumulative 1-3 Hz Seismicity')
%%
[cst_sm csd_sm] = nonparametric_smooth(survey_seis(:,1),res_seis,151.6,185.25,1/24,1/24);
%Horizontal
[cmotiont_sm dummy] = nonparametric_smooth(t4,m4res,159.6,175.25,1/24,1/24);
cmotion_sm = interp1(t4, m4res,cmotiont_sm); %linear interpolate to avoid NaN's
figure(30); scatter(cmotion_sm,csd_sm(193:568));
%vertical
[cmotionzt_sm dummyz] = nonparametric_smooth(t4,z4res,159.6,175.25,1/24,1/24);
cmotionz_sm = interp1(t4, z4res,cmotionzt_sm); %linear interpolate to avoid NaN's

figure(31); scatter(cmotionz_sm,csd_sm(193:568),'dr');
%%
csd_sm = csd_sm - nanmean(csd_sm);
cmotion_sm = cmotion_sm - nanmean(cmotion_sm);
cmotionz_sm = cmotionz_sm - nanmean(cmotionz_sm);

%%
N = length(cmotion_sm);
NN = length(csd_sm);
%%
lag = -(8*24):1:(10*24); %neg lag means seis preceeds delta A ==> seis forces area change; pos lag area forces seis
L = length(lag);

for h = 1:L
    [rho(h) pval(h)] = corr(csd_sm(h:NN-(L-h))',cmotion_sm(1:N)'); %pearson r
    [rho_k(h) pval_k(h)] = corr(csd_sm(h:NN-(L-h))',cmotion_sm(1:N)','type','Kendall'); %pearson r
    [rho_sp(h) pval_sp(h)] = corr(csd_sm(h:NN-(L-h))',cmotion_sm(1:N)','type','Spearman'); %pearson r
    
    
    [rhoz(h) pvalz(h)] = corr(csd_sm(h:NN-(L-h))',cmotionz_sm(1:N)'); %pearson r
    [rhoz_k(h) pvalz_k(h)] = corr(csd_sm(h:NN-(L-h))',cmotionz_sm(1:N)','type','Kendall'); %pearson r
    [rhoz_sp(h) pvalz_sp(h)] = corr(csd_sm(h:NN-(L-h))',cmotionz_sm(1:N)','type','Spearman'); %pearson r
   
end
%%
minrho = find(rho == min(rho));
minvalx = [lag(minrho)./24 lag(minrho)./24]; minvaly = [-0.8 1];

maxrho = find(rho == max(rho));
maxvalx = [lag(maxrho)./24 lag(maxrho)./24];
limx =[0 0];limy = [-0.8 1];
lim2x =[-8 10];lim2y = [-0 0];
%%
figure(19); hold on;box on
plot(lag./24,rho)
plot(lag./24,rho_k,':')
plot(lag./24,rho_sp,'--')
plot(minvalx, minvaly,'r:')
plot(maxvalx, minvaly,'r:')
plot(limx,limy,'k:')
plot(lim2x,lim2y,'k:')
xlabel('Lag [d]');ylabel('Correlation');title('Horizontal Motion')
%%
minrhoz = find(rhoz == min(rhoz));
 minvalxz = [lag(minrhoz)./24 lag(minrhoz)./24];
 
 maxrhoz = find(rhoz == max(rhoz));
 maxvalxz = [lag(maxrhoz)./24 lag(maxrhoz)./24];
limx =[0 0];limy = [-0.8 1];
lim2x =[-8 10];lim2y = [-0 0];
figure(190); hold on;box on
plot(lag./24,rhoz)
plot(lag./24,rhoz_k,':')
plot(lag./24,rhoz_sp,'--')
plot(minvalxz, minvaly,'r:')
plot(maxvalxz, minvaly,'r:')
plot(limx,limy,'k:')
plot(lim2x,lim2y,'k:')
xlabel('Lag [d]');ylabel('Correlation');title('Vertical Motion')