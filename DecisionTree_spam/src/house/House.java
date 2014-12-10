package house;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;


public class House {
	
	public static ArrayList<String[]> a =new ArrayList<String[]>();
	public static ArrayList<String[]> test =  new ArrayList<String[]>();
	public static int rowlen;
	public static int columnlen;
	
	public ArrayList<String[]> StartReadFile(String filename){
		ArrayList<String[]> datas =new ArrayList<String[]>();
		try{
			
		BufferedReader dr=new BufferedReader(new FileReader(filename));
		String line = null;
		rowlen = 0;
		while((line = dr.readLine())!=null){ 
			if(line.length()==0)
				continue;
			String l = line.trim();
			String[] nums = l.split("\\s{1,}");	
			datas.add(nums);
		}
		dr.close();
				
		}catch(Exception ex){
			System.out.print("StartReadFileError"+ex.getMessage());
		}
		return datas;
	}
	
	public double CaculateAverage(ArrayList<String[]> datas){
		if(datas==null||datas.size()==0)
			return 0;
		int rowsnum = datas.size();
		int i = columnlen - 1;
		double sum = 0;
		for(String[] d: datas){
			
			sum = sum + Double.parseDouble(d[i]);
		}
		double avg = sum/rowsnum;
		return avg;		
	}
	
	public double CaculateSum(ArrayList<String[]> datas){
		if(datas==null||datas.size()==0)
			return 0;
		
		double avg = CaculateAverage(datas);
		double sum = 0;
		for(String[] d: datas){
			double a = Double.parseDouble(d[columnlen-1]);
			sum = sum + ((a - avg)*(a - avg)); //sum((label-avg)^2)
		}		
		return sum;		
	}
	
	public HouseFeature Split(ArrayList<String[]> datas, String feature, int featureindex,
			double avg){
		double f = Double.parseDouble(feature);
		
		ArrayList<String[]> leftlist = new ArrayList<String[]>();
		ArrayList<String[]> rightlist = new ArrayList<String[]>();
		
		for(String[] d: datas){
			if(Double.parseDouble(d[featureindex]) < f){
				leftlist.add(d);
			}
			else
				rightlist.add(d);			
		}
		double lsum = CaculateSum(leftlist);
		double rsum = CaculateSum(rightlist);
		double tsum = lsum+rsum;
		double pre = avg;
		
		HouseFeature newfeature = new HouseFeature();
		
		newfeature.feature = feature;
		newfeature.index = featureindex;
		newfeature.leftlist = new ArrayList<String[]>(leftlist);
		newfeature.rightlist = new ArrayList<String[]>(rightlist);
		newfeature.ssesum = tsum;
		newfeature.predict = pre;
		
		return newfeature;
				
	}
	
	public HouseFeature StartCaculate(ArrayList<String[]> datas, double avg){
		double sse = Double.NEGATIVE_INFINITY;
		HouseFeature hf = null;
		for(int n = 0; n<columnlen-1;n++){
			ArrayList<String> r = new ArrayList<String>();
			for(String[] d : datas){
				if(r.contains(d[n]))
					continue;
				r.add(d[n]);
				HouseFeature tmphf = Split(datas, d[n], n, avg);
				
				if(sse< ((avg*avg) - tmphf.ssesum)){
					sse = (avg*avg) - tmphf.ssesum;
					hf = tmphf;
				}
			}
		}
		return hf;	
	}
	
	public Node Start(ArrayList<String[]> datas, int layer, String flag){
		
		if(layer>3)
			return null;
		double avg = CaculateAverage(datas);
		
		HouseFeature hf = StartCaculate(datas,avg);
		if(hf==null)
			return null;		
		Node newnode = new Node();
		newnode.feature = hf.feature;
		newnode.index = hf.index;
		newnode.pre = hf.predict;
		newnode.layer = layer;
		newnode.flag = flag;
		
		if(hf.leftlist!=null && hf.leftlist.size()>rowlen*0.05){
			newnode.leftnode = Start(hf.leftlist, layer+1, "L");			
		}
		if(hf.rightlist!=null && hf.rightlist.size()>rowlen*0.05){
			newnode.rightnode = Start(hf.rightlist, layer+1, "R");
		}
		return newnode;
	}
	
	public void Process(){
		Node n = new Node();
		n = Start(a, 1, "Root");
		n.prinode(n);
		
		TestHouse th = new TestHouse(n);
		double rateT = th.start(a);	
		System.out.println("Training MSE"+" "+rateT);
		
		double rateTest = th.start(test);	
		System.out.println("test MSE"+" "+rateTest);
	}
	
	public static void main(String []args){
		House newhouse = new House();
		a = newhouse.StartReadFile("housing_train.txt");
		
		if(a==null||a.size()==0)
			System.out.println("Can't get training datas");
		columnlen = a.get(0).length;
		rowlen = a.size();
		
		test = newhouse.StartReadFile("housing_test.txt");
		if(test==null||test.size()==0)
			System.out.println("Can't get test datas");
		
		newhouse.Process();
				
	}
	

}
