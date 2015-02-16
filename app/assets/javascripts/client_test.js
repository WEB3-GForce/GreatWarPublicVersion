var task = {
  name: 'Start taking advantage of WebSockets',
  completed: false
}

var dispatcher = new WebSocketRails('localhost:3000/websocket');

dispatcher.trigger('test_event', task);