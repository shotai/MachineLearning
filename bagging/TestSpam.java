package spam;


import java.util.ArrayList;

public class TestSpam {
	public Node originalnode;
	ArrayList<String[]> testdatas = new ArrayList<String[]>();
	public TestSpam(Node node){
		originalnode =  new Node();
		originalnode = node;
	}
	public ArrayList<TestRs> start(ArrayList<String[]> datas){
		testdatas = datas;
		ArrayList<TestRs> result = new ArrayList<TestRs>();
		for(String[] d : datas){
			
			result.add(split(originalnode,d));
		}
		double errornum=0;
		for(TestRs rs: result){
			if(rs.pre!=rs.real)
				errornum++;
		}
		calculaterate(result);
		double rate = errornum/result.size();
		System.out.println("TestErrorRate:" + rate);
		return result; 
	}
	public void calculaterate(ArrayList<TestRs> datas){
		int TP = 0;
		int TN = 0;
		int FP = 0;
		int FN = 0;
		double hit = 0;
		for(TestRs tr: datas){
			if(tr.pre == 1 && tr.real ==1){
				TP++;
				hit++;
			}
			if(tr.pre == 1 && tr.real == 0)
				FP++;
			if(tr.pre == 0 && tr.real == 1)
				FN++;
			if(tr.pre == 0 && tr.real == 0){
				TN++;
				hit++;
			}
		}
		System.out.println("True Positive: "+ TP);
		System.out.println("False Positive: "+ FP);
		System.out.println("True Negative: "+ TN);
		System.out.println("False Negative: "+FN);
		System.out.println("Acc: "+hit/datas.size());
	}
	public ArrayList<TestRs> start2(ArrayList<String[]> datas){
		testdatas = datas;
		ArrayList<TestRs> result = new ArrayList<TestRs>();
		for(String[] d : datas){
			
			result.add(split(originalnode,d));
		}
		double errornum=0;
		for(TestRs rs: result){
			errornum = errornum + (rs.real-rs.pre)*(rs.real-rs.pre);
		}
		double rate = errornum/result.size();
		System.out.println("Testing mse"+" "+rate);
		return result; 
	}

	private TestRs split(Node node,String[] datas){
		
		int num = Integer.parseInt(node.feature);
		double v= Double.parseDouble(node.threshold);
		TestRs r = new TestRs();
		if(Double.parseDouble(datas[num])<v){
			if(node.leftnode!=null)
				r = split(node.leftnode, datas);
			else{
				r.pre = node.pre;
				r.real = Double.parseDouble(datas[datas.length-1]);
			}
		}
		else{
			if(node.rightnode!=null)
				r = split(node.rightnode,datas);
			else{
				r.pre = node.pre;
				r.real = Double.parseDouble(datas[datas.length-1]);
			}
		}
//		System.out.println(r.pre);
		return r;	
	
	}
}
