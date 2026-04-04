"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const dotenv_1 = __importDefault(require("dotenv"));
const errorHandler_1 = require("./middleware/errorHandler");
const requestLogger_1 = require("./middleware/requestLogger");
const rateLimiter_1 = require("./middleware/rateLimiter");
const carbon_1 = require("./routes/carbon");
const user_1 = require("./routes/user");
const ai_1 = require("./routes/ai");
const social_1 = require("./routes/social");
const database_1 = require("./utils/database");
const carbonFactors_1 = require("./utils/carbonFactors");
// Load environment variables
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
// Middleware
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)({
    origin: process.env.FRONTEND_URL || 'http://localhost:3001',
    credentials: true
}));
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true }));
app.use(requestLogger_1.requestLogger);
app.use(rateLimiter_1.rateLimiter);
// Routes
app.use('/api/carbon', carbon_1.carbonRoutes);
app.use('/api/user', user_1.userRoutes);
app.use('/api/ai', ai_1.aiRoutes);
app.use('/api/social', social_1.socialRoutes);
// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Error handling
app.use(errorHandler_1.errorHandler);
// Initialize database and data
async function initializeApp() {
    try {
        await (0, database_1.initDatabase)();
        await (0, carbonFactors_1.initCarbonFactors)();
        app.listen(PORT, () => {
            console.log(`🌱 AI Carbon Footprint Tracker running on port ${PORT}`);
            console.log(`📊 Environment: ${process.env.NODE_ENV}`);
            console.log(`🔗 Health check: http://localhost:${PORT}/health`);
        });
    }
    catch (error) {
        console.error('❌ Failed to initialize application:', error);
        process.exit(1);
    }
}
// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('👋 SIGTERM received, shutting down gracefully');
    process.exit(0);
});
process.on('SIGINT', () => {
    console.log('👋 SIGINT received, shutting down gracefully');
    process.exit(0);
});
initializeApp();
//# sourceMappingURL=index.js.map