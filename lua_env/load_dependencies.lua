--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
local function load_ini(fileName)
    assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
    local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
    local data = {};
    local section;
    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$');
        if (tempSection) then
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
            data[section] = data[section] or {};
        end
        local param, value = line:match('^([%w|_|-]+)%s-=%s-(.+)$');
        if (param and value ~= nil) then
            if (tonumber(value)) then
                value = tonumber(value);
            elseif (value == 'true') then
                value = true;
            elseif (value == 'false') then
                value = false;
            end
            if (tonumber(param)) then
                param = tonumber(param);
            end
            data[section][param] = value;
        end
    end
    file:close();
    return data;
end

local function load_dependencies(fileName)
    local dependencies = load_ini(fileName);
    local function install_one_dependencies(k, v)
        local name = string.gsub(k, '^["]*([^"].*[^"])["]*$', "%1")
        local version = string.gsub(v, '^["]*([^"].*[^"])["]*$', "%1")

        if version == "*"
        then
            version = ""
        end
        local cmd = './luarocks install ' .. name .. version
        print('--    will execute ' .. cmd)
        local ret = os.execute(cmd)
        assert(ret == true)
    end
    for k, v in pairs(dependencies.packages) do
        install_one_dependencies(k, v)
    end
    for k, v in pairs(dependencies['dev-packages']) do
        install_one_dependencies(k, v)
    end
end
local conf_file = nil
if arg[1] == nil
then
    conf_file = "../dependencies.ini"
else
    conf_file = arg[1]
end
load_dependencies(conf_file)