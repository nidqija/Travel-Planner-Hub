import 'package:flutter/material.dart';
import '../models/social_community.dart';
import '../theme/app_theme.dart';

/// Interactive checkout & spot claiming modal for a Grouped Booking
class GroupBookingCheckoutSheet extends StatefulWidget {
  final CommunityGroupBooking booking;
  final String communityId;

  const GroupBookingCheckoutSheet({
    super.key,
    required this.booking,
    required this.communityId,
  });

  static Future<void> show(BuildContext context, CommunityGroupBooking booking, String communityId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupBookingCheckoutSheet(
        booking: booking,
        communityId: communityId,
      ),
    );
  }

  @override
  State<GroupBookingCheckoutSheet> createState() => _GroupBookingCheckoutSheetState();
}

class _GroupBookingCheckoutSheetState extends State<GroupBookingCheckoutSheet> {
  final _nameController = TextEditingController(text: 'Alex Mercer');
  final _emailController = TextEditingController(text: 'alex.mercer@aperture.ai');
  final _phoneController = TextEditingController(text: '+1 (555) 382-9014');
  final _specialRequestsController = TextEditingController();

  String _selectedRoomTier = 'Deluxe En-suite Room';
  bool _agreeToRules = true;
  bool _isProcessing = false;

  final List<String> _roomTiers = [
    'Deluxe En-suite Room',
    'Shared Twin Balcony Suite',
    'Poolside King Studio',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _submitBooking() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final success = SocialCommunityRepository.instance.bookSpotInGroupBooking(
      communityId: widget.communityId,
      bookingId: widget.booking.id,
      userName: name,
      userEmail: _emailController.text.trim(),
      userPhone: _phoneController.text.trim(),
      specialRequests: 'Room: $_selectedRoomTier. Note: ${_specialRequestsController.text.trim()}',
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      Navigator.pop(context);
      _showConfirmationDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not complete booking. Group may be full.')),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cinemaSlate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.cyberEmerald, width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.cyberEmerald, size: 26),
            SizedBox(width: 10),
            Text(
              'Spot Confirmed!',
              style: TextStyle(color: AppTheme.ghostIce, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have officially claimed your spot in "${widget.booking.title}"!',
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.midnightObsidian,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay: ${widget.booking.stayName}',
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dates: ${widget.booking.dates}',
                    style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Split: \$${widget.booking.pricePerPerson.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppTheme.cyberEmerald, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Booking Ref: ${widget.booking.bookingRef}',
                    style: const TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This reservation is automatically synced to your "Saved & Bookings" vault.',
              style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyberEmerald,
              foregroundColor: AppTheme.midnightObsidian,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final isAlreadyBooked = b.hasUserBooked;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.vapourIon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        b.communityName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.vapourIon,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      b.title,
                      style: const TextStyle(
                        color: AppTheme.ghostIce,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${b.stayName} • ${b.destination}',
                      style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.mutedPhosphor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scrollable Content
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Spots & Capacity Meter
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_alt_rounded, color: AppTheme.solarAmber, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${b.confirmedMembers.length} of ${b.totalSpots} spots claimed',
                                style: const TextStyle(
                                  color: AppTheme.ghostIce,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: b.spotsRemaining <= 2
                                  ? AppTheme.crimsonPulse.withValues(alpha: 0.2)
                                  : AppTheme.cyberEmerald.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${b.spotsRemaining} spots left',
                              style: TextStyle(
                                color: b.spotsRemaining <= 2 ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: b.fillPercentage,
                          backgroundColor: AppTheme.slateCard,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            b.spotsRemaining <= 2 ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: b.confirmedMembers.map((m) {
                          final isUser = m.contains('(You)');
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUser ? AppTheme.vapourIon.withValues(alpha: 0.25) : AppTheme.slateCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUser ? AppTheme.vapourIon : AppTheme.frameBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUser ? Icons.verified_user_rounded : Icons.check_circle_outline_rounded,
                                  size: 13,
                                  color: isUser ? AppTheme.vapourIon : AppTheme.cyberEmerald,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  m,
                                  style: TextStyle(
                                    color: isUser ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                                    fontSize: 11,
                                    fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
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
                const SizedBox(height: 14),

                // Pricing Summary Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Group Property Rate', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12)),
                          Text('\$${b.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Group Split Count', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12)),
                          Text('${b.totalSpots} members', style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(color: AppTheme.frameBorder, height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Price Per Person',
                            style: TextStyle(color: AppTheme.ghostIce, fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '\$${b.pricePerPerson.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.cyberEmerald,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Refundable Security Deposit Today', style: TextStyle(color: AppTheme.solarAmber, fontSize: 11.5)),
                          Text(
                            '\$${b.depositRequired.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppTheme.solarAmber, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Room Tier Preference
                const Text(
                  'SELECT ROOM TIER',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _roomTiers.map((tier) {
                    final isSel = tier == _selectedRoomTier;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () => setState(() => _selectedRoomTier = tier),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.slateCard : AppTheme.midnightObsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? AppTheme.vapourIon : AppTheme.frameBorder,
                              width: isSel ? 1.2 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSel ? AppTheme.vapourIon : AppTheme.mutedPhosphor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tier,
                                  style: TextStyle(
                                    color: isSel ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Included Group Amenities
                const Text(
                  'INCLUDED AMENITIES',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: b.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.frameBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, color: AppTheme.cyberEmerald, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            amenity,
                            style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Traveler Info
                const Text(
                  'YOUR DETAILS',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.midnightObsidian,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                          filled: true,
                          fillColor: AppTheme.midnightObsidian,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                          filled: true,
                          fillColor: AppTheme.midnightObsidian,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _specialRequestsController,
                  style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Special Requests / Dietary Notes (Optional)',
                    labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.midnightObsidian,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // Rule agreement
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agreeToRules,
                  onChanged: (val) => setState(() => _agreeToRules = val ?? true),
                  title: const Text(
                    'I agree to group etiquette and split payment schedule.',
                    style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                  ),
                  activeColor: AppTheme.vapourIon,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),

          // Bottom Action Button
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAlreadyBooked ? AppTheme.crimsonPulse : AppTheme.cyberEmerald,
                foregroundColor: AppTheme.midnightObsidian,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _agreeToRules && !_isProcessing
                  ? () {
                      if (isAlreadyBooked) {
                        // Release spot
                        SocialCommunityRepository.instance.bookSpotInGroupBooking(
                          communityId: widget.communityId,
                          bookingId: widget.booking.id,
                          userName: _nameController.text.trim(),
                          userEmail: _emailController.text.trim(),
                          userPhone: _phoneController.text.trim(),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Released your spot in group booking.')),
                        );
                      } else {
                        _submitBooking();
                      }
                    }
                  : null,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.midnightObsidian),
                    )
                  : Text(
                      isAlreadyBooked
                          ? 'Release My Spot'
                          : 'Confirm & Reserve Spot (\$${b.pricePerPerson.toStringAsFixed(0)})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Propose a new Grouped Booking Sheet
class CreateGroupBookingSheet extends StatefulWidget {
  final String communityId;
  final String destinationFocus;

  const CreateGroupBookingSheet({
    super.key,
    required this.communityId,
    required this.destinationFocus,
  });

  static Future<void> show(BuildContext context, String communityId, String destinationFocus) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateGroupBookingSheet(
        communityId: communityId,
        destinationFocus: destinationFocus,
      ),
    );
  }

  @override
  State<CreateGroupBookingSheet> createState() => _CreateGroupBookingSheetState();
}

class _CreateGroupBookingSheetState extends State<CreateGroupBookingSheet> {
  final _titleController = TextEditingController();
  final _stayController = TextEditingController();
  final _destController = TextEditingController();
  final _datesController = TextEditingController(text: 'Dec 10 – Dec 16, 2026');
  final _priceController = TextEditingController(text: '3200');
  final _spotsController = TextEditingController(text: '6');
  final _amenitiesController = TextEditingController(text: 'Private Pool, Fiber Internet, Daily Housekeeping');

  @override
  void initState() {
    super.initState();
    _destController.text = widget.destinationFocus.split(' ').first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _stayController.dispose();
    _destController.dispose();
    _datesController.dispose();
    _priceController.dispose();
    _spotsController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final stay = _stayController.text.trim();
    final dest = _destController.text.trim();
    final dates = _datesController.text.trim();
    final total = double.tryParse(_priceController.text.trim()) ?? 2400.0;
    final spots = int.tryParse(_spotsController.text.trim()) ?? 6;

    if (title.isEmpty || stay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out booking title and stay name.')),
      );
      return;
    }

    final amenities = _amenitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    SocialCommunityRepository.instance.createGroupBooking(
      communityId: widget.communityId,
      title: title,
      stayName: stay,
      destination: dest,
      dates: dates,
      totalPrice: total,
      totalSpots: spots,
      depositRequired: total / (spots * 4),
      amenities: amenities.isNotEmpty ? amenities : ['High Speed Wi-Fi', 'Group Kitchen'],
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cinemaSlate,
        content: Text('Launched grouped booking "$title"!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Launch Group Booking Pool',
              style: TextStyle(
                color: AppTheme.ghostIce,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Lock down an entire villa, suite block, or lodge and split the rate with members.',
              style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Group Booking Title',
                hintText: 'e.g. 6-Bedroom Oceanfront Villa Takeover',
                hintStyle: const TextStyle(color: AppTheme.frameBorder, fontSize: 12),
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stayController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Stay / Property Name',
                hintText: 'e.g. Villa Samadhi Canggu',
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _destController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _datesController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Dates',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Total Property Cost (\$)',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _spotsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Total Spots / Beds',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amenitiesController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Amenities (Comma separated)',
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vapourIon,
                  foregroundColor: AppTheme.midnightObsidian,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('Publish Group Booking', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Collaborative Trip Planning Modal Sheet
class PlanTripModalSheet extends StatefulWidget {
  final String communityId;
  final String defaultDestination;

  const PlanTripModalSheet({
    super.key,
    required this.communityId,
    required this.defaultDestination,
  });

  static Future<void> show(BuildContext context, String communityId, String defaultDestination) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanTripModalSheet(
        communityId: communityId,
        defaultDestination: defaultDestination,
      ),
    );
  }

  @override
  State<PlanTripModalSheet> createState() => _PlanTripModalSheetState();
}

class _PlanTripModalSheetState extends State<PlanTripModalSheet> {
  final _titleController = TextEditingController();
  final _destController = TextEditingController();
  final _datesController = TextEditingController(text: 'Nov 20 – Nov 28, 2026');
  final _budgetController = TextEditingController(text: '1200');
  final _firstActTitleController = TextEditingController(text: 'Group Welcome Sunset Gathering');
  final _firstActLocController = TextEditingController();
  final _pollQuestionController = TextEditingController(text: 'Which group experience should we vote on?');
  final _pollOption1 = TextEditingController(text: 'Private Local Guide & Food Tour');
  final _pollOption2 = TextEditingController(text: 'Scenic Mountain Bike / Hike Excursion');

  @override
  void initState() {
    super.initState();
    _destController.text = widget.defaultDestination;
    _firstActLocController.text = widget.defaultDestination.split(' ').first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destController.dispose();
    _datesController.dispose();
    _budgetController.dispose();
    _firstActTitleController.dispose();
    _firstActLocController.dispose();
    _pollQuestionController.dispose();
    _pollOption1.dispose();
    _pollOption2.dispose();
    super.dispose();
  }

  void _submitTrip() {
    final title = _titleController.text.trim();
    final dest = _destController.text.trim();
    if (title.isEmpty || dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a trip name and destination.')),
      );
      return;
    }

    final budget = double.tryParse(_budgetController.text.trim()) ?? 1000.0;

    SocialCommunityRepository.instance.createTripPlan(
      communityId: widget.communityId,
      title: title,
      destination: dest,
      dates: _datesController.text.trim(),
      targetBudget: budget,
      firstActivityTitle: _firstActTitleController.text.trim(),
      firstActivityLocation: _firstActLocController.text.trim(),
      pollQuestion: _pollQuestionController.text.trim(),
      pollOptions: [
        _pollOption1.text.trim(),
        _pollOption2.text.trim(),
      ],
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cinemaSlate,
        content: Text('Created collaborative trip "$title"!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.edit_calendar_rounded, color: AppTheme.solarAmber, size: 22),
                SizedBox(width: 8),
                Text(
                  'Co-Plan Community Trip',
                  style: TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Set up a collaborative itinerary with day-by-day stops and group voting polls.',
              style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Trip Title',
                hintText: 'e.g. Winter Snow & Onsen Tour \'26',
                hintStyle: const TextStyle(color: AppTheme.frameBorder, fontSize: 12),
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _destController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _datesController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Proposed Dates',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Target Budget Per Person (\$)',
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'INITIAL ITINERARY KICKOFF',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.solarAmber,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _firstActTitleController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Day 1 Activity Name',
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'GROUP VOTING POLL FOR MEMBERS',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.vapourIon,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pollQuestionController,
              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Poll Question',
                labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                filled: true,
                fillColor: AppTheme.midnightObsidian,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pollOption1,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12.5),
                    decoration: InputDecoration(
                      labelText: 'Option A',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _pollOption2,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12.5),
                    decoration: InputDecoration(
                      labelText: 'Option B',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11.5),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.solarAmber,
                  foregroundColor: AppTheme.midnightObsidian,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitTrip,
                child: const Text('Start Co-Planning Trip', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
