require('dotenv').config();
const express = require('express');
const https = require('https');
const http = require('http');
const WebSocket = require('ws');
const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');

const app = express();
const port = parseInt(process.env.PORT) || 8080;

// Initialize Telegram Bot
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

// User management
const users = new Map();

// Create HTTP server
const httpServer = http.createServer(app);

// WebSocket server for port 80
const wss = new WebSocket.Server({ server: httpServer });

// HTTPS server for SSL/TLS
const httpsServer = https.createServer({
    key: fs.readFileSync('/etc/nginx/ssl/private.key'),
    cert: fs.readFileSync('/etc/nginx/ssl/certificate.crt')
}, app);

// WebSocket server for SSL/TLS
const wssSecure = new WebSocket.Server({ server: httpsServer });

// Express routes
app.get('/', (req, res) => {
    res.send('Server is running');
});

// Telegram Bot commands
bot.onText(/\/start/, (msg) => {
    const chatId = msg.chat.id;
    bot.sendMessage(chatId, 'Welcome to VPN Management Bot! Use /help to see available commands.');
});

bot.onText(/\/help/, (msg) => {
    const chatId = msg.chat.id;
    const helpText = `
Available commands:
/adduser <username> <password> - Add new VPN user
/removeuser <username> - Remove VPN user
/status - Check service status
    `;
    bot.sendMessage(chatId, helpText);
});

bot.onText(/\/adduser (.+) (.+)/, (msg, match) => {
    const chatId = msg.chat.id;
    const username = match[1];
    const password = match[2];
    
    if (users.has(username)) {
        bot.sendMessage(chatId, 'User already exists!');
        return;
    }
    
    users.set(username, password);
    bot.sendMessage(chatId, `User ${username} added successfully!`);
});

bot.onText(/\/removeuser (.+)/, (msg, match) => {
    const chatId = msg.chat.id;
    const username = match[1];
    
    if (users.delete(username)) {
        bot.sendMessage(chatId, `User ${username} removed successfully!`);
    } else {
        bot.sendMessage(chatId, 'User not found!');
    }
});

bot.onText(/\/status/, (msg) => {
    const chatId = msg.chat.id;
    const status = {
        vpn: 'Running',
        ssh: 'Running',
        websocket: 'Running',
        ssl: 'Active',
        users: users.size
    };
    
    bot.sendMessage(chatId, JSON.stringify(status, null, 2));
});

// WebSocket handlers
wss.on('connection', (ws) => {
    console.log('New WebSocket connection on port 80');
    ws.on('message', (message) => {
        console.log('Received:', message);
    });
});

wssSecure.on('connection', (ws) => {
    console.log('New secure WebSocket connection on port 443');
    ws.on('message', (message) => {
        console.log('Received secure:', message);
    });
});

// Start HTTP server
httpServer.listen(80, () => {
    console.log('HTTP Server running on port 80');
});

// Start HTTPS server
httpsServer.listen(443, () => {
    console.log('HTTPS Server running on port 443');
});

// Start Express server
app.listen(port, () => {
    console.log(`Express Server listening on port ${port}`);
}); 