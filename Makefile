.PHONY: check check-config check-experience check-workflows check-theme

CONFIG_CHECKS := plugins undo window-picker last-position textobjects ruby \
	parser-install dap lua-lsp go-lsp plugin-options folds

check-workflows:
	nvim --headless -n -i NONE \
		"+lua require('custom.check').run(function() dofile('Tests/workflows.lua') end)"

check-experience:
	nvim --headless -n -i NONE \
		"+lua require('custom.check').run(function() dofile('Tests/experience.lua') end)"

check-config:
	nvim --headless +qa
	@set -e; for check in $(CONFIG_CHECKS); do \
		echo "Checking $$check"; \
		NVIM_CHECK_CASE=$$check nvim --headless -n -i NONE \
			--cmd "lua dofile('Tests/config_preload.lua')" \
			"+lua require('custom.check').run(function() dofile('Tests/config.lua') end)"; \
	done

check-theme:
	nvim --headless \
		"+lua vim.schedule(function() require('custom.check').run(function() dofile('tests/theme.lua') end); vim.cmd('qa') end)"

check:
	mise exec -- stylua --check .
	$(MAKE) check-experience
	$(MAKE) check-workflows
	$(MAKE) check-config
	$(MAKE) check-theme
	git diff --check
