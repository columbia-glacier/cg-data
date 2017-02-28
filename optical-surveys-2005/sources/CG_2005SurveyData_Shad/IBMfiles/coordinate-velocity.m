clear all
close all

data = xlsread('coords','mk333'); %loads marker 333 data

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