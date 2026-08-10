return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
      },
      move = {
        set_jumps = true, -- whether to set jumps in the jumplist
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")
    local repeatable_move = require("nvim-treesitter-textobjects.repeatable_move")

    local map = vim.keymap.set

    -- Selection: capture groups defined in textobjects.scm
    local selections = {
      ["a="] = { "@assignment.outer", "Select outer part of an assignment" },
      ["i="] = { "@assignment.inner", "Select inner part of an assignment" },
      ["l="] = { "@assignment.lhs", "Select left hand side of an assignment" },
      ["r="] = { "@assignment.rhs", "Select right hand side of an assignment" },

      -- works for javascript/typescript files (custom capture created in after/queries/ecma/textobjects.scm)
      ["a:"] = { "@property.outer", "Select outer part of an object property" },
      ["i:"] = { "@property.inner", "Select inner part of an object property" },
      ["l:"] = { "@property.lhs", "Select left part of an object property" },
      ["r:"] = { "@property.rhs", "Select right part of an object property" },

      ["aa"] = { "@parameter.outer", "Select outer part of a parameter/argument" },
      ["ia"] = { "@parameter.inner", "Select inner part of a parameter/argument" },

      ["ai"] = { "@conditional.outer", "Select outer part of a conditional" },
      ["ii"] = { "@conditional.inner", "Select inner part of a conditional" },

      ["al"] = { "@loop.outer", "Select outer part of a loop" },
      ["il"] = { "@loop.inner", "Select inner part of a loop" },

      ["af"] = { "@call.outer", "Select outer part of a function call" },
      ["if"] = { "@call.inner", "Select inner part of a function call" },

      ["am"] = { "@function.outer", "Select outer part of a method/function definition" },
      ["im"] = { "@function.inner", "Select inner part of a method/function definition" },

      ["ac"] = { "@class.outer", "Select outer part of a class" },
      ["ic"] = { "@class.inner", "Select inner part of a class" },
    }

    for lhs, spec in pairs(selections) do
      map({ "x", "o" }, lhs, function()
        select.select_textobject(spec[1], "textobjects")
      end, { desc = spec[2] })
    end

    -- Swap
    local swap_next = {
      ["<leader>na"] = { "@parameter.inner", "Swap parameter/argument with next" },
      ["<leader>n:"] = { "@property.outer", "Swap object property with next" },
      ["<leader>nm"] = { "@function.outer", "Swap function with next" },
    }
    for lhs, spec in pairs(swap_next) do
      map("n", lhs, function()
        swap.swap_next(spec[1])
      end, { desc = spec[2] })
    end

    local swap_previous = {
      ["<leader>pa"] = { "@parameter.inner", "Swap parameter/argument with previous" },
      ["<leader>p:"] = { "@property.outer", "Swap object property with previous" },
      ["<leader>pm"] = { "@function.outer", "Swap function with previous" },
    }
    for lhs, spec in pairs(swap_previous) do
      map("n", lhs, function()
        swap.swap_previous(spec[1])
      end, { desc = spec[2] })
    end

    -- Movement. Wrapped in make_repeatable_move so ; and , repeat them.
    local moves = {
      [move.goto_next_start] = {
        ["]f"] = { "@call.outer", "textobjects", "Next function call start" },
        ["]m"] = { "@function.outer", "textobjects", "Next method/function def start" },
        ["]c"] = { "@class.outer", "textobjects", "Next class start" },
        ["]i"] = { "@conditional.outer", "textobjects", "Next conditional start" },
        ["]l"] = { "@loop.outer", "textobjects", "Next loop start" },

        -- query groups from `queries/<lang>/<query_group>.scm` on the runtime path
        ["]s"] = { "@scope", "locals", "Next scope" },
        ["]z"] = { "@fold", "folds", "Next fold" },
      },
      [move.goto_next_end] = {
        ["]F"] = { "@call.outer", "textobjects", "Next function call end" },
        ["]M"] = { "@function.outer", "textobjects", "Next method/function def end" },
        ["]C"] = { "@class.outer", "textobjects", "Next class end" },
        ["]I"] = { "@conditional.outer", "textobjects", "Next conditional end" },
        ["]L"] = { "@loop.outer", "textobjects", "Next loop end" },
      },
      [move.goto_previous_start] = {
        ["[f"] = { "@call.outer", "textobjects", "Prev function call start" },
        ["[m"] = { "@function.outer", "textobjects", "Prev method/function def start" },
        ["[c"] = { "@class.outer", "textobjects", "Prev class start" },
        ["[i"] = { "@conditional.outer", "textobjects", "Prev conditional start" },
        ["[l"] = { "@loop.outer", "textobjects", "Prev loop start" },
      },
      [move.goto_previous_end] = {
        ["[F"] = { "@call.outer", "textobjects", "Prev function call end" },
        ["[M"] = { "@function.outer", "textobjects", "Prev method/function def end" },
        ["[C"] = { "@class.outer", "textobjects", "Prev class end" },
        ["[I"] = { "@conditional.outer", "textobjects", "Prev conditional end" },
        ["[L"] = { "@loop.outer", "textobjects", "Prev loop end" },
      },
    }

    for move_fn, mappings in pairs(moves) do
      for lhs, spec in pairs(mappings) do
        map(
          { "n", "x", "o" },
          lhs,
          repeatable_move.make_repeatable_move(function()
            move_fn(spec[1], spec[2])
          end),
          { desc = spec[3] }
        )
      end
    end

    -- vim way: ; goes to the direction you were moving.
    map({ "n", "x", "o" }, ";", repeatable_move.repeat_last_move)
    map({ "n", "x", "o" }, ",", repeatable_move.repeat_last_move_opposite)

    -- Make builtin f, F, t, T also repeatable with ; and ,
    map({ "n", "x", "o" }, "f", repeatable_move.builtin_f_expr, { expr = true })
    map({ "n", "x", "o" }, "F", repeatable_move.builtin_F_expr, { expr = true })
    map({ "n", "x", "o" }, "t", repeatable_move.builtin_t_expr, { expr = true })
    map({ "n", "x", "o" }, "T", repeatable_move.builtin_T_expr, { expr = true })
  end,
}
