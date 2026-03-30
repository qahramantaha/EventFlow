const mongoose = require('mongoose');
require('dotenv').config();

mongoose.connect(process.env.MONGO_URI).then(async () => {
  console.log('MongoDB connected');
  
  const Event = require('./models/Event');
  
  const result = await Event.updateMany(
    { isPrivate: { $exists: false } },
    { $set: { isPrivate: false } }
  );
  
  console.log('Fixed events:', result.modifiedCount);
  process.exit();
}).catch((err) => {
  console.log('Error:', err);
  process.exit();
});