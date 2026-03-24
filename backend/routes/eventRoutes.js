const express = require("express");
const router = express.Router();
const Event = require("../models/Event");

router.get("/", async (req, res) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 });
    res.status(200).json(events);
  } catch (error) {
    res.status(500).json({ message: "Error fetching events" });
  }
});

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

router.post("/", async (req, res) => {
  try {
    const {
      title,
      description,
      location,
      date,
      createdBy,
      latitude,
      longitude
    } = req.body;

    if (!title || !location || !date || latitude == null || longitude == null) {
      return res.status(400).json({
        message: "Title, location, date, latitude and longitude are required"
      });
    }

    const newEvent = new Event({
      title,
      description,
      location,
      date,
      createdBy,
      latitude,
      longitude
    });

    await newEvent.save();

    res.status(201).json(newEvent);
  } catch (error) {
    console.log("Create event error:", error);
    res.status(500).json({ message: "Error creating event" });
  }
});

router.put("/:id", async (req, res) => {
  try {
    const {
      title,
      description,
      location,
      date,
      createdBy,
      latitude,
      longitude
    } = req.body;

    const updatedEvent = await Event.findByIdAndUpdate(
      req.params.id,
      { title, description, location, date, createdBy, latitude, longitude },
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