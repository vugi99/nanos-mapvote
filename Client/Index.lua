

Mapvote_UI = WebUI(
    "Mapvote UI",
    "file:///ui/index.html",
    WidgetVisibility.Hidden,
    true,
    true
)

Mapvote_UI:Subscribe("SelectedNew", function(map)
    Events.CallRemote("SelectMap", map)
end)

Events.SubscribeRemote("UpdateMapVotes", function(votesData)
    for k, v in pairs(votesData) do
        Mapvote_UI:CallEvent("MapvoteVotesUpdate", k, tostring(v))
    end
end)

Events.SubscribeRemote("MapvoteStart", function(mapvoteData, votesData)
    Input.SetMouseEnabled(true)
    Input.SetInputEnabled(false)
    Mapvote_UI:BringToFront()
    Mapvote_UI:SetFocus()
    Mapvote_UI:SetVisibility(WidgetVisibility.Visible)
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