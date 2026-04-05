/**
 * 日期格式化工具函数 (已迁移到 shared/)
 * 现在从 shared/dateFormatter.ts 导入
 */

// 从共享模块导入日期格式化函数
import { formatDate, formatDateTime, getRelativeTime } from '../../shared/dateFormatter';

// 重新导出以保持向后兼容
export { formatDate, formatDateTime, getRelativeTime };