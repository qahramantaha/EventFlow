const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Message = require("../models/Message");
const Event = require("../models/Event");

router.post("/signup", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const newUser = new User({
      name: name,
      email: email,
      password: password
    });

    await newUser.save();

    res.status(201).json({ message: "User created successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    if (user.password != password) {
      return res.status(400).json({ message: "Incorrect password" });
    }

    res.json({
      message: "Login successful",
      user: {
        _id: user._id.toString(),
        name: user.name,
        email: user.email
      }
    });
  } catch (error) {
    console.log("LOGIN ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/profile/:email", async (req, res) => {
  try {
    const email = req.params.email;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      name: user.name,
      email: user.email,
      description: user.description || "",
      createdAt: user.createdAt
    });
  } catch (error) {
    console.log("GET PROFILE ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.put("/profile/:email", async (req, res) => {
  try {
    const email = req.params.email;
    const { description, name } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Update name if provided
    if (name && name.trim() !== "") {
      user.name = name.trim();
    }

    // Update description
    user.description = description;
    await user.save();

    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/home-notifications/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const unreadMessagesCount = await Message.countDocuments({
      receiverId: userId,
      isRead: false
    });

    const goingEventsCount = await Event.countDocuments({
      attendees: userId
    });

    const friendRequestsCount = user.friendRequests.length;

    const notifications = [];

    if (friendRequestsCount > 0) {
      notifications.push({
        type: "friend_request",
        text: `You have ${friendRequestsCount} friend request${friendRequestsCount == 1 ? "" : "s"}`
      });
    }

    if (unreadMessagesCount > 0) {
      notifications.push({
        type: "message",
        text: `You have ${unreadMessagesCount} unread message${unreadMessagesCount == 1 ? "" : "s"}`
      });
    }

    if (goingEventsCount > 0) {
      notifications.push({
        type: "event",
        text: `You are going to ${goingEventsCount} event${goingEventsCount == 1 ? "" : "s"}`
      });
    }

    res.status(200).json({
      friendRequestsCount,
      unreadMessagesCount,
      goingEventsCount,
      totalNotifications: notifications.length,
      notifications
    });
  } catch (error) {
    console.log("HOME NOTIFICATIONS ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/send-request", async (req, res) => {
  try {
    const { fromUserId, toUserId } = req.body;

    if (!fromUserId || !toUserId) {
      return res.status(400).json({ message: "Missing user ids" });
    }

    if (fromUserId === toUserId) {
      return res.status(400).json({ message: "You cannot add yourself" });
    }

    const fromUser = await User.findById(fromUserId);
    const toUser = await User.findById(toUserId);

    if (!fromUser || !toUser) {
      return res.status(404).json({ message: "User not found" });
    }

    const alreadyFriend = toUser.friends.some(
      (friendId) => friendId.toString() === fromUserId
    );

    if (alreadyFriend) {
      return res.status(400).json({ message: "Already friends" });
    }

    const alreadyRequested = toUser.friendRequests.some(
      (requestId) => requestId.toString() === fromUserId
    );

    if (alreadyRequested) {
      return res.status(400).json({ message: "Request already sent" });
    }

    toUser.friendRequests.push(fromUserId);
    await toUser.save();

    res.status(200).json({ message: "Friend request sent" });
  } catch (error) {
    console.log("SEND REQUEST ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/friends/:userId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId)
      .populate("friends", "name email")
      .populate("friendRequests", "name email");

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      friends: user.friends.map((friend) => ({
        _id: friend._id,
        name: friend.name,
        email: friend.email
      })),
      friendRequests: user.friendRequests.map((request) => ({
        _id: request._id,
        name: request.name,
        email: request.email
      }))
    });
  } catch (error) {
    console.log("GET FRIENDS ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/accept-request", async (req, res) => {
  try {
    const { userId, requestUserId } = req.body;

    const user = await User.findById(userId);
    const requestUser = await User.findById(requestUserId);

    if (!user || !requestUser) {
      return res.status(404).json({ message: "User not found" });
    }

    user.friendRequests = user.friendRequests.filter(
      (id) => id.toString() !== requestUserId
    );

    if (!user.friends.some((id) => id.toString() === requestUserId)) {
      user.friends.push(requestUserId);
    }

    if (!requestUser.friends.some((id) => id.toString() === userId)) {
      requestUser.friends.push(userId);
    }

    await user.save();
    await requestUser.save();

    res.status(200).json({ message: "Friend request accepted" });
  } catch (error) {
    console.log("ACCEPT REQUEST ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/reject-request", async (req, res) => {
  try {
    const { userId, requestUserId } = req.body;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.friendRequests = user.friendRequests.filter(
      (id) => id.toString() !== requestUserId
    );

    await user.save();

    res.status(200).json({ message: "Friend request rejected" });
  } catch (error) {
    console.log("REJECT REQUEST ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;