%spam with logistic regression

%LOAD FILE
O=load('spambase.txt');
row = size(O,1);

%ADD ONE COLUMN
Z = ones(row,1);
A = [Z,O];
column = size(A,2);
TEST = [];
TRAIN = [];

%SLIPT TO K-FOLDER
n = 1;
t = 1;
row1 = 0;
row2 = 0;
for i=1:row
    if(mod(i,10)==4)
        TEST(n,:) = A(i,:);
        n = n+ 1;
        row2 = row2 + 1;
    
    else
        TRAIN(t,:) = A(i,:);
        t = t+1;
        row1 = row1 + 1;
    end
end

%NORMALIZE
NORMAL = []; %column 1 = min, column 2 = max
for m = 2:column -1
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

%START TRAINING
X = TRAIN(1:row1,1:column-1);
Y = TRAIN(1:row1,column:column);

theta=zeros(column-1,1);
pre = X * theta;
lam = 0.0078;
XT = X';
a = exp(1);
for n = 1:1000
    for l = 1:row1
        pre(l, 1) = 1.0/(1 + (a^(-pre(l,1))));
    end
    %calculate mse
    sum = 0;
    for p = 1:row1
        sum = sum + (pre(p,1)-Y(p,1))^2;
    end
    avg = sum/row1;
    if(mod(n,100)== 0)
        fprintf(1,'%g\n',avg);
    end
    for i = 1:row1
        pre_tmp = pre(i, 1);
        Y_tmp = Y(i,1);
        theta = theta - lam * (XT(:,i) * (pre_tmp - Y_tmp) * pre_tmp * (1-pre_tmp));           
    end    
    pre = X * theta;
    
end
fprintf(1,'TRAIN MSE: %g\n',avg);

%calculate acc
resulttr = [];
acctr = 0;
for l = 1:row1
    pre(l, 1) = 1.0/(1 + (a^(-pre(l,1))));
    if(pre(l,1)>0.5)
        resulttr(l,1) = 1;
    else
        resulttr(l,1) =0;
    end
    if(resulttr(l,1)==Y(l,1))
        acctr = acctr + 1;
    end
end
acctr = acctr/row1;
fprintf(2,'TRAIN ACC: %g\n',acctr);

%calculate TP FP FN TN
TruePositiveTR = 0;
FalsePositiveTR = 0;
FalseNegativeTR = 0;
TrueNegativeTR = 0;
for i = 1:row1
    if(resulttr(i,1) == 1 && Y(i,1) ==1)
        TruePositiveTR = TruePositiveTR +1;        
    end
    if(resulttr(i,1) == 1 && Y(i,1) ==0)
        FalsePositiveTR= FalsePositiveTR + 1;
    end
    if(resulttr(i,1) == 0 && Y(i,1) == 1)
        FalseNegativeTR = FalseNegativeTR + 1;
    end
    if(resulttr(i,1) == 0 && Y(i,1)==0)
        TrueNegativeTR = TrueNegativeTR + 1;
    end
    
end
       
fprintf(1,'TRAIN TP %g\n',TruePositiveTR);
fprintf(1,'TRAIN NP %g\n',FalsePositiveTR);
fprintf(1,'TRAIN FN %g\n',FalseNegativeTR);
fprintf(1,'TRAIN TN %g\n',TrueNegativeTR);


%START TESTING
X1 = TEST(1:row2,1:column-1);
Y1 = TEST(1:row2,column:column);

H = X1*theta;
for l = 1:row2
   H(l, 1) = 1.0/(1 + (a^(-H(l,1))));
end

%calculate mse
sum2 = 0;
for i = 1:row2
    sum2 = sum2 + (H(i,1)-Y1(i,1))^2;
end
avg2 = sum2/row2;
fprintf(1,'TEST MSE %g\n',avg2);


%GET PREDICT BETWEENT {0,1}
RESULT = [];
acc = 0;
for i = 1: row2
    if(H(i,1)>0.5) 
        RESULT(i,1) = 1;
    else
        RESULT(i,1) = 0;
    end
    if(RESULT(i,1) == Y1(i,1))
        acc = acc + 1;
    end
end

%calculate acc
acc = acc/row2;
fprintf(2,'TEST ACC %g\n',acc);


%CALCULATE TP FP FN TN
TruePositive= 0;
TURE = 0;
FalsePositive = 0;
FALSE = 0;
matr = [];
FalseNegative = 0;
TrueNegative = 0;
for i = 1:row2
    if(Y1(i,1) ==1)
        TURE = TURE + 1;
    end
    if(Y1(i,1) ==0)
        FALSE = FALSE + 1;
    end
end
for i = 1:row2
    if(RESULT(i,1) == 1 && Y1(i,1) ==1)
        TruePositive = TruePositive +1;        
    end
    if(RESULT(i,1) == 1 && Y1(i,1) ==0)
        FalsePositive= FalsePositive + 1;
    end
    if(RESULT(i,1) == 0 && Y1(i,1) == 1)
        FalseNegative = FalseNegative + 1;
    end
    if(RESULT(i,1) == 0 && Y1(i,1)==0)
        TrueNegative = TrueNegative + 1;
    end
    
    matr(i,1) = TruePositive/TURE;
    matr(i,2) = FalsePositive/FALSE;
end
        
x = matr(:,1);
y = matr(:,2);
fprintf(2,'TEST TP %g\n',TruePositive);
fprintf(2,'TEST NP %g\n',FalsePositive);
fprintf(2,'TEST FN %g\n',FalseNegative);
fprintf(2,'TEST TN %g\n',TrueNegative);

%DRAW ROC
plotroc(Y1',H');

%CALCULATE AUC
[B,C,thre, AUC] = perfcurve(Y1,RESULT,'1');

fprintf(1,'AUC %g\n',AUC);