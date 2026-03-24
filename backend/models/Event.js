const mongoose = require("mongoose");

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ""
  },
  location: {
    type: String,
    required: true
  },
  date: {
    type: String,
    required: true
  },
  createdBy: {
    type: String,
    default: ""
  }
}, { timestamps: true });

module.exports = mongoose.model("Event", eventSchema);