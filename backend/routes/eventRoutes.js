const express = require('express');
const mongoose = require('mongoose');
const Event = require('../models/Event');
const User = require('../models/User');

const router = express.Router();

const fakeAuth = (req, res, next) => {
  const userId = req.header('userId');

  if (!userId) {
    return res.status(401).json({ message: 'No userId provided' });
  }

  req.user = { id: userId };
  next();
};

// Create event
router.post('/create', fakeAuth, async (req, res) => {
  try {
    const {
      title,
      organiser,
      description,
      date,
      time,
      location,
      category,
      isPrivate,
    } = req.body;

    if (
      !title ||
      !organiser ||
      !description ||
      !date ||
      !time ||
      !location ||
      !category
    ) {
      return res.status(400).json({ message: 'Please fill in all fields' });
    }

    const newEvent = new Event({
      title,
      organiser,
      description,
      date,
      time,
      location,
      category,
      isPrivate: isPrivate ?? false,
      createdBy: req.user.id,
      attendees: [],
      comments: [],
    });

    await newEvent.save();

    res.status(201).json({
      message: 'Event created successfully',
      event: newEvent,
    });
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all events
router.get('/', fakeAuth, async (req, res) => {
  try {
    const userId = req.user.id;

    const events = await Event.find({
      $or: [
        { isPrivate: false },
        { isPrivate: true, createdBy: userId },
        { isPrivate: true, invitedUsers: userId }
      ]
    }).sort({ createdAt: -1 });

    const formattedEvents = events.map((event) => {
      const isGoing = event.attendees.some(
        (attendeeId) => attendeeId.toString() === userId
      );

      return {
        _id: event._id,
        title: event.title,
        organiser: event.organiser,
        description: event.description,
        date: event.date,
        time: event.time,
        location: event.location,
        category: event.category,
        isPrivate: event.isPrivate,
        createdBy: event.createdBy,
        goingCount: event.attendees.length,
        isGoing: isGoing,
      };
    });

    res.json(formattedEvents);
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get events user is going to
router.get('/my-events', fakeAuth, async (req, res) => {
  try {
    const userId = req.user.id;

    const events = await Event.find({ attendees: userId }).sort({ createdAt: -1 });

    const formattedEvents = events.map((event) => ({
      _id: event._id,
      title: event.title,
      organiser: event.organiser,
      description: event.description,
      date: event.date,
      time: event.time,
      location: event.location,
      category: event.category,
      isPrivate: event.isPrivate,
      createdBy: event.createdBy,
      goingCount: event.attendees.length,
      isGoing: true,
    }));

    res.json(formattedEvents);
  } catch (error) {
    console.error('Get my events error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get one event
router.get('/:id', fakeAuth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id).populate('attendees', 'name email');

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const userId = req.user.id;

    const isCreator = event.createdBy?.toString() === userId;
    const isInvited = event.invitedUsers?.some(
      (id) => id.toString() === userId
    );

    if (event.isPrivate && !isCreator && !isInvited) {
      return res.status(403).json({ message: 'You do not have access to this private event' });
    }

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
      isPrivate: event.isPrivate,
      createdBy: event.createdBy,
      goingCount: event.attendees.length,
      isGoing: isGoing,
      attendees: event.attendees.map((attendee) => ({
        _id: attendee._id,
        name: attendee.name,
        email: attendee.email,
      })),
      comments: (event.comments || []).map((comment) => ({
        _id: comment._id,
        userId: comment.userId,
        userName: comment.userName,
        text: comment.text,
        createdAt: comment.createdAt,
      })),
    });
  } catch (error) {
    console.log('Get event details error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Add comment
router.post('/:id/comments', fakeAuth, async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || !text.trim()) {
      return res.status(400).json({ message: 'Comment cannot be empty' });
    }

    const event = await Event.findById(req.params.id);
    const user = await User.findById(req.user.id);

    if (!event || !user) {
      return res.status(404).json({ message: 'Event or user not found' });
    }

    const isCreator = event.createdBy?.toString() === req.user.id;
    const isInvited = event.invitedUsers?.some(
      (id) => id.toString() === req.user.id
    );

    if (event.isPrivate && !isCreator && !isInvited) {
      return res.status(403).json({ message: 'You do not have access to comment on this private event' });
    }
    if (!event.comments) {
      event.comments = [];
    }
    event.comments.push({
      userId: user._id,
      userName: user.name,
      text: text.trim(),
    });

    await event.save();

    const newComment = event.comments[event.comments.length - 1];

    res.status(201).json({
      message: 'Comment added successfully',
      comment: {
        _id: newComment._id,
        userId: newComment.userId,
        userName: newComment.userName,
        text: newComment.text,
        createdAt: newComment.createdAt,
      },
    });
  } catch (error) {
    console.log('Add comment error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete comment
router.delete('/:id/comments/:commentId', fakeAuth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    const comment = event.comments.id(req.params.commentId);

    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    if (comment.userId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'You can only delete your own comment' });
    }

    comment.deleteOne();
    await event.save();

    res.status(200).json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.log('Delete comment error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update event
router.put('/:id', fakeAuth, async (req, res) => {
  try {
    const {
      title,
      organiser,
      description,
      date,
      time,
      location,
      category,
      isPrivate,
    } = req.body;

    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    if (event.createdBy?.toString() !== req.user.id) {
      return res.status(403).json({ message: 'You can only edit your own event' });
    }

    event.title = title ?? event.title;
    event.organiser = organiser ?? event.organiser;
    event.description = description ?? event.description;
    event.date = date ?? event.date;
    event.time = time ?? event.time;
    event.location = location ?? event.location;
    event.category = category ?? event.category;
    event.isPrivate = isPrivate ?? event.isPrivate;

    await event.save();

    res.status(200).json({
      message: 'Event updated successfully',
      event,
    });
  } catch (error) {
    console.error('Update event error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete event
router.delete('/:id', fakeAuth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    if (event.createdBy?.toString() !== req.user.id) {
      return res.status(403).json({ message: 'You can only delete your own event' });
    }

    await Event.findByIdAndDelete(req.params.id);

    res.status(200).json({ message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Delete event error:', error);
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
      return res.status(400).json({ message: 'User already RSVP\'d' });
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
router.post('/:id/cancel-rsvp', fakeAuth, async (req, res) => {
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