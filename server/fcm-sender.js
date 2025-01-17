import { google } from 'googleapis';
import fetch from 'node-fetch';

class FCMNotificationSender {
    constructor() {
        this.projectId = 'your-project-id';
        this.baseUrl = 'https://fcm.googleapis.com';
        this.fcmEndpoint = `/v1/projects/${this.projectId}/messages:send`;
        this.serviceAccountPath = 'service-account.json';
    }

    async getAccessToken() {
        try {
            const auth = new google.auth.GoogleAuth({
                keyFile: this.serviceAccountPath,
                scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
            });

            const token = await auth.getAccessToken();
            return token;
        } catch (error) {
            console.error('Error getting access token:', error);
            throw new Error('Unable to get access token');
        }
    }

    buildNotificationMessage(deviceToken, title, body, data = {}) {
        return {
            message: {
                token: deviceToken,
                notification: {
                    title,
                    body
                },
                ...(Object.keys(data).length > 0 && { data })
            }
        };
    }

    async sendNotification(deviceToken, title, body, data = {}) {
        try {
            const accessToken = await this.getAccessToken();
            const message = this.buildNotificationMessage(deviceToken, title, body, data);

            const response = await fetch(`${this.baseUrl}${this.fcmEndpoint}`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(message)
            });

            const responseData = await response.json();

            if (!response.ok) {
                throw new Error(`FCM notification failed: ${JSON.stringify(responseData)}`);
            }

            return responseData;
        } catch (error) {
            console.error('Error sending notification:', error);
            throw error;
        }
    }
}


export default FCMNotificationSender;