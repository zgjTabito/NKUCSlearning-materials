#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cctype>
#include <regex>
#include <algorithm>
using namespace std;

const long long MOD = 1e9 + 7;  // 大素数，用于取模
const long long BASE = 31;      // 哈希的基数

// 音节块哈希函数
long long syllable_block_hash(const string& str) {
    long long hash_value = 0;
    long long power = 1;

    // 使用正则表达式提取音节块
    regex syllable_regex("([^aeiou]*[aeiou]+)");
    auto words_begin = sregex_iterator(str.begin(), str.end(), syllable_regex);
    auto words_end = sregex_iterator();

    for (auto it = words_begin; it != words_end; ++it) {
        string syllable = it->str();

        // 对音节块计算哈希值
        for (char c : syllable) {
            hash_value = (hash_value + (c * power) % MOD) % MOD;
            power = (power * BASE) % MOD;
        }
    }
    return hash_value;
}

// 普通字符哈希函数
long long polynomial_hash(const string& str) {
    long long hash_value = 0;
    long long power = 1;

    for (char c : str) {
        hash_value = (hash_value + (c * power) % MOD) % MOD;
        power = (power * BASE) % MOD;
    }
    return hash_value;
}

// 哈希表类
class HashTable {
public:
    HashTable(int size) : table(size, "") {}

    // 插入单词
    void insert(const string& word, long long (*hash_func)(const string&)) {
        long long hash_value = hash_func(word) % table.size();
        int index = hash_value;

        // 线性探测法解决冲突
        while (!table[index].empty()) {
            index = (index + 1) % table.size();
        }
        table[index] = word;
        ++count;
    }

    // 查找单词，返回探测次数
    int find(const string& word, long long (*hash_func)(const string&)) const {
        long long hash_value = hash_func(word) % table.size();
        int index = hash_value;
        int probes = 1;

        while (!table[index].empty()) {
            if (table[index] == word) {
                return probes;
            }
            index = (index + 1) % table.size();
            ++probes;
        }
        return probes;
    }

private:
    vector<string> table;
    int count = 0;  // 哈希表中的元素个数
};

// 提取文章中的单词并插入哈希表
void process_article(const string& article, HashTable& hash_table, long long (*hash_func)(const string&)) {
    istringstream stream(article);
    string word;

    while (stream >> word) {
        // 去除标点符号，仅保留字母
        word.erase(remove_if(word.begin(), word.end(), [](char c) { return !isalpha(c); }), word.end());
        // 转为小写字母
        transform(word.begin(), word.end(), word.begin(), ::tolower);

        if (!word.empty()) {
            hash_table.insert(word, hash_func);
        }
    }
}

int main() {
    // 输入文章内容
    string article1, article2;
    cout << "请输入第一篇文章：\n";
    getline(cin, article1);

    cout << "请输入第二篇文章：\n";
    getline(cin, article2);

    // 创建两个哈希表
    int table_size = 100;
    HashTable hash_table_letters(table_size);
    HashTable hash_table_syllables(table_size);

    // 处理第一篇文章并构造两个哈希表
    process_article(article1, hash_table_letters, polynomial_hash);
    process_article(article1, hash_table_syllables, syllable_block_hash);

    // 查找第二篇文章中的单词并显示查询结果
    istringstream stream(article2);
    string word;
    int total_probes_letters = 0;
    int total_probes_syllables = 0;
    int word_count = 0;

    cout << "\n第二篇文章中的每个单词的查询结果：\n";
    while (stream >> word) {
        word.erase(remove_if(word.begin(), word.end(), [](char c) { return !isalpha(c); }), word.end());
        transform(word.begin(), word.end(), word.begin(), ::tolower);

        if (!word.empty()) {
            int probes_letters = hash_table_letters.find(word, polynomial_hash);
            int probes_syllables = hash_table_syllables.find(word, syllable_block_hash);

            // 输出查询结果
            cout << "单词: " << word << "\n"
                << "基于字母的查询次数: " << probes_letters << "\n"
                << "基于音节块的查询次数: " << probes_syllables << "\n\n";

            total_probes_letters += probes_letters;
            total_probes_syllables += probes_syllables;
            ++word_count;
        }
    }

    // 输出两个平均查找长度
    if (word_count > 0) {
        double average_probes_letters = static_cast<double>(total_probes_letters) / word_count;
        double average_probes_syllables = static_cast<double>(total_probes_syllables) / word_count;

        cout << "基于字母的平均查找长度: " << average_probes_letters << endl;
        cout << "基于音节块的平均查找长度: " << average_probes_syllables << endl;
    }
    else {
        cout << "没有有效的单词进行查找。" << endl;
    }

    return 0;
}
