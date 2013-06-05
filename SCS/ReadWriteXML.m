% 读写xml
function [ output_args ] = ReadWriteXML( input_args )
clear
docNode=com.mathworks.xml.XMLUtils.createDocument('root_element');%创建xml
docRootNode = docNode.getDocumentElement;%获取xml跟节点
newSlide=docNode.createElement('Slide1');%新建newSlide节点
a=12.22;
newSlide.setAttribute('Max',sprintf('%f',a));%设置Max属性
newSlide.setAttribute('Min','0');%设置Min属性
docRootNode.appendChild(newSlide);%将newSlide插入docRootNode的末尾
xmlwrite('regular.xml',docNode);%保存xml
end
