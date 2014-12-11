function boosting()
    A = load('spambase.txt');
    f = K_FORLDER(A, 0);
    TR = f.Train;
    TS = f.Test;
    
    X = TR(:,1:57);
    Y = TR(:,58:58);
    
    X1 = TS(:,1:57);
    Y1 = TS(:, 58:58);
    
    n = size(X,1);
    W = ones(1,n)/n;
    total = 0;
    model = struct;
    localerror = zeros(25,1);
    for k = 1:25
        fprintf(1,'round %g\n',k);
        dt = getdecisionstump(X,Y,W);

        alpha = 0.5*log((1-dt.error)/dt.error);

        up = update(W,alpha,Y,dt.res);
        W = up.W;
        model(k).threshold = dt.threshold;
        model(k).class = dt.class;
        model(k).feaindex = dt.feature_index;
        model(k).alpha = alpha;
        model(k).error = dt.error;
        
        
        if(dt.error==0)
            model(k).alpha = 2^k;
            total = total + alpha;
            break;
        end
        total = total + alpha;
        localerror(k,1)= dt.error;
        fprintf(1,'train round %g, localerror %g \n',k,dt.error);
        
    end
    
    save('localerror', 'localerror');
    for a = 1:k
        model(a).alpha = model(a).alpha/total;
    end
    
    
    %test train
    predict = zeros(size(X,1),1);
    D = ones(1,size(X,1))/size(X,1);
    
    trainacc = zeros(k,1);
    trainauc = zeros(k,1);
    for a = 1:k
        fprintf(1,'test trian round %g\n',a);
        m = model(a);
        ts = test(m.threshold,X,m.feaindex,m.class);
        diff = ts.predict - Y;
        d = zeros(1,length(diff));
        d(diff==0) = -1;
        d(diff~=0) = 1;
        
        
        predict = predict + m.alpha * ts.predict;
        
        n = 0;
        uniY = unique(Y);
        resul =  zeros(size(X,1),1);
        for i=1:size(Y,1)
            diff = abs(uniY-predict(i));
            [~,index] = min(diff);
            resul(i) = uniY(index);
        end
        for i = 1:size(X,1)
            if(resul(i,1)==Y(i,1))
                n = n+1;
            end
        end
        trainacc(a,1) = n/size(X,1);
        [B,C,thre, AUC] = perfcurve(Y,predict,1);
        trainauc(a,1) = AUC;
        fprintf(1,'test trian round %g, acc %g, auc %g \n',a,trainacc(a),trainauc(a));
        
        
    end
    save('train', 'trainacc','trainauc');
    plot(trainacc');
    
    
    
    %test test
    predict = zeros(size(X1,1),1);
    D = ones(1,size(X1,1))/size(X1,1);
    
    acc = zeros(k,1);
    auc = zeros(k,1);
    for a = 1:k
        fprintf(1,'test round %g\n',k);
        m = model(a);
        ts = test(m.threshold,X1,m.feaindex,m.class);
        diff = ts.predict - Y1;
        d = zeros(1,length(diff));
        d(diff==0) = -1;
        d(diff~=0) = 1;
        
        D = D.*exp(alpha*d);
        
        predict = predict + m.alpha * ts.predict;
        
        n = 0;
        uniY1 = unique(Y1);
        resul =  zeros(size(X1,1),1);
        for i=1:size(Y1,1)
            diff = abs(uniY1-predict(i));
            [~,index] = min(diff);
            resul(i) = uniY1(index);
        end
        for i = 1:size(X1,1)
            if(resul(i,1)==Y1(i,1))
                n = n+1;
            end
        end
        acc(a,1) = n/size(X1,1);
        [B,C,thre, AUC] = perfcurve(Y1,predict,1);
        auc(a,1) = AUC;
        fprintf(2,'test round %g, acc %g, auc %g \n',a,acc(a),auc(a));
        
        
    end
    save('test', 'acc', 'auc');
    s = sum(D);
    %s = logical(s);
    
    D = D./s;
    plotroc(Y1',predict');

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
function dt = getdecisionstump(X, Y, W)
    [row, col] = size(X);
    tmptable = ones(row,col);
    for j = 1:col
        uniX  = unique(X(:,j));
        for i = 1:length(uniX)
            threshold = uniX(i,1);
            ll = find(X(:,j) > threshold);
            rl = find(X(:,j) <= threshold);
            llerr = geterror(Y,ll,W);
            rlerr = geterror(Y,rl,W);        
            tmptable(i,j) = llerr.error + rlerr.error;
        end
    end

    error = min(min(tmptable));
    [n,m] = find(tmptable==error);
    n = n(1);
    m = m(1);
    feature_index = m;

    v = unique(X(:,m));
    threshold = v(n);
    ll = find(X(:,m) > threshold);
    rl = find(X(:,m) <= threshold);
    
    class = zeros(2,1);
    class(1,1) = getlabel(Y(ll),W(ll));
    class(2,1) = getlabel(Y(rl),W(rl));
    
    res(ll) = class(1,1);
    res(rl) = class(2,1);
    %class = unique(res);

    dt.threshold = threshold;
    dt.class = class;
    dt.feature_index = feature_index;
    dt.error = error;
    dt.res = res';


end

function err = geterror(Y,index, W)
    y  = Y(index);
    w = W(index);
    label = getlabel(y,w); 
    if(length(label)~=1)
        disp(label);
    end
    res = ones(length(y),1)*label;
    diff = zeros(length(y),1);
    diff(res~=y) = 1;
    error = w*diff;
    err.error = error;
end
function [label] = getlabel(y,w)
    if isempty(y)
        label=1;
        return;
    end
    values = unique(y);
    N = length(values);
    num = zeros(1,N);
    for n = 1:N
        num(n) = sum(w(y == values(n)));
    end
    [~,in] = max(num);
    label = values(in);    
end

function up = update(W,alpha,Y,res)
    diff = Y-res;
    d = zeros(1,length(diff));
    d(diff==0) = -1;
    d(diff~=0) = 1;
    updateW = W.*exp(alpha*d);
    updateW = updateW./sum(updateW);
    up.W = updateW;
end


function test = test(threshold,X,feaindex,class)
row = size(X,1);
predict = ones(row,1);
llp = find(X(:,feaindex)>threshold);
rlp = find(X(:,feaindex)<=threshold);
predict(llp) = class(1,1);
predict(rlp) = class(2,1);

test.predict = predict;

end
