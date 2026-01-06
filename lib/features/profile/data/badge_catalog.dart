import 'package:flutter/material.dart';
import '../models/badge.dart';

class BadgeCatalog {
  static const badges = <AppBadge>[
    AppBadge(
      id: 'clear_communicator',
      name: 'Clear Communicator',
      category: BadgeCategory.communication,
      description:
          'Consistently expresses needs, boundaries, and intentions in ways that are easy to understand.',
      icon: Icons.record_voice_over_outlined,
    ),
    AppBadge(
      id: 'thoughtful_responder',
      name: 'Thoughtful Responder',
      category: BadgeCategory.communication,
      description:
          'Responds with care, consideration, and attention to context rather than urgency.',
      icon: Icons.mark_chat_read_outlined,
    ),
    AppBadge(
      id: 'consent_forward',
      name: 'Consent-Forward',
      category: BadgeCategory.consent,
      description:
          'Regularly centers mutual consent and checks for ongoing comfort and alignment.',
      icon: Icons.handshake_outlined,
    ),
    AppBadge(
      id: 'compassionate_presence',
      name: 'Compassionate Presence',
      category: BadgeCategory.care,
      description:
          'Often experienced as emotionally caring, gentle, and considerate.',
      icon: Icons.volunteer_activism_outlined,
    ),
    AppBadge(
      id: 'keeps_commitments',
      name: 'Keeps Commitments',
      category: BadgeCategory.reliability,
      description: 'Generally follows through on plans and agreements.',
      icon: Icons.all_inclusive,
    ),
    AppBadge(
      id: 'open_to_feedback',
      name: 'Open to Feedback',
      category: BadgeCategory.growth,
      description:
          'Receives reflection with curiosity rather than defensiveness.',
      icon: Icons.psychology_outlined,
    ),
    AppBadge(
      id: 'supportive_member',
      name: 'Supportive Community Member',
      category: BadgeCategory.community,
      description:
          'Offers encouragement or perspective that benefits others.',
      icon: Icons.groups_outlined,
    ),
    AppBadge(
      id: 'new_to_app',
      name: 'New to the App',
      category: BadgeCategory.misc,
      description:
          'Recently joined the community and is still finding their footing.',
      icon: Icons.waving_hand_outlined,
    ),
  ];

  static AppBadge? byId(String id) {
    for (final b in badges) {
      if (b.id == id) return b;
    }
    return null;
  }
}
