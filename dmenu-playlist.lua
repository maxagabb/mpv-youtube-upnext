-- Bound to F8 by default.

local mp = require 'mp'

local function exec(args, stdin)
    local command = {
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        detach = false,
        args = args,
    }
    if stdin then command.stdin_data = stdin end
    local ret = mp.command_native(command)
    return ret.status, ret.stdout, ret
end


local function show_menu()

    local playlist = mp.get_property_native('playlist')
    local choiceTable = {}
    for i = 1, #playlist do
	local title = playlist[i].title
	if(title == nil) then
		title = playlist[i].filename:match("^.+/(.+)$")
	end
        choiceTable[i] = title.."\n"
    end
    local choices = table.concat(choiceTable)
    local command = {
	    "dmenu-dwm",
	    "-b",
	    "-l",
	    "40",
	    "-p",
	    "___   Search in playlist: "
    }
    local es, choice, _ = exec(command, choices)
    mp.osd_message(choice)

    local selected = -3
    for k,v in pairs(choiceTable) do
        if v == choice then
            selected = k-1
	    break
        end
    end

    if(selected == -3) then
	return
    end

    mp.commandv("playlist-play-index", selected)

    return
end

-- keybind to launch menu
mp.add_key_binding("F8", "dmenu-playlist", show_menu)
