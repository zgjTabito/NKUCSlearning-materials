#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>
using namespace std;

class BTreeNode {
public:
    vector<int> keys; // 关键字数组
    vector<BTreeNode*> children; // 子节点数组
    int maxChildren; // 每个节点最多的子节点数
    bool leaf; // 是否是叶子节点
    int n; // 当前节点中的关键字个数

    BTreeNode(int maxChildren1, bool leaf1) {
        maxChildren = maxChildren1;
        leaf = leaf1;
        keys.resize(maxChildren); // 每个节点最多 maxChildren-1 个关键字
        children.resize(maxChildren+1); // 每个节点最多 maxChildren 个子节点
        n = 0;
    }

    void insertNonFull(int k);
    void splitChild(int i, BTreeNode* y);
    void display(int indent = 0);
    void remove(int k);
    void removeFromLeaf(int idx);
    void removeFromNonLeaf(int idx);
    int findKey(int k);
    int getPred(int idx);
    int getSucc(int idx);
    void fill(int idx);
    void borrowFromPrev(int idx);
    void borrowFromNext(int idx);
    void merge(int idx);
    void toDotFormat(ofstream& out, int& nodeCount, bool isRoot);
    bool contains(int k) {
        int i = 0;
        while (i < n && k > keys[i]) {
            i++;
        }
        // 如果找到了该关键字，返回 true
        if (i < n && keys[i] == k) {
            return true;
        }
        // 如果是叶子节点且没有找到关键字，返回 false
        if (leaf) {
            return false;
        }
        // 在适当的子节点递归查找
        return children[i]->contains(k);
    }

};

class BTree {
public:
    BTreeNode* root;
    int maxChildren; // B树每个节点最多允许的子节点数量

    BTree(int maxChildren) {
        root = nullptr;
        this->maxChildren = maxChildren;
    }
    bool contains(int k);
    void insert(int k);
    void remove(int k);
    void display() {
        if (root != nullptr) root->display();
    }
    void generateDotFile(const string& filename) {
        ofstream out(filename);
        int nodeCount = 0;
        out << "digraph BTree {\n";
        if (root != nullptr) root->toDotFormat(out, nodeCount, true);
        out << "}\n";
        out.close();
        string command = "dot -Tpng -o  graph_dot.png .\\btree.dot";
        int result = system(command.c_str()); // 调用系统命令,生成图片
    }
};

void BTreeNode::insertNonFull(int k) {
    int i = n-1;
    if (leaf) {
        // 如果当前节点是叶节点，则在这里插入关键字k
        while (i >= 0 && keys[i] > k) {
            keys[i + 1] = keys[i];
            i--;
        }
        keys[i + 1] = k;
        n++;
    }
    else {
        // 如果是非叶子节点，先找到要插入的子节点
        while (i >= 0 && keys[i] > k) i--;
        // 递归地向子节点插入关键字
        children[i + 1]->insertNonFull(k);
        // 插入后，检查是否需要分裂子节点
        if (children[i+1]->n == maxChildren) {
            // 如果子节点已满，分裂子节点并将中间关键字提升到当前节点
            splitChild(i + 1, children[i + 1]);
        }
    }

}

void BTreeNode::splitChild(int i, BTreeNode* y) {
    // 创建一个新节点 z，分割节点 y
    BTreeNode* z = new BTreeNode(maxChildren, y->leaf);
    int midIndex = maxChildren / 2;
    z->n = maxChildren - 1 - midIndex;  // 新节点 z 的关键字数量

    // 将 y 的后半部分关键字移动到 z 中
    for (int j = 0; j < z->n; j++) {
        z->keys[j] = y->keys[midIndex + 1 + j];
    }

    // 如果 y 不是叶子节点，将 y 的子节点指针分配给 z
    if (!y->leaf) {
        for (int j = 0; j <= z->n; j++) {
            z->children[j] = y->children[midIndex + 1 + j];
        }
    }

    // 更新 y 节点的关键字数量为中间位置
    y->n = midIndex;

    // 将新节点 z 插入到当前节点的子节点数组中
    for (int j = n; j >= i + 1; j--) {
        children[j + 1] = children[j];
    }
    children[i + 1] = z;

    // 将中间关键字提升到当前节点
    for (int j = n - 1; j >= i; j--) {
        keys[j + 1] = keys[j];
    }
    keys[i] = y->keys[midIndex];

    // 更新当前节点的关键字数量
    n++;
}



void BTreeNode::remove(int k) {
    int idx = findKey(k);
    if (idx < n && keys[idx] == k) {
        if (leaf) {
            removeFromLeaf(idx);
        }
        else {
            removeFromNonLeaf(idx);
        }
    }
    else {
        // 未找到关键字
        if (leaf) {
            cout << "未找到相应的关键字\n";
            return;
        }
        // 先递归删除关键字
        children[idx]->remove(k);
    }
    // 递归删除后，再判断是否发生下溢出并进行修复
    if (!leaf&&children[idx]->n < ceil(maxChildren / 2) - 1)
        fill(idx);
}


int BTreeNode::findKey(int k) {
    int idx = 0;
    while (idx < n && keys[idx] < k) ++idx;
    return idx;
}

void BTreeNode::removeFromLeaf(int idx) {
    for (int i = idx + 1; i < n; ++i)
        keys[i - 1] = keys[i];
    n--;
}

void BTreeNode::removeFromNonLeaf(int idx) {
    int k = keys[idx];
    if (children[idx]->n >= (maxChildren + 1) / 2) {
        int pred = getPred(idx);
        keys[idx] = pred;
        children[idx]->remove(pred);
    }
    else if (children[idx + 1]->n >= (maxChildren + 1) / 2) {
        int succ = getSucc(idx);
        keys[idx] = succ;
        children[idx + 1]->remove(succ);
    }
    else {
        merge(idx);
        children[idx]->remove(k);
    }
}

int BTreeNode::getPred(int idx) {
    BTreeNode* cur = children[idx];
    while (!cur->leaf)
        cur = cur->children[cur->n];
    return cur->keys[cur->n - 1];
}

int BTreeNode::getSucc(int idx) {
    BTreeNode* cur = children[idx + 1];
    while (!cur->leaf)
        cur = cur->children[0];
    return cur->keys[0];
}

void BTreeNode::fill(int idx) {
    if (idx != 0 && children[idx - 1]->n > (maxChildren + 1) / 2)
        borrowFromPrev(idx);
    else if (idx != n && children[idx + 1]->n > (maxChildren + 1) / 2)
        borrowFromNext(idx);
    else {
        if (idx != n)
            merge(idx);
        else
            merge(idx - 1);
    }
}

void BTreeNode::borrowFromPrev(int idx) {
    BTreeNode* child = children[idx];
    BTreeNode* sibling = children[idx - 1];

    for (int i = child->n - 1; i >= 0; --i)
        child->keys[i + 1] = child->keys[i];

    if (!child->leaf) {
        for (int i = child->n; i >= 0; --i)
            child->children[i + 1] = child->children[i];
    }

    child->keys[0] = keys[idx - 1];

    if (!leaf)
        child->children[0] = sibling->children[sibling->n];

    keys[idx - 1] = sibling->keys[sibling->n - 1];

    child->n += 1;
    sibling->n -= 1;
}

void BTreeNode::borrowFromNext(int idx) {
    BTreeNode* child = children[idx];
    BTreeNode* sibling = children[idx + 1];

    child->keys[child->n] = keys[idx];

    if (!child->leaf)
        child->children[child->n + 1] = sibling->children[0];

    keys[idx] = sibling->keys[0];

    for (int i = 1; i < sibling->n; ++i)
        sibling->keys[i - 1] = sibling->keys[i];

    if (!sibling->leaf) {
        for (int i = 1; i <= sibling->n; ++i)
            sibling->children[i - 1] = sibling->children[i];
    }

    child->n += 1;
    sibling->n -= 1;
}

void BTreeNode::merge(int idx) {
    BTreeNode* child = children[idx];
    BTreeNode* sibling = children[idx + 1];

    child->keys[child->n] = keys[idx];

    for (int i = 0; i < sibling->n; ++i)
        child->keys[i + child->n + 1] = sibling->keys[i];

    if (!child->leaf) {
        for (int i = 0; i <= sibling->n; ++i)
            child->children[i + child->n + 1] = sibling->children[i];
    }

    for (int i = idx + 1; i < n; ++i)
        keys[i - 1] = keys[i];

    for (int i = idx + 2; i <= n; ++i)
        children[i - 1] = children[i];

    child->n += sibling->n + 1;
    n--;

    delete sibling;
}

void BTreeNode::display(int indent) {
    for (int i = 0; i < n; i++) {
        if (!leaf) children[i]->display(indent + 4);
        cout << string(indent, ' ') << keys[i] << "\n";
    }
    if (!leaf) children[n]->display(indent + 4);
}

void BTree::insert(int k) {
    if (contains(k)) {
        cout << "关键字 " << k << " 已经存在，不能重复插入。\n";
        return;
    }
    if (root == nullptr) {
        // 如果树为空，创建一个新的根节点
        root = new BTreeNode(maxChildren, true);
        root->keys[0] = k;
        root->n = 1;
    }
    else {
        // 从根节点开始插入
        root->insertNonFull(k);
        if (root->n == maxChildren) {
            // 如果根节点已满，需要分裂根节点
            BTreeNode* newRoot = new BTreeNode(maxChildren, false); // 新的根节点
            newRoot->children[0] = root;  // 新根的第一个子节点是当前的根
            newRoot->splitChild(0, root);  // 分裂当前根节点
            root = newRoot;  // 更新根节点为新的根节点
        }
    }
}

bool BTree::contains(int k) {
    if (root == nullptr) return false;
    return root->contains(k);
}

void BTree::remove(int k) {
    if (!root) {
        cout << "树是空的\n";
        return;
    }

    root->remove(k);

    if (root->n == 0) {
        BTreeNode* tmp = root;
        if (root->leaf) root = nullptr;
        else root = root->children[0];
        delete tmp;
    }
}

void BTreeNode::toDotFormat(ofstream& out, int& nodeCount, bool isRoot) {
    stringstream nodeLabel;
    string nodeName = "node" + to_string(nodeCount);
    nodeCount++;

    for (int i = 0; i < n; i++) {
        nodeLabel << keys[i];
        if (i < n - 1) nodeLabel << ", ";
    }

    out << nodeName << " [label=\"" << nodeLabel.str() << "\"];\n";

    if (isRoot) {
        out << nodeName << " [style=bold];\n";
    }

    for (int i = 0; i <= n; i++) {
        if (children[i]) {
            string childName = "node" + to_string(nodeCount);
            children[i]->toDotFormat(out, nodeCount, false);
            out << nodeName << " -> " << childName << ";\n";
        }
    }
}

int main() {
    int maxChildren, numKeys;
    cin >> numKeys >> maxChildren;

    BTree tree(maxChildren);
    string input;
    cin.ignore();
    getline(cin, input);

    stringstream ss(input);
    string token;
    while (getline(ss, token, ',')) {
        int key = stoi(token);
        tree.insert(key);
        cout << "插入 " << key << " 后的树形结构：\n";
        tree.display();
    }
    tree.generateDotFile("btree.dot");
    string op;
    int key;
    while (true) {
        cout << "请输入操作（I 插入, D 删除, Q 退出）：";
        cin >> op;
        if (op == "Q") break;
        if (op == "I") {
            cin >> key;
            tree.insert(key);
            cout << "插入 " << key << " 后的树形结构：\n";
            tree.display();
            tree.generateDotFile("btree.dot");
        }
        else if (op == "D") {
            cin >> key;
            tree.remove(key);
            cout << "删除 " << key << " 后的树形结构：\n";
            tree.display();
            tree.generateDotFile("btree.dot");
        }
        else if (op == "MI") {
            string token = "";
            char ch;
            while (cin >> ch) {
                //cout << ch;
                if (ch == '#') {
                    key = stoi(token);
                    token.clear();
                    tree.insert(key);
                    cout << "插入 " << key << " 后的树形结构：\n";
                    tree.display();
                    break;
                }
                else if (ch == ',') {
                    key = stoi(token);
                    token.clear();
                    tree.insert(key);
                    cout << "插入 " << key << " 后的树形结构：\n";
                    tree.display();
                }
                else if (isdigit(ch)) {
                    token += ch;
                }
            }
            tree.generateDotFile("btree.dot");
        }
        else if (op == "MD")
        {
            string token = "";
            char ch;
            while (cin >> ch) {
                if (ch == '#')
                {
                    key = stoi(token);
                    token.clear();
                    tree.remove(key);
                    cout << "删除 " << key << " 后的树形结构：\n";
                    tree.display();
                    break;
                }
                else if (ch == ',') {
                    key = stoi(token);
                    token.clear();
                    tree.remove(key);
                    cout << "删除 " << key << " 后的树形结构：\n";
                    tree.display();
                }
                else if (isdigit(ch)) {
                    token += ch;
                }
            }
            tree.generateDotFile("btree.dot");
        }
    }
    tree.generateDotFile("btree.dot");
    return 0;
}
