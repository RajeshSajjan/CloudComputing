#include<iostream>
#include<cstdlib>
using namespace std;

int main(int argc, char *argv[])
{
	float a =atof(argv[1]);
	float b =atof(argv[2]);
	int inverse = atoi(argv[3]);
	float volume = 0;
	if(inverse == -1)
	{
		a = 1-a;
		b = 1-b;
	}
	if( a==1 && b==1)
	{
		a=.9999;
		b=.9999;
	}	
	volume = (1/(1-a))*(1/(1-b));
		
	cout<<volume<<endl;
	return(0);
}

