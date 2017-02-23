function columbia_netrs_2010

[n1,n2,n3] = get_data;


%correct data for dig-out and reset on day 137
p = polyfit(n1.t(1:10),n1.x(1:10),1);
n1.x(13:end) =   n1.x(13:end) - (n1.x(13) - polyval(p,n1.t(13),1)); 
p = polyfit(n1.t(1:10),n1.y(1:10),1);
n1.y(13:end) =   n1.y(13:end) - (n1.y(13) - polyval(p,n1.t(13),1)); 
p = polyfit(n1.t(1:10),n1.z(1:10),1);
n1.z(13:end) =   n1.z(13:end) - (n1.z(13) - polyval(p,n1.t(13),1)); 

p = polyfit(n2.t(1:10),n2.x(1:10),1);
n2.x(14:end) =   n2.x(14:end) - (n2.x(14) - polyval(p,n2.t(14),1)); 
p = polyfit(n2.t(1:10),n2.y(1:10),1);
n2.y(14:end) =   n2.y(14:end) - (n2.y(14) - polyval(p,n2.t(14),1)); 
p = polyfit(n2.t(1:10),n2.z(1:10),1);
n2.z(14:end) =   n2.z(14:end) - (n2.z(14) - polyval(p,n2.t(14),1)); 

p = polyfit(n3.t(1:14),n3.x(1:14),1);
n3.x(15:end) =   n3.x(15:end) - (n3.x(15) - polyval(p,n3.t(15),1)); 
p = polyfit(n3.t(1:14),n3.y(1:14),1);
n3.y(15:end) =   n3.y(15:end) - (n3.y(15) - polyval(p,n3.t(15),1)); 
p = polyfit(n3.t(1:14),n3.z(1:14),1);
n3.z(15:end) =   n3.z(15:end) - (n3.z(15) - polyval(p,n3.t(15),1));


[n1.xr,n1.yr] = vecrot('major',n1.x,n1.y,n1.t);
[n2.xr,n2.yr] = vecrot('major',n2.x,n2.y,n2.t);
[n3.xr,n3.yr] = vecrot('major',n3.x,n3.y,n3.t);

n1.dx = n1.xr - n1.xr(1);
n2.dx = n2.xr - n2.xr(1);
n3.dx = n3.xr - n3.xr(1);

n1.dy = n1.yr - n1.yr(1);
n2.dy = n2.yr - n2.yr(1);
n3.dy = n3.yr - n3.yr(1);

n1.dz = n1.z - n1.z(1);
n2.dz = n2.z - n2.z(1);
n3.dz = n3.z - n3.z(1);





%% Along-flow displacement plot
figure;
set(gcf,'position',[400,400,1000,700],'color','w');
plot(n1.t,n1.dx,'ob','markerfacecolor','b'); hold on;
plot(n2.t,n2.dx,'og','markerfacecolor','g'); hold on;
plot(n3.t,n3.dx,'or','markerfacecolor','r'); hold on;

p1 = polyfit(n1.t,n1.dx,1);
p2 = polyfit(n2.t,n2.dx,1);
p3 = polyfit(n3.t,n3.dx,1);

plot(n1.t(1):n1.t(end),polyval(p1,n1.t(1):n1.t(end)),'linewidth',1.5);
plot(n2.t(1):n2.t(end),polyval(p2,n2.t(1):n2.t(end)),'g','linewidth',1.5);
plot(n3.t(1):n3.t(end),polyval(p3,n3.t(1):n3.t(end)),'r','linewidth',1.5);

ht(1) = text(n1.t(end)-3,n1.dx(end)+1,[num2str(round(365*p1(1))),' m a^-^1']);
ht(2) = text(n2.t(end)+1,n2.dx(end),[num2str(round(365*p2(1))),' m a^-^1']);
ht(3) = text(n3.t(end)+1,n3.dx(end),[num2str(round(365*p3(1))),' m a^-^1']);

set(ht,'fontname','futura','fontsize',14);

set(gca,'ylim',[0 25],'fontname','futura','fontsize',14);
legend([num2str(round(mean(n1.z))),' m'],...
       [num2str(round(mean(n2.z))),' m'],...
       [num2str(round(mean(n3.z))),' m']);
   
ylabel('Displacement along avg. flow direction (m)')
xlabel('Day of year 2010')


%% Across-flow displacement plot
figure;
set(gcf,'position',[400,400,1000,700],'color','w');
plot(n1.t,n1.dy,'ob','markerfacecolor','b'); hold on;
plot(n2.t,n2.dy,'og','markerfacecolor','g'); hold on;
plot(n3.t,n3.dy,'or','markerfacecolor','r'); hold on;

set(gca,'fontname','futura','fontsize',14);
legend([num2str(round(mean(n1.z))),' m'],...
       [num2str(round(mean(n2.z))),' m'],...
       [num2str(round(mean(n3.z))),' m']);
   
legend('location','southeast')
ylabel('Displacement across avg. flow direction (m)')
xlabel('Day of year 2010')

%% vertical displacement plot
figure;
set(gcf,'position',[400,400,1000,700],'color','w');
plot(n1.t,n1.dz,'ob','markerfacecolor','b'); hold on;
plot(n2.t,n2.dz,'og','markerfacecolor','g'); hold on;
plot(n3.t,n3.dz,'or','markerfacecolor','r'); hold on;

set(gca,'fontname','futura','fontsize',14);
legend([num2str(round(mean(n1.z))),' m'],...
       [num2str(round(mean(n2.z))),' m'],...
       [num2str(round(mean(n3.z))),' m']);
   
ylabel('Vertical displacement (m)')
xlabel('Day of year 2010')


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
function [n1,n2,n3] = get_data
t = [124:184]';

n = [...
6805418.628	492847.709	2663.7717
6805418.715	492847.793	2663.7396
6805418.903	492847.964	2663.6548
6805419.088	492848.135	2663.5684
6805419.283	492848.303	2663.4851
6805419.44	492848.456	2663.4345
6805419.623	492848.618	2663.358
6805419.802	492848.776	2663.2838
6805419.984	492848.937	2663.215
6805420.178	492849.13	2663.1173
6805420.361	492849.286	2663.0559
6805420.518	492849.422	2662.9905
NaN	NaN	NaN
NaN	NaN	NaN
6805421.846	492850.984	2663.924
6805422.022	492851.142	2663.7597
6805422.201	492851.298	2663.6142
6805422.364	492851.453	2663.4911
6805422.534	492851.614	2663.3829
6805422.704	492851.773	2663.3124
6805422.88	492851.913	2663.2141
6805423.075	492851.993	2663.1205
6805423.211	492852.088	2662.9837
6805423.338	492852.141	2662.8533
6805423.43	492852.184	2662.6909
6805423.613	492852.344	2662.6025
6805423.693	492852.403	2662.4828
6805423.829	492852.499	2662.3627
6805423.99	492852.62	2662.2515
6805424.169	492852.779	2662.1675
6805424.339	492852.914	2662.1123
6805424.512	492853.054	2662.0457
6805424.7	492853.236	2661.9664
6805424.879	492853.392	2661.9257
6805425.061	492853.563	2661.8595
6805425.244	492853.725	2661.8158
6805425.423	492853.89	2661.7624
6805425.608	492854.063	2661.7177
6805425.781	492854.218	2661.6815
6805425.951	492854.375	2661.6165
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
6805428.23	492856.363	2661.005
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
6805429.357	492857.453	2660.6692
6805429.62	492857.605	2660.5741
6805429.737	492857.816	2660.5826];

n1.t = t(~isnan(sum(n,2)));
n1.x = n(~isnan(sum(n,2)),1);
n1.y = n(~isnan(sum(n,2)),2);
n1.z = n(~isnan(sum(n,2)),3);

n = [...
6808729.533	497977.473	2231.2405
6808729.511	497977.741	2231.2273
6808729.687	497978.547	2231.1498
6808729.841	497979.365	2231.0801
6808730.008	497980.218	2230.9723
6808730.134	497980.982	2230.9148
6808730.279	497981.788	2230.8487
6808730.434	497982.586	2230.7886
6808730.594	497983.442	2230.6895
6808730.767	497984.311	2230.5823
6808730.918	497985.084	2230.5174
6808731.069	497985.883	2230.4723
6808731.195	497986.616	2230.4108
NaN	NaN	NaN
6808731.896	497989.978	2230.6985
6808731.905	497990.274	2230.7725
6808732.028	497991.071	2230.6695
6808732.179	497991.879	2230.5713
6808732.352	497992.715	2230.4
6808732.479	497993.451	2230.3657
6808732.636	497994.212	2230.2824
6808732.787	497994.977	2230.2191
6808732.954	497995.627	2230.055
6808733.093	497996.178	2229.9501
6808733.21	497996.674	2229.7111
6808733.201	497996.936	2228.8342
6808733.281	497997.74	2228.5834
6808733.342	497998.472	2228.4385
6808733.521	497999.319	2228.2867
6808733.703	498000.144	2228.1824
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN];


n2.t = t(~isnan(sum(n,2)));
n2.x = n(~isnan(sum(n,2)),1);
n2.y = n(~isnan(sum(n,2)),2);
n2.z = n(~isnan(sum(n,2)),3);


n = [...
6806414.578	503897.984	1939.1348
6806414.448	503898.222	1939.164
6806414.217	503898.728	1939.1261
6806413.97	503899.255	1939.0634
6806413.713	503899.766	1939.0154
6806413.473	503900.277	1938.978
6806413.22	503900.773	1938.9116
6806412.985	503901.26	1938.8731
6806412.744	503901.773	1938.8387
6806412.5	503902.321	1938.7998
6806412.275	503902.802	1938.7523
6806412.04	503903.311	1938.6912
6806411.793	503903.804	1938.652
6806411.556	503904.309	1938.595
6806410.34	503904.582	1939.0427
6806410.226	503904.797	1939.0535
6806409.991	503905.274	1938.9475
6806409.769	503905.785	1938.862
6806409.531	503906.292	1938.777
6806409.263	503906.753	1938.7226
6806408.957	503907.293	1938.6627
6806408.605	503907.78	1938.6195
6806408.249	503908.272	1938.5296
6806407.928	503908.726	1938.4666
6806407.597	503909.158	1938.4168
6806407.267	503909.625	1938.2962
6806406.877	503909.941	1938.1444
6806406.5	503910.287	1937.9665
6806406.133	503910.703	1937.8218
6806405.811	503911.086	1937.6536
6806405.465	503911.514	1937.3648
6806405.206	503912.016	1937.369
6806404.971	503912.556	1937.2962
6806404.703	503913.076	1937.1986
6806404.471	503913.553	1937.1431
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN
NaN	NaN	NaN ];

n3.t = t(~isnan(sum(n,2)));
n3.x = n(~isnan(sum(n,2)),1);
n3.y = n(~isnan(sum(n,2)),2);
n3.z = n(~isnan(sum(n,2)),3);


