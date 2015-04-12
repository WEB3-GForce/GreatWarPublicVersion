$(document).ready(function() {
    var dispatcher = new WebSocketRails('localhost:3000/websocket');

    // subscribe to the channel
    var channel = dispatcher.subscribe('messages');

    // bind to a channel event
    channel.bind('new', function(data) {
	var textArea = $(".chat-area textarea")
	var currentText = textArea.val();
	textArea.val(currentText + data + "\n")
    });

    $(".chat-input form").submit(function(e) {
	e.preventDefault();
	var input = $(".chat-input input")
	var text = input.val();
	input.val("");
	dispatcher.trigger("chat_message", {text: text});
    });

    $(".chat-name input").change(function() {
	dispatcher.trigger("set_name", {name: $(".chat-name input").val()});
    });
});
