import 'package:flutter/material.dart';
import 'models/event_models.dart';
import 'services/event_services.dart';
import 'user_session.dart';
import 'api_service.dart';
import 'edit_event_page.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  EventModel? event;
  bool isLoading = true;

  Set<String> sentRequests = {};
  TextEditingController commentController = TextEditingController();
  bool isSubmittingComment = false;

  String get userId => UserSession.id;

  Future<void> loadEventDetails() async {
    print('widget.eventId: ${widget.eventId}');
    print('UserSession.id: ${UserSession.id}');

    if (userId.isEmpty) {
      print('userId is empty');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final loadedEvent =
          await EventService.getEventDetails(widget.eventId, userId);

      setState(() {
        event = loadedEvent;
        isLoading = false;
      });
    } catch (e) {
      print('Load event details error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadEventDetails();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  String formatCommentDate(String dateText) {
    try {
      DateTime date = DateTime.parse(dateText).toLocal();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  Future<void> handleAddComment() async {
    if (commentController.text.trim().isEmpty || event == null) {
      return;
    }

    setState(() {
      isSubmittingComment = true;
    });

    try {
      await EventService.addComment(
        event!.id,
        userId,
        commentController.text.trim(),
      );

      commentController.clear();
      await loadEventDetails();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    }

    if (!mounted) return;

    setState(() {
      isSubmittingComment = false;
    });
  }

  Future<void> handleDeleteComment(String commentId) async {
    if (event == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await EventService.deleteComment(event!.id, commentId, userId);
        await loadEventDetails();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment')),
        );
      }
    }
  }

  Future<void> handleRsvp() async {
    if (event == null) return;

    if (event!.isGoing) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel RSVP'),
          content: const Text('Are you sure you want to cancel your RSVP?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await EventService.cancelRsvp(event!.id, userId);
        await loadEventDetails();
      }
    } else {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("I'm Going"),
          content: const Text('Are you sure you want to go to this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await EventService.rsvpToEvent(event!.id, userId);
        await loadEventDetails();
      }
    }
  }

  Future<void> sendFriendRequest(String toUserId) async {
    final result = await ApiService.sendFriendRequest(UserSession.id, toUserId);

    if (!mounted) return;

    setState(() {
      sentRequests.add(toUserId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "Request sent")),
    );
  }

  Future<void> handleDeleteEvent() async {
    if (event == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await EventService.deleteEvent(event!.id, userId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete event')),
        );
      }
    }
  }

  Future<void> handleEditEvent() async {
    if (event == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(event: event!),
      ),
    );

    if (result == true) {
      await loadEventDetails();
    }
  }

  Future<void> showInviteFriendsDialog() async {
    final result = await ApiService.getFriends(UserSession.id);
    final friends = result["friends"] as List? ?? [];

    if (!mounted) return;

    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have no friends to invite yet!")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event!.isPrivate ? "Invite Friends to Private Event" : "Invite Friends",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...friends.map((friend) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF005F89),
                    child: Text(
                      friend["name"].toString().isNotEmpty
                          ? friend["name"].toString()[0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(friend["name"].toString()),
                  subtitle: Text(friend["email"].toString()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final result = await ApiService.inviteFriendToEvent(
                        UserSession.id,
                        friend["_id"].toString(),
                        event!.id,
                      );

                      if (!mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result["message"] ?? "Invite sent!"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F89),
                    ),
                    child: const Text(
                      "Invite",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  bool get canInviteFriends {
    if (event == null) return false;

    if (event!.isPrivate) {
      return event!.createdBy == UserSession.id;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005F89),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Event Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : event == null
              ? const Center(child: Text('Failed to load event'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event!.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2D3D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event!.organiser,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (event!.createdBy == UserSession.id) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: handleEditEvent,
                                icon: const Icon(Icons.edit, color: Colors.white),
                                label: const Text(
                                  'Edit Event',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005F89),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: handleDeleteEvent,
                                icon: const Icon(Icons.delete, color: Colors.white),
                                label: const Text(
                                  'Delete Event',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DATE',
                              style: TextStyle(
                                color: Color(0xFF005F89),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(event!.date),
                            const SizedBox(height: 14),
                            const Text(
                              'TIME',
                              style: TextStyle(
                                color: Color(0xFF005F89),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(event!.time),
                            const SizedBox(height: 14),
                            const Text(
                              'LOCATION',
                              style: TextStyle(
                                color: Color(0xFF005F89),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(event!.location),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2D3D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event!.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${event!.goingCount} ${event!.goingCount == 1 ? "person" : "people"} going',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: handleRsvp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: event!.isGoing
                                    ? Colors.red
                                    : const Color(0xFF005F89),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                event!.isGoing ? 'Cancel RSVP' : "I'm Going",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if (canInviteFriends) ...[
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: showInviteFriendsDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Invite",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2D3D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: commentController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSubmittingComment ? null : handleAddComment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005F89),
                                ),
                                child: isSubmittingComment
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Post Comment',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      event!.comments.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'No comments yet.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Column(
                              children: event!.comments.map((comment) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              comment.userName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formatCommentDate(comment.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (comment.userId == UserSession.id)
                                            IconButton(
                                              onPressed: () {
                                                handleDeleteComment(comment.id);
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        comment.text,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 28),
                      const Text(
                        'People Going',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2D3D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      event!.attendees.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'No one is going yet.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Column(
                              children: event!.attendees.map((attendee) {
                                final requestSent = sentRequests.contains(attendee.id);

                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF005F89),
                                        child: Text(
                                          attendee.name.isNotEmpty
                                              ? attendee.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          attendee.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (attendee.id != UserSession.id)
                                        TextButton(
                                          onPressed: requestSent
                                              ? null
                                              : () async {
                                                  await sendFriendRequest(attendee.id);
                                                },
                                          style: TextButton.styleFrom(
                                            foregroundColor: requestSent
                                                ? Colors.grey
                                                : const Color(0xFF005F89),
                                          ),
                                          child: Text(
                                            requestSent ? "Request Sent" : "Add Friend",
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
    );
  }
}