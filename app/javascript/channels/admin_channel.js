import consumer from "channels/consumer"

const pathre = RegExp("/games/(\\d+)");
const matches = location.pathname.match(pathre);
const id = (matches == null) ? "0" : matches[1];

if (matches)
  consumer.subscriptions.create(
    { channel: "AdminChannel", id: id},
    {
      connected() {
        // Called when the subscription is ready for use on the server
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        let td = new TextDecoder();
        if (data["action"] == "reload") {
          fetch(location.pathname + "?reload=true&page=admin-pannel")
            .then(res => res.body.getReader().read())
            .then(({done, value}) => {
              let admin_pannel = document.getElementById("admin-pannel")
              if (admin_pannel)
                admin_pannel.innerHTML = td.decode(value)
            })
        }
      }
    });
