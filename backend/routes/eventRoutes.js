const express = require('express');
const mongoose = require('mongoose');
const Event = require('../models/Event');

const router = express.Router();

// Replace this with your real auth middleware later
const fakeAuth = (req, res, next) => {
  const userId = req.header('userId');

  if (!userId) {
    return res.status(401).json({ message: 'No userId provided' });
  }

  req.user = { id: userId };
  next();
};

// Get all events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 });

    const formattedEvents = events.map((event) => ({
      _id: event._id,
      title: event.title,
      organiser: event.organiser,
      description: event.description,
      date: event.date,
      time: event.time,
      location: event.location,
      category: event.category,
      goingCount: event.attendees.length,
    }));

    res.json(formattedEvents);
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get one event
router.get('/:id', fakeAuth, async (req, res) => {
  try {
    console.log('params id:', req.params.id);
    console.log('header userId:', req.user.id);

    const event = await Event.findById(req.params.id).populate('attendees', 'name email');

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const userId = req.user.id;

    const isGoing = event.attendees.some(
      (attendee) => attendee._id.toString() === userId
    );

    res.json({
      _id: event._id,
      title: event.title,
      organiser: event.organiser,
      description: event.description,
      date: event.date,
      time: event.time,
      location: event.location,
      category: event.category,
      goingCount: event.attendees.length,
      isGoing: isGoing,
      attendees: event.attendees.map((attendee) => ({
        _id: attendee._id,
        name: attendee.name,
        email: attendee.email
      }))
    });
  } catch (error) {
    console.log('Get event details error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// RSVP to event
router.post('/:id/rsvp', fakeAuth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const userId = req.user.id;

    const alreadyGoing = event.attendees.some(
      (attendeeId) => attendeeId.toString() === userId
    );

    if (alreadyGoing) {
      return res.status(400).json({ message: 'User already RSVP’d' });
    }

    event.attendees.push(new mongoose.Types.ObjectId(userId));
    await event.save();

    res.json({
      message: 'RSVP successful',
      goingCount: event.attendees.length,
      isGoing: true,
    });
  } catch (error) {
    console.error('RSVP error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Cancel RSVP
router.delete('/:id/rsvp', fakeAuth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const userId = req.user.id;

    event.attendees = event.attendees.filter(
      (attendeeId) => attendeeId.toString() !== userId
    );

    await event.save();

    res.json({
      message: 'RSVP cancelled',
      goingCount: event.attendees.length,
      isGoing: false,
    });
  } catch (error) {
    console.error('Cancel RSVP error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;