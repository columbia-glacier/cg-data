positions = table2array(readtable('positions.csv'));
t = positions(:, 1);
X = positions(:, 2);
Y = positions(:, 3);
Z = positions(:, 4);

figure(1);
plot(X,Y,'.');

figure(2);
XC = complex(X,Y);
Xdist = cumsum([0;abs(diff(XC))]);
y = 3.6759.*t -643.93; %linear regression
res = Xdist - y;
plot(t,Xdist,'.');

figure(3);
plot(t,res,'.');

figure(4);
Zd = [0;diff(Z)];
Zc = cumsum(Zd);
y2 = -0.142583736022376.*t +25.334994525027046;
zres = Zc - y2;
plot(t,zres)

%%

load GPS_seis %time series of hourly trigger durations
cum_seis = cumsum(GPS_seis(:,2)); %integrate it to resemble the motion
y_seis = 3411.5875.*GPS_seis(:,1) -602921.4697057244;
seis_res = cum_seis - y_seis;

%cum_seis_detrend = detrend(cum_seis);
figure(5); plot(GPS_seis(:,1),cum_seis)
figure(6); plot(GPS_seis(:,1),seis_res)

figure(10);
subplot(2,1,1);hold on
plot(t,res,'.')
ylabel('Along Flow Coordinate [m]');
title('Surface Motion')
axis([170 243 -6 6]);
subplot(2,1,2);
plot(GPS_seis(:,1),seis_res)
xlabel('Time DOY 2004'); ylabel('Cumulative Trigger Duration [s]')
title('Cumulative 1-3 Hz Seismicity')
axis([170 243 1500 30000]);

%%

figure(11);
subplot(2,1,1);hold on; box on;grid on
plot(t,zres,'.')
ylabel('Along Flow Vertical Position [m]');
title('Vertical Surface Motion')
axis([170 243 -0.3 0.3]);
subplot(2,1,2);grid on
plot(GPS_seis(:,1),seis_res);grid on
xlabel('Time DOY 2004'); ylabel('Cumulative Trigger Duration [s]')
title('Cumulative 1-3 Hz Seismicity')
axis([170 243 1500 30000]);

%% FIXME: nonparametric_smooth() not found

[cst_sm csd_sm] = nonparametric_smooth(GPS_seis(:,1),seis_res,170.75,250.75,0.125,0.125);
[cmotiont_sm cmotion_sm] = nonparametric_smooth(t,res,176.75,235.75,0.125,0.125);
[cmotiont_sm cmotionz_sm] = nonparametric_smooth(t,zres,176.75,235.75,0.125,0.125);
figure(20); scatter(cmotion_sm,csd_sm(51:523));
figure(21); scatter(cmotionz_sm,csd_sm(51:523));

%%

csd_sm = csd_sm - nanmean(csd_sm);
cmotion_sm = cmotion_sm - nanmean(cmotion_sm);
cmotion_sm(246) = (cmotion_sm(245) + cmotion_sm(247))/2;
cmotion_sm(261) = (cmotion_sm(260) + cmotion_sm(262))/2;

cmotionz_sm = cmotionz_sm - nanmean(cmotionz_sm);
cmotionz_sm(246) = (cmotionz_sm(245) + cmotionz_sm(247))/2;
cmotionz_sm(261) = (cmotionz_sm(260) + cmotionz_sm(262))/2;

%%

N = length(cmotion_sm);
NN = length(csd_sm);

%%

lag = -(6*8):1:(15*8); %neg lag means seis preceeds delta A ==> seis forces area change; pos lag area forces seis
L = length(lag);

for h = 1:L
  [rho(h) pval(h)] = corr(csd_sm(h:NN-(L-h))',cmotion_sm(1:N)'); %pearson r
  [rho_k(h) pval_k(h)] = corr(csd_sm(h:NN-(L-h))',cmotion_sm(1:N)','type','kendall'); %pearson r
  [rho_sp(h) pval_sp(h)] = corr(csd_sm(h:NN-(L-h))',cmotion_sm(1:N)','type','spearman'); %pearson r

  [rhoz(h) pvalz(h)] = corr(csd_sm(h:NN-(L-h))',cmotionz_sm(1:N)'); %pearson r
  [rhoz_k(h) pvalz_k(h)] = corr(csd_sm(h:NN-(L-h))',cmotionz_sm(1:N)','type','kendall'); %pearson r
  [rhoz_sp(h) pvalz_sp(h)] = corr(csd_sm(h:NN-(L-h))',cmotionz_sm(1:N)','type','spearman'); %pearson r
end

%%

minrho = find(rho == min(rho));
minvalx = [lag(minrho)./8 lag(minrho)./8]; minvaly = [-0.8 0.1];
maxrho = find(rho == max(rho));
maxvalx = [lag(maxrho)./8 lag(maxrho)./8];

minrhoz = find(rhoz == min(rhoz));
minvalzx = [lag(minrhoz)./8 lag(minrhoz)./8];
maxrhoz = find(rhoz == max(rhoz));
maxvalzx = [lag(maxrhoz)./8 lag(maxrhoz)./8];

%%

limx =[0 0];limy = [-0.8 0.1];
lim2x =[-6 15];lim2y = [-0 0];

figure(19); hold on;box on
plot(lag./8,rho)
plot(lag./8,rho_k,':')
plot(lag./8,rho_sp,'--')
plot(minvalx, minvaly,'r:')
plot(maxvalx, minvaly,'r:')
plot(limx,limy,'k:')
plot(lim2x,lim2y,'k:')
axis([-6 15 -0.8 0.1])
xlabel('Lag [d]');ylabel('Correlation');title('Horizontal Motion')

%%

figure(29); hold on;box on
plot(lag./8,rhoz)
plot(lag./8,rhoz_k,':')
plot(lag./8,rhoz_sp,'--')
plot(minvalzx, minvaly,'r:')
plot(maxvalzx, minvaly,'r:')
plot(limx,limy,'k:')
plot(lim2x,lim2y,'k:')
axis([-6 15 -0.8 0.1])
xlabel('Lag [d]');ylabel('Correlation');title('Vertical Motion')
