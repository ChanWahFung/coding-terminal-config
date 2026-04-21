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
brew install ghostty starship neovim yazi zoxide ripgrep fd fzf lazygit jq ffmpeg file-formula tree-sitter-cli
brew install --cask font-jetbrains-mono-nerd-font
npm install -g typescript typescript-language-server @vue/language-server
```

补充说明：

- 如果 `file-formula` 在 Homebrew 中不可用，可以跳过；多数 macOS 默认已经自带 `file`
- `JetBrainsMono Nerd Font` 是 Ghostty 当前配置所需字体
- `tree-sitter-cli` 是 `nvim-treesitter` 首次同步语法解析器时会调用的外部命令；缺少它时，第一次 `:TSUpdate` 或 `Lazy! sync` 可能失败
- `typescript-language-server` 和 `@vue/language-server` 是当前 Neovim 配置中明确启用的外部语言服务，不会随插件自动安装

## 这些依赖的用途

- `ghostty`、`starship`、`neovim`、`yazi`、`zoxide`、`ripgrep`、`fd`、`fzf`、`lazygit`：当前配置直接依赖的工具
- `jq`、`ffmpeg`、`file`：`yazi` 预览能力依赖的外部工具
- `tree-sitter-cli`：`nvim-treesitter` 首次安装或更新 parser 所需依赖
- `typescript`、`typescript-language-server`、`@vue/language-server`：Neovim 中 `ts_ls` 与 `volar` 所需依赖

## 应用配置

以下命令默认在本仓库根目录执行。

`zsh` 相关文件不能直接覆盖。必须先备份，再对比，再把需要的片段合并进目标机器原有的 shell 配置。

随后，把以下内容从仓库中的 `zsh` 文件合并到目标机器现有配置：

- `zoxide` 初始化
- `vim` / `vi` alias，以及 `EDITOR` / `VISUAL`
- `starship` 初始化
- `lazygit` alias

除非发生直接冲突，否则不要删除目标机器原本已有的 shell 配置。

## 仓库外资源

当前仓库还存在一个需要额外准备的主题文件：

- `config/yazi/theme.toml` 中的 `syntect_theme` 指向 `~/.config/yazi/Catppuccin-mocha.tmTheme`
- 这个 `Catppuccin-mocha.tmTheme` 文件当前不在仓库内，迁移时需要额外下载并放到目标路径
- 可用来源：<https://github.com/catppuccin/bat>

## 首次启动说明

- 合并完 `zsh` 配置后，重新打开一个新的 shell
- 第一次启动 `nvim` 时，等待 `lazy.nvim` 和插件自动安装
- 如果 Neovim 能启动但 LSP 不工作，优先检查上面的 npm 全局安装命令是否执行成功
- 如果 Ghostty 中图标显示异常，优先检查 Nerd Font 是否已安装
- 某些 Homebrew 安装场景下，Ghostty App 已安装但 `command -v ghostty` 仍然找不到 CLI；如果发生这种情况，需要额外补一个可执行入口到 PATH 中，例如补到 `/opt/homebrew/bin/ghostty`
- 如果 `yazi` 预览能力不完整，检查 `jq`、`ffmpeg`、`ffprobe`、`file` 是否在 PATH 中
- 如果 `yazi` 启动时报语法高亮主题文件缺失，优先检查上面的 `Catppuccin-mocha.tmTheme` 是否已放到 `~/.config/yazi/`
- 当前仓库中的 `lazygit` 配置是安全占位文件，因为源机器没有可公开迁移的 Lazygit 配置内容
- 当前锁文件中的 `nvim-tree.lua` 在 `nvim 0.12.1` 上已通过 headless 启动和 `Lazy! sync` 验证，但版本提示更偏向 `nvim 0.12.2+`；如果后续交互式使用出现插件异常，优先升级 `nvim`

## 迁移后验证

在目标机器执行：

```bash
zsh -lic 'command -v starship nvim yazi zoxide rg fd fzf lazygit ghostty tree-sitter typescript-language-server vue-language-server tsc'
zsh -lic 'echo $EDITOR && echo $VISUAL'
nvim --headless "+qa"
nvim --headless "+Lazy! sync" +qa
yazi --version
lazygit --version
ghostty --version
tree-sitter --version
tsc --version
typescript-language-server --version
vue-language-server --version
```

预期结果：

- 上述命令都能正确找到可执行文件
- `EDITOR` 和 `VISUAL` 输出为 `nvim`
- `nvim --headless "+qa"` 能正常退出
- `nvim` 的插件同步过程无报错
- `yazi`、`lazygit`、`ghostty`、`tree-sitter`、`tsc` 和语言服务命令都能正常输出版本
