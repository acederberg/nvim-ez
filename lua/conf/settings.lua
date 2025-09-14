

---@alias LanguagesSettings {
--- quarto: boolean,
--- yaml: boolean,
--- markdown: boolean,
--- typescript: boolean,
--- prisma: boolean,
--- css: boolean,
--- html: boolean,
--- lua: boolean,
--- csharp: boolean,
--- haskell: boolean,
--- python: boolean,
--- go: boolean }

--- @alias FeaturesSettings {
--- }

---@alias Settings { languages: LanguagesSettings, features: FeaturesSettings }


---@return Settings
local function default_settings() 
  return {
    languages = {
      quarto = true,
      yaml = true,
      markdown = true,
      typescript = true,
      python = true,
      lua= true,
      css=true,
  
      html=true,
      go = false,
      prisma = false,
      csharp = false,
      haskell = false,
    },
    features = {}
  }
end



---@param settings Settings
---@return Settings
local function handle_settings(settings)
  return default_settings()
  -- return vim.tbl_deep_extend('error', default_settings(), settings)
end


-- local settings = handle_settings({})




return { default_settings = default_settings, handle_settings = handle_settings }
