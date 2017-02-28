%% Plot June 2008 Columbia Survey Data
cd C:\MyFiles\Columbia\Field_2008\Survey
load CG190608A-111.txt
load CG190608A-222.txt
load CG190608A-333.txt
%% Separate variables
T1 = CG190608A_111(:,2);
E1 = CG190608A_111(:,3);
N1 = CG190608A_111(:,4);
Z1 = CG190608A_111(:,5);

T2 = CG190608A_222(:,2);
E2 = CG190608A_222(:,3);
N2 = CG190608A_222(:,4);
Z2 = CG190608A_222(:,5);

T3 = CG190608A_333(:,2);
E3 = CG190608A_333(:,3);
N3 = CG190608A_333(:,4);
Z3 = CG190608A_333(:,5);
%% Plot trajectories
figure(1)
plot(T1,E1-mean(E1))
hold on
plot(T2,E2-mean(E2),'g')
plot(T3,E3-mean(E3),'r')
legend('E1','E2','E3')

figure(2)
plot(T1,N1-mean(N1))
hold on
plot(T2,N2-mean(N2),'g')
plot(T3,N3-mean(N3),'r')
legend('N1','N2','N3')

figure(3)
plot(T1,Z1-mean(Z1))
hold on
plot(T2,Z2-mean(Z2),'g')
plot(T3,Z3-mean(Z3),'r')
legend('Z1','Z2','Z3')


%% Shad's calc: m1v = sqrt((diff(motion_08(2:end,2).^2)) + diff((motion_08(2:end,3).^2)))