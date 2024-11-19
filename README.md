# navigate-note.nvim
[![Mega-Linter](https://github.com/you-n-g/navigate-note.nvim/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/mega-linter)
[![panvimdoc](https://github.com/you-n-g/navigate-note.nvim/actions/workflows/panvimdoc.yml/badge.svg)](https://github.com/kdheepak/panvimdoc)
[![Neovim Version](https://img.shields.io/badge/Neovim-0.8%2B-blue.svg)](https://neovim.io)

## Plugin Motivation
Navigating through project files and understanding them by taking notes is a crucial task for developers. While there are many tools available for navigation, such as [arrow.nvim](https://github.com/author/arrow.nvim) and [harpoon](https://github.com/ThePrimeagen/harpoon), they often lack integrated note-taking capabilities aligned with navigation.
`navigate-note.nvim` aims to bridge this gap.

## Design Philosophy
`navigate-note.nvim` creates a `nav.md` note in your project's root directory. This allows you to take notes and add links to files, facilitating navigation between them. By interleaving notes and file links, `navigate-note` aligns navigation with your understanding of the project.

## Installation
```lua
-- Lazy.nvim
{
  "you-n-g/navigate-note.nvim",
  dependencies = {
  },
}
```

## Demo
<!-- Add demo content here -->

## TODO
- Bug:
  - [ ] Do not override the previous filename

## Development
Contributions to this project are welcome. You can test the plugin with a minimal configuration using:
- `vim -u tests/init_conf/lazy.lua -U NONE -N -i NONE` for [lazy.nvim](https://github.com/folke/lazy.nvim)

## Related Projects
- [arrow.nvim](https://github.com/author/arrow.nvim): A navigation tool for Neovim.
- [harpoon](https://github.com/ThePrimeagen/harpoon): Another navigation tool for Neovim.
