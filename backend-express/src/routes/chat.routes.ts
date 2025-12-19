import express, { Request, Response } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';

const router = express.Router();

// Initialize Gemini with API key
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');

// Gemini chat endpoint
router.post('/gemini', async (req: Request, res: Response) => {
    try {
        const { message, restaurantId, restaurantName } = req.body;

        if (!message) {
            return res.status(400).json({ error: 'Message is required' });
        }

        // Initialize the model
        const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

        // Build context based on restaurant info
        let context = '';
        if (restaurantName) {
            context = `You are a helpful AI assistant for "${restaurantName}" restaurant. Help customers with menu questions, hours, ordering, and general inquiries. Be friendly and concise. `;
        } else {
            context = 'You are a helpful AI assistant for a food delivery platform. Help users find restaurants, understand menus, track orders, and answer general questions. Be friendly and concise. ';
        }

        const prompt = context + `User question: ${message}`;

        // Generate response
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        res.json({ response: text });
    } catch (error) {
        console.error('Gemini API error:', error);
        res.status(500).json({
            error: 'Failed to get AI response',
            message: error instanceof Error ? error.message : 'Unknown error',
        });
    }
});

// Health check
router.get('/health', (req: Request, res: Response) => {
    res.json({ status: 'Chat service is running', gemini: !!process.env.GEMINI_API_KEY });
});

export default router;
