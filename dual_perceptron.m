function dualperceptron()
%LOAD FILE
O = load('twoSpirals.txt');
row = size(O,1);

%ADD ONE COLUMN dot
% Z = ones(row,1);
% A = [Z,O];

%gaussian
A=O;

f = K_FORLDER(A, 0);
TR = f.Train;
TS = f.Test;
    
X = TR(:,1:(size(TR,2)-1));
Y = TR(:,size(TR,2):size(TR,2));
    
X1 = TS(:,1:(size(TS,2)-1));
Y1 = TS(:, size(TS,2):size(TS,2));



column = size(A,2);


%initialize theta
M = zeros(size(X,1),1);
a = 10000;
n = 0;

%start loop
while(a ~= 0 && n<1000)
    n = n +1;
    pre = preall(M,X,X);
    a = 0;
    tmp = Y.*pre;
    for i = 1: size(X,1)
        if(tmp(i)<=0)
            M(i) = M(i)+Y(i);
            a = a+1;
        end           
    end
    fprintf(2,'Iteration %g , total_wrong %g \n',n, a);
    
end


%normalize theta
n_theta = [];
for i = 2:column -1
    n_theta(i-1,1) = M(i,1)/(-M(1,1));
end

res = preall(M,X,X1);
res(res<=0) = -1;
res(res>0) = 1;
dif = res - Y1;
m = length(find(dif==0));
acc = m/length(Y1);

%print result
fprintf(1,'Test Acc: %g\n',acc);
fprintf(1,'\n\nFINAL theta: ');
fprintf(1, '%g ', M);
fprintf(1,'\nFINAL normalized theta: ');
fprintf(1, '%g ', n_theta);
fprintf(1,'\n\nEnd\n');
end

function pre = preall(M,X,XTest)
%kernel
[m,n]=size(XTest);
pre = zeros(m,1);
%gaussian
sigma = 10;
for i = 1:m
    %dot
%     tmpt = XTest(i,:);
%     dist = X*tmpt';
    
    %gaussian
    d = XTest(i,:);
    tmp = bsxfun(@minus,X,d);
    dist = tmp.^2;
    dist = sum(dist,2);
    dist = -dist./(2*sigma^2);
    dist = exp(dist);
    
    tmp = M.*dist;
    pre(i,1) = sum(M .* dist);
end    
end
function f = K_FORLDER(A,ram)
    n = 1;
    t = 1;
    row1 = 0;
    row2 = 0;
    A=  A(randperm(end),:);
    row = size(A,1);
    for i=1:row
        if(mod(i,10)==ram)
            TEST(n,:) = A(i,:);
            n = n+ 1;
            row2 = row2 + 1;

        else
            TRAIN(t,:) = A(i,:);
            t = t+1;
            row1 = row1 + 1;
        end
    end
    f.Test = TEST;
    f.Train = TRAIN;
end