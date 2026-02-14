# Changelog

## [1.2.0](https://github.com/you-n-g/navigate-note.nvim/compare/v1.1.1...v1.2.0) (2026-02-14)


### Features

* add block navigation support via enable_block flag ([e94896a](https://github.com/you-n-g/navigate-note.nvim/commit/e94896a7f12799e6548295404ae3f5155a006ef1))
* add default tmux target config support ([23fb81c](https://github.com/you-n-g/navigate-note.nvim/commit/23fb81ce42354121ced48e70ec595141bc990c7e))
* Add is_tmux utility function and refactor ops.lua to use it ([9d8c284](https://github.com/you-n-g/navigate-note.nvim/commit/9d8c284453a2d42f9f185b7b15bb55b87d601d3c))
* add support for switching to specific tmux panes via nav links ([ee9063f](https://github.com/you-n-g/navigate-note.nvim/commit/ee9063f77c6f94778f208008ed32311b62e3e5ee))
* Add tmux session switching for T:session.window links ([6ec1fba](https://github.com/you-n-g/navigate-note.nvim/commit/6ec1fba922780ff0574e2e837eed3c72cf9938db))
* debounce extmark update on cursor movement events ([1687fc2](https://github.com/you-n-g/navigate-note.nvim/commit/1687fc2531af301e332ad0854bed0bc64aec2d72))
* export send_to_tmux function for external use ([add1b70](https://github.com/you-n-g/navigate-note.nvim/commit/add1b70bcde53c68081a017ed9062c7211108ee9))
* Generalize link pattern to support tmux links ([c049d8e](https://github.com/you-n-g/navigate-note.nvim/commit/c049d8eeff8e933cf92c5f5999662aedaa3e1c65))
* Implement &lt;m-cr&gt; behavior for sending content to tmux and update tmux integration ([7acfe31](https://github.com/you-n-g/navigate-note.nvim/commit/7acfe31ddbfc6f09b77efd4144b0ef0715a94404))
* send to last tmux pane if pane not specified ([ff410c7](https://github.com/you-n-g/navigate-note.nvim/commit/ff410c7a660ea2c773d974167d0ef3b0d4a5e0da))
* support {current} placeholder in tmux target parsing and resolution ([d41e3b5](https://github.com/you-n-g/navigate-note.nvim/commit/d41e3b58e3692873406d5f259696f4e3e3a92f90))


### Bug Fixes

* allow default_tmux_target to be a string or function ([cd9eb8b](https://github.com/you-n-g/navigate-note.nvim/commit/cd9eb8b3ad2f9d8d3c5fac0f7eb8c8d79974ff41))
* ensure nav-mode activates when opening nav.md directly on startup ([672b319](https://github.com/you-n-g/navigate-note.nvim/commit/672b319a88061fe27a236033d398f7994992b974))
* exit visual mode after sending selection to tmux ([597aa16](https://github.com/you-n-g/navigate-note.nvim/commit/597aa1693d7b8b081d67ec398945c8098b2dcd77))
* improve tmux command handling and visual selection extraction ([38900dc](https://github.com/you-n-g/navigate-note.nvim/commit/38900dc809158a5ab56b51cbdecfdf0a6899ba6b))
* pass callback_args to update_extmark for correct buffer handling ([a1439d4](https://github.com/you-n-g/navigate-note.nvim/commit/a1439d4d727355f94d41801e59e7c3743155e903))
* use readfile for context extraction to avoid swapfile issues ([5415cbe](https://github.com/you-n-g/navigate-note.nvim/commit/5415cbe40fa37f25b6f34fa53191fe79054cd08d))

## [1.1.1](https://github.com/you-n-g/navigate-note.nvim/compare/v1.1.0...v1.1.1) (2025-02-25)


### Bug Fixes

* handle missing files & convert tabs to spaces for consistent indentation ([74c50a7](https://github.com/you-n-g/navigate-note.nvim/commit/74c50a74b92dffdcceafb96e811761f73c563359))

## [1.1.0](https://github.com/you-n-g/navigate-note.nvim/compare/v1.0.0...v1.1.0) (2024-12-30)


### Features

* add customizable link surround delimiters in configuration ([#5](https://github.com/you-n-g/navigate-note.nvim/issues/5)) ([0238b97](https://github.com/you-n-g/navigate-note.nvim/commit/0238b97c9c9fc286c882d33c2633f852f8c8e95f))
* add tests for pckr ([920adc3](https://github.com/you-n-g/navigate-note.nvim/commit/920adc32c4c9378cde4f7d8470b00366027473d1))
* Enhance winbar text with custom highlight groups for keymaps ([37b7fff](https://github.com/you-n-g/navigate-note.nvim/commit/37b7fff577af8c9db75eec85cbea3c74c994e12a))


### Bug Fixes

* which-key ([f454785](https://github.com/you-n-g/navigate-note.nvim/commit/f454785e25e7872e60856cb84f0695869008e37c))

## 1.0.0 (2024-12-01)


### Features

* move feature here ([9eef941](https://github.com/you-n-g/navigate-note.nvim/commit/9eef9415198da6f0873cb1ebd8e1a24d5bc0b316))
* nicer left sign ([5c8fe9a](https://github.com/you-n-g/navigate-note.nvim/commit/5c8fe9a36303d4bfad6f46208955798403942fe4))
* peeking mode ([b56dfbd](https://github.com/you-n-g/navigate-note.nvim/commit/b56dfbd4de7e0e695bce00187592c4044dc4fdba))
* support file/line jump mode toggle ([bcfcf6d](https://github.com/you-n-g/navigate-note.nvim/commit/bcfcf6db82af09dd930e22ca00204cef85d35b8b))
* update from template ([ac5d1cc](https://github.com/you-n-g/navigate-note.nvim/commit/ac5d1cc11d0653b13b106ff92df4edb9f757a095))


### Bug Fixes

* correct floating window ([cee0a04](https://github.com/you-n-g/navigate-note.nvim/commit/cee0a04ab27437913990a71c2df0394ce0cf7e1c))
* correct keyboard icon & fix link ([e5516b0](https://github.com/you-n-g/navigate-note.nvim/commit/e5516b067e5d29d615ccfe61a51fa60084c3d016))
* correct wrapper ([1ec1a5e](https://github.com/you-n-g/navigate-note.nvim/commit/1ec1a5ef2a39bfd4df40eb53f356f6c3c271cde9))
