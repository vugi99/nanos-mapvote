

/*var testFuncs = {}
var Events = {}

Events.Subscribe = function(name, func) {
    testFuncs[name] = function(...Args) {
        return func(...Args)
    }
}*/

const time_bar = document.getElementById("time");
const mapvote_frame = document.getElementById("mapvote_frame");

let Votes_Texts = {};

let Selected = false;

Events.Subscribe("MapvoteStart", function(mapvote_json) {
    let mapvote_data = JSON.parse(mapvote_json);
    let time_s = mapvote_data.time
    let remaining_time_s = mapvote_data.time
    time_bar.value = (remaining_time_s * 100 / time_s).toString();
    let interval_ID = setInterval(function() {
        remaining_time_s = remaining_time_s - 1
        time_bar.value = (remaining_time_s * 100 / time_s).toString();
        if (remaining_time_s == 0) {
            clearInterval(interval_ID);
        }
    }, 1000);

    for (const [k, v] of Object.entries(mapvote_data.maps)) {
        let item = document.createElement("button");
        item.classList.add("mapvote_item");

        item.onclick = function() {
            if (Selected) {
                if (Selected == k) {
                    return
                }
                Votes_Texts[Selected].innerText = Votes_Texts[Selected].innerText.replace(" [X]",'');
            }
            Selected = k
            Votes_Texts[k].innerText = Votes_Texts[k].innerText + " [X]"

            Events.Call("SelectedNew", Selected)
        }

        let item_img = document.createElement("img");
        item_img.classList.add("mapvote_img");
        item_img.src = v.image;

        item.appendChild(item_img);

        let item_text = document.createElement("div");
        item_text.classList.add("mapvote_text")
        item_text.innerText = v.UI_name

        item.appendChild(item_text);

        let item_votes = document.createElement("div");
        item_votes.classList.add("mapvote_votes")
        item_votes.innerText = "0"

        item.appendChild(item_votes);

        mapvote_frame.appendChild(item);

        Votes_Texts[k] = item_votes;
    }
})

Events.Subscribe("MapvoteVotesUpdate", function(map, votes) {
    Votes_Texts[map].innerText = votes;
    if (Selected) {
        if (Selected == map) {
            Votes_Texts[map].innerText = Votes_Texts[map].innerText + " [X]"
        }
    }
})

/*testFuncs.MapvoteStart('{\
    "time": 10,\
    "maps": {\
        "map1": {\
            "image": "test_images/z.jpg"\
        },\
        "map2": {\
            "image": "images/missing.png"\
        },\
        "map3": {\
            "image": "images/missing.png"\
        }\
    }\
}')*/