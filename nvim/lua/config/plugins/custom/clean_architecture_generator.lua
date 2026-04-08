local M = {}

local function create_directories(base, paths)
  for _, path in ipairs(paths) do
    vim.fn.mkdir(base .. "/" .. path, "p")
  end
end

local function create_files(base, feature, root_folder, files, ext)
  for _, item in ipairs(files) do
    local full_path = string.format("%s/%s/%s/%s.%s.%s", base, root_folder, item.subdir, feature, item.suffix, ext)
    vim.fn.writefile({ "// " .. item.suffix .. " for " .. feature }, full_path)
  end
end

function M.generate_clean_architecture_structure()
  vim.ui.input({ prompt = "Feature name: " }, function(feature)
    if not feature or feature == "" then
      print("Feature name is required.")
      return
    end

    vim.ui.select({ "frontend", "backend", "flutter" }, { prompt = "Project type:" }, function(choice)
      if not choice then
        print("Project type is required.")
        return
      end

      local cwd = vim.fn.expand("%:p:h") .. "/" .. feature

      -- common folder structure
      local common_paths = {
        "domain/entities",
        "domain/repositories",
        "domain/usecases",
        "data/datasources",
        "data/repositories",
      }

      -- frontend-specific folders
      local frontend_extra_paths = {
        "presentation/actions",
        "presentation/pages",
        "presentation/components",
      }

      -- backend-specific folders
      local backend_extra_paths = {
        "presentation/controllers",
      }

      -- flutter-specific folders
      local flutter_extra_paths = {
        "presentation/pages",
        "presentation/widgets",
      }

      -- domain files
      local domain_files = {
        { subdir = "entities", suffix = "entity" },
        { subdir = "repositories", suffix = "domain.repository" },
      }

      -- frontend files
      local frontend_data_files = {
        { subdir = "datasources", suffix = "remote.datasource" },
        { subdir = "repositories", suffix = "data.repository" },
      }

      local frontend_presentation_files = {
        { subdir = "actions", suffix = "action" },
      }

      -- backend files
      local backend_data_files = {
        { subdir = "repositories", suffix = "data.repository" },
      }

      local backend_presentation_files = {
        { subdir = "controllers", suffix = "controller" },
      }

      -- flutter files
      local flutter_data_files = {
        { subdir = "datasources", suffix = "remote.datasource" },
        { subdir = "repositories", suffix = "data.repository" },
      }

      local flutter_presentation_files = {
        { subdir = "widgets", suffix = "widget" },
        { subdir = "pages", suffix = "page" },
      }

      -- combine paths
      local full_paths = vim.deepcopy(common_paths)
      if choice == "frontend" then
        vim.list_extend(full_paths, frontend_extra_paths)
      elseif choice == "backend" then
        vim.list_extend(full_paths, backend_extra_paths)
      elseif choice == "flutter" then
        vim.list_extend(full_paths, flutter_extra_paths)
      end

      -- create folders
      create_directories(cwd, full_paths)

      -- create files (different extensions for Flutter vs TS)
      local ext = (choice == "flutter") and "dart" or "ts"

      create_files(cwd, feature, "domain", domain_files, ext)

      if choice == "frontend" then
        create_files(cwd, feature, "data", frontend_data_files, ext)
        create_files(cwd, feature, "presentation", frontend_presentation_files, ext)
      elseif choice == "backend" then
        create_files(cwd, feature, "data", backend_data_files, ext)
        create_files(cwd, feature, "presentation", backend_presentation_files, ext)

        -- create route file
        local route_file = string.format("%s/presentation/%s.route.%s", cwd, feature, ext)
        vim.fn.writefile({ "// route for " .. feature }, route_file)
        -- elseif choice == "flutter" then
        --   create_files(cwd, feature, "data", flutter_data_files, ext)
        --   create_files(cwd, feature, "presentation", flutter_presentation_files, ext)
        --
        --   -- create route file (Flutter style)
        --   local route_file = string.format("%s/presentation/%s_routes.%s", cwd, feature, ext)
        --   vim.fn.writefile({ "// routes for " .. feature }, route_file)
      end

      print(choice .. " folder structure created for feature: " .. feature)
    end)
  end)
end

vim.api.nvim_create_user_command("CreateCleanArchitectureFeature", M.generate_clean_architecture_structure, {})

return M
