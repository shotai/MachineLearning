package house;

import java.util.ArrayList;


public class TestHouse {
	
	public Node originalnode;
	ArrayList<String[]> testdatas = new ArrayList<String[]>();
	public TestHouse(Node node){
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
			errornum = errornum + (rs.real-rs.predict)*(rs.real-rs.predict);
		}
		double rate = errornum/result.size();
		return rate; 
	}

	private TestRs split(Node node,String[] datas){
		
		int num = node.index;
		double v= Double.parseDouble(node.feature);
		TestRs r = new TestRs();
		if(Double.parseDouble(datas[num])<v){
			if(node.leftnode!=null)
				r = split(node.leftnode, datas);
			else{
				r.predict = node.pre;
				r.real = Double.parseDouble(datas[datas.length-1]);
			}
		}
		else{
			if(node.rightnode!=null)
				r = split(node.rightnode,datas);
			else{
				r.predict = node.pre;
				r.real = Double.parseDouble(datas[datas.length-1]);
			}
		}
//		System.out.println(r.pre);
		return r;	
	
	}

}
