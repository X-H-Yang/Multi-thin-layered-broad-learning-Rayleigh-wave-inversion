function drawOneProfile_invertedOnlyVs_addSS(h_assumed,Y_hat,h_true,Vs_true,Y_lower_boundry,Y_upper_boundry,myFontSize)

A_large_number = 100;

h_true_plot = [0 reshape([cumsum(h_true);cumsum(h_true)],1,length(cumsum(h_true))*2) A_large_number]; 
Vs_true_plot = reshape([Vs_true;Vs_true],1,length(Vs_true)*2);

h_assumed_plot = [0 reshape([cumsum(h_assumed);cumsum(h_assumed)],1,length(cumsum(h_assumed))*2) A_large_number];
Y_hat_plot = reshape([Y_hat;Y_hat],1,length(Y_hat)*2);

Y_lower_boundry_plot = reshape([Y_lower_boundry;Y_lower_boundry],1,length(Y_lower_boundry)*2);
Y_upper_boundry_plot = reshape([Y_upper_boundry;Y_upper_boundry],1,length(Y_upper_boundry)*2);


plot(Y_lower_boundry_plot,h_assumed_plot,'k-.','Linewidth',1.8);
hold on
plot(Y_upper_boundry_plot,h_assumed_plot,'k-.','Linewidth',1.8);
plot(Vs_true_plot,h_true_plot,'k','Linewidth',1.8);
plot(Y_hat_plot,h_assumed_plot,'r','Linewidth',1.8);

set(gca,'xaxislocation','top');
xlabel('Shear-wave velocity [m/s]','FontSize',myFontSize);
ylabel('Depth [m]','FontSize',myFontSize);
box on
set(gca,'ydir','reverse')
set(gca,'FontName','Times New Roman','FontSize',myFontSize);

end