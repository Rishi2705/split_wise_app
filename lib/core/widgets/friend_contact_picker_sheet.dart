import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

typedef FriendsStreamGetter = Stream<QuerySnapshot<Map<String, dynamic>>> Function();
typedef ContactsLoader = Future<bool> Function();
typedef ContactsGetter = List<Contact> Function();
typedef AddFriendFromContact = Future<bool> Function(Contact contact);
typedef ErrorGetter = String? Function();

class FriendContactPickerSheet {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required FriendsStreamGetter watchFriends,
    required ContactsLoader loadContacts,
    required ContactsGetter contacts,
    required AddFriendFromContact addFriendFromContact,
    required ErrorGetter errorMessage,
    required Color accentColor,
    String emptyFriendsMessage = 'No friends yet. Add from contacts.',
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        bool showingContacts = false;
        bool loadingContacts = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      showingContacts ? Icons.people_alt_outlined : Icons.contacts,
                      color: accentColor,
                    ),
                    title: Text(showingContacts ? 'Choose contact' : 'Pick from contacts'),
                    trailing: showingContacts
                        ? IconButton(
                            onPressed: () {
                              setSheetState(() {
                                showingContacts = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                          )
                        : null,
                    onTap: () async {
                      if (showingContacts || loadingContacts) return;

                      setSheetState(() {
                        loadingContacts = true;
                      });

                      final ok = await loadContacts();
                      if (!context.mounted) return;

                      setSheetState(() {
                        loadingContacts = false;
                      });

                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage() ?? 'Cannot access contacts')),
                        );
                        return;
                      }

                      if (contacts().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No contacts found on device')),
                        );
                        return;
                      }

                      setSheetState(() {
                        showingContacts = true;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: loadingContacts
                        ? const Center(child: CircularProgressIndicator())
                        : showingContacts
                            ? _buildContactsList(
                                context: context,
                                sheetContext: sheetContext,
                                contacts: contacts,
                                addFriendFromContact: addFriendFromContact,
                                errorMessage: errorMessage,
                              )
                            : _buildFriendsList(
                                sheetContext: sheetContext,
                                watchFriends: watchFriends,
                                accentColor: accentColor,
                                emptyFriendsMessage: emptyFriendsMessage,
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFriendsList({
    required BuildContext sheetContext,
    required FriendsStreamGetter watchFriends,
    required Color accentColor,
    required String emptyFriendsMessage,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: watchFriends(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(child: Text(emptyFriendsMessage));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final friendName = (data['friendName'] ?? '').toString();
            final friendPhone = (data['friendPhone'] ?? '').toString();

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: accentColor.withOpacity(0.1),
                child: Text(
                  (friendName.isEmpty ? '?' : friendName[0]).toUpperCase(),
                ),
              ),
              title: Text(friendName),
              subtitle: Text(friendPhone),
              onTap: () => Navigator.pop(sheetContext, {
                'friendName': friendName,
                'friendPhone': friendPhone,
              }),
            );
          },
        );
      },
    );
  }

  static Widget _buildContactsList({
    required BuildContext context,
    required BuildContext sheetContext,
    required ContactsGetter contacts,
    required AddFriendFromContact addFriendFromContact,
    required ErrorGetter errorMessage,
  }) {
    final contactList = contacts();
    return ListView.separated(
      itemCount: contactList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = contactList[index];
        final phone = c.phones.isNotEmpty
            ? c.phones.first.number.replaceAll(RegExp(r'\s+'), '')
            : '';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(c.displayName.isEmpty ? '?' : c.displayName[0].toUpperCase()),
          ),
          title: Text(c.displayName),
          subtitle: Text(phone.isEmpty ? 'No phone' : phone),
          onTap: () async {
            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact has no phone number')),
              );
              return;
            }

            final added = await addFriendFromContact(c);
            if (!context.mounted) return;
            if (!added) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage() ?? 'Failed to add contact')),
              );
              return;
            }

            Navigator.pop(sheetContext, {
              'friendName': c.displayName,
              'friendPhone': phone,
            });
          },
        );
      },
    );
  }
}