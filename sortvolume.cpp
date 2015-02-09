#include<iostream>
#include<cstdlib>
#include<algorithm>

using namespace std;

int main(int argc, char *argv[])
{
	int locator = 0;
	float nodeArray[3];
	for(int i=0;i<3;i++)
	{
		nodeArray[i] = atof(argv[i+1]);
	}

	//For locating the nodes after sorting
	//float master =atof(argv[1]);
	float node1 =atof(argv[1]);
	float node2 =atof(argv[2]);
	float node3 =atof(argv[3]);
	float vm = atof(argv[4]);

	//Getting the count of CPU and Memory
	int nodeSpec[8];
	for(int i=0;i<8;i++)
	{
		if(i< 6)
		{
			if((i%2) == 0) 
				nodeSpec[i] = 64-atoi(argv[i+5]);
			else
				nodeSpec[i] = 8192-atoi(argv[i+5]);
		}
		else
			nodeSpec[i] = atoi(argv[i+5]);
	}
	


	sort(nodeArray, nodeArray+3);


	/*cout<<"result array looks like this \t";
	for(int i=0;i<10;i++)
	{
		cout<<nodeSpec[i]<<"\t";
	}
	cout<<endl;*/
//	cout<<"vm volume = "<<vm<<endl;




	for(int i=0;i<3;i++)
	{
		if(vm < nodeArray[i])
		{	
		
			/*if(master == nodeArray[i] && nodeSpec[0] > nodeSpec[8] && nodeSpec[1] > nodeSpec[9])
			{
				cout<<"Master"; locator =1;
				break;
			}
			else */
			if(node1 == nodeArray[i] && nodeSpec[0] > nodeSpec[6] && nodeSpec[1] > nodeSpec[7])
			{
				cout<<"Node1"; locator =1;
				break;
			}
			else if(node2 == nodeArray[i] && nodeSpec[2] > nodeSpec[6] && nodeSpec[3] > nodeSpec[7])
			{
				cout<<"Node2"; locator =1;
				break;
			}
			else if(node3 == nodeArray[i] && nodeSpec[4] > nodeSpec[6] && nodeSpec[5] > nodeSpec[7])
			{
				cout<<"Node3"; locator =1;
				break;
			}

		}
	}	

	//If no match is found	
	if(locator == 0)
		cout<<"NULL";
	
	/*
	if(master == nodeArray[locator])
		cout<<"Master";
	else if(node1 == nodeArray[locator])
		cout<<"Node1";
	else if(node2 == nodeArray[locator])
		cout<<"Node2";
	else if(node3 == nodeArray[locator])
		cout<<"Node3";
	*/
//	cout<<volume<<endl;
	return(0);
}

