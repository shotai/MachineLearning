%housing with linear regression

TRO=load('housing_train.txt');
TEO=load('housing_test.txt');


row1 = size(TRO,1);
row2 = size(TEO,1);


Z1 = ones(row1,1);
TRAIN = [Z1,TRO];
Z2 = ones(row2,1);
TEST = [Z2,TEO];
column = size(TRAIN,2);

e = exp(1);

%normalize
NORMAL = []; %column 1 = min, column 2 = max
for m = 2:column - 1
    mi = min(TRAIN(:,m));
    for n  = 1:row1
        TRAIN(n,m) = TRAIN(n,m) - mi;
    end
    ma = max(TRAIN(:,m));
    for n = 1:row1
        TRAIN(n,m) = TRAIN(n,m)/ma;
    end
    NORMAL(m,1) = mi;
    NORMAL(m,2) = ma;
end

for m = 2:column - 1
    mi = NORMAL(m,1);
    for n  = 1:row2
        TEST(n,m) = TEST(n,m) - mi;
    end
    ma = NORMAL(m,2);
    for n = 1:row2
        TEST(n,m) = TEST(n,m)/ma;
    end
end

%training
X = TRAIN(1:row1,1:column-1);
Y = TRAIN(1:row1,column:column);


theta=zeros(column-1,1);
pre = X * theta;
lam = 0.001;
XT = X';

for n = 1:1000    
    for i = 1:row1
            pre_tmp = pre(i, 1);
            npre = - pre_tmp;
            ne = e^npre;
            h = 1/(1+ne);
            Y_tmp = Y(i,1);
            theta = theta - lam  * (pre_tmp - Y_tmp)*XT(:,i);        
    end
    
    pre = X * theta;
    sum = 0;
    for i = 1:row1
        sum = sum + (pre(i,1)-Y(i,1))^2;
    end
    avg = sum/row1;
    
end
fprintf(1,'TRAIN MSE: %g\n',avg);


%testing
X1 = TEST(1:row2,1:column-1);
Y1 = TEST(1:row2,column:column);

H = X1*theta;
sum2 = 0;
for i = 1:row2
    sum2 = sum2 + (H(i,1)-Y1(i,1))^2;
end
avg2 = sum2/row2;
fprintf(2,'TEST MSE: %g\n',avg2);
