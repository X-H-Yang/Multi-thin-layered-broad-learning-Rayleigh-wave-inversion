% Code package purpose: Accoplish the proposed method in the paper entitled
%                       "Multi-thin-layered surface wave dispersion curve 
%                       inversion based on broad learning".
%
% paper status: Accepted (journal: Chinese Journal of Geophysics)  
%
% software version: MATLAB R2017a
%
% Acknowledgement: The forward modeling program used to generate 
%                  theoretical Rayleigh wave dispersion curves in this 
%                  code package was obtained from the  website 
%                  (https://github.com/eespr/MuLTI) provided by 
%                  Killingbeck et al. (2018); the broad learning network 
%                  codes available on the website 
%                  (https://broadlearning.ai/, Chen and Liu 2017 and Chen 
%                  et al. 2018) were also applied for the accomplishment of
%                  this code package.
%
% Killingbeck et al. (2018): Killingbeck, S. F., Livermore, P. W., 
%                            Booth, A. D., & West, L. J. (2018). Multimodal 
%                            layered transdimensional inversion of seismic 
%                            dispersion curves with depth constraints. 
%                            Geochemistry, Geophysics, Geosystems, 19(12), 
%                            4957-4971.
%
% Chen and Liu 2017: Chen, C. P., & Liu, Z. (2017). Broad learning system: 
%                    An effective and efficient incremental learning system
%                    without the need for deep architecture. IEEE 
%                    transactions on neural networks and learning systems, 
%                    29(1), 10-24.
%
% Chen et al. 2018: Chen, C. P., Liu, Z., & Feng, S. (2018). Universal 
%                   approximation capability of broad learning system and 
%                   its structural variations. IEEE transactions on neural 
%                   networks and learning systems, 30(4), 1191-1204.
%
% Variables about training samples:
%           train_x: input training samples
%           train_y: output training samples
%
% Date: 2024/02/19
%
% Developed by: Xiao-Hui Yang, Currently working at 
%               Chengdu University of Information Technology
%
% Email: yangxh@cuit.edu.cn / xiao-hui.yang@hotmail.com
%
% Note: the specific descriptions of the proposed inversion method can 
%       refer to the paper entitiled "Multi-thin-layered surface wave 
%       dispersion curve inversion based on broad learning"; the users 
%       can cite this paper for scientific research.
% 

clear;
clc;
close all;

%% Reset the seed by clock for random number generation
rand('seed',sum(100*clock))
randn('seed',sum(100*clock))

%% Raw data (a numerical example, measured dispersion curves)
data_0 = xlsread('numerical_fun.xls');
data_1 = xlsread('numerical_1st.xls');
data_2 = xlsread('numerical_2nd.xls');
data_3 = xlsread('numerical_3rd.xls');

curve_00 = data_0;
curve_01 = data_1;
curve_02 = data_2;
curve_03 = data_3;

% fundamental mode
f_00_original = curve_00(:,1)'; f_00_original = f_00_original(:)';
dispersion_00_original = curve_00(:,2); 
dispersion_00_original = dispersion_00_original(:)';
% first higher mode
f_01_original = curve_01(:,1)'; f_01_original = f_01_original(:)';
dispersion_01_original = curve_01(:,2); 
dispersion_01_original = dispersion_01_original(:)';
% second higher mode
f_02_original = curve_02(:,1); f_02_original = f_02_original(:)';
dispersion_02_original = curve_02(:,2); 
dispersion_02_original = dispersion_02_original(:)';
% third higher mode
f_03_original = curve_03(:,1); f_03_original = f_03_original(:)';
dispersion_03_original = curve_03(:,2); 
dispersion_03_original = dispersion_03_original(:)';

% interpolation process - frequency and dispersion values for invertion use
f_00_min = 6; f_00_max = 48;
f_01_min = 31.5; f_01_max = 69.5;
f_02_min = 29.5; f_02_max = 49;
f_03_min = 64; f_03_max = 100;
df = 0.5;
f_00 = f_00_min:df:f_00_max;
f_01 = f_01_min:df:f_01_max;
f_02 = f_02_min:df:f_02_max;
f_03 = f_03_min:df:f_03_max;
dispersion_00 = interp1(f_00_original,dispersion_00_original,f_00);
dispersion_01 = interp1(f_01_original,dispersion_01_original,f_01);
dispersion_02 = interp1(f_02_original,dispersion_02_original,f_02);
dispersion_03 = interp1(f_03_original,dispersion_03_original,f_03);

dispersion_all_cell = cell(1,4);
dispersion_all_cell{1} = dispersion_00;
dispersion_all_cell{2} = dispersion_01;
dispersion_all_cell{3} = dispersion_02;
dispersion_all_cell{4} = dispersion_03;


f = 6:df:100;
index_vec_all = cell(1,4);
index_vec_all{1} = [find(f == f_00_min) find(f == f_00_max)];
index_vec_all{2} = [find(f == f_01_min) find(f == f_01_max)];
index_vec_all{3} = [find(f == f_02_min) find(f == f_02_max)];
index_vec_all{4} = [find(f == f_03_min) find(f == f_03_max)];

modes_num_vec = [1 2 3 4]; % available modes of dispersion curves
% modes_num_vec = 1;
index_vec = index_vec_all(modes_num_vec);

dispersions_R_true = []; % integrate different modes of dispersion curves
for jj = 1:1:length(modes_num_vec)
    temp = modes_num_vec(jj);
    dispersions_R_true = [dispersions_R_true dispersion_all_cell{temp}];
end

validation_x = dispersions_R_true;

%% Actual model parameters (a numerical example)
h_true = [2 4 5 5];
h_true2 = [h_true 0];
Vs_true = [400 200 300 500 650];
Vp_true = [700 300 500 900 1100]; % primary wave velocity (all layers)
den_true = [1.9 1.7 1.8 2.0 2.1]; % density (all layers)

Vs_profile_lower = [130 130 130 130 130 130 130 195 195 195 195 195 325 ...
    325 325 385 385 500 500 500 500 500]; % search space
Vs_profile_upper = [540 540 540 540 540 540 540 540 540 675 675 675 675 ...
    675 675 775 775 880 880 880 880 880]; % search space

h_known = ones(1,length(Vs_profile_lower)-1);
Vp_known = [700 700 300 300 300 300 500 500 500 500 500 900 900 900 900 ...
    900 1100 1100 1100 1100 1100 1100]; % assumed known
den_known = [1.9 1.9 1.7 1.7 1.7 1.7 1.7 1.8 1.8 1.8 1.8 1.8 1.8 2.0 ...
    2.0 2.0 2.0 2.0 2.1 2.1 2.1 2.1]; % assumed known

%% Hyperparameters of the broad learning network
Fea_vec = 4:2:10;
Win_vec = 4:2:20;
Enhan_vec = 4:2:30;

tic % start to record time
%% generate training set and validation set - 1st stage
train_samples_N = 500; % each stage
samples_N = train_samples_N;
disp('Waiting several minutes for generating training samples (1st inversion stage) ...')
[train_x,train_y] = getSamples_RW_fieldData_sub_3(samples_N,...
    modes_num_vec,index_vec_all,f,Vp_known,den_known,Vs_profile_lower,...
    Vs_profile_upper,dispersions_R_true,h_known);

% Normalize data (mean=0, std=1)
[mean_x,std_x,train_x_norm] = normalized_fun(train_x);
[mean_y,std_y,train_y_norm] = normalized_fun(train_y);
validation_x_norm = zeros(size(validation_x,1),size(validation_x,2));
for i = 1:1:size(validation_x,2)
    validation_x_norm(:,i) = (validation_x(:,i)-mean_x(i))/std_x(i);
end

%% BLS regression for inversion - 1st stage
[Y_hat,all_index,NumFea_hat,NumWin_hat,NumEnhan_hat] = ...
    bls_regression_Y_sub_noTest_2(train_x_norm,train_y_norm,Fea_vec,...
    Win_vec,Enhan_vec,validation_x,Vp_known,den_known,f,modes_num_vec,...
    index_vec,index_vec_all,mean_y,std_y,validation_x_norm,h_known);
dispersions_R_inverted = calDispersions_3(Y_hat,Vp_known,den_known,f,...
    modes_num_vec,index_vec_all,h_known);

disp('Inverted S-wave velocity profile - 1st inversion stage');
Y_hat


%% generate training set and validation set - 2nd stage
Vs_profile_lower_2 = Y_hat*0.75;
Vs_profile_upper_2 = Y_hat*1.25;

disp('Waiting several minutes for generating training samples (2nd inversion stage) ...')
[train_x_2,train_y_2] = getSamples_RW_fieldData_sub_3(samples_N,...
    modes_num_vec,index_vec_all,f,Vp_known,den_known,Vs_profile_lower_2,...
    Vs_profile_upper_2,dispersions_R_true,h_known);
% Normalize data (mean=0, std=1)
[mean_x_2,std_x_2,train_x_norm_2] = normalized_fun(train_x_2);
[mean_y_2,std_y_2,train_y_norm_2] = normalized_fun(train_y_2);
validation_x_norm_2 = zeros(size(validation_x,1),size(validation_x,2));
for i = 1:1:size(validation_x,2)
    validation_x_norm_2(:,i) = (validation_x(:,i)-mean_x_2(i))/std_x_2(i);
end
%% BLS regression for inversion - 2nd stage
[Y_hat_2,all_index_2,NumFea_hat_2,NumWin_hat_2,NumEnhan_hat_2] = ...
    bls_regression_Y_sub_noTest_2(train_x_norm_2,train_y_norm_2,Fea_vec,...
    Win_vec,Enhan_vec,validation_x,Vp_known,den_known,f,modes_num_vec,...
    index_vec,index_vec_all,mean_y_2,std_y_2,validation_x_norm_2,h_known);
dispersions_R_inverted_2 = calDispersions_3(Y_hat_2,Vp_known,den_known,...
    f,modes_num_vec,index_vec_all,h_known);

disp('Inverted S-wave velocity profile - 1st inversion stage');
Y_hat_2

%% cal predicted error
Y_hat_true = [400 400 200 200 200 200 300 300 300 300 300 500 500 500 ...
    500 500 650 650 650 650 650 650];

disp('Inversion error - 1st inversion stage');
error_1 = mean(abs((Y_hat-Y_hat_true)./Y_hat_true))
disp('Inversion error - 2nd inversion stage');
error_2 = mean(abs((Y_hat_2-Y_hat_true)./Y_hat_true))


%% draw plots
figure()
plot(all_index(:,1),all_index(:,2),'b');
hold on
plot(all_index_2(:,1),all_index_2(:,2),'r');


%% 1st stage
myFontSize = 20;
% draw plots
figure(2)
drawDispersionsCompareField_2(dispersions_R_true,dispersions_R_inverted,...
    f,modes_num_vec,index_vec,myFontSize,curve_00,curve_01,curve_02,curve_03)
axis([0 100 200 600]);
set(gca,'XTick',0:20:100);
set(gca,'YTick',100:100:700);


profile_true = [0 400;2 400;2 200;6 200;6 300;11 300;11 500;16 500;...
    16 650; 25 650];
figure(3)
plot(profile_true(:,2),profile_true(:,1),'k--','Linewidth',1.2);
hold on
plot(profile_true(1:4:end,2),profile_true(1:4:end,1),'k.','MarkerSize',20);
hold on
temp = [h_known Y_hat];
Vs_profile_lower_plot = [h_known Vs_profile_lower];
Vs_profile_upper_plot = [h_known Vs_profile_upper];
drawOneProfile_invertedOnlyVs_addSS(h_known,Y_hat,h_true,Vs_true,...
    Vs_profile_lower,Vs_profile_upper,myFontSize)
set(gca,'xaxislocation','top');
xlabel('Shear-wave velocity [m/s]','FontSize',myFontSize);
ylabel('Depth [m]','FontSize',myFontSize);
axis([100 800 0 25]);
box on
set(gca,'ydir','reverse')
set(gca,'FontName','Times New Roman','FontSize',myFontSize);
set(gca,'XTick',0:200:1000);
set(gca,'YTick',0:5:25);
set(figure(3),'Position',[680,-20,560,880]); %[left, bottom, width, height]

%% 2nd stage
figure()
drawDispersionsCompareField_2(dispersions_R_true,...
    dispersions_R_inverted_2,f,modes_num_vec,index_vec,...
    myFontSize,curve_00,curve_01,curve_02,curve_03)
axis([0 100 200 600]);
set(gca,'XTick',0:20:100);
set(gca,'YTick',100:100:700);



figure(5)
plot(profile_true(:,2),profile_true(:,1),'k--','Linewidth',1.2);
hold on
plot(profile_true(1:4:end,2),profile_true(1:4:end,1),'k.','MarkerSize',20);
hold on
temp = [h_known Y_hat_2];
Vs_profile_lower_plot_2 = [h_known Vs_profile_lower_2];
Vs_profile_upper_plot_2 = [h_known Vs_profile_upper_2];
drawOneProfile_invertedOnlyVs_addSS(h_known,Y_hat_2,h_true,Vs_true,...
    Vs_profile_lower_2,Vs_profile_upper_2,myFontSize)
set(gca,'xaxislocation','top');
xlabel('Shear-wave velocity [m/s]','FontSize',myFontSize);
ylabel('Depth [m]','FontSize',myFontSize);
axis([100 800 0 25]);
box on
set(gca,'ydir','reverse')
set(gca,'FontName','Times New Roman','FontSize',myFontSize);
set(gca,'XTick',0:200:1000);
set(gca,'YTick',0:5:25);
set(figure(5),'Position',[680,-20,560,880]); %[left, bottom, width, height]
