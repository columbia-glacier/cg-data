clear all
close all

data = xlsread('coords','mk444'); %loads marker 333 data

t=data(:,2);
y=data(:,4);
x=data(:,5);

n=length(x);  %number data
for i=1:n-1

t_avg(i)=(t(i+1)+t(i))./2;    %average times
disp(i)=sqrt((x(i+1)-x(i)).^2+(y(i+1)-y(i)).^2);  %displacements (new vector)
end

delta_t=diff(t);   %time intervals between measurements

v=disp./delta_t';  %velocity

windowSize = 15;
vsmooth= filter(ones(1,windowSize)/windowSize,1,v);

tsmooth= filter(ones(1,windowSize)/windowSize,1,t_avg);

plot(t_avg,v);hold on
axis([158.5,175.5,0,22]);
plot(tsmooth,vsmooth,'k','linewidth',3)


Y = fft(vsmooth,512);
%The power spectrum, a measurement of the power at various frequencies, is
Pyy = Y.* conj(Y) / 512; f = 1000*(0:256)/512;
figure(2);
plot(f,Pyy(1:257))
title('Frequency content of y')
xlabel('frequency (Hz)')