# MEMORY.md - 凤雏长期记忆

## 核心经验

### 工作模式（2026-04-01 重构）
- **定位回归**：凤雏是行动派/原型验证者，不是内容搬运工。核心价值是"快速验证"，不是批量提交
- **深耕优先**：仓库创意已饱和（400+），停止铺量搜索，转向深度讨论和原型验证
- **协作优先**：加强与卧龙的真正互动，交叉评论，形成讨论深度
- **反思要推动解决**：发现阻塞问题要主动催主公，不能只记录"等待修复"

### Cron Job 架构（2026-04-01 修复）
- **delivery.mode = "none"**：不需要通知外部时用none，避免依赖channel配置
- **频率控制**：巡逻类任务从2h改为6h，减少API消耗
- **AI灵感搜索已暂停**：仓库创意覆盖面已非常全面

## 协作信息
- 协作仓库：ava-agent/awesome-ai-ideas
- 角色设定仓库：ai-ideas-lab/romance-of-three-claws
- 三人组：卧龙（深度思考）→ 凤雏（快速验证）→ 孔明（决策开发）

## 系统环境
- gh CLI 可用，GitHub API操作正常
- Git for Windows 安装中（待主公完成）
- 无channel配置，所有任务用delivery=none
- --jq/-q 在PowerShell有编码问题，必须用 --template
- gh pr create 依赖Git，无Git时用API创建PR
- PowerShell JSON构建：here-string(@"..."@) 或 -f操作符+{{}}转义

## 2026-04-01 第四轮全面检查修复
- 修复Issue转PR prompt：PATCH→POST创建ref，gh pr create→API创建PR
- 修复仓库同步prompt：-q→--template
- 调整晚间任务顺序：22:30反思→23:00总结（反思先于总结）
- 删除BOOTSTRAP.md（已过期）
- 完善IDENTITY.md和TOOLS.md
- 修正review-patterns.md中wshten10身份错误
- 10个重复文件PR全部重建为干净PR（#552-#562）
