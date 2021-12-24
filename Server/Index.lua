
local Voting = false
local Voting_Tbl

local SelectedMapPerPlayer = {}
local Votes = {}

function table_count(ta)
    local count = 0
    for k, v in pairs(ta) do count = count + 1 end
    return count
end

function split_str(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function isdir(strFolderName)
	 local fileHandle, strError = io.open(strFolderName.."\\*.*","r")
	 if fileHandle ~= nil then
         io.close(fileHandle)
         return true
	 else
         if string.match(strError,"No such file or directory") then
             return false
         else
             return true
         end
	 end
end

Events.Subscribe("SelectMap", function(ply, map)
    local ply_id = ply:GetID()
    local Selected_map = SelectedMapPerPlayer[ply_id]
    if Selected_map then
        Votes[Selected_map] = Votes[Selected_map] - 1
    end
    SelectedMapPerPlayer[ply_id] = map
    Votes[map] = Votes[map] + 1

    Events.BroadcastRemote("UpdateMapVotes", Votes)
end)

function IsAssetPack(asset_pack_name)
    if isdir("Assets/" .. asset_pack_name) then
        return true
    end
end

function StartMapVote(mapvote_tbl)
    if not IsInMapVote() then
        local cur_map = Server.GetMap()
        for k, v in pairs(mapvote_tbl.maps) do
            if v.path == cur_map then
                mapvote_tbl.maps[k] = nil
                break
            end
        end

        local new_mapvote_tbl = {}
        new_mapvote_tbl.time = mapvote_tbl.time
        new_mapvote_tbl.maps = {}
        for k, v in pairs(mapvote_tbl.maps) do
            if v then
                local split_path = split_str(v.path, ":")
                if (split_path[1] and split_path[2]) then
                    if IsAssetPack(split_path[1]) then
                        new_mapvote_tbl.maps[k] = v
                    end
                end
            end
        end

        --print(NanosUtils.Dump(new_mapvote_tbl))

        if table_count(new_mapvote_tbl.maps) > 0 then
            Voting = true
            Voting_Tbl = new_mapvote_tbl
            for k, v in pairs(Voting_Tbl.maps) do
                Votes[k] = 0
            end


            Events.BroadcastRemote("MapvoteStart", mapvote_tbl)

            Timer.SetTimeout(function()
                local max_votes = 0
                local maps_with_these_votes = {}
                for k, v in pairs(Votes) do
                    if v > max_votes then
                        max_votes = v
                        maps_with_these_votes = {k}
                    elseif v == max_votes then
                        table.insert(maps_with_these_votes, k)
                    end
                end

                local SelectedMap = maps_with_these_votes[math.random(table_count(maps_with_these_votes))]
                Server.ChangeMap(Voting_Tbl.maps[SelectedMap].path)
            end, Voting_Tbl.time * 1000)

            return true
        end
    end
    return false
end
Package.Export("StartMapVote", StartMapVote)

function IsInMapVote()
    return Voting
end
Package.Export("IsInMapVote", IsInMapVote)

Player.Subscribe("Spawn", function(ply)
    if IsInMapVote() then
        Events.CallRemote("MapvoteStart", ply, Voting_Tbl, Votes)
    end
end)