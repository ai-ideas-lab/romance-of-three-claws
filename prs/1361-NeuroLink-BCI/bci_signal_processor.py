"""
NeuroLink - 意念控制脑机接口平台
核心BCI信号处理和意图识别系统
"""

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from typing import Dict, List, Any, Optional, Tuple
import logging
from dataclasses import dataclass
from enum import Enum

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class IntentType(Enum):
    """意图类型枚举"""
    TEXT_INPUT = "text_input"
    ENVIRONMENT_CONTROL = "environment_control"
    COMMUNICATION = "communication"
    GAMING = "gaming"
    SCROLLING = "scrolling"
    SELECTION = "selection"
    EMERGENCY = "emergency"
    UNKNOWN = "unknown"

@dataclass
class EEGData:
    """脑电数据结构"""
    signals: np.ndarray  # (channels, time_samples)
    sampling_rate: int = 250
    timestamp: Optional[float] = None
    quality_score: float = 0.0
    
@dataclass
class IntentionResult:
    """意图识别结果"""
    intent: IntentType
    confidence: float
    features: Dict[str, Any]
    timestamp: float
    signal_quality: float

class BrainSignalProcessor:
    """脑电信号处理器"""
    
    def __init__(self, num_channels: int = 64):
        self.num_channels = num_channels
        self.sampling_rate = 250
        self.preprocessor = SignalPreprocessor()
        self.feature_extractor = FeatureExtractor(num_channels)
        self.quality_analyzer = SignalQualityAnalyzer()
        
    def process_eeg_data(self, eeg_data: EEGData) -> IntentionResult:
        """
        处理脑电数据并识别意图
        
        Args:
            eeg_data: 脑电数据
            
        Returns:
            意图识别结果
        """
        logger.info(f"开始处理脑电数据，通道数: {eeg_data.signals.shape[0]}")
        
        # 1. 信号预处理
        cleaned_signals = self.preprocessor.clean(eeg_data.signals)
        
        # 2. 信号质量评估
        quality_score = self.quality_analyzer.assess_quality(cleaned_signals)
        eeg_data.quality_score = quality_score
        
        # 3. 特征提取
        features = self.feature_extractor.extract_features(cleaned_signals)
        
        # 4. 意图分类
        intent, confidence = self._classify_intent(features)
        
        # 5. 结果验证
        if confidence < 0.7:
            intent = IntentType.UNKNOWN
            confidence = 0.0
            
        result = IntentionResult(
            intent=intent,
            confidence=confidence,
            features=features,
            timestamp=eeg_data.timestamp or 0.0,
            signal_quality=quality_score
        )
        
        logger.info(f"意图识别结果: {intent.value}, 置信度: {confidence:.2f}")
        return result
    
    def _classify_intent(self, features: Dict[str, np.ndarray]) -> Tuple[IntentType, float]:
        """
        基于特征分类意图
        
        Args:
            features: 提取的特征
            
        Returns:
            意图类型和置信度
        """
        # 简化的意图分类逻辑
        # 实际实现中使用深度学习模型
        
        # 根据特征强度判断意图
        alpha_power = features.get('alpha_power', 0)
        beta_power = features.get('beta_power', 0)
        gamma_power = features.get('gamma_power', 0)
        theta_power = features.get('theta_power', 0)
        
        # 运动想象检测（beta和gamma功率增加）
        motor_imagery = (beta_power + gamma_power) / (alpha_power + theta_power + 1e-6)
        
        # 放松状态检测（alpha功率增加）
        relaxed_state = alpha_power / (beta_power + gamma_power + 1e-6)
        
        # 决策逻辑
        if motor_imagery > 2.0:
            return IntentType.SELECTION, min(motor_imagery / 3.0, 1.0)
        elif relaxed_state > 1.5:
            return IntentType.COMMUNICATION, min(relaxed_state / 2.0, 1.0)
        elif gamma_power > 0.8:
            return IntentType.EMERGENCY, min(gamma_power, 1.0)
        else:
            return IntentType.UNKNOWN, 0.0

class SignalPreprocessor:
    """信号预处理器"""
    
    def __init__(self):
        self.notch_filter = NotchFilter(50)  # 50Hz工频干扰
        self.bandpass_filter = BandpassFilter(1, 45)  # 1-45Hz通带
        self.artifact_removal = ArtifactRemoval()
        
    def clean(self, signals: np.ndarray) -> np.ndarray:
        """
        清理脑电信号
        
        Args:
            signals: 原始信号
            
        Returns:
            清理后的信号
        """
        cleaned = signals.copy()
        
        # 1. 去除工频干扰
        cleaned = self.notch_filter.filter(cleaned)
        
        # 2. 带通滤波
        cleaned = self.bandpass_filter.filter(cleaned)
        
        # 3. 伪迹去除
        cleaned = self.artifact_removal.remove_artifacts(cleaned)
        
        # 4. 归一化
        cleaned = self._normalize_signals(cleaned)
        
        return cleaned
    
    def _normalize_signals(self, signals: np.ndarray) -> np.ndarray:
        """信号归一化"""
        # 去除均值，标准化方差
        mean_removed = signals - np.mean(signals, axis=1, keepdims=True)
        normalized = mean_removed / (np.std(mean_removed, axis=1, keepdims=True) + 1e-6)
        return normalized

class FeatureExtractor:
    """特征提取器"""
    
    def __init__(self, num_channels: int):
        self.num_channels = num_channels
        self.frequency_analyzer = FrequencyAnalyzer()
        self.time_domain_analyzer = TimeDomainAnalyzer()
        self.spatial_analyzer = SpatialAnalyzer(num_channels)
        
    def extract_features(self, signals: np.ndarray) -> Dict[str, Any]:
        """
        从脑电信号中提取特征
        
        Args:
            signals: 清理后的脑电信号
            
        Returns:
            提取的特征字典
        """
        features = {}
        
        # 1. 时域特征
        time_features = self.time_domain_analyzer.extract(signals)
        features.update(time_features)
        
        # 2. 频域特征
        freq_features = self.frequency_analyzer.extract(signals)
        features.update(freq_features)
        
        # 3. 空域特征
        spatial_features = self.spatial_analyzer.extract(signals)
        features.update(spatial_features)
        
        # 4. 统计特征
        statistical_features = self._extract_statistical_features(signals)
        features.update(statistical_features)
        
        return features
    
    def _extract_statistical_features(self, signals: np.ndarray) -> Dict[str, float]:
        """提取统计特征"""
        features = {}
        
        # 计算各通道的统计特征
        for i in range(signals.shape[0]):
            channel_data = signals[i]
            features[f'channel_{i}_mean'] = np.mean(channel_data)
            features[f'channel_{i}_std'] = np.std(channel_data)
            features[f'channel_{i}_var'] = np.var(channel_data)
            features[f'channel_{i}_rms'] = np.sqrt(np.mean(channel_data**2))
        
        # 全局统计特征
        features['global_mean'] = np.mean(signals)
        features['global_std'] = np.std(signals)
        features['global_var'] = np.var(signals)
        
        return features

class HybridBCINetwork(nn.Module):
    """混合BCI神经网络"""
    
    def __init__(self, num_channels: int = 64, num_intents: int = len(IntentType)):
        super(HybridBCINetwork, self).__init__()
        
        self.num_channels = num_channels
        self.num_intents = num_intents
        
        # 时域卷积网络
        self.temporal_net = TemporalConvNet(num_channels)
        
        # 空域图网络
        self.spatial_net = SpatialGraphNet(num_channels)
        
        # 意图解码器
        self.intent_decoder = IntentDecoder(
            temporal_dim=128,
            spatial_dim=128,
            num_intents=num_intents
        )
        
        # 注意力机制
        self.attention = MultiHeadAttention(
            embed_dim=256,
            num_heads=8,
            dropout=0.1
        )
        
    def forward(self, x: torch.Tensor) -> Dict[str, Any]:
        """
        前向传播
        
        Args:
            x: 输入信号 (batch, channels, time)
            
        Returns:
            预测结果
        """
        batch_size, channels, time = x.shape
        
        # 1. 时域特征提取
        temporal_features = self.temporal_net(x)
        
        # 2. 空域特征提取
        spatial_features = self.spatial_net(x)
        
        # 3. 特征融合
        fused_features = torch.cat([temporal_features, spatial_features], dim=-1)
        
        # 4. 注意力机制
        attended_features = self.attention(fused_features, fused_features)
        
        # 5. 意图解码
        intent_logits = self.intent_decoder(attended_features)
        intent_probs = F.softmax(intent_logits, dim=-1)
        
        return {
            'intent_logits': intent_logits,
            'intent_probs': intent_probs,
            'temporal_features': temporal_features,
            'spatial_features': spatial_features,
            'attended_features': attended_features
        }

class TemporalConvNet(nn.Module):
    """时域卷积网络"""
    
    def __init__(self, num_channels: int):
        super(TemporalConvNet, self).__init__()
        
        self.conv_layers = nn.ModuleList([
            nn.Conv1d(num_channels, 64, kernel_size=3, padding=1),
            nn.Conv1d(64, 128, kernel_size=3, padding=1),
            nn.Conv1d(128, 256, kernel_size=3, padding=1),
        ])
        
        self.pool = nn.AdaptiveAvgPool1d(1)
        self.dropout = nn.Dropout(0.3)
        
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """前向传播"""
        x = x.transpose(1, 2)  # (batch, time, channels) -> (batch, channels, time)
        
        for conv in self.conv_layers:
            x = F.relu(conv(x))
            x = self.dropout(x)
        
        x = self.pool(x)  # (batch, channels, 1)
        x = x.squeeze(-1)  # (batch, channels)
        
        return x

class SpatialGraphNet(nn.Module):
    """空域图网络"""
    
    def __init__(self, num_channels: int):
        super(SpatialGraphNet, self).__init__()
        
        # 简化的图卷积层
        self.graph_conv = nn.Conv1d(num_channels, 128, kernel_size=1)
        self.attention = nn.Sequential(
            nn.Linear(128, 64),
            nn.Tanh(),
            nn.Linear(64, 1)
        )
        
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """前向传播"""
        batch_size, channels, time = x.shape
        
        # 图卷积
        spatial_features = self.graph_conv(x)  # (batch, 128, time)
        
        # 空间注意力
        attention_weights = self.attention(spatial_features.transpose(1, 2))  # (batch, time, 1)
        attended_features = spatial_features * attention_weights.transpose(1, 2)
        
        # 全局平均池化
        spatial_features = torch.mean(attended_features, dim=-1)  # (batch, 128)
        
        return spatial_features

class IntentDecoder(nn.Module):
    """意图解码器"""
    
    def __init__(self, temporal_dim: int, spatial_dim: int, num_intents: int):
        super(IntentDecoder, self).__init__()
        
        total_dim = temporal_dim + spatial_dim
        
        self.decoder = nn.Sequential(
            nn.Linear(total_dim, 256),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(256, 128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, num_intents)
        )
        
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """前向传播"""
        return self.decoder(x)

class MultiHeadAttention(nn.Module):
    """多头注意力机制"""
    
    def __init__(self, embed_dim: int, num_heads: int, dropout: float = 0.1):
        super(MultiHeadAttention, self).__init__()
        
        self.embed_dim = embed_dim
        self.num_heads = num_heads
        self.head_dim = embed_dim // num_heads
        
        self.qkv = nn.Linear(embed_dim, 3 * embed_dim)
        self.projection = nn.Linear(embed_dim, embed_dim)
        self.dropout = nn.Dropout(dropout)
        
    def forward(self, x: torch.Tensor, mask: Optional[torch.Tensor] = None) -> torch.Tensor:
        """前向传播"""
        batch_size, seq_len, _ = x.shape
        
        # QKV投影
        qkv = self.qkv(x)
        q, k, v = qkv.chunk(3, dim=-1)
        
        # 重塑为多头
        q = q.view(batch_size, seq_len, self.num_heads, self.head_dim).transpose(1, 2)
        k = k.view(batch_size, seq_len, self.num_heads, self.head_dim).transpose(1, 2)
        v = v.view(batch_size, seq_len, self.num_heads, self.head_dim).transpose(1, 2)
        
        # 注意力计算
        attention = torch.matmul(q, k.transpose(-2, -1)) / (self.head_dim ** 0.5)
        
        if mask is not None:
            attention = attention.masked_fill(mask == 0, -1e9)
        
        attention = F.softmax(attention, dim=-1)
        attention = self.dropout(attention)
        
        # 输出投影
        output = torch.matmul(attention, v)
        output = output.transpose(1, 2).contiguous().view(batch_size, seq_len, self.embed_dim)
        
        return self.projection(output)

class AdaptiveLearningSystem:
    """自适应学习系统"""
    
    def __init__(self):
        self.federated_learner = FederatedLearningModule()
        self.online_learner = OnlineLearningModule()
        self.transfer_learner = TransferLearningModule()
        
    def adapt_to_user(self, user_id: str, eeg_data: EEGData, 
                     performance_metrics: Dict[str, float]) -> None:
        """适应用户个性化需求"""
        
        # 联邦学习更新
        if self._should_federated_learning(user_id):
            self.federated_learner.update_model(user_id, eeg_data)
        
        # 在线学习适应
        self.online_learner.adapt(eeg_data, performance_metrics)
        
        # 迁移学习（新用户）
        if self._is_new_user(user_id):
            self.transfer_learner.quick_deploy(user_id, eeg_data)
    
    def _should_federated_learning(self, user_id: str) -> bool:
        """判断是否需要联邦学习"""
        # 检查用户数据量和隐私设置
        user_data = self.federated_learner.get_user_data(user_id)
        return (len(user_data) > 100 and 
                user_data.get('consent', False) and
                user_data.get('data_quality', 0) > 0.8)

class FederatedLearningModule:
    """联邦学习模块"""
    
    def update_model(self, user_id: str, eeg_data: EEGData) -> None:
        """更新联邦学习模型"""
        # 实际实现中会使用安全的多方计算
        logger.info(f"联邦学习更新: 用户 {user_id}")
        
    def get_user_data(self, user_id: str) -> Dict[str, Any]:
        """获取用户数据"""
        return {}

class OnlineLearningModule:
    """在线学习模块"""
    
    def adapt(self, eeg_data: EEGData, performance_metrics: Dict[str, float]) -> None:
        """在线学习适应"""
        logger.info(f"在线学习适应，性能指标: {performance_metrics}")

class TransferLearningModule:
    """迁移学习模块"""
    
    def quick_deploy(self, user_id: str, eeg_data: EEGData) -> None:
        """快速部署到新用户"""
        logger.info(f"为新用户 {user_id} 快速部署")

class SignalQualityAnalyzer:
    """信号质量分析器"""
    
    def assess_quality(self, signals: np.ndarray) -> float:
        """评估信号质量"""
        # 简化的信号质量评估
        signal_power = np.mean(signals ** 2)
        noise_level = np.std(np.diff(signals, axis=1), axis=1)
        snr = signal_power / (np.mean(noise_level) + 1e-6)
        
        # 将信噪比映射到0-1范围
        quality = min(snr / 10.0, 1.0)
        return quality

class NotchFilter:
    """陷波滤波器"""
    
    def __init__(self, freq: float, quality: float = 30):
        self.freq = freq
        self.quality = quality
        
    def filter(self, signals: np.ndarray) -> np.ndarray:
        """应用陷波滤波"""
        # 简化的陷波滤波实现
        return signals

class BandpassFilter:
    """带通滤波器"""
    
    def __init__(self, low_freq: float, high_freq: float):
        self.low_freq = low_freq
        self.high_freq = high_freq
        
    def filter(self, signals: np.ndarray) -> np.ndarray:
        """应用带通滤波"""
        # 简化的带通滤波实现
        return signals

class ArtifactRemoval:
    """伪迹去除"""
    
    def remove_artifacts(self, signals: np.ndarray) -> np.ndarray:
        """去除伪迹"""
        # 简化的伪迹去除实现
        return signals

class TimeDomainAnalyzer:
    """时域分析器"""
    
    def extract(self, signals: np.ndarray) -> Dict[str, float]:
        """提取时域特征"""
        features = {}
        
        # 计算均值
        features['mean'] = np.mean(signals)
        features['std'] = np.std(signals)
        features['var'] = np.var(signals)
        features['rms'] = np.sqrt(np.mean(signals ** 2))
        
        # 计算偏度和峰度
        features['skewness'] = self._calculate_skewness(signals)
        features['kurtosis'] = self._calculate_kurtosis(signals)
        
        return features
    
    def _calculate_skewness(self, data: np.ndarray) -> float:
        """计算偏度"""
        mean = np.mean(data)
        std = np.std(data)
        return np.mean(((data - mean) / std) ** 3)
    
    def _calculate_kurtosis(self, data: np.ndarray) -> float:
        """计算峰度"""
        mean = np.mean(data)
        std = np.std(data)
        return np.mean(((data - mean) / std) ** 4) - 3

class FrequencyAnalyzer:
    """频域分析器"""
    
    def extract(self, signals: np.ndarray) -> Dict[str, float]:
        """提取频域特征"""
        features = {}
        
        # FFT分析
        fft_result = np.fft.fft(signals, axis=1)
        power_spectrum = np.abs(fft_result) ** 2
        
        # 频带功率
        fs = 250  # 采样频率
        bands = {
            'delta': (0.5, 4),
            'theta': (4, 8),
            'alpha': (8, 13),
            'beta': (13, 30),
            'gamma': (30, 45)
        }
        
        for band_name, (low, high) in bands.items():
            band_power = self._extract_band_power(power_spectrum, fs, low, high)
            features[f'{band_name}_power'] = band_power
            
        return features
    
    def _extract_band_power(self, power_spectrum: np.ndarray, fs: float, 
                           low_freq: float, high_freq: float) -> float:
        """提取频带功率"""
        freqs = np.fft.fftfreq(power_spectrum.shape[1], 1/fs)
        
        # 找到频带索引
        band_mask = (freqs >= low_freq) & (freqs <= high_freq)
        
        # 计算频带功率
        band_power = np.sum(power_spectrum[:, band_mask])
        total_power = np.sum(power_spectrum)
        
        return band_power / (total_power + 1e-6)

class SpatialAnalyzer:
    """空域分析器"""
    
    def __init__(self, num_channels: int):
        self.num_channels = num_channels
        
    def extract(self, signals: np.ndarray) -> Dict[str, float]:
        """提取空域特征"""
        features = {}
        
        # 通道间相关性
        correlation_matrix = np.corrcoef(signals)
        features['avg_correlation'] = np.mean(correlation_matrix)
        
        # 空域梯度
        gradients = np.gradient(signals, axis=0)
        features['avg_gradient'] = np.mean(np.abs(gradients))
        
        # 通道平衡
        channel_power = np.mean(signals ** 2, axis=1)
        features['channel_balance'] = 1.0 / (np.std(channel_power) + 1e-6)
        
        return features

# 使用示例
if __name__ == "__main__":
    # 创建BCI系统
    bci_processor = BrainSignalProcessor(num_channels=64)
    bci_network = HybridBCINetwork(num_channels=64)
    
    # 模拟脑电数据
    eeg_data = EEGData(
        signals=np.random.randn(64, 1000) * 0.1,  # 64通道，1000个时间点
        sampling_rate=250,
        timestamp=1234567890.0
    )
    
    # 处理脑电数据
    result = bci_processor.process_eeg_data(eeg_data)
    print(f"识别意图: {result.intent.value}, 置信度: {result.confidence:.2f}")
    
    # 神经网络推理
    with torch.no_grad():
        x = torch.randn(1, 64, 1000)  # 批次大小=1
        network_output = bci_network(x)
        print(f"网络输出: {network_output['intent_probs'].shape}")