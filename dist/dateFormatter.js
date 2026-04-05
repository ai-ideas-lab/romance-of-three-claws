"use strict";
/**
 * 共享日期格式化工具函数
 * 从两个项目中提取的重复代码 - 重构版本
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatDate = formatDate;
exports.formatDateTime = formatDateTime;
exports.getRelativeTime = getRelativeTime;
/**
 * 检查日期是否有效
 * @param date 日期输入
 * @returns 是否有效
 */
function isValidDate(date) {
    if (typeof date === 'string') {
        // 尝试解析ISO格式的日期字符串
        const parsedDate = new Date(date);
        return !isNaN(parsedDate.getTime());
    }
    const d = new Date(date);
    return !isNaN(d.getTime());
}
/**
 * 安全创建日期对象，处理无效日期
 * @param date 日期输入
 * @returns 日期对象，无效时返回当前时间
 */
function safeCreateDate(date) {
    if (typeof date === 'string') {
        // 尝试解析ISO格式的日期字符串
        const parsedDate = new Date(date);
        if (!isNaN(parsedDate.getTime())) {
            return parsedDate;
        }
    }
    const d = new Date(date);
    return isNaN(d.getTime()) ? new Date() : d;
}
/**
 * 格式化日期数字为两位数
 * @param num 数字
 * @returns 两位数字符串
 */
function formatTwoDigits(num) {
    return String(num).padStart(2, '0');
}
/**
 * 提取日期组件
 * @param date 日期对象
 * @returns 日期组件对象
 */
function getDateComponents(date) {
    return {
        year: date.getFullYear(),
        month: date.getMonth() + 1,
        day: date.getDate()
    };
}
/**
 * 格式化日期为 YYYY-MM-DD 格式
 * @param date 日期对象或时间戳
 * @returns 格式化后的日期字符串
 */
function formatDate(date) {
    const d = safeCreateDate(date);
    const { year, month, day } = getDateComponents(d);
    return `${year}-${formatTwoDigits(month)}-${formatTwoDigits(day)}`;
}
/**
 * 格式化日期为 YYYY-MM-DD HH:mm:ss 格式
 * @param date 日期对象或时间戳
 * @returns 格式化后的日期时间字符串
 */
function formatDateTime(date) {
    const d = safeCreateDate(date);
    const { year, month, day } = getDateComponents(d);
    const hours = formatTwoDigits(d.getHours());
    const minutes = formatTwoDigits(d.getMinutes());
    const seconds = formatTwoDigits(d.getSeconds());
    return `${year}-${formatTwoDigits(month)}-${formatTwoDigits(day)} ${hours}:${minutes}:${seconds}`;
}
/**
 * 获取相对时间描述
 * @param date 日期对象或时间戳
 * @returns 相对时间描述字符串
 */
function getRelativeTime(date) {
    const now = new Date();
    const targetDate = safeCreateDate(date);
    // 如果日期是当前时间或未来时间，返回"刚刚"
    if (targetDate >= now) {
        return '刚刚';
    }
    const diffMs = now.getTime() - targetDate.getTime();
    const diffMinutes = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    if (diffMinutes < 1) {
        return '刚刚';
    }
    else if (diffMinutes < 60) {
        return `${diffMinutes}分钟前`;
    }
    else if (diffHours < 24) {
        return `${diffHours}小时前`;
    }
    else if (diffDays < 7) {
        return `${diffDays}天前`;
    }
    else {
        return formatDate(date);
    }
}
