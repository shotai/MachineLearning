O=load('spambase.txt');


row = size(O,1);

Z = ones(row,1);
A = [Z,O];

column = size(A,2);


TEST = [];
TRAIN = [];
n = 1;
t = 1;
row1 = 0;
row2 = 0;
for i=1:row
    if(mod(i,10)==0)
        TEST(n,:) = A(i,:);
        n = n+ 1;
        row2 = row2 + 1;
    
    else
        TRAIN(t,:) = A(i,:);
        t = t+1;
        row1 = row1 + 1;
    end
end



X = TRAIN(1:row1,1:column-1);
Y = TRAIN(1:row1,column:column);

XT = X';

STEP1 = XT*X;
STEP1I = STEP1^-1;
XTY = XT*Y;
FINAL = STEP1I*XTY;


X1 = TEST(1:row2,1:column-1);
Y1 = TEST(1:row2,column:column);

H = X1*FINAL;

sum = 0;
for p = 1:row2
    sum = sum + (H(p,1) - Y1(p,1))^2;
end
sum = sum/row2;
