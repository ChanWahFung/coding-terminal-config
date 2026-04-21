# 终端开发配置仓库

这个仓库存放当前机器上可公开分享、可迁移的终端开发配置，目标是让另一个 AI 在新的 macOS 设备上按文档完成迁移。

## 仓库范围

已包含：

- `zsh`
- `ghostty`
- `starship`
- `neovim`
- `yazi`
- `lazygit`

## 目标路径

将仓库中的文件应用到目标机器时，路径规则如下：

- `home/.zshrc` -> 合并到 `~/.zshrc`，不要直接覆盖
- `config/starship.toml` -> `~/.config/starship.toml`
- `config/ghostty/config` -> `~/.config/ghostty/config`
- `config/ghostty/auto/theme.ghostty` -> `~/.config/ghostty/auto/theme.ghostty`
- `config/nvim/init.lua` -> `~/.config/nvim/init.lua`
- `config/nvim/lazy-lock.json` -> `~/.config/nvim/lazy-lock.json`
- `config/yazi/keymap.toml` -> `~/.config/yazi/keymap.toml`
- `config/yazi/theme.toml` -> `~/.config/yazi/theme.toml`
- `config/lazygit/config.yml` -> `~/Library/Application Support/lazygit/config.yml`

## 安装依赖

在目标 macOS 机器上先执行：

```bash
brew install ghostty starship neovim yazi zoxide ripgrep fd fzf lazygit jq ffmpeg lsd file-formula
brew install --cask font-jetbrains-mono-nerd-font
npm install -g typescript typescript-language-server @vue/language-server
```

补充说明：

- 如果 `file-formula` 在 Homebrew 中不可用，可以跳过；多数 macOS 默认已经自带 `file`
- `JetBrainsMono Nerd Font` 是 Ghostty 当前配置所需字体
- `typescript-language-server` 和 `@vue/language-server` 是当前 Neovim 配置中明确启用的外部语言服务，不会随插件自动安装

## 这些依赖的用途

- `ghostty`、`starship`、`neovim`、`yazi`、`zoxide`、`ripgrep`、`fd`、`fzf`、`lazygit`：当前配置直接依赖的工具
- `jq`、`ffmpeg`、`file`：`yazi` 预览能力依赖的外部工具
- `typescript`、`typescript-language-server`、`@vue/language-server`：Neovim 中 `ts_ls` 与 `volar` 所需依赖

## 应用配置

以下命令默认在本仓库根目录执行。

`zsh` 相关文件不能直接覆盖。必须先备份，再对比，再把需要的片段合并进目标机器原有的 shell 配置。

随后，把以下内容从仓库中的 `zsh` 文件合并到目标机器现有配置：

- `home/.zshrc` 中的 PATH 补充
- `zoxide` 初始化
- `vim` / `vi` alias，以及 `EDITOR` / `VISUAL`
- `starship` 初始化
- `lazygit` alias

除非发生直接冲突，否则不要删除目标机器原本已有的 shell 配置。

## 首次启动说明

- 合并完 `zsh` 配置后，重新打开一个新的 shell
- 第一次启动 `nvim` 时，等待 `lazy.nvim` 和插件自动安装
- 如果 Neovim 能启动但 LSP 不工作，优先检查上面的 npm 全局安装命令是否执行成功
- 如果 Ghostty 中图标显示异常，优先检查 Nerd Font 是否已安装
- 如果 `yazi` 预览能力不完整，检查 `jq`、`ffmpeg`、`ffprobe`、`file` 是否在 PATH 中
- 当前仓库中的 `lazygit` 配置是安全占位文件，因为源机器没有可公开迁移的 Lazygit 配置内容

## 迁移后验证

在目标机器执行：

```bash
zsh -lic 'command -v starship nvim yazi zoxide rg fd fzf lazygit ghostty'
zsh -lic 'echo $EDITOR && echo $VISUAL'
nvim --headless "+Lazy! sync" +qa
yazi --version
lazygit --version
```

预期结果：

- 上述命令都能正确找到可执行文件
- `EDITOR` 和 `VISUAL` 输出为 `nvim`
- `nvim` 的插件同步过程无报错
- `yazi` 和 `lazygit` 能正常输出版本
