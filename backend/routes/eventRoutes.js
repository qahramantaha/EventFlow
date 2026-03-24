const express = require("express");
const router = express.Router();
const Event = require("../models/Event");

// Get all events
router.get("/", async (req, res) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 });
    res.status(200).json(events);
  } catch (error) {
    res.status(500).json({ message: "Error fetching events" });
  }
});

// Get one event
router.get("/:id", async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.status(200).json(event);
  } catch (error) {
    res.status(500).json({ message: "Error fetching event" });
  }
});

// Create event
router.post("/", async (req, res) => {
  try {
    const { title, description, location, date, createdBy } = req.body;

    if (!title || !location || !date) {
      return res.status(400).json({ message: "Title, location and date are required" });
    }

    const newEvent = new Event({
      title,
      description,
      location,
      date,
      createdBy
    });

    await newEvent.save();

    res.status(201).json(newEvent);
  } catch (error) {
    console.log("Create event error:", error);
    res.status(500).json({ message: "Error creating event" });
  }
});

// Update event
router.put("/:id", async (req, res) => {
  try {
    const { title, description, location, date, createdBy } = req.body;

    const updatedEvent = await Event.findByIdAndUpdate(
      req.params.id,
      { title, description, location, date, createdBy },
      { new: true }
    );

    if (!updatedEvent) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.status(200).json(updatedEvent);
  } catch (error) {
    res.status(500).json({ message: "Error updating event" });
  }
});

// Delete event
router.delete("/:id", async (req, res) => {
  try {
    const deletedEvent = await Event.findByIdAndDelete(req.params.id);

    if (!deletedEvent) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.status(200).json({ message: "Event deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting event" });
  }
});

module.exports = router;