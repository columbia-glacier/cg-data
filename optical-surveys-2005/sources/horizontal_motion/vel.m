clear all
close all


load cg05j333.txt
t=cg05j333(:,2);
y=cg05j333(:,11);
x=cg05j333(:,12);


n=length(x);  %number data
for i=1:n-1

t_avg(i)=(t(i+1)+t(i))./2;    %average times
disp(i)=sqrt((x(i+1)-x(i)).^2+(y(i+1)-y(i)).^2);  %displacements (new vector)
end

delta_t=diff(t);   %time intervals between measurements

v=disp./delta_t';  %velocity

plot(t_avg,v,'.r')
hold on

%take different samplings by k

k=24;
for i=1:n-k
changet(i)=t(i+k)-t(i);
t_avgspecial(i)=(t(i+k)+t(i))./2;    %average times
dispspecial(i)=sqrt((x(i+k)-x(i)).^2+(y(i+k)-y(i)).^2);  %displacements (new vector)
end

delta_t=diff(t);   %time intervals between measurements

specialv=dispspecial./changet;  %velocity

plot(t_avgspecial,specialv,'.y')