clear all
close all


%%%%%%%%%%%%%%%%MARKER 111%%%%%%%%%%%%
load mk111.txt
data1 = mk111; %loads marker 333 data
t_1=data1(:,2); %Time in decimal days; day 154 = 3 June

yloc_1=data1(:,4); %y = Northing (main flow direction)

xloc_1=data1(:,3); %x = Easting

z_1=data1(:,5); %z = Elevation

n_1 = length(t_1); %Length of time series

%%%%%%%%%%%%%%MARKER 333%%%%%%%%%%%%%%%%%%%%
load mk333.txt
data3 = mk333; %loads marker 333 data

t_3=data3(:,2); %Time in decimal days; day 154 = 3 June

yloc_3=data3(:,4); %y = Northing (main flow direction)

xloc_3=data3(:,3); %x = Easting

z_3=data3(:,5); %z = Elevation

n_3 = length(t_3); %Length of time series

%%%%%%%%%%%%%%%%%%MARKER 444%%%%%%%%%%%%%%%%%%%
load mk444.txt
data4 = mk444; %loads marker 444 data

t_4=data4(:,2); %Time in decimal days; day 154 = 3 June

yloc_4=data4(:,4); %y = Northing (main flow direction)

xloc_4=data4(:,3); %x = Easting

z_4=data4(:,5); %z = Elevation

n_4 = length(t_4); %Length of time series



% Convert coordinates to UTM:
% Gun coordinates 
Gn = 6775852.739;
Ge =  497126.859;

% Ref coordinates 
Rn = 6775984.429;
Re =  497126.388;

% >> Line Gun to Ref points 0.2049 degrees W of N.
dela = deg2rad(-.2049);
Rotmat = [ cos(dela) sin(dela); -sin(dela) cos(dela)]
%%%%%%%%%%%%%%%%%Marker 111%%%%%%%%%%%%%%%%%%%%%
for i = 1:n_1

    Plocal= [yloc_1(i),xloc_1(i)]';
    Ptrans = Rotmat*Plocal;

    Nutm(i)= Ptrans(1) - 5000 + Gn; 
    Eutm(i)= Ptrans(2) - 5000 + Ge;

end

%Reduce UTM coords to local numbers by

y_111 = Nutm;% - 6770000.0;
x_111 = Eutm;% -  490000.0;

marker1 = [t_1 x_111' y_111' z_1];
save marker1_UTM marker1

%%%%%%%%%%%%MARKER 333%%%%%%%%%%%%%%%%%%%%%%
clear i Plocal Ptrans Nutm Eutm 
for i = 1:n_3

    Plocal= [yloc_3(i),xloc_3(i)]';
    Ptrans = Rotmat*Plocal;

    Nutm(i)= Ptrans(1) - 5000 + Gn; 
    Eutm(i)= Ptrans(2) - 5000 + Ge;

end

%Reduce UTM coords to local numbers by

y_333 = Nutm;% - 6770000.0;
x_333 = Eutm;% -  490000.0;

marker3 = [t_3 x_333' y_333' z_3];
save marker3_UTM marker3


%%%%%%%%%%%%MARKER 444%%%%%%%%%%%%%%%%%%%%%%
clear i Plocal Ptrans Nutm Eutm 
for i = 1:n_4

    Plocal= [yloc_4(i),xloc_4(i)]';
    Ptrans = Rotmat*Plocal;

    Nutm(i)= Ptrans(1) - 5000 + Gn; 
    Eutm(i)= Ptrans(2) - 5000 + Ge;

end

%Reduce UTM coords to local numbers by

y_444 = Nutm;% - 6770000.0;
x_444 = Eutm;% -  490000.0;

marker4 = [t_4 x_444' y_444' z_4];
save marker4_UTM marker4

%========= End coordinate transform ============
