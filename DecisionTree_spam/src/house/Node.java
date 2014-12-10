package house;

public class Node {
	public String feature;
	public int index;
	public double pre;
	public Node leftnode;
	public Node rightnode;
	public int layer;
	public String flag;
	public int father;
	
	public void pri(){
		System.out.println("FeatureIndex: "+this.index
				+" Threshold: " + this.feature
				+" Predict: "+this.pre 
				+" Layer: "+this.layer
				+" Flag: "+this.flag
				+" FatherIndex: "+this.father);
		
	}
	public void prinode(Node n){
		n.pri();
		if(n.leftnode!=null)			
			prinode(n.leftnode);
		if(n.rightnode!=null)
			prinode(n.rightnode);
	}

}
