close all
clear all
clc
format short g           % Stop exponential answers

%% Parameters 
m_B   = 1.137;            % Mass of pendulum body
m_W   = 0.034;           % Mass of wheel
l     = 0.05869;           % COM length of pendulum
r     = 0.0325;          % Radius of wheel
d     = 0.1587;            % Distance between wheels
I_W_a = 1.795625000000000e-05 ;       % MOI of wheel wrt its rotating axis
I_W_d = 0.000019;      % MOI of wheel wrt its radial (diameter)
I_y   = 0.003304;      % MOI of pendulum body wrt y-axis %I_2  = 0.006548;
I_z   = 0.001295;        % MOI of pendulum body wrt z-axis
I_x   = 0.002438;
C_L   = 0;
g     = 9.81;            % Gravitational Constant
k_m   = 0.00984;            % Motor Torque Constant
k_e   = 0.00103;            % Motor Back Emf Constant
R_m   = 2.3;            % Motor Resistance 
n     = 30;
%% computing all matrix

A_v = linear_SBR6voltage_A(I_W_a,I_y,R_m,g,k_e,k_m,l,m_B,m_W,r)
B_v = linear_SBR6voltage_B(I_W_a,I_W_d,I_y,I_z,R_m,d,k_m,l,m_B,m_W,r)

A_test = linear_SBRvoltage_A(I_W_a,I_W_d,I_y,I_z,R_m,d,g,k_e,k_m,l,m_B,m_W,n,r)
B_test = linear_SBRvoltage_B(I_W_a,I_W_d,I_y,I_z,R_m,d,k_m,l,m_B,m_W,n,r)

C   = eye(6);
D   = zeros(6,2);
R   = diag([0.01 0.01]);           % Input Weight Matrix
Q   = diag([500 20000 1000 2000 1 0]); % State Weight Matrix

% R   = diag([0.01 0.01]);           % Input Weight Matrix
% Q   = diag([500 20000 1000 2000 1 0]); % State Weight Matrix

% Controllability Test
ra = rank(ctrb(A_v,B_v)); 
ra_test = rank(ctrb(A_test,B_test)); 
%% Continious time control design 
K_v    = lqr(A_v,B_v,Q,R)  % LQR control design
K_test    = lqr(A_test,B_test,Q,R)
%% Discrete time control design
sys_c = ss(A_v,B_v,C,D);
sys_test = ss(A_test,B_test,C,D)
Ts    = 1/400;
sys_d = c2d(sys_c,Ts,'zoh');
sys_dtest = c2d(sys_test,Ts,'zoh');
a     = sys_d.A;
b     = sys_d.B;
c     = sys_d.C;
dd    = sys_d.D;

a_test     = sys_dtest.A;
b_test     = sys_dtest.B;
c_test     = sys_dtest.C;
dd_test   = sys_dtest.D;
K_dis = dlqr(a,b,Q,R)  % Discrete LQR control design

K_dis_test = dlqr(a_test,b_test,Q,R)  % Discrete LQR control design

%cl    = feedback(sys_c,K_v);
%cl_d  = feedback(sys_d,K_dis);
% step(cl,'r')