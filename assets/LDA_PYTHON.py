import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix, roc_curve, auc, RocCurveDisplay

# ---------------------------------------------------------
# 1. 模拟信用风险数据生成
# ---------------------------------------------------------
# 为了演示，我们生成模拟的借贷数据
# 特征：
# - Income: 年收入 (假设经过对数变换符合正态分布)
# - Debt_Ratio: 负债率
# - Credit_History_Score: 历史信用评分 (越高越好)
# 目标：Default (0: 守信, 1: 违约)

np.random.seed(42)
n_samples = 1000

# 生成非违约客户 (Good Customers)
good_income = np.random.normal(11.5, 0.5, 800) # Log income
good_debt = np.random.normal(0.3, 0.1, 800)    # 30% debt ratio
good_score = np.random.normal(750, 50, 800)    # High credit score
y_good = np.zeros(800)

# 生成违约客户 (Bad Customers) - 均值有所偏移
bad_income = np.random.normal(10.8, 0.6, 200)  # Lower income
bad_debt = np.random.normal(0.55, 0.15, 200)   # Higher debt ratio
bad_score = np.random.normal(600, 60, 200)     # Low credit score
y_bad = np.ones(200)

# 合并数据
X = pd.DataFrame({
    'Log_Income': np.concatenate([good_income, bad_income]),
    'Debt_Ratio': np.concatenate([good_debt, bad_debt]),
    'Credit_Score': np.concatenate([good_score, bad_score])
})
y = np.concatenate([y_good, y_bad])

print(f"数据概览:\n总样本数: {n_samples}")
print(f"违约率 (Default Rate): {y.mean():.2%}\n")

# ---------------------------------------------------------
# 2. 数据预处理
# ---------------------------------------------------------
# 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42, stratify=y)

# 标准化 (Standardization) - LDA对数据的尺度比较敏感
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# ---------------------------------------------------------
# 3. LDA 模型训练
# ---------------------------------------------------------
lda = LinearDiscriminantAnalysis()
lda.fit(X_train_scaled, y_train)

# ---------------------------------------------------------
# 4. 模型预测与评估
# ---------------------------------------------------------
y_pred = lda.predict(X_test_scaled)
y_prob = lda.predict_proba(X_test_scaled)[:, 1] # 获取违约的概率

print("--- 线性判别分析 (LDA) 评估报告 ---")
print("\n1. 分类报告 (Classification Report):")
print(classification_report(y_test, y_pred, target_names=['Non-Default', 'Default']))

# 混淆矩阵
cm = confusion_matrix(y_test, y_pred)
print("\n2. 混淆矩阵 (Confusion Matrix):")
print(cm)

# 计算解释方差比 (对于多分类更有意义，但这里可以展示特征重要性的方向)
print("\n3. 特征系数 (Coefficients):")
coef_df = pd.DataFrame(lda.coef_, columns=X.columns, index=['Coefficient'])
print(coef_df.T)
# 解释: 
# 正系数增加判别为1(违约)的概率，负系数增加判别为0(守信)的概率
# 例如，Credit_Score 应该是很大的负数，Debt_Ratio 应该是正数

# ---------------------------------------------------------
# 5. 可视化 (ROC 曲线 & 决策边界)
# ---------------------------------------------------------
plt.figure(figsize=(12, 5))

# 绘制 ROC 曲线
plt.subplot(1, 2, 1)
fpr, tpr, _ = roc_curve(y_test, y_prob)
roc_auc = auc(fpr, tpr)
plt.plot(fpr, tpr, color='darkorange', lw=2, label=f'ROC curve (area = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate (1 - Specificity)')
plt.ylabel('True Positive Rate (Sensitivity)')
plt.title('ROC Curve for Credit Risk Model')
plt.legend(loc="lower right")
plt.grid(True, alpha=0.3)

# 绘制降维后的直方图 (LDA 1D Projection)
# 将数据投影到 LDA 找到的最佳轴上
plt.subplot(1, 2, 2)
X_test_proj = lda.transform(X_test_scaled)
plt.hist(X_test_proj[y_test==0], bins=20, alpha=0.6, label='Non-Default', color='green', density=True)
plt.hist(X_test_proj[y_test==1], bins=20, alpha=0.6, label='Default', color='red', density=True)
plt.title('LDA Projection Distribution')
plt.xlabel('LDA Discriminant Score')
plt.ylabel('Density')
plt.legend()
plt.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

# ---------------------------------------------------------
# 6. 简单的应用示例
# ---------------------------------------------------------
print("\n--- 单个申请人测试 ---")
# 假设一个新申请人: Log Income 11.0, Debt Ratio 0.45, Credit Score 680
new_applicant = np.array([[11.0, 0.45, 680]])
new_applicant_scaled = scaler.transform(new_applicant)
prediction = lda.predict(new_applicant_scaled)[0]
probability = lda.predict_proba(new_applicant_scaled)[0][1]

print(f"申请人数据: {new_applicant[0]}")
print(f"预测结果: {'违约 (拒贷)' if prediction==1 else '守信 (放贷)'}")
print(f"违约概率: {probability:.2%}")