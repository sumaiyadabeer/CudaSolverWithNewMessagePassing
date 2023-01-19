#include "../inc/helper.h"

void random_ints(int* a, int N)
{
   int i;
   for (i = 0; i < N; ++i)
    a[i] = rand();
}

bool cnt0(int *cnt, int n){

	bool result=true;

	for(int i=0;i<n;i++){
		if(cnt[i]){
			result=false;
			break;
		}

	}
return result;
}


// This function takes the filename linenumber lengh of array and return the values in arr 
void read_file_by_line(std:: string file_path, int *arr, int line_no, int len){
	std:: string myText;
	std:: string word;
	std:: ifstream MyReadFile;
	MyReadFile.open(file_path);
	line_no++;
	while (line_no){
		getline (MyReadFile, myText);
		line_no--;
	}
	std:: stringstream ss(myText);
	int index=0;
	while(index != len){
		ss >> word;
		*(arr+index)= std:: stoi(word);
		index++;
	}
	MyReadFile.close();
}


void read_file_by_line(std:: string file_path, float *arr, int line_no, int len){
	std:: string myText;
	std:: string word;
	std:: ifstream MyReadFile;
	MyReadFile.open(file_path);
	line_no++;
	while (line_no){
		getline (MyReadFile, myText);
		line_no--;
	}
	std:: stringstream ss(myText);
	int index=0;
	while(index != len){
		ss >> word; 
		*(arr+index)= std:: stod(word);
		index++;
	}
	MyReadFile.close();
}




void read_file( std:: string file_path, int *arr){
	std::string myText;
	std::string word;
	std::ifstream MyReadFile;
	MyReadFile.open(file_path);
	int index=0;
	while (getline (MyReadFile, myText)) {  
		std::stringstream ss(myText);
		ss >> word;
		*(arr+index)= std::stoi(word);
		index++;
	}
	MyReadFile.close();


}

void read_file( std:: string file_path, float *arr){
	std::string myText;
	std::string word;
	std::ifstream MyReadFile;
	MyReadFile.open(file_path);
	int index=0;
	while (getline (MyReadFile, myText)) {  
		std::stringstream ss(myText);
		ss >> word;
		*(arr+index)= std::stof(word);
		index++;
	}
	MyReadFile.close();


}

