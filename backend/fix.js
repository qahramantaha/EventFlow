const mongoose = require('mongoose');
require('dotenv').config();

const Event = require('./models/Event');

mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('MongoDB connected');

    const result = await Event.updateMany(
      { isPrivate: { $exists: false } },
      { $set: { isPrivate: false } }
    );

    console.log('Updated events:', result.modifiedCount);
    process.exit();
  })
  .catch((error) => {
    console.log('Error:', error);
    process.exit();
  });