local M = {}

local function create_directories(base, paths)
  for _, path in ipairs(paths) do
    vim.fn.mkdir(base .. "/" .. path, "p")
  end
end

local function create_files(base, feature, root_folder, files)
  for _, item in ipairs(files) do
    local full_path = string.format("%s/%s/%s/%s.%s.ts", base, root_folder, item.subdir, feature, item.suffix)
    vim.fn.writefile({ "// " .. item.suffix .. " for " .. feature }, full_path)
  end
end

function M.generate_clean_architecture_structure()
  vim.ui.input({ prompt = "Feature name: " }, function(feature)
    if not feature or feature == "" then
      print("Feature name is required.")
      return
    end

    vim.ui.select({ "frontend", "backend" }, { prompt = "Project type:" }, function(choice)
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
        "presentation/schemas",
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

      local domain_files = {
        { subdir = "entities", suffix = "entity" },
        { subdir = "repositories", suffix = "domain.repository" },
      }

      local frontend_data_files = {
        { subdir = "datasources", suffix = "remote.datasource" },
        { subdir = "repositories", suffix = "data.repository" },
      }

      local frontend_presentation_files = {
        { subdir = "actions", suffix = "action" },
        { subdir = "schemas", suffix = "schema" },
      }

      local backend_data_files = {
        { subdir = "repositories", suffix = "data.repository" },
      }

      local backend_presentation_files = {
        { subdir = "controllers", suffix = "controller" },
        { subdir = "schemas", suffix = "schema" },
      }

      -- combine paths
      local full_paths = vim.deepcopy(common_paths)
      if choice == "frontend" then
        vim.list_extend(full_paths, frontend_extra_paths)
      elseif choice == "backend" then
        vim.list_extend(full_paths, backend_extra_paths)
      end

      -- create folders
      create_directories(cwd, full_paths)

      -- create files
      create_files(cwd, feature, "domain", domain_files)

      if choice == "frontend" then
        create_files(cwd, feature, "data", frontend_data_files)
        create_files(cwd, feature, "presentation", frontend_presentation_files)
      elseif choice == "backend" then
        create_files(cwd, feature, "data", backend_data_files)
        create_files(cwd, feature, "presentation", backend_presentation_files)

        -- create route file
        local route_file = string.format("%s/presentation/%s.route.ts", cwd, feature)
        vim.fn.writefile({ "// route for " .. feature }, route_file)
      end

      print(choice .. " folder structure created for feature: " .. feature)
    end)
  end)
end

vim.api.nvim_create_user_command("CreateCleanArchitectureFeature", M.generate_clean_architecture_structure, {})

return M
