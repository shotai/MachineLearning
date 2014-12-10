package spam;


import java.util.ArrayList;

public class TestSpam {
	public Node originalnode;
	ArrayList<String[]> testdatas = new ArrayList<String[]>();
	public TestSpam(Node node){
		originalnode =  new Node();
		originalnode = node;
	}
	public double start(ArrayList<String[]> datas){
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
		double rate = errornum/result.size();
		return rate; 
	}
	public double start2(ArrayList<String[]> datas){
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
		return rate; 
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
