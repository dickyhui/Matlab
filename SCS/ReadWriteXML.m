% ��дxml
function [ output_args ] = ReadWriteXML( input_args )
clear
docNode=com.mathworks.xml.XMLUtils.createDocument('root_element');%����xml
docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
newSlide=docNode.createElement('Slide1');%�½�newSlide�ڵ�
a=12.22;
newSlide.setAttribute('Max',sprintf('%f',a));%����Max����
newSlide.setAttribute('Min','0');%����Min����
docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
xmlwrite('regular.xml',docNode);%����xml
end
