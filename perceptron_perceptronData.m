function perceptron()
%LOAD FILE
O = load('perceptronData.txt');
row = size(O,1);

%ADD ONE COLUMN
Z = ones(row,1);
A = [Z,O];

column = size(A,2);


%START TRAINING
X = A(:,1: column-1);
Y = A(:,column:column);

%initialize theta
theta=zeros(column-1,1);

tmph = X*theta;

%calculate initial prediction
cal = calculateH(tmph);
h = cal.h;
lambda = 1;
XT = X';
mse = calculateMSE(h,Y);
n = 0;

%start loop
while(mse.e ~= 0)
    n = n +1;
    for i = 1: row
        theta = theta - lambda*(XT(:,i)*(h(i,1) - Y(i,1)));   
    end
    tmph = X*theta;
    cal = calculateH(tmph);
    h = cal.h;
    
    mse = calculateMSE(h,Y);
    if(mod(n,10)==0)
        fprintf(2,'Iteration %g , total_mistake %g \n',n, mse.totalmis);
        fprintf(1,'MSE : %g\n',mse.e);
    end
end


%normalize theta
n_theta = [];
for i = 2:column -1
    n_theta(i-1,1) = theta(i,1)/(-theta(1,1));
end

%print result
fprintf(1,'FINAL Iteration %g , FINAL total_mistake %g \n',n, mse.totalmis);
fprintf(1,'FINAL MSE : %g\n',mse.e);
fprintf(1,'\n\nFINAL theta: ');
fprintf(1, '%g ', theta);
fprintf(1,'\nFINAL normalized theta: ');
fprintf(1, '%g ', n_theta);
fprintf(1,'\n\nEnd\n');



%TURN H TO {1,0}
function cal = calculateH(tmph)
cal.h = [];
rowh = size(tmph,1);
for i = 1:rowh
    if(tmph(i,1)>0)
        cal.h(i,1) = 1;
    else
        cal.h(i,1) = -1;
    end
end

%CALCULATE MSE & TOTALMISTAKE
function mse = calculateMSE(h,y)
row = size(h,1);
sum = 0;
mse.totalmis = 0;
for i = 1:row
    sum = sum + ((h(i,1)-y(i,1))*(h(i,1)-y(i,1)));
    if(h(i,1)~=y(i,1))
        mse.totalmis = mse.totalmis+1;
    end
end
mse.e = sum/row;