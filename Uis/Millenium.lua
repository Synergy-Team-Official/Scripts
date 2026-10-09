local function patchedLibrary()
    local sourceURL = "https://raw.githubusercontent.com/Synergy-Team-Official/Scripts/refs/heads/main/Uis/Millenium.lua"
    print("[Millenium Showcase] Downloading library...")
    local source = game:HttpGet(sourceURL)
    assert(type(source) == "string" and #source > 5000, "Library download was empty or incomplete")

    local folderSearch = "for _, path in next, library.folders do"
    local folderStart = assert(source:find(folderSearch, 1, true), "Library folder initialization not found")
    local folderEnd = assert(source:find("\nlocal flags = library.flags", folderStart, true), "Library folder initialization end not found")
    local folderReplacement = [==[
local function ensureFolder(path)
    if type(isfolder) == "function" then
        local ok, exists = pcall(isfolder, path)
        if ok and exists then return end
    end
    if type(makefolder) == "function" then
        pcall(makefolder, path)
    end
end
ensureFolder(library.directory)
for _, path in next, library.folders do
    ensureFolder(library.directory .. path)
end
]==]
    source = source:sub(1, folderStart - 1) .. folderReplacement .. source:sub(folderEnd)

    local fontStart = assert(source:find("local fonts = {}; do", 1, true), "Font initialization not found")
    local fontEnd = assert(source:find("\nfunction library:tween", fontStart, true), "Font initialization end not found")
    local fontReplacement = [==[
local fonts = {}
do
    local function getFont(name, assetName, url, fallback)
        local ok, font = pcall(function()
            if type(isfile) ~= "function" or type(writefile) ~= "function" or type(getcustomasset) ~= "function" then
                return nil
            end
            if not isfile(assetName) then
                return nil
            end
            local descriptionName = name .. ".font"
            local data = {
                name = name,
                faces = {{
                    name = "Normal",
                    weight = 200,
                    style = "Normal",
                    assetId = getcustomasset(assetName)
                }}
            }
            writefile(descriptionName, http_service:JSONEncode(data))
            return Font.new(getcustomasset(descriptionName), Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end)
        if ok and font then return font end
        return Font.fromEnum(fallback)
    end
    fonts.small = getFont("Medium", "Medium.ttf", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-Medium.ttf", Enum.Font.Gotham)
    fonts.font = getFont("SemiBold", "SemiBold.ttf", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-SemiBold.ttf", Enum.Font.GothamMedium)
end
]==]
    source = source:sub(1, fontStart - 1) .. fontReplacement .. source:sub(fontEnd)

    local chunk, compilerError = loadstring(source)
    assert(type(chunk) == "function", "Library compiler error: " .. tostring(compilerError))
    local result = chunk()
    assert(type(result) == "table" and type(result.window) == "function", "Library did not return a valid API")
    print("[Millenium Showcase] Library loaded successfully")
    return result
end

return patchedLibrary()
