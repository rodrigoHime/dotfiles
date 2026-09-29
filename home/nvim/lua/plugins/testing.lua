-- neotest adapters for JS/TS - lang.ruby already brings neotest-rspec for
-- Ruby automatically (gated behind test.core, which is now enabled), but
-- lang.typescript doesn't ship a neotest adapter at all, so it's added
-- here the same way LazyVim's own lang extras do it: as a neotest
-- dependency + an entry in `opts.adapters`. Both Jest and Vitest adapters
-- are added since either might be in use; each one auto-detects its own
-- config file (jest.config.*/vitest.config.*) in a project and no-ops
-- otherwise, so having both installed is harmless.
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {},
        ["neotest-vitest"] = {},
      },
    },
  },
}
