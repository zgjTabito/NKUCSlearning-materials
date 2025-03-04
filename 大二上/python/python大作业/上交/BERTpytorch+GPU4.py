import jieba
import re
import pandas as pd
import torch
from torch.utils.data import Dataset, DataLoader, random_split
from torch.optim import AdamW
from torch.nn import CrossEntropyLoss
from transformers import BertTokenizer, BertForSequenceClassification
from tqdm import tqdm
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, roc_curve, auc
import matplotlib.pyplot as plt
import numpy as np

# 加载停用词
def load_stopwords(file_path):
    stopwords = set()
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            stopwords.add(line.strip())
    return stopwords


# 数据加载函数
def load_data(file_path, has_label=True):
    data = []
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                parts = line.strip().split('_separator_')
                if len(parts) >= 3:
                    id = parts[0]
                    text = parts[1].strip() if parts[1] != 'nan' else ''
                    key = parts[2].strip() if parts[2] != 'nan' else ''
                    label = parts[3].strip() if has_label and len(parts) > 3 and parts[3] not in ['nan', ''] else None
                    data.append((id, text, key, label))
            except Exception as e:
                print(f"Error processing line: {line} - {e}")
    columns = ['ID', '文本内容', '关键词', '标签']
    return pd.DataFrame(data, columns=columns)


# 加载数据
train_data = load_data('train.txt', has_label=True)
test_data = load_data('test1.txt', has_label=False)

# 标签编码
unique_labels = sorted(set(train_data['标签'].dropna()))
label_to_index = {label: idx for idx, label in enumerate(unique_labels)}
index_to_label = {idx: label for label, idx in label_to_index.items()}
train_data['标签编码'] = train_data['标签'].map(label_to_index)

# 加载 BERT 分词器
tokenizer = BertTokenizer.from_pretrained('bert-base-chinese')

# 加载停用词
stopwords = load_stopwords('cn_stopwords.txt')


# 正则表达式，用于保留中文字符
def remove_non_chinese(text):
    return re.sub(r'[^\u4e00-\u9fa5]', '', text)


# 自定义 PyTorch 数据集
class TextDataset(Dataset):
    def __init__(self, data, tokenizer, stopwords, max_len=128, has_label=True):
        self.data = data
        self.tokenizer = tokenizer
        self.stopwords = stopwords
        self.max_len = max_len
        self.has_label = has_label

    def __len__(self):
        return len(self.data)

    def __getitem__(self, index):
        row = self.data.iloc[index]
        # 对标题进行分词
        title = (row['文本内容'] or '')
        keywords = (row['关键词'] or '')

        # 使用 jieba 对标题进行分词
        title_words = jieba.cut(title)

        # 将关键词按逗号分割，不进行分词处理
        keyword_words = keywords.split(',')

        # 拼接标题分词和关键词
        text = " ".join(title_words) + " " + " ".join(keyword_words)

        # 去除停用词
        filtered_words = [word for word in jieba.cut(text) if word not in self.stopwords and word.strip() != '']

        # 去除非汉字字符
        filtered_text = remove_non_chinese(" ".join(filtered_words))

        # 使用 BERT 分词器处理文本
        encoding = self.tokenizer(
            filtered_text,     # 处理好的数据
            truncation=True,
            padding='max_length',
            max_length=self.max_len,  # 因为标题都不长，认为128足够，不足128的部分用[PAD]填充
            return_tensors='pt'      # 返回pytorch张量，方便处理
        )
        input_ids = encoding['input_ids'].squeeze()
        attention_mask = encoding['attention_mask'].squeeze()
        if self.has_label:
            label = row['标签编码']
            return input_ids, attention_mask, label
        return input_ids, attention_mask


# 创建数据集和数据加载器
train_dataset = TextDataset(train_data, tokenizer, stopwords, has_label=True)
test_dataset = TextDataset(test_data, tokenizer, stopwords, has_label=False)

train_size = int(0.9 * len(train_dataset))
val_size = len(train_dataset) - train_size
train_dataset, val_dataset = random_split(train_dataset, [train_size, val_size])

train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=32)
test_loader = DataLoader(test_dataset, batch_size=32)

# 加载模型
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = BertForSequenceClassification.from_pretrained('bert-base-chinese', num_labels=len(label_to_index))
model.to(device)  # 将模型移到 GPU 或 CPU 上

# 优化器
optimizer = AdamW(model.parameters(), lr=2e-5)


# 训练函数
def train_epoch(model, data_loader, optimizer, device):
    model.train()
    loss_fn = CrossEntropyLoss()
    total_loss, total_correct = 0, 0

    for input_ids, attention_mask, labels in tqdm(data_loader):
        input_ids, attention_mask, labels = (
            input_ids.to(device),
            attention_mask.to(device),
            labels.to(device)
        )
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        logits = outputs.logits
        loss = loss_fn(logits, labels)
        total_loss += loss.item()
        total_correct += (logits.argmax(dim=1) == labels).sum().item()

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        # 清理缓存
        torch.cuda.empty_cache()
    return total_loss / len(data_loader), total_correct / len(data_loader.dataset)


def plot_multiclass_roc(y_true, y_probs, num_classes):
    true_labels_one_hot = np.zeros((len(y_true), num_classes))
    for i, label in enumerate(y_true):
        true_labels_one_hot[i, label] = 1

    plt.figure(figsize=(10, 8))
    for i in range(num_classes):
        fpr, tpr, _ = roc_curve(true_labels_one_hot[:, i], y_probs[:, i])
        roc_auc = auc(fpr, tpr)
        plt.plot(fpr, tpr, label=f'Class {index_to_label[i]} (AUC = {roc_auc:.2f})')

    plt.plot([0, 1], [0, 1], 'k--', label='Random Guessing')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Multiclass ROC Curve')
    plt.legend(loc='lower right')
    plt.show()


# 验证函数（移除即时评估指标输出，返回完整数据）
def eval_model(model, data_loader, device):
    model.eval()
    total_loss, total_correct = 0, 0
    loss_fn = CrossEntropyLoss()

    all_true_labels = []
    all_predicted_labels = []
    all_predicted_probs = []

    with torch.no_grad():
        for input_ids, attention_mask, labels in data_loader:
            input_ids, attention_mask, labels = (
                input_ids.to(device),
                attention_mask.to(device),
                labels.to(device)
            )
            outputs = model(input_ids=input_ids, attention_mask=attention_mask)
            logits = outputs.logits
            loss = loss_fn(logits, labels)
            total_loss += loss.item()
            total_correct += (logits.argmax(dim=1) == labels).sum().item()

            all_true_labels.extend(labels.cpu().numpy())
            all_predicted_labels.extend(logits.argmax(dim=1).cpu().numpy())
            all_predicted_probs.extend(torch.softmax(logits, dim=1).cpu().numpy())

    return total_loss / len(data_loader), all_true_labels, all_predicted_labels, all_predicted_probs


# 训练模型
EPOCHS = 10# 验证函数（移除即时评估指标输出，返回完整数据）
def eval_model(model, data_loader, device):
    model.eval()
    total_loss, total_correct = 0, 0
    loss_fn = CrossEntropyLoss()

    all_true_labels = []
    all_predicted_labels = []
    all_predicted_probs = []

    with torch.no_grad():
        for input_ids, attention_mask, labels in data_loader:
            input_ids, attention_mask, labels = (
                input_ids.to(device),
                attention_mask.to(device),
                labels.to(device)
            )
            outputs = model(input_ids=input_ids, attention_mask=attention_mask)
            logits = outputs.logits
            loss = loss_fn(logits, labels)
            total_loss += loss.item()
            total_correct += (logits.argmax(dim=1) == labels).sum().item()

            all_true_labels.extend(labels.cpu().numpy())
            all_predicted_labels.extend(logits.argmax(dim=1).cpu().numpy())
            all_predicted_probs.extend(torch.softmax(logits, dim=1).cpu().numpy())

    return total_loss / len(data_loader), all_true_labels, all_predicted_labels, all_predicted_probs

patience = 3  # 设定耐心值为3轮
best_val_loss = float('inf')
patience_counter = 0  # 记录验证集损失没有改善的轮次
best_model_state = None  # 用于保存最优模型

final_true_labels = None
final_predicted_probs = None
final_predicted_labels = None

for epoch in range(EPOCHS):
    print(f"Epoch {epoch + 1}/{EPOCHS}")
    train_loss, train_acc = train_epoch(model, train_loader, optimizer, device)
    val_loss, all_true_labels, all_predicted_labels, all_predicted_probs = eval_model(model, val_loader, device)

    # 计算分类指标
    val_acc = accuracy_score(all_true_labels, all_predicted_labels)
    val_precision = precision_score(all_true_labels, all_predicted_labels, average='weighted')
    val_recall = recall_score(all_true_labels, all_predicted_labels, average='weighted')
    val_f1 = f1_score(all_true_labels, all_predicted_labels, average='weighted')

    print(f"Train Loss: {train_loss:.4f}, Train Accuracy: {train_acc:.4f}")
    print(f"Val Loss: {val_loss:.4f}, Val Accuracy: {val_acc:.4f}")
    print(f"Val Precision: {val_precision:.4f}, Val Recall: {val_recall:.4f}, Val F1 Score: {val_f1:.4f}")

    # 如果验证集损失下降，保存模型并重置耐心计数器
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        best_model_state = model.state_dict()  # 保存最优模型状态
        patience_counter = 0  # 重置耐心计数器

        # 保存最优模型的验证集结果
        final_true_labels = all_true_labels
        final_predicted_probs = all_predicted_probs
        final_predicted_labels = all_predicted_labels
    else:
        patience_counter += 1  # 增加耐心计数器

    # 如果耐心计数器达到设定值，停止训练
    if patience_counter >= patience:
        print(f"Early stopping triggered. Stopping training after {epoch + 1} epochs.")
        break

# 恢复到最佳模型状态
if best_model_state is not None:
    model.load_state_dict(best_model_state)

# 在训练结束后基于最优模型计算最终指标并绘制ROC曲线
if final_true_labels is not None and final_predicted_probs is not None:
    final_accuracy = accuracy_score(final_true_labels, final_predicted_labels)
    final_precision = precision_score(final_true_labels, final_predicted_labels, average='weighted')
    final_recall = recall_score(final_true_labels, final_predicted_labels, average='weighted')
    final_f1 = f1_score(final_true_labels, final_predicted_labels, average='weighted')

    print("\nFinal Evaluation Metrics:")
    print(f"Accuracy: {final_accuracy:.4f}")
    print(f"Precision: {final_precision:.4f}")
    print(f"Recall: {final_recall:.4f}")
    print(f"F1 Score: {final_f1:.4f}")

    # 绘制最终的ROC曲线
    plot_multiclass_roc(final_true_labels, np.array(final_predicted_probs), len(unique_labels))



# 预测测试集
model.eval()
predicted_labels = []

with torch.no_grad():
    for input_ids, attention_mask in tqdm(test_loader):
        input_ids, attention_mask = input_ids.to(device), attention_mask.to(device)
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        logits = outputs.logits
        predicted_labels.extend(logits.argmax(dim=1).cpu().numpy())

# 将预测结果映射回标签
test_data['预测标签'] = [index_to_label[label] for label in predicted_labels]

# 保存预测结果
test_data[['ID', '预测标签']].to_csv("submission.csv", index=False)

# 输出部分预测结果
print(test_data[['ID', '预测标签']].head())


# 保存模型
torch.save(model.state_dict(), 'best_model_zgj.pth')

