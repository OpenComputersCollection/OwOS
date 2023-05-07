--[[
By: rater193
original repo: https://github.com/rater193/OpenComputers-1.7.10-Base-Monitor/tree/master

-- Modyfied by Crafty-Codes
]] -- CONFIGURATION
local CONFIG = {}
CONFIG.GIT = {}
CONFIG.GIT.NAME = "OpenComputersCollection"
CONFIG.GIT.REPO = "OwOS"
CONFIG.GIT.BRANCH = "fix/dhcp"
CONFIG.FOLDER = "/mnt/cf3/"

local shell = require("shell")
local internet = require("internet")
local fs = require("filesystem")

-- downloading the json libs if they do not exsist
shell.execute('mkdir /lib')
shell.execute(
    'wget -fq "https://raw.githubusercontent.com/rater193/OpenComputers-1.7.10-Base-Monitor/master/lib/json.lua" "/lib/json.lua"')
local json = require("json")

-- these are some functions for handling downloading data from http requests
local function getStringFromResponce(responce)
    local ret = ""
    local resp = responce()
    while (resp ~= nil) do
        ret = ret .. tostring(resp)
        resp = responce()
    end
    return ret
end

local function getHTTPData(url)
    local ret = nil
    local request, responce = pcall(internet.request, url)
    if (request) then
        ret = getStringFromResponce(responce)
    end
    return ret
end

-- this is a function for downloading a repository tree
local function downloadTree(treedataurl, parentdir)
    -- this is used to make it so you dont have to set the parent dir it will default to the root directory
    if (not parentdir) then
        parentdir = ""
    end

    local treedata = json.decode(getHTTPData(treedataurl))

    for _, child in pairs(treedata.tree) do
        -- os.sleep(0.1)
        local filename = parentdir .. "/" .. tostring(child.path)
        if (child.type == "tree") then
            -- print("Downloading tree")
            print("Checking directory, " .. tostring(filename))

            if not fs.exists(CONFIG.FOLDER .. filename) then
                local result, reason = fs.makeDirectory(CONFIG.FOLDER .. filename)
                if not result then
                    print("Error mkdir: " .. reason)
                end
            end

            downloadTree(child.url, filename)
        else
            shell.execute('rm -f "' .. CONFIG.FOLDER .. tostring(filename) .. '"')
            -- print("Installing file")
            -- local repodata = data.decode64(json.decode(getHTTPData(child.url)).content)
            print("downloading " .. filename)
            local repodata = getHTTPData("https://raw.githubusercontent.com/" .. tostring(CONFIG.GIT.NAME) .. "/" ..
                                             tostring(CONFIG.GIT.REPO) .. "/" .. tostring(CONFIG.GIT.BRANCH) .. "/" ..
                                             tostring(filename))

            local file = fs.open(CONFIG.FOLDER .. filename, "w")
            file:write(repodata)
            file:close()
        end
    end
end

-- the data for the json api for the repository
local data = getHTTPData("https://api.github.com/repos/" .. tostring(CONFIG.GIT.NAME) .. "/" ..
                             tostring(CONFIG.GIT.REPO) .. "/git/refs")

if (data) then
    print("Loading updates")

    git = nil

    local all_refs = json.decode(data)

    local counter = 1
    while git == nil do
        if all_refs[counter].ref == "refs/heads/" .. CONFIG.GIT.BRANCH then
            git = json.decode(data)[counter].object
        end
        counter = counter + 1
    end
    --[[
  sha
  type
  url
  ]]

    -- This is the version ID we are going to compare, to see if we are outdated!
    local newversion = git.sha
    -- this is the repositories commit api url
    local gitcommit = git.url

    local commitdata = getHTTPData(gitcommit)

    if (commitdata) then
        print("Loading commit data")
        -- print("commitdata: ", tostring(commitdata))
        -- print("length: ", tostring(string.len(commitdata)))

        local commitdatatree = json.decode(commitdata).tree
        -- print("commitdatatree: ", tostring(commitdatatree))

        downloadTree(commitdatatree.url)
    end

    --[[for _, v in pairs(git) do
  print(tostring(_), " = ", tostring(v))
  end]]
end

print("Update complete! enjoy!")
