const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true
    },
    email: {
      type: String,
      required: true,
      unique: true
    },
    password: {
      type: String,
      required: true
    },
    description: {
      type: String,
      default: ""
    },
    friends: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],
    friendRequests: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ],
    // Event invites from friends
    eventInvites: [
      {
        eventId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Event"
        },
        fromUserId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User"
        }
      }
    ]
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model("User", userSchema);