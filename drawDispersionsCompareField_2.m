function drawDispersionsCompareField_2(dispersions_R_true,dispersions_R_inverted,...
    f,modes_num_vec,index_vec,myFontSize,curve_00,curve_01,curve_02,curve_03)

dispersions_R_true_cell = cell(1,length(modes_num_vec));
dispersions_R_inverted_cell = cell(1,length(modes_num_vec));
f_cell = cell(1,length(modes_num_vec));

index_start = 1;
for i = 1:1:length(modes_num_vec)
    temp = index_vec{i};
    f_cell{i} = f(temp(1):temp(2));
    dispersions_R_inverted_cell{i} = dispersions_R_inverted(index_start:index_start+length(f_cell{i})-1);
    index_start = index_start + length(f_cell{i});
end

symbol_cell = {'k*' 'k^' 'ko' 'ks' 'k.'};
legend_cell = {'Measured fun' 'Measured 1st' 'Measured 2nd' 'Measured 3rd' 'Measured 4th'};

plot(curve_00(:,1),curve_00(:,2),symbol_cell{1});
hold on
plot(curve_01(:,1),curve_01(:,2),symbol_cell{2});
plot(curve_02(:,1),curve_02(:,2),symbol_cell{3});
plot(curve_03(:,1),curve_03(:,2),symbol_cell{4});

plot(f_cell{1},dispersions_R_inverted_cell{1},'r');
if length(modes_num_vec) > 1
    for i = 1:1:length(modes_num_vec)
        plot(f_cell{i},dispersions_R_inverted_cell{i},'r');
    end
end

if length(modes_num_vec) == 1
    aa = legend(legend_cell{modes_num_vec(1)},'Inverted');
elseif length(modes_num_vec) == 2
    aa = legend(legend_cell{modes_num_vec(1)},legend_cell{modes_num_vec(2)},'Inverted');
elseif length(modes_num_vec) == 3
    aa = legend(legend_cell{modes_num_vec(1)},legend_cell{modes_num_vec(2)},legend_cell{modes_num_vec(3)},'Inverted');
elseif length(modes_num_vec) == 4
    aa = legend(legend_cell{modes_num_vec(1)},legend_cell{modes_num_vec(2)},legend_cell{modes_num_vec(3)},legend_cell{modes_num_vec(4)},'Inverted');
else
    aa = legend(legend_cell{modes_num_vec(1)},legend_cell{modes_num_vec(2)},legend_cell{modes_num_vec(3)},legend_cell{modes_num_vec(4)},legend_cell{modes_num_vec(5)},'Inverted');
end

set(aa,'FontSize',floor(myFontSize*0.75));
xlabel('Frequency [Hz]','FontSize',myFontSize);
ylabel('Phase velocity [m/s]','FontSize',myFontSize);
set(gca,'FontName','Times New Roman','FontSize',myFontSize);
end
