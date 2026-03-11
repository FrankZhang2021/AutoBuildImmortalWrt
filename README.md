# AutoBuildImmortalWrt (N1 Only)

本仓库已裁剪为仅保留斐讯 N1 平台相关内容。

## 保留内容
- N1 构建脚本与配置: `n1/`
- 通用脚本: `shell/`
- 首次启动初始化脚本: `files/etc/uci-defaults/99-custom.sh`
- N1 GitHub Actions 工作流: `.github/workflows/build-N1.yml`

## 默认信息
- 管理账号: `root`
- 默认密码: `password`
- 单网口模式: 默认 DHCP（请在上级路由器 DHCP 列表查询地址）

## 构建入口
- 工作流: `build-N1`
- 平台: `armsr-armv8` ImageBuilder + Flippy 打包
