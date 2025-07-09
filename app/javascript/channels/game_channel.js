import consumer from "channels/consumer"

const pathre = RegExp("/games/(\\d+)");
const matches = location.pathname.match(pathre);
const id = (matches == null) ? "0" : matches[1];

if (matches)
  consumer.subscriptions.create(
    {channel: "GameChannel", id: id}, 
    {
      connected() {
        // Called when the subscription is ready for use on the server
        // console.log("Connected!")
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        let td = new TextDecoder();
        if (data["action"] == "reload") {
          fetch(location.pathname + "?reload=true")
            .then(res => res.body.getReader().read())
            .then(({done, value}) => {
              document.getElementById("game-table")
                .innerHTML = td.decode(value)
            })
        }
      },
  });
