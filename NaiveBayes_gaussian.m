function gaussian()
A = load('spambase.txt');
re = zeros(11,3);
for i = 1:10
    f = K_FORLDER(A, 1);
    TR = f.Train;
    TS = f.Test;
    col = size(TR,2);
    row = size(TR,1);

    p =  PrepareTraining(TR, col, row);
    per = p.per;
    s = p.s;
    ns = p.ns;
    avgs = p.Avgs;
    avgn = p.Avgn;

    tr = StartTraining(s,ns,avgs,avgn);
    ms = tr.ms;
    mns = tr.mns;

    ts = StartTesting(TS,ms,mns,per,avgs,avgn);
    acc=ts.acc;
    auc = ts.auc;
    re(i,1) = ts.fp;
    re(i,2) = ts.fn;
    re(i,3) = 1-acc;
end
re(11,1) = sum(re(1:10,1))/10;
re(11,2) = sum(re(1:10,2))/10;
re(11,3) = sum(re(1:10,3))/10;
fprintf(2,'TEST ACC %g\n',acc);
fprintf(1,'TEST AUC %g\n',auc);
disp('end');


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

function p = PrepareTraining(TR, col, row)
Spams = TR(find(TR(:,col)==1),1:(col-1));
Nonspams = TR(find(TR(:,col)==0),1:(col-1));
Slen = size(Spams,1);
Nlen = size(Nonspams,1);
Avg_S = sum(Spams)/Slen;
Avg_NS = sum(Nonspams)/Nlen;
Avg_TR = sum(TR)/row;
per = Slen/row;

p.Avgs = Avg_S;
p.Avgn = Avg_NS;
p.Avgtr = Avg_TR';
p.per = per;
p.s = Spams;
p.ns = Nonspams;


function train = StartTraining(s,ns,avgs, avgn)
Mspam = zeros(1,57);
Mnsp = zeros(1,57);
Slen = size(s,1);
Nlen = size(ns,1);
for i=1:57
    % spam with smoothing
    Mspam(1,i) = (sum((s(:,i)-avgs(1,i)).^2)+1)/(Slen+2);
    % non-spam with smoothing
    Mnsp(1,i) = (sum((ns(:,i)-avgn(1,i)).^2)+1)/(Nlen+2);
end
train.ms = Mspam;
train.mns = Mnsp;

function test = StartTesting(TS, ms,mns, per,avgs, avgn)

res = zeros(size(TS,1),1);
rocres = zeros(size(TS,1),1);
X = TS(:,1:57);
Y = TS(:,58:58);
for i=1:size(TS,1)
    ps = per;
    pns= 1-per; 
    for j=1:57
        x = X(i,j);
        
        %spam
        se = avgs(1,j);
        sv = ms(1,j);
        ps = ps*  (1/(sqrt(2*pi*sv))) *exp(-1*(x-se)^2/(2*sv));
        
        %non-spam
        ne = avgn(1,j);
        nv = mns(1,j);
        pns = pns* (1/(sqrt(2*pi*nv))) *exp(-1*(x-ne)^2/(2*nv));
    end

    if ps/pns>=1
        res(i) = 1;
    else
        res(i) = 0;
    end
    rocres(i) = log(ps/pns);
end
n = 0;
fn = 0;
fp = 0;
for i = 1:size(X,1)
    if(res(i,1)==Y(i,1))
        n = n+1;
    end
    if(res(i,1) == 1 && Y(i,1)==0)
        fp = fp +1;
    end
    if(res(i,1)==0 && Y(i,1)==1)
        fn = fn +1;
    end
end
RES = [res,Y];
acc = n/size(X,1);
[B,C,thre, AUC] = perfcurve(Y,res,1);
plotroc(Y',rocres');
test.res = res;
test.acc = acc;
test.auc = AUC;
test.fn = fn/length(find(TS(:,58)==0));
test.fp = fp/length(find(TS(:,58)==1));
