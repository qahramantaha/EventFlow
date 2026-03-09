const express = require("express");
const router = express.Router();
const User = require("../models/User");

router.post("/signup", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    console.log("Signup hit");
    console.log("Data received:", name, email, password);

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      console.log("User already exists");
      return res.status(400).json({ message: "User already exists" });
    }

    const newUser = new User({
      name: name,
      email: email,
      password: password
    });

    await newUser.save();

    console.log("User saved successfully");

    res.status(201).json({ message: "User created successfully" });
  } catch (error) {
    console.log("Signup error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;

router.post("/login", async (req, res) => {
  try {

    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    if (user.password !== password) {
      return res.status(400).json({ message: "Incorrect password" });
    }

    res.status(200).json({
      message: "Login successful",
      user: user
    });

  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});