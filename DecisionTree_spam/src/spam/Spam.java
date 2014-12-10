package spam;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

public class Spam {
	public ArrayList<String[]> a = new ArrayList<String[]>();
	public int columnlen = 0;
	public int rowlen = 0;
	
	
	public void StartReadFile(String filename){
		try{
		BufferedReader dr=new BufferedReader(new FileReader(filename));
		String line = null;
		rowlen = 0;
		while((line = dr.readLine())!=null){ 
			if(line.length()==0)
				continue;
			String[] nums = line.split(",");	
			a.add(nums);
		}
		dr.close();
		columnlen = a.get(0).length;
		rowlen = a.size();		
		}catch(Exception ex){
			System.out.print("StartReadFileError"+ex.getMessage());
		}
	}
	
	public void StartProcess(){
		System.out.println("Total " + a.size());
		ArrayList<String[]> test = new ArrayList<String[]>();
		for(int i=0; i<a.size(); i++) {
			if ((i%10) == 0) {
				test.add(a.remove(i));
			}
		}
		ArrayList<String[]> training = new ArrayList<String[]>(a);
		System.out.println("Training " + training.size());
		System.out.println("Testing " + test.size());
		Node node = new Node();
		node = SaveFeature(training,1);
		
		node.prinode(node);
		TestSpam newtest = new TestSpam(node);
		double rateT = newtest.start(training);
		System.out.println("Training Error Rate"+" "+rateT);
		
		
		double rate = newtest.start(test);
		System.out.println("Testing Error Rate"+" "+rate);
		
		double mse = newtest.start2(test);
		System.out.println("Testing mse"+" "+mse);

	}
	
	private predict Caculate(ArrayList<String[]> datas)
	{
		predict p = new predict();
		try{
		double ZeroNum = 0;
		double OneNum = 0;
		for(String[] d: datas){
			if(Double.parseDouble(d[columnlen-1])==0){
				ZeroNum++;
			}
			else if(Double.parseDouble(d[columnlen-1]) == 1){
				OneNum++;
			}
		}
		double h;
		double total = datas.size();
		h = (ZeroNum/total) * (Math.log(1/(ZeroNum/total))/Math.log(2)) + 
				(OneNum/total) * (Math.log(1/(OneNum/total))/Math.log(2));
		p.h = h;
		if(ZeroNum>=OneNum)
			p.pre = 0;
		else
			p.pre = 1;
		return p;
		}
		catch(Exception ex){
			System.out.print("Caculate"+ex.getMessage());
		}
		return p;
	}
	
	private spamfeature Caculate_2(ArrayList<String[]> datas, String feature, int i)
	{
		ArrayList<String[]> leftlist = new ArrayList<String[]>();
		ArrayList<String[]> rightlist = new ArrayList<String[]>();
		for(String[] data: datas){
			if(Double.parseDouble(data[i])<Double.parseDouble(feature))
				leftlist.add(data);
			else
				rightlist.add(data);			
		}
		double total = datas.size();
		double l_total = leftlist.size();
		double r_total = rightlist.size();
		double left_h = Caculate(leftlist).h;
		double right_h = Caculate(rightlist).h;
		
		double h = (l_total/total)*left_h + (r_total/total)*right_h;
		
		spamfeature newspam = new spamfeature();
		newspam.h = h;
		newspam.feature = i;
		newspam.threshold = feature;
		if (feature == null) {
			System.out.println(h);
		}
		newspam.leftlist = new ArrayList<String[]>(leftlist);
		newspam.rightlist = new ArrayList<String[]>(rightlist);
		return newspam;
	}
	
	private spamfeature GoOverFeature(ArrayList<String[]> datas, predict hy){		
		double ig = 0;
		spamfeature sf = null;
		for(int i = 0;i<columnlen-1;i++){
			ArrayList<String> r = new ArrayList<String>();
			for(String[] d : datas){
				if(r.contains(d[i]))
					continue;
				r.add(d[i]);
				spamfeature s = new spamfeature();
				s = Caculate_2(datas,d[i],i);
				if(ig< hy.h-s.h ){
					ig = hy.h-s.h;
					sf = s;	
					sf.pre = hy.pre;
				}
			}
		}
		return sf;		
	}

	private Node SaveFeature(ArrayList<String[]> datas, int layer){		
		predict hy = Caculate(datas);
		if (hy.h<0.3)
			return null;
		spamfeature rs = GoOverFeature(datas,hy);
		if(rs==null)
			return null;
		Node n = new Node();
		
		n.feature = String.valueOf(rs.feature);
		n.threshold = rs.threshold;
		n.pre =rs.pre;
		n.layer = layer;
		
		if(rs.leftlist!=null){
			n.leftnode = SaveFeature(rs.leftlist, layer+1);			
		}
		if(rs.rightlist!=null){
			n.rightnode = SaveFeature(rs.rightlist, layer+1);
		}
		
		return n;
	}
	public static void main(String []args){
		Spam newspam = new Spam();
		newspam.StartReadFile("spambase.txt");
		newspam.StartProcess();
	}
		

}
