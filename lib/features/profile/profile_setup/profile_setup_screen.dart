import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/section_header.dart';

import '../controllers/profile_controller.dart';

import '../models/preference_item.dart';
import '../models/enums.dart';
import '../models/profile.dart';

import '../../../app/theme/app_colors.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEdit;
  const ProfileSetupScreen({super.key, required this.isEdit});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _pronounsCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  final Set<String> _orientations = {};
  final Set<String> _relationshipTags = {};
  final Set<String> _interests = {};
  final Set<String> _seeking = {};

  final Map<String, PreferenceIntensity> _preferences = {};
  bool _showPreferences = true;

  bool _initialized = false;

  static const orientations = [
    'Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Pansexual',
    'Queer',
    'Asexual',
    'Demisexual',
  ];

  static const relationshipContext = [
    'Polyamorous',
    'Open relationship',
    'ENM',
    'Solo poly',
    'Relationship anarchist',
    'Exploring',
  ];

  static const seekingOptions = [
    'Seeking partner',
    'Seeking friends',
    'Seeking playmate',
    'Seeking couples',
  ];

  // Keep this list small for v1. We can expand later.
  // No custom entries (locked).
  static const interestOptions = [
    'Coffee chats',
    'Hiking / outdoors',
    'Game nights',
    'Live music',
    'Art / museums',
    'Cooking',
    'Books',
    'Fitness',
    'Travel',
    'Kink-positive spaces',
    'Community events',
  ];

  static const preferenceOptions = [
    'Bondage / restraints',
    'Impact play',
    'Roleplay',
    'Voyeurism (watching)',
    'Being watched',
    'Group play',
    'Threesomes',
    'Orgies / parties',
    'D/s dynamics',
    'Praise / affirmation',
    'Degradation (consensual)',
    'Age play (consensual)',
    'Exhibitionism',
    'Asexual fetishism (general)',
    'Receiving oral',
    'Giving oral',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pronounsCtrl.dispose();
    _aboutCtrl.dispose();
    _ageCtrl.dispose();
    _locationCtrl.dispose();

    super.dispose();
  }

  void _initFromProfile(Profile me) {
    if (_initialized) return;
    _initialized = true;

    _nameCtrl.text = me.displayName;
    _pronounsCtrl.text = me.pronouns ?? '';
    _ageCtrl.text = me.age?.toString() ?? '';
    _locationCtrl.text = me.location ?? '';

    _orientations.addAll(me.sexualOrientations);
    _relationshipTags.addAll(me.relationshipContextTags);
    _seeking
      ..clear()
      ..addAll(me.seeking);

    _aboutCtrl.text = me.about ?? '';
    _interests.addAll(me.interests);
    _showPreferences = me.showPreferences;
    _preferences.clear();
    for (final p in me.preferences) {
      _preferences[p.label] = p.intensity;
    }
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  Future<void> _save() async {
    final controller = context.read<ProfileController>();

    final name = _nameCtrl.text.trim();
    final pronouns = _pronounsCtrl.text;
    final parsedAge = int.tryParse(_ageCtrl.text.trim());
    await controller.updateAge(parsedAge);
    await controller.updateLocation(_locationCtrl.text);
    await controller.setSeeking(_seeking.toList());

    await controller.updateDisplayName(name);
    await controller.updatePronouns(pronouns);
    await controller.updateAbout(_aboutCtrl.text);
    await controller.setSexualOrientations(_orientations.toList());
    await controller.setRelationshipContextTags(_relationshipTags.toList());
    await controller.setInterests(_interests.toList());
    await controller.setShowPreferences(_showPreferences);

    final prefs = _preferences.entries.map((e) {
      return PreferenceItem(
        id: e.key, // v1: label as id
        label: e.key,
        intensity: e.value,
        isVisible: true, // v1 default visible if selected
      );
    }).toList();

    await controller.setPreferences(prefs);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<ProfileController>().me;
    _initFromProfile(me);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit profile' : 'Set up your profile'),
        actions: [
          if (!widget.isEdit)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header / tone
          SectionHeader(
            title: widget.isEdit ? 'Your profile' : 'Welcome to Polycool',
            subtitle: widget.isEdit
                ? 'Update your profile anytime.'
                : 'You can change everything later. Start with the basics.',
          ),
          const SizedBox(height: 12),

          // Square photo card (locked square)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.person_outline, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your main photo is square. Add more anytime.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 110,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('My Photos coming next.'),
                          ),
                        );
                      },
                      child: const Text('My photos'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Basics
          const SectionHeader(title: 'Basics'),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    maxLength: 20,
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Display name *',
                      hintText: 'How you want to be seen',
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLength: 20,
                    controller: _pronounsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pronouns (optional)',
                      hintText: '(e.g., she/her, they/them)',
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          decoration: const InputDecoration(
                            labelText: 'Age (optional)',
                            counterText: '',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _locationCtrl,
                          maxLength: 40,
                          decoration: const InputDecoration(
                            labelText: 'Location (optional)',
                            hintText: 'City / area',
                            counterText: '',
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const SectionHeader(
            title: 'About me',
            subtitle:
                'A quick snapshot of who you are and what you’re looking for.',
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _aboutCtrl,
                maxLength: 500,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'About me (optional)',
                  hintText: 'What should someone know before messaging you?',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Relationship context
          const SectionHeader(title: 'Relationship context'),
          const SizedBox(height: 12),

          _ChipMultiSelectCard(
            options: relationshipContext,
            selected: _relationshipTags,
            onToggle: (v) => setState(() {
              _relationshipTags.contains(v)
                  ? _relationshipTags.remove(v)
                  : _relationshipTags.add(v);
            }),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Why are you here?',
            subtitle: 'Choose what you’re open to right now.',
          ),

          const SizedBox(height: 12),

          _ChipMultiSelectCard(
            options: seekingOptions,
            selected: _seeking,
            onToggle: (v) => setState(() {
              _seeking.contains(v) ? _seeking.remove(v) : _seeking.add(v);
            }),
          ),

          const SizedBox(height: 16),

          // Sexual orientation (locked list)
          const SectionHeader(
            title: 'Sexual orientation',
            subtitle:
                'Select what best describes who you’re attracted to. You can change this anytime.',
          ),
          const SizedBox(height: 12),

          _ChipMultiSelectCard(
            options: orientations,
            selected: _orientations,
            onToggle: (v) => setState(() {
              _orientations.contains(v)
                  ? _orientations.remove(v)
                  : _orientations.add(v);
            }),
          ),

          const SizedBox(height: 16),

          // Interests (no custom entry; empty not public)
          const SectionHeader(
            title: 'Interests',
            subtitle:
                'Pick a few things you’d enjoy sharing with others. (No custom entries in v1.)',
          ),
          const SizedBox(height: 12),

          _ChipMultiSelectCard(
            options: interestOptions,
            selected: _interests,
            onToggle: (v) => setState(() {
              _interests.contains(v) ? _interests.remove(v) : _interests.add(v);
            }),
          ),

          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Sexual preferences',
            subtitle:
                'Select what you’re into and how strongly you feel about it.',
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show this section on my profile'),
                    subtitle: const Text('Hidden if turned off or left empty.'),
                    value: _showPreferences,
                    onChanged: (v) => setState(() => _showPreferences = v),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: preferenceOptions.map((label) {
                      final selected = _preferences.containsKey(label);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FilterChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (on) {
                              setState(() {
                                if (on) {
                                  _preferences[label] =
                                      PreferenceIntensity.enjoys;
                                } else {
                                  _preferences.remove(label);
                                }
                              });
                            },
                          ),

                          // Intensity dropdown appears directly under selected preference
                          if (selected) ...[
                            const SizedBox(height: 6),
                            _PreferenceIntensityDropdown(
                              value: _preferences[label]!,
                              onChanged: (v) {
                                setState(() => _preferences[label] = v);
                              },
                            ),
                          ],
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'This section reflects preferences not obligations.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Save
          ElevatedButton(
            onPressed: _canSave ? _save : null,
            child: Text(widget.isEdit ? 'Save changes' : 'Continue'),
          ),

          const SizedBox(height: 10),
          Text(
            'Pronouns and interests won’t be shown publicly if left blank.',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _PreferenceIntensityDropdown extends StatelessWidget {
  final PreferenceIntensity value;
  final ValueChanged<PreferenceIntensity> onChanged;

  const _PreferenceIntensityDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<PreferenceIntensity>(
        value: value,
        isDense: true,
        borderRadius: BorderRadius.circular(12),
        items: const [
          DropdownMenuItem(
            value: PreferenceIntensity.curious,
            child: Text('Curious'),
          ),
          DropdownMenuItem(
            value: PreferenceIntensity.enjoys,
            child: Text('Enjoys'),
          ),
          DropdownMenuItem(
            value: PreferenceIntensity.deeplyEnjoys,
            child: Text('Deeply enjoys'),
          ),
          DropdownMenuItem(
            value: PreferenceIntensity.favorite,
            child: Text('Favorite'),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _ChipMultiSelectCard extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final void Function(String value) onToggle;

  const _ChipMultiSelectCard({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((o) {
            final isOn = selected.contains(o);
            return FilterChip(
              label: Text(o),
              selected: isOn,
              onSelected: (_) => onToggle(o),
            );
          }).toList(),
        ),
      ),
    );
  }
}
