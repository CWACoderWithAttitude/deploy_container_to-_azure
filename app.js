const http = require('http');

const server = http.createServer((req, res) => {
  res.end('Hello from Azure Container Apps! 🎉');
});

server.listen(3000, () => console.log('Server läuft auf Port 3000'));
