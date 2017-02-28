 close all
clear all

k=5; 

load CG05_Gdata.mat
%111 data
t111=data(1:53,3);
Nc111=data(1:53,4);
Ec111=data(1:53,5);
Zc111=data(1:53,6);



t = t111;
nn = Nc111;
ee = Ec111;
zz = Zc111;
n=length(t);  %Get Size of file

%Difference Times and Coordinates
k=1;
for i=1:n-k
delta_t(i)=t(i+k)-t(i);
t_avg(i)=(t(i+k)+t(i))./2;    %average times
hdisp(i)=sqrt((nn(i+k)-nn(i)).^2+(ee(i+k)-ee(i)).^2);%displacements (new vector)
end

vh=hdisp./delta_t;  %velocity
figure(1); clf
plot(t_avg,vh,'.')
hold on
% ----------------------------------------------
% now plot non-parametric density estimate 
%Specific Times: 147.5 to 160.5
%Dec Day: 0.5 hr = 0.02083
%         1.0 hr = 0.04166
%         4.0 hr = 0.1667
%         6.0 hr = 0.25
%        12.0 hr = 0.5
tmin=min(t); tmax=max(t); 
stepsize=0.1667; 
winsize=[0.01667 0.25 0.5];

color='kgy'
for i=1:3
  [tmod,eemod]=nonparametric_smooth(t,ee,tmin,tmax,stepsize,winsize(i));
  h=plot(tmod,eemod,color(i)); set(h,'linewidth',2);
end

%legend('measured signal','NPDE, winsize=0.0125 s','NPDE, winsize=0.0250 s','NPDE, winsize=0.0500 s')
xlabel('Dec day')
ylabel('Coordinate')
disp('press any key to continue')
pause


%%Difference data over more than 1 15 minute interval
% for i=1:n-k
% 
% delta_t(i)=t(i+k)-t(i);
% t_avg(i)=(t(i+k)+t(i))./2;    %average times
% hdisp(i)=sqrt((nn(i+k)-nn(i)).^2+(ee(i+k)-ee(i)).^2);%displacements (new vector)
% end
% 
% vh=hdisp./delta_t;  %velocity
% plot(t_avg,vh,'.')


% %Boxcar Filter
% w = 7; %Boxcar filter size
% nlim =(w-1)/2 %Boxcar Margin
% for i = nlim+1:n-nlim-1
%     tfilt(i-nlim+1) = sum(t(i-nlim:i+nlim))/w;
%     nfilt(i-nlim+1) = sum(nn(i-nlim:i+nlim))/w;
%     efilt(i-nlim+1) = sum(ee(i-nlim:i+nlim))/w;
%     zfilt(i-nlim+1) = sum(zz(i-nlim:i+nlim))/w;
% end

