function GDA()
A = load('spambase.txt');
re = zeros(2,11);
for i = 1:10
    f = K_FORLDER(A);
    TR = f.Train;
    TS = f.Test;
    col = size(TR,2);
    row = size(TR,1);
    p =  PrepareTraining(TR, col, row);
    avgs = p.Avgs;
    avgn = p.Avgn;
    per = p.per;
    c = getCov(TR(:,1:57));
    sigma = c.s;
    t = StartTest(sigma, TS, per, avgs, avgn);
    re(1,i) = t.acc;
    re(2,i) = t.auc;
end
re(1,11) = sum(re(1,1:10))/10;
re(2,11) = sum(re(2,1:10))/10;
disp(re)
%disp(avgs);
%disp(avgn);
%disp(sigma);
%disp(t.res);


function f = K_FORLDER(A)
n = 1;
t = 1;
row1 = 0;
row2 = 0;
A=  A(randperm(end),:);
row = size(A,1);
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
f.Test = TEST;
f.Train = TRAIN;

function p = PrepareTraining(TR, col, row)
Spams = TR(find(TR(:,col)==1),1:(col-1));
Nonspams = TR(find(TR(:,col)==0),1:(col-1));
Slen = size(Spams,1);
Nlen = size(Nonspams,1);
Avg_S = sum(Spams)/Slen;
Avg_NS = sum(Nonspams)/Nlen;
p.Avgs = Avg_S';
p.Avgn = Avg_NS';
per = Slen/row;
p.per = per;

function c = getCov(M)
sigma = cov(M);
c.s = sigma;

function test = StartTest(sigma, TS, per, avgs, avgn)
invsigma = inv(sigma);
detsigma = det(sigma);
X = TS(:,1:57);
Y = TS(:,58:58);

for i=1:size(X,1) 
    x = X(i,:); 
    p_s = per/((2*pi)^(57/2)*(detsigma^0.5))*exp(-0.5*(x'-avgs)'*invsigma*(x'-avgs));
    p_n = (1-per)/((2*pi)^(57/2)*(detsigma^0.5))*exp(-0.5*(x'-avgn)'*invsigma*(x'-avgn));
    
    % classify
    if p_s/p_n>1
        res(i,1) = 1;
    else
        res(i,1) = 0;
    end
end


n = 0.0;
for i = 1:size(X,1)
    if(res(i,1)==Y(i,1))
        n = n+1;
    end
end
RE = [res,Y];
acc = n/size(X,1);
test.res = res;
test.acc = acc;


[B,C,thre, AUC] = perfcurve(Y,res,'1');
test.auc = AUC;
fprintf(1,'TEST AUC %g\n',AUC);
fprintf(2,'TEST ACC %g\n',acc);



