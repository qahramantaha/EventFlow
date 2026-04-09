const express = require("express");
const router = express.Router();
const Message = require("../models/Message");

router.get("/:userId/:friendId", async (req, res) => {
  try {
    const { userId, friendId } = req.params;

    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: friendId },
        { senderId: friendId, receiverId: userId }
      ]
    }).sort({ createdAt: 1 });

    res.status(200).json(
      messages.map((message) => ({
        _id: message._id,
        senderId: message.senderId,
        receiverId: message.receiverId,
        text: message.text,
        isRead: message.isRead,
        createdAt: message.createdAt
      }))
    );
  } catch (error) {
    console.log("GET MESSAGES ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/send", async (req, res) => {
  try {
    const { senderId, receiverId, text } = req.body;

    if (!senderId || !receiverId || !text || !text.trim()) {
      return res.status(400).json({ message: "Missing message data" });
    }

    const newMessage = new Message({
      senderId,
      receiverId,
      text: text.trim(),
      isRead: false
    });

    await newMessage.save();

    res.status(201).json({
      message: "Message sent",
      newMessage: {
        _id: newMessage._id,
        senderId: newMessage.senderId,
        receiverId: newMessage.receiverId,
        text: newMessage.text,
        isRead: newMessage.isRead,
        createdAt: newMessage.createdAt
      }
    });
  } catch (error) {
    console.log("SEND MESSAGE ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.put("/mark-read", async (req, res) => {
  try {
    const { userId, friendId } = req.body;

    if (!userId || !friendId) {
      return res.status(400).json({ message: "Missing user ids" });
    }

    await Message.updateMany(
      {
        senderId: friendId,
        receiverId: userId,
        isRead: false
      },
      {
        $set: { isRead: true }
      }
    );

    res.status(200).json({ message: "Messages marked as read" });
  } catch (error) {
    console.log("MARK READ ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/unread/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    const unreadMessages = await Message.find({
      receiverId: userId,
      isRead: false
    });

    const unreadByFriend = {};

    unreadMessages.forEach((message) => {
      const senderId = message.senderId.toString();

      if (!unreadByFriend[senderId]) {
        unreadByFriend[senderId] = 0;
      }

      unreadByFriend[senderId] += 1;
    });

    res.status(200).json({
      totalUnread: unreadMessages.length,
      unreadByFriend
    });
  } catch (error) {
    console.log("GET UNREAD ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;