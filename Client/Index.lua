

Mapvote_UI = WebUI(
    "Mapvote UI",
    "file:///ui/index.html",
    false,
    true,
    true
)

Mapvote_UI:Subscribe("SelectedNew", function(map)
    Events.CallRemote("SelectMap", map)
end)

Events.Subscribe("UpdateMapVotes", function(votesData)
    for k, v in pairs(votesData) do
        Mapvote_UI:CallEvent("MapvoteVotesUpdate", k, tostring(v))
    end
end)

Events.Subscribe("MapvoteStart", function(mapvoteData, votesData)
    Client.SetMouseEnabled(true)
    Client.SetInputEnabled(false)
    Mapvote_UI:BringToFront()
    Mapvote_UI:SetFocus()
    Mapvote_UI:SetVisible(true)
    Mapvote_UI:CallEvent("MapvoteStart", JSON.stringify(mapvoteData))

    if votesData then
        for k, v in pairs(votesData) do
            if v > 0 then
                Mapvote_UI:CallEvent("MapvoteVotesUpdate", k, tostring(v))
            end
        end
    end
end)

function IsInMapVote()
    return Mapvote_UI:IsVisible()
end
Package.Export("IsInMapVote", IsInMapVote)