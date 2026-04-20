const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const eventRoutes = require('./routes/eventRoutes');
const userRoutes = require('./routes/userRoutes');
const messageRoutes = require('./routes/messageRoutes');

const app = express();

app.use(cors());
app.use(express.json());

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');
  })
  .catch((error) => {
    console.log('MongoDB connection error:', error);
  });

app.get('/test-server', (req, res) => {
  res.json({ message: 'Backend is working' });
});

app.use('/api/events', eventRoutes);
app.use('/api/users', userRoutes);
app.use('/api/messages', messageRoutes);

app.listen(5000, () => {
  console.log('Server running on port 5000');
});