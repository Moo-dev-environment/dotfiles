-- CompetiTest.nvim: compile/run against multiple test cases and parse problems
-- from Competitive Companion browser extension.
--
-- Browser extension: https://github.com/jmerle/competitive-companion
-- Point it at port 27121 (default). Use :CompetiTestReceive testcases OR
-- :CompetiTestReceive problem (creates file + tests).
return {
  {
    "xeluxee/competitest.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    cmd = "CompetiTest",
    keys = {
      { "<leader>ta", "<cmd>CompetiTest add_testcase<cr>", desc = "Add test case" },
      { "<leader>te", "<cmd>CompetiTest edit_testcase<cr>", desc = "Edit test cases" },
      { "<leader>tR", "<cmd>CompetiTest run<cr>", desc = "Run all test cases" },
      { "<leader>tr", "<cmd>CompetiTest receive testcases<cr>", desc = "Receive testcases (browser)" },
      { "<leader>tp", "<cmd>CompetiTest receive problem<cr>", desc = "Receive problem (browser)" },
      { "<leader>tc", "<cmd>CompetiTest receive contest<cr>", desc = "Receive contest (browser)" },
      { "<leader>tu", "<cmd>CompetiTest run_no_compile<cr>", desc = "Run (no recompile)" },
    },
    opts = {
      local_config_file_name = ".competitest.lua",

      runner_ui = {
        interface = "popup",
        selector_show_nu = true,
        selector_show_rnu = false,
        total_width = 0.85,
        total_height = 0.8,
      },

      popup_ui = { total_width = 0.9, total_height = 0.9 },

      compile_command = {
        c = { exec = "gcc", args = { "-O2", "-std=gnu17", "-Wall", "-Wextra", "-o", "$(FNOEXT)", "$(FNAME)", "-lm" } },
        cpp = {
          exec = "g++",
          args = {
            "-O2",
            "-std=gnu++20",
            "-Wall",
            "-Wextra",
            "-Wshadow",
            "-DLOCAL",
            "-I" .. vim.fn.stdpath("config") .. "/include",
            "-o",
            "$(FNOEXT)",
            "$(FNAME)",
          },
        },
        java = { exec = "javac", args = { "$(FNAME)" } },
        python = { exec = "true" },
        rust = { exec = "rustc", args = { "-O", "$(FNAME)" } },
      },

      run_command = {
        c = { exec = "./$(FNOEXT)" },
        cpp = { exec = "./$(FNOEXT)" },
        java = { exec = "java", args = { "$(FNOEXT)" } },
        python = { exec = "python3", args = { "$(FNAME)" } },
        rust = { exec = "./$(FNOEXT)" },
      },

      multiple_testing = -1, -- use all cores
      maximum_time = 5000,
      output_compare_method = "squish",
      view_output_diff = true,

      -- Store tests next to source as <stem>/input<N>.txt / output<N>.txt
      testcases_use_single_file = false,
      testcases_directory = ".",
      testcases_input_file_format = "$(FNOEXT)_input$(TCNUM).txt",
      testcases_output_file_format = "$(FNOEXT)_output$(TCNUM).txt",

      -- Previous layout:
      -- received_problems_path = "$(HOME)/cp/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",
      -- received_problems_prompt_path = true,
      received_problems_path = "$(CWD)/$(PROBLEM).$(FEXT)",
      received_problems_prompt_path = false,
      received_contests_directory = "$(HOME)/cp/$(JUDGE)/$(CONTEST)",
      received_contests_problems_path = "$(PROBLEM).$(FEXT)",
      received_contests_prompt_directory = true,
      received_contests_prompt_extension = true,

      template_file = {
        cpp = vim.fn.stdpath("config") .. "/templates/cp.cpp",
        c = vim.fn.stdpath("config") .. "/templates/cp.c",
        java = vim.fn.stdpath("config") .. "/templates/Main.java",
        python = vim.fn.stdpath("config") .. "/templates/cp.py",
      },
      evaluate_template_modifiers = true,

      companion_port = 27121,
      receive_print_message = true,
    },
  },
}
