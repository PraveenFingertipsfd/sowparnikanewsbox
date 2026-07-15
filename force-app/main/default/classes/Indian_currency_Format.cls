public class Indian_currency_Format {
public string num{get;set;}
public string[] numArr{get;set;}

public static String test(String curr){
string num;
string[] numArr;
String num1=curr;
if(num1.length()<=3)
{
num=num1;
return num;
}
else if(num1.length()==4){
numArr=num1.split('');
num=numArr[0]+','+numArr[1]+numArr[2]+numArr[3];
return num;
}
else if(num1.length()==5){
numArr=num1.split('');
num=numArr[0]+numArr[1]+','+numArr[2]+numArr[3]+numArr[4];
return num;
}
else if(num1.length()==6){
numArr=num1.split('');
num=numArr[0]+','+numArr[1]+numArr[2]+','+numArr[3]+numArr[4]+numArr[5];
return num;
}
else if(num1.length()==7){
numArr=num1.split('');
num=numArr[0]+numArr[1]+','+numArr[2]+numArr[3]+','+numArr[4]+numArr[5]+numArr[6];
return num;
}
else if(num1.length()==8){
numArr=num1.split('');
num=numArr[0]+','+numArr[1]+numArr[2]+','+numArr[3]+numArr[4]+','+numArr[5]+numArr[6]+numArr[7];
return num;
}
else if(num1.length()==9){
numArr=num1.split('');
num=numArr[0]+numArr[1]+','+numArr[2]+numArr[3]+','+numArr[4]+numArr[5]+','+numArr[6]+numArr[7]+numArr[8];
return num;
}
else if(num1.length()==10){
numArr=num1.split('');
num=numArr[0]+','+numArr[1]+numArr[2]+','+numArr[3]+numArr[4]+','+numArr[5]+numArr[6]+','+numArr[7]+numArr[8]+numArr[9];
return num;
}
else if(num1.length()==11){
numArr=num1.split('');
num=numArr[0]+numArr[1]+','+numArr[2]+numArr[3]+','+numArr[4]+numArr[5]+','+numArr[6]+numArr[7]+','+numArr[8]+numArr[9]+numArr[10];
return num;
}
else if(num1.length()==12){
numArr=num1.split('');
num=numArr[0]+','+numArr[1]+numArr[2]+','+numArr[3]+numArr[4]+','+numArr[5]+numArr[6]+','+numArr[7]+numArr[8]+','+numArr[9]+numArr[10]+numArr[11];
return num;
}
else if(num1.length()==13){
numArr=num1.split('');
num=numArr[0]+numArr[1]+','+numArr[2]+numArr[3]+','+numArr[4]+numArr[5]+','+numArr[6]+numArr[7]+','+numArr[8]+numArr[9]+','+numArr[10]+numArr[11]+numArr[12];
return num;
}
else if(num1.length()==14){
numArr=num1.split('');
num=numArr[0]+','+numArr[1]+numArr[2]+','+numArr[3]+numArr[4]+','+numArr[5]+numArr[6]+','+numArr[7]+numArr[8]+','+numArr[9]+numArr[10]+','+numArr[11]+numArr[12]+numArr[13];
return num;
}
else if(num1.length()==15){
numArr=num1.split('');
num=numArr[0]+numArr[1]+','+numArr[2]+numArr[3]+','+numArr[4]+numArr[5]+','+numArr[6]+numArr[7]+','+numArr[8]+numArr[9]+','+numArr[10]+numArr[11]+','+numArr[12]+numArr[13]+numArr[14];
return num;
}
else{
return num1; 
}
}

}