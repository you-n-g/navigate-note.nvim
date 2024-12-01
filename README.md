# 🧭navigate-📝note.nvim
[![Mega-Linter](https://github.com/you-n-g/navigate-note.nvim/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/mega-linter)
[![panvimdoc](https://github.com/you-n-g/navigate-note.nvim/actions/workflows/panvimdoc.yml/badge.svg)](https://github.com/kdheepak/panvimdoc)
[![Neovim Version](https://img.shields.io/badge/Neovim-0.8%2B-blue.svg)](https://neovim.io)

## 🎯Plugin Motivation
Navigating through project files and understanding them by taking notes is a crucial task for developers. While there are many tools available for navigation, such as [arrow.nvim](https://github.com/otavioschwanck/arrow.nvim) and [harpoon](https://github.com/ThePrimeagen/harpoon), they often lack integrated note-taking capabilities aligned with navigation.
`navigate-note.nvim` aims to bridge this gap.

## 📐Design Philosophy
`navigate-note.nvim` creates a `nav.md` note in your project's root directory. This allows you to take notes and add links to files, facilitating navigation between them. By interleaving notes and file links, `navigate-note` aligns navigation with your understanding of the project.

## 📦Installation
```lua
-- Lazy.nvim
{
  "you-n-g/navigate-note.nvim",
  config=true,
}
```

## 🎥Demo
[![navigate-note youtube video](https://img.youtube.com/vi/Sr1p_rm5b6A/0.jpg)](https://www.youtube.com/watch?v=Sr1p_rm5b6A)


### 📖Features & Usage
![image](https://github.com/user-attachments/assets/eb939826-bc7c-4eea-b6f6-dede9a6a4ccb)


- Nav Mode
  - `<m-h>`: Switch to the `nav.md` file, your main hub for notes and navigation. If you're already in `nav.md`, it takes you back to the last file you were on.
  - `<m-p>`: Add the current file and line to `nav.md`. This is great for bookmarking important code sections.
  - `<m-cr>`: Open the file and line under the cursor in `nav.md`.

- Tab Jumping and Preview
  - `<tab>`: Move to the next `file:line` in `nav.md`.
  - `<s-tab>`: Move to the previous `file:line`.
  - A floating window shows a preview of the file content when you use `<tab>`.

- Fast Navigating
  - `<numbers>`: Jump to the i-th "file:line" entry.

- Peeking Mode
  - Get a quick look at file content without fully opening it.
  - Use `<c-a>` and `<c-x>` to change the line number in the preview.

- Jump Mode
  - Toggle between jumping to the file only or to the exact `file:line` with `<m-l>`.
  - In file-only mode, go to the start of the file; in file:line mode, go to the specific line.


## ⚙️Advanced Setup
```lua
-- Lazy.nvim
{
  "you-n-g/navigate-note.nvim",
  opts = {
		filename = "nav.md", -- The filename of the markdown.
		width = 0.6, -- The width of the popup window when jumping in the file with <tab>.
		keymaps = {
			nav_mode = {
				-- Navigation & Jumping
				next = "<tab>",
				prev = "<s-tab>",
				open = "<m-cr>",
				switch_back = "<m-h>", -- Switch back to the previous file from `nav.md`.
				-- Editing
				append_link = "<m-p>", -- (P)aste will more align with the meaning.
				-- Mode switching
				jump_mode = "<m-l>", -- When we jump to a file, jump to the file only or jump to the exact file:line.
			},
			add = "<localleader>na",
			open_nav = "<m-h>", -- Switch to `nav.md`.
		},
		context_line_count = { -- It would be a total of `2 * context_line_count - 1` lines.
			tab = 8,
			vline = 2,
		},
  }
}
```

More detailed [configuration](lua/navigate-note/conf.lua) are listed here.
You can find my latest and preferred configuration [here](https://github.com/you-n-g/deploy/blob/master/configs/lazynvim/lua/plugins/navigating.lua) as an example.


## ☑️TODO
- Bug:
  - [ ] Do not override the previous filename
  - [ ] Directly open `nav.md` will not enter nav mode
  - [x] Wrong position when displaying tab floating with peeking mode
- Feature:
  - [ ] Detailed Helper
  - [x] Peeking mode
    - [x] better left sign([reference](https://github.com/ErichDonGubler/lsp_lines.nvim))
    - [ ] dynamic adjusting context length

## 🔨Development
Contributions to this project are welcome.

You can test the plugin in UI with minimal config with
- `vim -u tests/init_conf/lazy.lua -U NONE -N -i NONE` for [lazy.nvim](https://github.com/folke/lazy.nvim)

If you prefer to run tests without a user interface, you can execute `make test` to initiate the test suite.

## 🔗Related Projects
- [arrow.nvim](https://github.com/otavioschwanck/arrow.nvim): A navigation tool for Neovim.
- [harpoon](https://github.com/ThePrimeagen/harpoon): Another navigation tool for Neovim.
