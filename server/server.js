import express from 'express';
import cors from 'cors';
import FCMNotificationSender from './fcm-sender.js';

const app = express();
app.use(cors());
app.use(express.json());

const fcmSender = new FCMNotificationSender();

app.post('/send-notification', async (req, res) => {
    try {
        const { token, title, body, data } = req.body;
        const result = await fcmSender.sendNotification(token, title, body, data);
        res.json({ success: true, result });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

const PORT = 3000;
// Change this line to listen on all network interfaces
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});