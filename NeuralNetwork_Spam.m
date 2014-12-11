function NeuralNetwork()
input = [1 1 0 0 0 0 0 0 0;
         1 0 1 0 0 0 0 0 0;
         1 0 0 1 0 0 0 0 0;
         1 0 0 0 1 0 0 0 0;
         1 0 0 0 0 1 0 0 0;
         1 0 0 0 0 0 1 0 0;
         1 0 0 0 0 0 0 1 0;
         1 0 0 0 0 0 0 0 1];
output = input;
hiddenvalue = [0.89 0.04 0.08;
               0.15 0.99 0.99;
               0.01 0.97 0.27;
               0.99 0.97 0.71;
               0.03 0.05 0.02;
               0.01 0.11 0.88; 
               0.80 0.01 0.98;
               0.60 0.94 0.01];
theta1 = rand(9,4);
theta2 = rand(4,9);

disp(input);
lambda = 0.5;
for i = 1:20000
    layer1 = calculatePredict(input,theta1);

    predict = calculatePredict(layer1.h,theta2);

    bplayer = calculateTheta(output, predict.h, lambda,theta1,input,theta2, layer1.h);

    
    theta1 = bplayer.theta1;
    theta2 = bplayer.theta2;
end

%layer1 = calculatePredict(input,theta1);
%predict = calculatePredict(layer1.h,theta2);

disp(theta1);
disp(theta2);
disp(predict.h);
fprintf(1,'\n\nEnd\n');

function pre = calculatePredict(input,theta)

pre.z = input*theta;

pre.h = 1./(1+exp(1).^(-pre.z));


function th = calculateTheta(output, pre,lambda,theta1,input,theta2,pre2)
    
% calculate the error of output
Err = pre.*(1-pre).*(output-pre);


% calculate the error of hidden layer
sum = (Err*theta2');
Err_hidden = pre2.*(1-pre2).*sum;
    
% update theta
th.theta1 = theta1 + (lambda * input' * Err_hidden );
th.theta2 = theta2 + (lambda * pre2' * Err );




