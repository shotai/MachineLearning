package spam;

public class Node {
	public Node leftnode;
	public String feature;
	public String threshold;
	public Node rightnode;
	public double pre;
	public int layer;
	
	public void pri(){
		System.out.println("FeatureIndex: "+this.feature
				+" Threshold: " + this.threshold
				+" Predict: "+this.pre 
				+" Layer: "+this.layer);
		
	}
	public void prinode(Node n){
		n.pri();
		if(n.leftnode!=null)
			
			prinode(n.leftnode);
		if(n.rightnode!=null)
			prinode(n.rightnode);
	}

}
