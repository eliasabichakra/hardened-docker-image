const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Testing endpoint
app.get('/testing-image', (req, res) => {
  res.json({
    status: 'success',
    message: 'Test succeeded',
    timestamp: new Date().toISOString(),
    service: 'hardened-docker-image-tester'
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint not found'
  });
});

app.listen(PORT, () => {
  console.log(`Testing server running on http://localhost:${PORT}`);
  console.log(`Test endpoint available at http://localhost:${PORT}/testing-image`);
});
