function histogram_4()
A = load('spambase.txt');
re = zeros(11,3);
for i = 1:10
    f = K_FORLDER(A, 0);
    TR = f.Train;
    TS = f.Test;
    col = size(TR,2);

    p =  PrepareTraining(TR, col);
    avg = p.Avgtr;
    savg = p.Avgs;
    nsavg = p.Avgn;
    sl = p.sl;
    nsl = p.nsl;
    spam = p.s;
    nonspam = p.ns;
    per = p.per;

    t = StartTraining(spam,nonspam,avg, savg, nsavg, sl, nsl);
    sdis = t.spamdis;
    ndis = t.nonspamdis;

    ts = StartTesting(TS, avg, savg, nsavg, sdis,ndis,per);
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

function p = PrepareTraining(TR, col)
Spams = TR(find(TR(:,col)==1),:);
Nonspams = TR(find(TR(:,col)==0),:);
Slen = size(Spams,1);
Nlen = size(Nonspams,1);

Avg_S = sum(Spams)/Slen;
Avg_NS = sum(Nonspams)/Nlen;
Avg_TR = sum(TR)/size(TR,1);

per = Slen/size(TR,1);

Min_avg = (Avg_TR + min(TR))/2;
Max_avg = (Avg_TR + max(TR))/2;

p.Avgs = Avg_S;
p.Avgn = Avg_NS;
p.Avgtr = Avg_TR;
p.per = per;
p.s = Spams;
p.ns = Nonspams;
p.sl = Slen;
p.nsl = Nlen;
p.minavg = Min_avg;
p.maxavg = Max_avg;

function train = StartTraining(spam,nonspam,avg, savg, navg, sl, nsl)

spamdis = zeros(4,57);
nonspamdis = zeros(4,57);
for i=1:57       
    % spam
    if(savg(1,i)>navg(1,i))
        minavg = navg(1,i);
        maxavg = savg(1,i);
    else
        minavg = savg(1,i);
        maxavg = navg(1,i);
    end
    a = length(find(spam(:,i)<=minavg));
    b = size(spam(find(spam(:,i)<=minavg),:),1);
    spamdis(1,i) = (length(find(spam(:,i)<=minavg))+1)/(sl+2);
    spamdis(2,i) = (length(find(spam(:,i)>minavg&spam(:,i)<=avg(1,i)))+1)/(sl+2) ;
    spamdis(3,i) = (length(find(spam(:,i)>avg(1,i)&spam(:,i)<=maxavg))+1)/(sl+2);
    spamdis(4,i) = (length(find(spam(:,i)>maxavg))+1)/(sl+2);
    % non-spam
    nonspamdis(1,i) = (length(find(nonspam(:,i)<=minavg))+1)/(nsl+2);
    nonspamdis(2,i) = (length(find(nonspam(:,i)>minavg&nonspam(:,i)<=avg(1,i)))+1)/(nsl+2);
    nonspamdis(3,i) = (length(find(nonspam(:,i)>avg(1,i)&nonspam(:,i)<=maxavg))+1)/(nsl+2);
    nonspamdis(4,i) = (length(find(nonspam(:,i)>maxavg))+1)/(nsl+2);
end
train.spamdis = spamdis;
train.nonspamdis = nonspamdis;

function test = StartTesting(TS, avg, savg, navg, sdis,ndis,per)
res = zeros(size(TS,1),1);
rocres = zeros(size(TS,1),1);
X = TS(:,1:57);
Y = TS(:,58:58);

for i=1:size(X,1)
    ps = per;
    pns = 1-per;
    for j=1:57
        if(savg(1,j)>navg(1,j))
            minavg = navg(1,j);
            maxavg = savg(1,j);
        else
            minavg = savg(1,j);
            maxavg = navg(1,j);
        end
        if X(i,j)<=minavg
            ps = ps*sdis(1,j);
            pns = pns*ndis(1,j);
        elseif X(i,j)<=avg(1,j)
            ps = ps*sdis(2,j);
            pns = pns*ndis(2,j);
        elseif X(i,j)<=maxavg
            ps = ps*sdis(3,j);
            pns = pns*ndis(3,j);
        else
            ps = ps*sdis(4,j);
            pns = pns*ndis(4,j);
        end
        if ps/pns>=1
            res(i) = 1;
        else
            res(i) = 0;
        end
        rocres(i) = log(ps/pns);
    end

    % classify the email
    
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

