# navigate-note.nvim
[![Mega-Linter](https://github.com/you-n-g/navigate-note.nvim/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/mega-linter)
[![panvimdoc](https://github.com/you-n-g/navigate-note.nvim/actions/workflows/panvimdoc.yml/badge.svg)](https://github.com/kdheepak/panvimdoc)
[![Neovim Version](https://img.shields.io/badge/Neovim-0.8%2B-blue.svg)](https://neovim.io)

## Plugin Motivation
Navigating through project files and understanding them by taking notes is a crucial task for developers. While there are many tools available for navigation, such as [arrow.nvim](https://github.com/otavioschwanck/arrow.nvim) and [harpoon](https://github.com/ThePrimeagen/harpoon), they often lack integrated note-taking capabilities aligned with navigation.
`navigate-note.nvim` aims to bridge this gap.

## Design Philosophy
`navigate-note.nvim` creates a `nav.md` note in your project's root directory. This allows you to take notes and add links to files, facilitating navigation between them. By interleaving notes and file links, `navigate-note` aligns navigation with your understanding of the project.

## Installation
```lua
-- Lazy.nvim
{
  "you-n-g/navigate-note.nvim",
  config=true,
  dependencies = {
  },
}
```

## Demo
<!-- Add demo content here -->
    A demo showcasing how to use the plugin will be available soon. If you're eager to try it out, simply press `<m-h>` (for example, `alt+h`) to launch the plugin.

### Features & Usage
- Nav Mode
  - `<m-cr>` to open the file under the cursor
- Tab jumping
  - Tab Floating Preview
- Fast navigating
- Peeking mode:
  - 💡 When using `<c-a>` and `<c-x>` to change the line number in peeking mode, this feature, which might initially seem hard to find useful, can actually provide you with an amazing experience.
- Jump mode

## Advanced Setup
```lua
-- Lazy.nvim
{
  "you-n-g/navigate-note.nvim",
  opts = {
  }
}
```

More detailed [configuration](lua/navigate-note/conf.lua) are listed here.
You can find my latest and preferred configuration [here](https://github.com/you-n-g/deploy/blob/master/configs/lazynvim/lua/plugins/navigating.lua) as an example.


## TODO
- Bug:
  - [ ] Do not override the previous filename
  - [ ] Directly open `nav.md` will not enter nav mode
  - [x] Wrong position when displaying tab floating with peeking mode
- UI:
  - [ ] Detailed Helper
  - [x] Peeking mode
    - [x] better left sign([reference](https://github.com/ErichDonGubler/lsp_lines.nvim))

## Development
Contributions to this project are welcome.

You can test the plugin in UI with minimal config with
- `vim -u tests/init_conf/lazy.lua -U NONE -N -i NONE` for [lazy.nvim](https://github.com/folke/lazy.nvim)

If you prefer to run tests without a user interface, you can execute `make test` to initiate the test suite.

## Related Projects
- [arrow.nvim](https://github.com/otavioschwanck/arrow.nvim): A navigation tool for Neovim.
- [harpoon](https://github.com/ThePrimeagen/harpoon): Another navigation tool for Neovim.
