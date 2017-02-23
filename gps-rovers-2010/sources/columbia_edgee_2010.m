function columbia_edgee_2010

% s1r1 = grafnav_ascii_read('S1R1.txt');
% s1r2 = grafnav_ascii_read('S1R2.txt');
% s1r3 = grafnav_ascii_read('S1R3.txt');
% 
% s2r1 = grafnav_ascii_read('S2R1.txt');
% s2r2 = grafnav_ascii_read('S2R2.txt');
% s2r3 = grafnav_ascii_read('S2R3.txt');
% save columbia2010_edgee.mat s1r1 s1r2 s1r3 s2r1 s2r2 s2r3


load columbia2010_edgee.mat s1r1 s1r2 s1r3 s2r1 s2r2 s2r3

% % plot raw data time series in each coordinate. overlay with only points
% % for quality 1 and 2. Visually assess how good the filter is.
% 
% raw_vs_filt_plots(s1r1,2,'S1R1');
% % Almost continuous data for 1st ~10 days (break on May 22/23rd, 
% % intermittent till 6/13. 
% 
% raw_vs_filt_plots(s1r2,2,'S1R2');
% % continuous data until 23, intermittent till 6/13. Time break on 23rd
% % looks like it overlaps s1r1. Data until May 29.
% 
% raw_vs_filt_plots(s1r3,2,'S1R3');
% %data for only ~20 hours, big perturbation at 08:00 UTC.
% 
% raw_vs_filt_plots(s2r1,2,'S2R1');
% % maybe need to to increase the quality filter on S2? 
% % data until 6/15 with frequent gaps - power failures?
% 
% raw_vs_filt_plots(s2r2,2,'S2R2');
% % data until 6/10 with frequent gaps - power failures?
% 
% raw_vs_filt_plots(s2r3,2,'S2R3');
% % data until 5/30 with frequent gaps - power failures?


%break up stations that were relocated:
n = 1:2215;
r = structfun(@(x) ( x(n) ), s2r1, 'UniformOutput', false);
n = 2216:length(s2r1.t);
r(2) = structfun(@(x) ( x(n) ), s2r1, 'UniformOutput', false);
s2r1 = r;

n = 1:3439;
r = structfun(@(x) ( x(n) ), s2r2, 'UniformOutput', false);
n = 3441:3755;
r(2) = structfun(@(x) ( x(n) ), s2r2, 'UniformOutput', false);
n = 3756:length(s2r2.t);
r(3) = structfun(@(x) ( x(n) ), s2r2, 'UniformOutput', false);
s2r2 = r;


n = 1:1918;
r = structfun(@(x) ( x(n) ), s2r3, 'UniformOutput', false);
n = 1919:2190;
r(2) = structfun(@(x) ( x(n) ), s2r3, 'UniformOutput', false);
n = 2195:length(s2r3.t);
r(3) = structfun(@(x) ( x(n) ), s2r3, 'UniformOutput', false);
s2r3 = r;

%% filter and rotate the data along flow
s1r1 = filter_rotate(s1r1,2);
s1r2 = filter_rotate(s1r2,2);
s1r3 = filter_rotate(s1r3,2);
s2r1 = filter_rotate(s2r1,2);
s2r2 = filter_rotate(s2r2,2);
s2r3 = filter_rotate(s2r3,2);


% %% Along-flow displacement plot
% figure;
% set(gcf,'position',[400,400,1000,700],'color','w');
% plot(s1r1.t,s1r1.dx,'ob','markerfacecolor','b'); hold on;
% plot(s1r2.t,s1r2.dx,'og','markerfacecolor','g'); hold on;
% plot(s1r3.t,s1r3.dx,'or','markerfacecolor','r'); hold on;
% 
% p1 = polyfit(s1r1.t,s1r1.dx,1);
% p2 = polyfit(s1r2.t,s1r2.dx,1);
% p3 = polyfit(s1r3.t,s1r3.dx,1);
% 
% plot(s1r1.t(1):s1r1.t(end),polyval(p1,s1r1.t(1):s1r1.t(end)),'linewidth',1.5);
% plot(s1r2.t(1):s1r2.t(end),polyval(p2,s1r2.t(1):s1r2.t(end)),'g','linewidth',1.5);
% plot(s1r3.t(1):s1r3.t(end),polyval(p3,s1r3.t(1):s1r3.t(end)),'r','linewidth',1.5);
% 
% ht(1) = text(s1r1.t(end)+.5,s1r1.dx(end),[num2str(round(365*p1(1))),' m a^-^1']);
% ht(2) = text(s1r2.t(end)+1,s1r2.dx(end),[num2str(round(365*p2(1))),' m a^-^1']);
% ht(3) = text(s1r3.t(end)+1,s1r3.dx(end),[num2str(round(365*p3(1))),' m a^-^1']);
% 
% set(ht,'fontname','futura','fontsize',14);
% 
% set(gca,'fontname','futura','fontsize',14);
% legend('S1R1','S1R2','S1R3','location','southeast')
% 
%    
% ylabel('Displacement along avg. flow direction (m)')
% xlabel('Day of 2010')
% 
% figure;
% set(gcf,'position',[400,400,1000,700],'color','w');
% p1 = polyfit(s1r1.t(s1r1.t < 143),s1r1.dx(s1r1.t < 143),1);
% plot(s1r1.t,s1r1.dx- polyval(p1,s1r1.t),'ob'); hold on;
% p2 = polyfit(s1r2.t(s1r2.t < 143),s1r2.dx(s1r2.t < 143),1);
% plot(s1r2.t,s1r2.dx- polyval(p2,s1r2.t),'og'); hold on;
% 
% set(gca,'fontname','futura','fontsize',14);
% legend(['S1R1, ',num2str(p1(1)),'md^-^1'],['S1R2, ',num2str(p2(1)),'md^-^1'])
% 
% ylabel('Detrended displacement along avg. flow direction (m)')
% xlabel('Day of 2010')


%% S1 POlynomial fitting
p1 = polyfit(s1r1.t,s1r1.dx,5);
ti1 = s1r1.t(1):.1:s1r1.t(end);
res1= polyval(p1,s1r1.t) - s1r1.dx;
rmse(res)
dxi1 = polyval(p1,ti1);

p2 = polyfit(s1r2.t,s1r2.dx,5);
ti2 = s1r2.t(1):.1:s1r2.t(end);
res2= polyval(p2,s1r2.t) - s1r2.dx;
rmse(res2)
dxi2 = polyval(p2,ti2);

p3 = polyfit(s1r3.t,s1r3.dx,5);
ti3 = s1r3.t(1):.1:s1r3.t(end);
res3= polyval(p3,s1r3.t) - s1r3.dx;
rmse(res3)
dxi3 = polyval(p3,ti3);


figure;
set(gcf,'position',[400,400,800,1300],'color','w');
ax1 = subplot(3,1,1)
plot(s1r1.t,s1r1.dx,'o'); hold on;
plot(s1r2.t,s1r2.dx,'or'); hold on;
plot(s1r3.t,s1r3.dx,'og'); hold on;

plot(ti1,dxi1,'k')
plot(ti2,dxi2,'k')
plot(ti3,dxi3,'k')

set(gca,'fontname','futura','fontsize',14);
ylabel('Displacement (m)');
legend('S1R1','S1R2','S1R3','location','southeast')


ax2 = subplot(3,1,2)
plot(s1r1.t,res1,'.'); hold on
plot(s1r2.t,res2,'.r')
plot(s1r3.t,res3,'.g')
set(gca,'fontname','futura','fontsize',14);
ylabel('Residual (m)');

ax3 = subplot(3,1,3)
plot(ti1(2:end),diff(dxi1)*10,'linewidth',2); hold on
plot(ti2(2:end),diff(dxi2)*10,'r','linewidth',2)
plot(ti3(2:end),diff(dxi3)*10,'g','linewidth',2)

set(gca,'fontname','futura','fontsize',14);
ylabel('Speed (m d^-^1)');

xlabel('Day of 2010')


%% S2 POlynomial fitting
p1 = polyfit(s2r1(2).t,s2r1(2).dx,5);
ti1 = s2r1(2).t(1):.1:s2r1(2).t(end);
res1= polyval(p1,s2r1(2).t) - s2r1(2).dx;
rmse(res)
dxi1 = polyval(p1,ti1);

p2 = polyfit(s2r2(3).t,s2r2(3).dx,5);
ti2 = s2r2(3).t(1):.1:s2r2(3).t(end);
res2= polyval(p2,s2r2(3).t) - s2r2(3).dx;
rmse(res2)
dxi2 = polyval(p2,ti2);

p3 = polyfit(s2r3(3).t,s2r3(3).dx,5);
ti3 = s2r3(3).t(1):.1:s2r3(3).t(end);
res3= polyval(p3,s2r3(3).t) - s2r3(3).dx;
rmse(res3)
dxi3 = polyval(p3,ti3);


figure;
set(gcf,'position',[400,400,800,1300],'color','w');
ax1 = subplot(3,1,1)
plot(s2r1(2).t,s2r1(2).dx,'o'); hold on;
plot(s2r2(3).t,s2r2(3).dx,'or'); hold on;
plot(s2r3(3).t,s2r3(3).dx,'og'); hold on;

plot(ti1,dxi1,'k')
plot(ti2,dxi2,'k')
plot(ti3,dxi3,'k')

set(gca,'fontname','futura','fontsize',14);
ylabel('Displacement (m)');
legend('S2R1','S2R2','S2R3','location','southeast')


ax2 = subplot(3,1,2)

plot(s2r2(3).t,res2,'or'); hold on
plot(s2r3(3).t,res3,'og')
plot(s2r1(2).t,res1,'o')
set(gca,'fontname','futura','fontsize',14);
ylabel('Residual (m)');

ax3 = subplot(3,1,3)
plot(ti1(2:end),diff(dxi1)*10,'linewidth',2); hold on
plot(ti2(2:end),diff(dxi2)*10,'r','linewidth',2)
plot(ti3(2:end),diff(dxi3)*10,'g','linewidth',2)

set(gca,'fontname','futura','fontsize',14);
ylabel('Speed (m d^-^1)');

xlabel('Day of 2010')






function rn = filter_rotate(r,q)


for i =1:length(r);
   %add dummy fields to make loop wor
    r(i).dx  = r(i).t;
    r(i).dy  = r(i).t;
    r(i).dz  = r(i).t;
    
    n = r(i).q <= q;
    rn(i) = structfun(@(x) ( x(n) ), r(i), 'UniformOutput', false);
    [x,y] = vecrot('major',rn(i).e,rn(i).n,rn(i).t);
    rn(i).dx = x - x(1);
    rn(i).dy = y - y(1);
    rn(i).dz = rn(i).h - rn(i).h(1);
end


%%
function raw_vs_filt_plots(r,q,name)

n = r.q <= q;

figure;
set(gcf,'position',[400,400,1000,700],'color','w');
subplot(3,1,1)
plot(r.t,r.e,'.')
hold on
plot(r.t(n),r.e(n),'or')
datetick
legend('raw','filtered')
ylabel('east (m)')
title(name);

subplot(3,1,2)
plot(r.t,r.n,'.')
hold on
plot(r.t(n),r.n(n),'or')
datetick
ylabel('north (m)')

subplot(3,1,3)
plot(r.t,r.h,'.')
hold on
plot(r.t(n),r.h(n),'or')
datetick
ylabel(' height(m)')

%%
function [x_rot,y_rot] = vecrot(varargin)
% VECROT Rotate vector around the origin
%[x_rot,y_rot] = vecrot(theta,x,y) rotate x and y by theta radians around
%the origin
% vecrot('major',x,y) rotate to major axis of mean(x) and mean(y).
% vecrot('major',x,y,d) where d specifies the position (i.e. time) of x and
% y - needed if 'major' is passed and x and y are irregular intervals.


if nargin == 4;
    theta = varargin{1};
    x = varargin{2};
    y = varargin{3};
    d = varargin{4};
end

if ~isnumeric(theta) && strcmp(theta,'major')

    p = polyfit(d,x,1);
    x_m = p(1);

    p = polyfit(d,y,1);
    y_m = p(1);

    disp(num2str(vsum(x_m,y_m)))

    [theta,r] = cart2pol(x_m,y_m);

    if theta < 0
        theta =  (2*pi - abs(theta));
    end

end

x_rot = x.* cos(-theta) - y.* sin(-theta);
y_rot = y.* cos(-theta) + x.* sin(-theta);



%%
function r = grafnav_ascii_read(filename)

r.t = [];
r.e = [];
r.n = [];
r.h = [];
r.xe = [];
r.ze = [];
r.q = [];
r.stat = [];


[r.stat t d r.e r.n r.h r.xe r.ze r.q] = textread(filename,...
    '%s %s %s %f %f %f %f %f %f','headerlines',22);

l = length(r.e);
disp([num2str(l),' records read, formatting dates...'])

r.t = datenum([char(d),repmat(' ',size(d)),char(t)]);

r = sortfields(r,'sortbyfield','t');

while ~isempty(r.t)
    n = diff(r.t) == 0;
    if any(n)
        r = structfun(@(x) ( x(~n) ), r, 'UniformOutput', false);
    else
        break
    end
end

disp([num2str(l-length(r.t)),' duplicates found and deleted'])

disp(['records from ',datestr(r.t(1)),' to ',datestr(r.t(end))]);
r.t = dayofyear(r.t);
%%
function nday = dayofyear(t1)
% DAYOFYEAR; Returns the number of the day in the year from a full date.
%
% NDAY = DAYOFYEAR(DATE) where DATE can be either a vector of datenums,
%               datevecs or a single date string.
%
%   2008, Ian Howat, OSU

sz = size(t1);

%is t1 numeric?
if isnumeric(t1)
    
    %yes, then could it be a list of datevecs? 
    if sz(2) == 6 && t1(:,2) > 0 && t1(:,2) < 13 &&...
            t1(:,3) > 0 && t1(:,3) < 32;
        %yes, leave it as is
        t1 = t1;
    else %no, assume its datenums
        t1 = datevec(t1);
        
    end
else
    %no, then must be  a single date string: 
    if sz(1) == 1
        t1 = datevec(t1);
    else
        error('Can''t read the date string - only single strings')
    end
end


t0 = t1;
t0(:,2:6) = 0;
nday = datenum(t1) - datenum(t0);






