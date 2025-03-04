#include <iostream>
#include <fstream>
#include <queue>
#include <vector>
#include <unordered_map>
#include <string>

using namespace std;

class Node {
public:
    char c;
    int freq;
    Node* left;
    Node* right;

    Node(char c, int freq) {
        this->c = c;
        this->freq = freq;
        left = nullptr;
        right = nullptr;
    }

    // 用于合并节点
    Node(int freq, Node* left, Node* right) {
        this->c = '\0'; // 非叶子节点，字符为空
        this->freq = freq;
        this->left = left;
        this->right = right;
    }
};

// 比较函数，用于优先队列
class Compare {
public:
    bool operator()(Node* l, Node* r) {
        return l->freq > r->freq;
    }
};

// 创建Huffman树
Node* buildTree(priority_queue<Node*, vector<Node*>, Compare>& pq) {
    while (pq.size() > 1) {
        Node* left = pq.top(); pq.pop();
        Node* right = pq.top(); pq.pop();

        // 合并两个频率最小的节点
        Node* merged = new Node(left->freq + right->freq, left, right);
        pq.push(merged);
    }
    return pq.top(); // 返回根节点
}


// 生成Huffman编码
void generateHuffmanCodes(Node* root, const string& str, unordered_map<char, string>& huffmanCodes) {
    if (!root) return;
    if (root->left == nullptr && root->right == nullptr) {
        huffmanCodes[root->c] = str;
    }
    generateHuffmanCodes(root->left, str + "0", huffmanCodes);
    generateHuffmanCodes(root->right, str + "1", huffmanCodes);
}

string decodeHuffman(Node* root, const string& binaryStr) {
    string decodedText = "";
    Node* current = root;
    for (char bit : binaryStr) {
        if (bit == '0') current = current->left;
        else current = current->right;

        if (current->left == nullptr && current->right == nullptr) {
            decodedText += current->c;
            current = root;
        }
    }
    return decodedText;
}


int main() {

    int freqMap[128]; 
    for (int i = 0;i < 128;i++)freqMap[i] = 0;
    char c;
    ifstream inputFile("inputfile1.txt");

    while (inputFile.get(c)) {
        freqMap[c]++; 
    }
    inputFile.close();
    //测试
    //string test = "test example exaarafoasaegaegfa";
    //for(auto c : test)
    //    freqMap[c]++; // 更新频率

    priority_queue<Node*, vector<Node*>, Compare> pq;

    for (int i = 0;i < 128;i++) {
        //if (freqMap[i] == 0) freqMap[i] = 1;
        pq.push(new Node(char(i), freqMap[i]));
    }

    // 构造Huffman树
    Node* root = buildTree(pq);

    // 生成Huffman编码
    unordered_map<char, string> huffmanCodes;
    generateHuffmanCodes(root, "", huffmanCodes);


    ofstream outputfile1("outputfile1.txt");
    for (int i = 0; i < 128; i++) {
        if (i < 32 || i == 127) {
            outputfile1 << "ASCII " << i << ";" << freqMap[i] << ";" << huffmanCodes[char(i)] << endl;
        }
        else {
            outputfile1 << char(i) << ";" << freqMap[i] << ";" << huffmanCodes[char(i)] << endl;
        }
    }
    outputfile1.close();

    ifstream input("inputfile2.txt");
    ofstream binaryOutput("outputfile.dat", ios::binary);
    char ch;
    while (input.get(ch))
    {
        binaryOutput << huffmanCodes[ch];
    }
    binaryOutput.close();
    input.close();
    char byte;
    ifstream binaryInput("outputfile.dat", ios::binary);
    string binaryStr = "";
    // 逐字节读取文件内容并拼接为01串
    while (binaryInput.get(byte)) {
        binaryStr += byte; // 将每个字节直接追加到binaryStr中
    }
    binaryInput.close();
    
    string decodedText = decodeHuffman(root, binaryStr);
    ofstream outputfile2("outputfile2.txt");
    outputfile2 << decodedText;
    outputfile2.close();

    return 0;
}
