import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/group_chat.dart';
import '../models/travel_booking.dart';
import '../models/video_item.dart';
import '../theme/app_theme.dart';

class GroupChatDetailPage extends StatefulWidget {
  final String chatId;

  const GroupChatDetailPage({
    super.key,
    required this.chatId,
  });

  @override
  State<GroupChatDetailPage> createState() => _GroupChatDetailPageState();
}

class _GroupChatDetailPageState extends State<GroupChatDetailPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final repo = GroupChatRepository.instance;
  int _selectedSection = 0; // 0 = Announcements & Debts, 1 = Squad Chat
  String _announcementFilter = 'all'; // 'all', 'pending', 'settled', 'notices'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      repo.markChatAsRead(widget.chatId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    repo.sendMessage(widget.chatId, text);
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  // -------------------------------------------------------------
  // WhatsApp-Style Action Menu (Bill Splitter, QR Pay, Ledger)
  // -------------------------------------------------------------
  void _showWhatsAppStyleAttachmentMenu(GroupChat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.2)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SQUAD TRAVEL TOOLS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    chat.destinationTag,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // WhatsApp-style 2-Row / 3-Column Attachment Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Split Bill',
                    gradientColors: [const Color(0xFF00E699), const Color(0xFF00B377)],
                    onTap: () {
                      Navigator.pop(context);
                      _showBillSplitDialog(chat);
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'QR Pay',
                    gradientColors: [const Color(0xFFF5A623), const Color(0xFFD48806)],
                    onTap: () {
                      Navigator.pop(context);
                      _showQrPaymentDialog(chat);
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Trip Ledger',
                    gradientColors: [const Color(0xFF5686F5), const Color(0xFF335CC4)],
                    onTap: () {
                      Navigator.pop(context);
                      _showTripLedgerSheet(chat);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.add_link_rounded,
                    label: 'Group Booking',
                    gradientColors: [const Color(0xFF00E5FF), const Color(0xFF0072FF)],
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateGroupBookingDialog(chat);
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.movie_filter_rounded,
                    label: 'FYP Reel',
                    gradientColors: [const Color(0xFFFF4757), const Color(0xFFD63031)],
                    onTap: () {
                      Navigator.pop(context);
                      repo.shareVideoToChat(
                        chat.id,
                        VideoItem.getSampleFeed().first,
                        comment: 'Check out this travel reel for our upcoming trip! 🎬✨',
                      );
                      _scrollToBottom();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.lightbulb_rounded,
                    label: 'AI Spark',
                    gradientColors: [const Color(0xFFB066FF), const Color(0xFF8833E6)],
                    onTap: () {
                      Navigator.pop(context);
                      repo.sendMessage(
                        chat.id,
                        '💡 AI Travel Spark: Recommended visiting Ubud Sacred Monkey canopy early morning for soft light!',
                      );
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.push_pin_rounded,
                    label: 'Pin Plan',
                    gradientColors: [const Color(0xFF00C9FF), const Color(0xFF92FE9D)],
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.cinemaSlate,
                          content: Text('Pinned to ${chat.title}: ${chat.pinnedItinerary}'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 54),
                  const SizedBox(width: 54),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: AppTheme.midnightObsidian, size: 26),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Interactive Bill Splitter Dialog
  // -------------------------------------------------------------
  void _showBillSplitDialog(GroupChat chat) {
    final titleController = TextEditingController(text: 'Seafood BBQ Dinner');
    final amountController = TextEditingController(text: '120.00');
    final selectedMembers = Set<String>.from(chat.memberNames);
    String paidBy = 'You';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalAmount = double.tryParse(amountController.text) ?? 0.0;
            final count = selectedMembers.isEmpty ? 1 : selectedMembers.length;
            final perPerson = totalAmount / count;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.cyberEmerald, width: 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppTheme.cyberEmerald, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Squad Bill Splitter',
                            style: TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Split expenses equally across travel squad',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.mutedPhosphor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bill Description
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Expense Name',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      hintText: 'e.g. Seafood BBQ, Villa, Grab Ride',
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Total Amount Input
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setModalState(() {}),
                    style: const TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(color: AppTheme.cyberEmerald, fontSize: 16, fontWeight: FontWeight.w800),
                      labelText: 'Total Bill Amount',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Paid By Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Paid By:',
                        style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                      ),
                      DropdownButton<String>(
                        value: paidBy,
                        dropdownColor: AppTheme.cinemaSlate,
                        style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13, fontWeight: FontWeight.w600),
                        underline: const SizedBox(),
                        items: chat.memberNames.map((name) {
                          return DropdownMenuItem(value: name, child: Text(name));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => paidBy = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.frameBorder, height: 16),

                  // Split Among Members Checkboxes
                  const Text(
                    'SPLIT EQUALLY AMONG:',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: chat.memberNames.map((m) {
                      final isSelected = selectedMembers.contains(m);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(m, style: TextStyle(fontSize: 11, color: isSelected ? AppTheme.midnightObsidian : AppTheme.ghostIce)),
                        selectedColor: AppTheme.cyberEmerald,
                        backgroundColor: AppTheme.midnightObsidian,
                        side: BorderSide(color: isSelected ? AppTheme.cyberEmerald : AppTheme.frameBorder),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              selectedMembers.add(m);
                            } else if (selectedMembers.length > 1) {
                              selectedMembers.remove(m);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Live Calculation Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EACH SQUAD MEMBER PAYS',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${selectedMembers.length} participants',
                              style: const TextStyle(color: AppTheme.ghostIce, fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          '\$${perPerson.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: AppTheme.cyberEmerald,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Post Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyberEmerald,
                        foregroundColor: AppTheme.midnightObsidian,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text(
                        'POST BILL SPLIT TO CHAT',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () {
                        final bill = BillSplitInfo(
                          title: titleController.text.trim().isEmpty ? 'Shared Expense' : titleController.text.trim(),
                          totalAmount: totalAmount,
                          currency: 'USD',
                          paidBy: paidBy,
                          splitAmongCount: selectedMembers.length,
                          amountPerPerson: perPerson,
                          participants: selectedMembers.toList(),
                          isSettled: false,
                        );

                        repo.sendBillSplit(chat.id, bill);
                        Navigator.pop(context);
                        _scrollToBottom();
                      },
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

  // -------------------------------------------------------------
  // Interactive QR Payment Generator / Settlement Dialog
  // -------------------------------------------------------------
  void _showQrPaymentDialog(
    GroupChat chat, {
    double? defaultAmount,
    String? defaultPayee,
    String? defaultNote,
    String? settlementAnnouncementId,
  }) {
    final amountController = TextEditingController(
      text: defaultAmount != null ? defaultAmount.toStringAsFixed(2) : '25.00',
    );
    final noteController = TextEditingController(
      text: defaultNote ?? 'Speedboat Nusa Penida',
    );
    String payee = defaultPayee ?? 'You';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final amt = double.tryParse(amountController.text) ?? 0.0;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.solarAmber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.solarAmber, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Squad QR Payment',
                            style: TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.midnightObsidian,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.frameBorder),
                        ),
                        child: const Text(
                          'DUITNOW / PEER PAY',
                          style: TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 9.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // High-Tech Stylized QR Code Graphic Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.solarAmber.withValues(alpha: 0.2),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CustomPaint(
                            painter: _StylizedQrPainter(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payee: $payee',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        Text(
                          '\$${amt.toStringAsFixed(2)} USD',
                          style: const TextStyle(fontFamily: 'monospace', color: Color(0xFFD48806), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Note & Amount Inputs
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: noteController,
                          style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'For',
                            labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                            filled: true,
                            fillColor: AppTheme.midnightObsidian,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setModalState(() {}),
                          style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: const TextStyle(color: AppTheme.solarAmber, fontSize: 13),
                            labelText: 'Amount',
                            labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                            filled: true,
                            fillColor: AppTheme.midnightObsidian,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions: Post to Chat & Instant Settle
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.ghostIce,
                            side: const BorderSide(color: AppTheme.frameBorder),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: const Text('Simulate Pay', style: TextStyle(fontSize: 11.5)),
                          onPressed: () {
                            if (settlementAnnouncementId != null) {
                              repo.toggleAnnouncementSettled(chat.id, settlementAnnouncementId);
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.cinemaSlate,
                                content: Text('Payment of \$${amt.toStringAsFixed(2)} to $payee settled via QR! Enquiry closed & checked.'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.solarAmber,
                            foregroundColor: AppTheme.midnightObsidian,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text(
                            'POST QR TO CHAT',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                          onPressed: () {
                            final qr = QrPaymentInfo(
                              payeeName: payee,
                              amount: amt,
                              currency: 'USD',
                              referenceNote: noteController.text.trim().isEmpty ? 'Trip Payment' : noteController.text.trim(),
                              qrPayload: 'aperture://pay/$payee?amt=$amt',
                              isPaid: false,
                            );

                            repo.sendQrPayment(chat.id, qr);
                            Navigator.pop(context);
                            _scrollToBottom();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Trip Ledger Sheet
  // -------------------------------------------------------------
  void _showTripLedgerSheet(GroupChat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trip Expense Ledger',
                    style: TextStyle(color: AppTheme.ghostIce, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chat.destinationTag,
                      style: const TextStyle(fontFamily: 'monospace', color: AppTheme.solarAmber, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.frameBorder),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL SPENT', style: TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 9)),
                          SizedBox(height: 2),
                          Text('\$345.00', style: TextStyle(color: AppTheme.ghostIce, fontSize: 16, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightObsidian,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.6)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR BALANCE', style: TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 9)),
                          SizedBox(height: 2),
                          Text('+\$35.00 (Owed)', style: TextStyle(color: AppTheme.cyberEmerald, fontSize: 15, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'MEMBER BALANCES',
                style: TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 10, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              ...chat.memberNames.map((m) {
                final isYou = m == 'You';
                final isOwed = m == 'You' || m == 'Alex Rivera';
                final balance = isYou ? '+\$35.00' : (m == 'Alex Rivera' ? '+\$60.00' : '-\$30.00');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.midnightObsidian,
                            child: Text(m[0], style: const TextStyle(fontSize: 10, color: AppTheme.ghostIce)),
                          ),
                          const SizedBox(width: 8),
                          Text(m, style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text(
                        balance,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isOwed ? AppTheme.cyberEmerald : AppTheme.crimsonPulse,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vapourIon,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text('SETTLE BALANCES VIA QR', style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, fontWeight: FontWeight.w800)),
                  onPressed: () {
                    Navigator.pop(context);
                    _showQrPaymentDialog(chat, defaultAmount: 30.0, defaultPayee: 'Alex Rivera', defaultNote: 'Settle Dinner Bill');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSquadMembers(GroupChat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.vapourIon, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Squad Members (${chat.memberNames.length})',
                    style: const TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: Text(
                      chat.destinationTag,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(chat.memberNames.length, (idx) {
                final name = chat.memberNames[idx];
                final color = chat.memberAvatarColors[idx % chat.memberAvatarColors.length];
                final role = idx == 0 ? 'Trip Admin' : (idx == 1 ? 'Navigator' : 'Explorer');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.midnightObsidian,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppTheme.ghostIce,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              role,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.midnightObsidian,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.frameBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: AppTheme.cyberEmerald, size: 7),
                            SizedBox(width: 5),
                            Text(
                              'Active',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: AppTheme.mutedPhosphor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final chat = repo.chats.firstWhere(
          (c) => c.id == widget.chatId,
          orElse: () => repo.chats.first,
        );

        final pendingDebtsCount = chat.announcements
            .where((a) => !a.isEnquiryClosed && (a.billSplit != null || a.qrPayment != null))
            .length;

        return Scaffold(
          backgroundColor: AppTheme.midnightObsidian,
          appBar: _buildAppBar(chat),
          body: Column(
            children: [
              // WhatsApp Community Sub-Section Channel Switcher
              _buildCommunityChannelSelector(chat),

              // Sub-Section Content: 0 = Announcements & Debts, 1 = Squad Chat
              Expanded(
                child: _selectedSection == 0
                    ? _buildAnnouncementsSection(chat)
                    : _buildSquadChatSection(chat, pendingDebtsCount),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Community Channel Selector (Announcements vs Squad Chat)
  // -------------------------------------------------------------
  Widget _buildCommunityChannelSelector(GroupChat chat) {
    final pendingCount = chat.announcements
        .where((a) => !a.isEnquiryClosed && (a.billSplit != null || a.qrPayment != null))
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.frameBorder),
      ),
      child: Row(
        children: [
          // Section 1: Announcements
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSection = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: _selectedSection == 0 ? AppTheme.midnightObsidian : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: _selectedSection == 0
                      ? Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.6))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      size: 14,
                      color: _selectedSection == 0 ? AppTheme.solarAmber : AppTheme.mutedPhosphor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Announcements',
                      style: TextStyle(
                        color: _selectedSection == 0 ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                        fontSize: 12,
                        fontWeight: _selectedSection == 0 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.solarAmber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: AppTheme.midnightObsidian,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Section 2: Squad Chat
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSection = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: _selectedSection == 1 ? AppTheme.midnightObsidian : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: _selectedSection == 1
                      ? Border.all(color: AppTheme.vapourIon.withValues(alpha: 0.6))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 13,
                      color: _selectedSection == 1 ? AppTheme.vapourIon : AppTheme.mutedPhosphor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Squad Chat',
                      style: TextStyle(
                        color: _selectedSection == 1 ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                        fontSize: 12,
                        fontWeight: _selectedSection == 1 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Section 1: Simplified Announcements & Debt Checklist
  // -------------------------------------------------------------
  Widget _buildAnnouncementsSection(GroupChat chat) {
    final allAnnouncements = chat.announcements;
    final pendingCount = allAnnouncements
        .where((a) => !a.isEnquiryClosed && (a.billSplit != null || a.qrPayment != null))
        .length;
    final settledCount = allAnnouncements
        .where((a) => a.isEnquiryClosed && (a.billSplit != null || a.qrPayment != null))
        .length;

    double pendingDebtsTotal = 0.0;
    for (final a in allAnnouncements) {
      if (!a.isEnquiryClosed) {
        if (a.billSplit != null) {
          pendingDebtsTotal += a.billSplit!.amountPerPerson;
        } else if (a.qrPayment != null) {
          pendingDebtsTotal += a.qrPayment!.amount;
        }
      }
    }

    final filtered = allAnnouncements.where((a) {
      if (_announcementFilter == 'pending') {
        return !a.isEnquiryClosed && (a.billSplit != null || a.qrPayment != null);
      }
      if (_announcementFilter == 'settled') {
        return a.isEnquiryClosed && (a.billSplit != null || a.qrPayment != null);
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Clean Minimal Header Strip: 1-line status + filter tabs
        Container(
          margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.frameBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    pendingCount > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    size: 15,
                    color: pendingCount > 0 ? AppTheme.solarAmber : AppTheme.cyberEmerald,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    pendingCount > 0
                        ? '$pendingCount pending • \$${pendingDebtsTotal.toStringAsFixed(2)}'
                        : 'All debts settled ✓',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: pendingCount > 0 ? AppTheme.solarAmber : AppTheme.cyberEmerald,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildFilterTab('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterTab('pending', 'Pending ($pendingCount)'),
                  const SizedBox(width: 8),
                  _buildFilterTab('settled', 'Settled ($settledCount)'),
                ],
              ),
            ],
          ),
        ),

        // Streamlined Cards List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyEnquiriesState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ann = filtered[index];
                    return _buildSimplifiedAnnouncementCard(chat, ann);
                  },
                ),
        ),

        // Simple Minimal Bottom Bar
        _buildSimplifiedBottomBar(chat),
      ],
    );
  }

  Widget _buildFilterTab(String key, String label) {
    final isSelected = _announcementFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _announcementFilter = key),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          color: isSelected ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          decoration: isSelected ? TextDecoration.underline : null,
          decorationColor: AppTheme.solarAmber,
        ),
      ),
    );
  }

  Widget _buildSimplifiedAnnouncementCard(GroupChat chat, SquadAnnouncement ann) {
    // 0. Group Booking Link (Members book individually via link)
    if (ann.groupBooking != null) {
      return _buildAnnouncementGroupBookingCard(chat, ann);
    }

    final isClosed = ann.isEnquiryClosed;
    final isBillSplit = ann.billSplit != null;
    final isQrPay = ann.qrPayment != null;
    final isDebt = isBillSplit || isQrPay;
    final double amount = ann.billSplit?.amountPerPerson ?? ann.qrPayment?.amount ?? 0.0;

    // 1. Pinned Notice (clean single-surface text card)
    if (!isDebt) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cinemaSlate,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.frameBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10, top: 2),
              child: Icon(Icons.push_pin_rounded, color: AppTheme.solarAmber, size: 15),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ann.title,
                    style: const TextStyle(
                      color: AppTheme.ghostIce,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ann.content,
                    style: const TextStyle(
                      color: AppTheme.mutedPhosphor,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ann.author} • ${_formatTimeAgo(ann.timestamp)}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.mutedPhosphor.withValues(alpha: 0.6),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Bill Split or QR Debt (clean checklist row)
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isClosed ? AppTheme.slateCard.withValues(alpha: 0.3) : AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isClosed ? AppTheme.frameBorder.withValues(alpha: 0.5) : AppTheme.solarAmber.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox toggle
          InkWell(
            onTap: () => repo.toggleAnnouncementSettled(chat.id, ann.id),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                isClosed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: isClosed ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
              ),
            ),
          ),

          // Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ann.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isClosed ? AppTheme.mutedPhosphor : AppTheme.ghostIce,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isClosed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isClosed
                      ? 'Settled by ${ann.closedBy ?? 'You'} • ${_formatTimeAgo(ann.closedAt ?? ann.timestamp)}'
                      : 'By ${ann.author} • \$${amount.toStringAsFixed(2)} / pax',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right action: Pay button if pending, or Paid checkmark if closed
          if (isClosed)
            const Text(
              'Paid ✓',
              style: TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.cyberEmerald,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.solarAmber,
                foregroundColor: AppTheme.midnightObsidian,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                minimumSize: const Size(0, 28),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () => _handleSettleEnquiry(chat, ann),
              child: Text(
                'Pay \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementGroupBookingCard(GroupChat chat, SquadAnnouncement ann) {
    final booking = ann.groupBooking!;
    final isUserBooked = booking.isBookedBy('You');
    final isFull = booking.isFull;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cinemaSlate,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUserBooked
              ? AppTheme.cyberEmerald.withValues(alpha: 0.6)
              : AppTheme.solarAmber.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tag & Ref
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_link_rounded,
                    color: isUserBooked ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GROUP BOOKING LINK',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isUserBooked ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Text(
                  booking.bookingRef,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Property title & dates
          Text(
            booking.hotelOrStayName,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${booking.destination} • ${booking.dates}',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.mutedPhosphor,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 10),

          // Price & Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)} / person',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isUserBooked ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                isFull
                    ? 'All ${booking.totalSpots} spots locked ✓'
                    : '${booking.bookedMembers.length} of ${booking.totalSpots} booked individually',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isFull ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Occupancy progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (booking.bookedMembers.length / booking.totalSpots).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppTheme.midnightObsidian,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? AppTheme.cyberEmerald : AppTheme.solarAmber,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Member spots checklist chips
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: booking.allMembers.map((member) {
              final booked = booking.isBookedBy(member);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: booked
                      ? AppTheme.cyberEmerald.withValues(alpha: 0.12)
                      : AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: booked
                        ? AppTheme.cyberEmerald.withValues(alpha: 0.4)
                        : AppTheme.frameBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      booked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 11,
                      color: booked ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      member,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: booked ? AppTheme.ghostIce : AppTheme.mutedPhosphor,
                        fontSize: 9.5,
                        fontWeight: booked ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Action row: Book My Spot button + Copy Link
          Row(
            children: [
              Expanded(
                child: isUserBooked
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.4)),
                        ),
                        child: const Center(
                          child: Text(
                            '✓ Your Spot is Booked & Confirmed',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.cyberEmerald,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.solarAmber,
                          foregroundColor: AppTheme.midnightObsidian,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 15),
                        label: Text(
                          'Book My Spot (${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: isFull
                            ? null
                            : () => _showIndividualBookingCheckoutSheet(chat, booking),
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: const EdgeInsets.all(8),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.midnightObsidian,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppTheme.frameBorder),
                  ),
                ),
                icon: const Icon(Icons.copy_rounded, size: 15, color: AppTheme.ghostIce),
                tooltip: 'Copy Group Booking Link',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.cinemaSlate,
                      content: Text('Group booking link copied: ${booking.shareableUrl}'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEnquiriesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline_rounded, color: AppTheme.cyberEmerald, size: 28),
            SizedBox(height: 8),
            Text(
              'No pending items',
              style: TextStyle(color: AppTheme.ghostIce, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2),
            Text(
              'All squad debts and notices are cleared.',
              style: TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedBottomBar(GroupChat chat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        border: Border(top: BorderSide(color: AppTheme.frameBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.ghostIce,
              side: const BorderSide(color: AppTheme.frameBorder),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_rounded, size: 16, color: AppTheme.solarAmber),
            label: const Text(
              'Add Notice or Bill',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _showAddOptionsSheet(chat),
          ),
        ),
      ),
    );
  }

  void _showAddOptionsSheet(GroupChat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppTheme.frameBorder)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                dense: true,
                leading: const Icon(Icons.receipt_long_rounded, color: AppTheme.cyberEmerald),
                title: const Text('Split a Bill', style: TextStyle(color: AppTheme.ghostIce, fontWeight: FontWeight.w600)),
                subtitle: const Text('Split group expenses equally', style: TextStyle(fontSize: 11, color: AppTheme.mutedPhosphor)),
                onTap: () {
                  Navigator.pop(context);
                  _showBillSplitDialog(chat);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.qr_code_2_rounded, color: AppTheme.solarAmber),
                title: const Text('Request via QR Pay', style: TextStyle(color: AppTheme.ghostIce, fontWeight: FontWeight.w600)),
                subtitle: const Text('Post direct QR payment enquiry', style: TextStyle(fontSize: 11, color: AppTheme.mutedPhosphor)),
                onTap: () {
                  Navigator.pop(context);
                  _showQrPaymentDialog(chat);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.campaign_rounded, color: AppTheme.vapourIon),
                title: const Text('Post Pinned Notice', style: TextStyle(color: AppTheme.ghostIce, fontWeight: FontWeight.w600)),
                subtitle: const Text('Add official itinerary bulletin or info', style: TextStyle(fontSize: 11, color: AppTheme.mutedPhosphor)),
                onTap: () {
                  Navigator.pop(context);
                  _showPostNoticeDialog(chat);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.add_link_rounded, color: AppTheme.cyberEmerald),
                title: const Text('Create Group Booking Link', style: TextStyle(color: AppTheme.ghostIce, fontWeight: FontWeight.w600)),
                subtitle: const Text('Generate link for members to book individually', style: TextStyle(fontSize: 11, color: AppTheme.mutedPhosphor)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateGroupBookingDialog(chat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSettleEnquiry(GroupChat chat, SquadAnnouncement ann) {
    if (ann.qrPayment != null) {
      _showQrPaymentDialog(
        chat,
        defaultAmount: ann.qrPayment!.amount,
        defaultPayee: ann.qrPayment!.payeeName,
        defaultNote: ann.qrPayment!.referenceNote,
        settlementAnnouncementId: ann.id,
      );
    } else if (ann.billSplit != null) {
      _showQrPaymentDialog(
        chat,
        defaultAmount: ann.billSplit!.amountPerPerson,
        defaultPayee: ann.billSplit!.paidBy,
        defaultNote: 'Settlement for ${ann.billSplit!.title}',
        settlementAnnouncementId: ann.id,
      );
    }
  }

  void _showPostNoticeDialog(GroupChat chat) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Post Squad Announcement',
                style: TextStyle(color: AppTheme.ghostIce, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add an official announcement to the community board',
                style: TextStyle(fontFamily: 'monospace', color: AppTheme.mutedPhosphor, fontSize: 10),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Notice Title',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Announcement Details / Instructions',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.solarAmber,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final t = titleController.text.trim();
                    final c = contentController.text.trim();
                    if (t.isEmpty) return;
                    repo.addAnnouncement(
                      chat.id,
                      SquadAnnouncement(
                        id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
                        title: t,
                        content: c.isEmpty ? 'Official squad announcement.' : c,
                        author: 'You',
                        authorRole: 'Squad Lead',
                        timestamp: DateTime.now(),
                        isPinned: true,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'PUBLISH ANNOUNCEMENT',
                    style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Section 2: Main Squad Conversational Chat
  // -------------------------------------------------------------
  Widget _buildSquadChatSection(GroupChat chat, int pendingDebtsCount) {
    return Column(
      children: [
        // Pinned Itinerary Banner
        if (chat.pinnedItinerary != null) _buildPinnedItinerary(chat),

        // Quick Notice Pill if pending debts exist in Announcements
        if (pendingDebtsCount > 0)
          GestureDetector(
            onTap: () => setState(() => _selectedSection = 0),
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 6, 14, 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.solarAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign_rounded, color: AppTheme.solarAmber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$pendingDebtsCount debt payment enquiry waiting in Announcements',
                      style: const TextStyle(
                        color: AppTheme.solarAmber,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Text(
                    'View Board ➔',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Message Thread List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chat.messages.length && chat.isTyping) {
                return _buildTypingIndicator(chat.typingUser ?? 'Someone');
              }
              final msg = chat.messages[index];
              return _buildMessageBubble(chat, msg);
            },
          ),
        ),

        // WhatsApp-style Input Bar with Attachment Menu
        _buildInputBar(chat),
      ],
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  PreferredSizeWidget _buildAppBar(GroupChat chat) {
    return AppBar(
      backgroundColor: AppTheme.cinemaSlate,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.ghostIce, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [chat.memberAvatarColors.first, chat.memberAvatarColors.last],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppTheme.vapourIon, width: 1.5),
            ),
            child: Center(
              child: Text(
                chat.title[0],
                style: const TextStyle(
                  color: AppTheme.midnightObsidian,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.solarAmber, size: 11),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${chat.destination} • ${chat.memberNames.length} squad members',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppTheme.mutedPhosphor,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.cyberEmerald, size: 20),
          tooltip: 'Trip Ledger',
          onPressed: () => _showTripLedgerSheet(chat),
        ),
        IconButton(
          icon: const Icon(Icons.group_rounded, color: AppTheme.vapourIon, size: 20),
          tooltip: 'Squad Members',
          onPressed: () => _showSquadMembers(chat),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppTheme.frameBorder,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildPinnedItinerary(GroupChat chat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.slateCard.withValues(alpha: 0.7),
        border: const Border(
          bottom: BorderSide(color: AppTheme.frameBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.solarAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.push_pin_rounded, color: AppTheme.solarAmber, size: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PINNED SQUAD PLAN',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.solarAmber,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  chat.pinnedItinerary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.cinemaSlate,
                  content: Text('Viewing pinned itinerary: ${chat.pinnedItinerary}'),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.midnightObsidian,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.frameBorder),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: AppTheme.vapourIon,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(GroupChat chat, ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.slateCard,
              child: Text(
                msg.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.ghostIce,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!msg.isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3, left: 2),
                    child: Text(
                      msg.senderName,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Main Message Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isMe ? AppTheme.vapourIon : AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                    ),
                    border: Border.all(
                      color: msg.isMe ? AppTheme.vapourIon : AppTheme.frameBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Render Group Booking Card if present
                      if (msg.groupBooking != null) ...[
                        _buildGroupBookingAttachment(chat, msg),
                        const SizedBox(height: 8),
                      ],

                      // Render Bill Split Card if present
                      if (msg.billSplit != null) ...[
                        _buildBillSplitAttachment(chat, msg),
                        const SizedBox(height: 8),
                      ],

                      // Render QR Payment Card if present
                      if (msg.qrPayment != null) ...[
                        _buildQrPaymentAttachment(chat, msg),
                        const SizedBox(height: 8),
                      ],

                      // Shared Video Card Attachment if present
                      if (msg.sharedVideoTitle != null) ...[
                        _buildSharedVideoAttachment(msg),
                        const SizedBox(height: 8),
                      ],

                      Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isMe ? AppTheme.midnightObsidian : AppTheme.ghostIce,
                          fontSize: 13.5,
                          fontWeight: msg.isMe ? FontWeight.w600 : FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(msg.timestamp),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.6),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          if (msg.isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.vapourIon,
              child: Text(
                'Y',
                style: TextStyle(
                  color: AppTheme.midnightObsidian,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // In-Chat Group Booking Card
  // -------------------------------------------------------------
  Widget _buildGroupBookingAttachment(GroupChat chat, ChatMessage msg) {
    final booking = msg.groupBooking!;
    final isUserBooked = booking.isBookedBy('You');
    final isFull = booking.isFull;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUserBooked
              ? AppTheme.cyberEmerald.withValues(alpha: 0.6)
              : AppTheme.solarAmber.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_link_rounded,
                    color: isUserBooked ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GROUP BOOKING INVITATION',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isUserBooked ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.cinemaSlate,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking.bookingRef,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            booking.hotelOrStayName,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${booking.destination} • ${booking.dates}',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.mutedPhosphor,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Individual Rate', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 9.5)),
                    Text(
                      '${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)} / pax',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isUserBooked ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Squad Progress', style: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 9.5)),
                    Text(
                      '${booking.bookedMembers.length}/${booking.totalSpots} booked',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: isFull ? AppTheme.cyberEmerald : AppTheme.ghostIce,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Member progress chips
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: booking.allMembers.map((member) {
              final booked = booking.isBookedBy(member);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: booked ? AppTheme.cyberEmerald.withValues(alpha: 0.12) : AppTheme.cinemaSlate,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: booked ? AppTheme.cyberEmerald.withValues(alpha: 0.4) : AppTheme.frameBorder,
                  ),
                ),
                child: Text(
                  '$member ${booked ? '✓' : '⏳'}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: booked ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
                    fontSize: 9,
                    fontWeight: booked ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Action button
          Row(
            children: [
              Expanded(
                child: isUserBooked
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.3)),
                        ),
                        child: const Center(
                          child: Text(
                            '✓ Spot Booked',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.cyberEmerald,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.solarAmber,
                          foregroundColor: AppTheme.midnightObsidian,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: isFull
                            ? null
                            : () => _showIndividualBookingCheckoutSheet(chat, booking),
                        child: Text(
                          '⚡ Book My Spot (${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.cinemaSlate,
                      content: Text('Link copied: ${booking.shareableUrl}'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.cinemaSlate,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: const Icon(Icons.copy_rounded, size: 15, color: AppTheme.ghostIce),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateGroupBookingDialog(GroupChat chat) {
    final titleController = TextEditingController(text: '${chat.destinationTag.replaceAll(RegExp(r'[^\w\s]'), '').trim()} Villa Stay');
    final hotelController = TextEditingController(text: 'Kinetic Eco-Resort & Spa');
    final datesController = TextEditingController(text: 'Nov 12 – Nov 15, 2026 (3 nights)');
    final priceController = TextEditingController(text: '210.00');
    int spots = chat.memberNames.length > 1 ? chat.memberNames.length : 4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: AppTheme.cinemaSlate,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.solarAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_link_rounded, color: AppTheme.solarAmber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Group Booking Link',
                            style: TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Squad members use link to book individually',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.mutedPhosphor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hotel / Stay Name
                  TextField(
                    controller: hotelController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Property / Hotel Name',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dates
                  TextField(
                    controller: datesController,
                    style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Travel Dates',
                      labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                      filled: true,
                      fillColor: AppTheme.midnightObsidian,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.frameBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Price per person
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppTheme.solarAmber, fontSize: 14, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            labelText: 'Price / Person (\$)',
                            labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                            prefixText: '\$ ',
                            prefixStyle: const TextStyle(color: AppTheme.solarAmber),
                            filled: true,
                            fillColor: AppTheme.midnightObsidian,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppTheme.frameBorder),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Spots count
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.midnightObsidian,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.frameBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL SPOTS',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.mutedPhosphor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_rounded, size: 15),
                                    color: spots > 2 ? AppTheme.ghostIce : AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                                    onPressed: spots > 2 ? () => setModalState(() => spots--) : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  ),
                                  Text(
                                    '$spots',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: AppTheme.ghostIce,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded, size: 15),
                                    color: spots < 16 ? AppTheme.ghostIce : AppTheme.mutedPhosphor.withValues(alpha: 0.4),
                                    onPressed: spots < 16 ? () => setModalState(() => spots++) : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.solarAmber,
                        foregroundColor: AppTheme.midnightObsidian,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_link_rounded, size: 16),
                      label: const Text(
                        'POST GROUP BOOKING LINK TO SQUAD',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: () {
                        final price = double.tryParse(priceController.text) ?? 210.0;
                        final cleanTag = chat.destinationTag.replaceAll(RegExp(r'[^\w]'), '');
                        final prefix = cleanTag.length >= 3 ? cleanTag.substring(0, 3).toUpperCase() : 'GRP';
                        final randomRef = '#GRP-$prefix-${1000 + math.Random().nextInt(9000)}';

                        final info = GroupBookingLinkInfo(
                          id: 'gbl-${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text.trim().isEmpty ? 'Squad Group Booking' : titleController.text.trim(),
                          hotelOrStayName: hotelController.text.trim().isEmpty ? 'Squad Villa & Resort' : hotelController.text.trim(),
                          destination: chat.destination,
                          dates: datesController.text.trim().isEmpty ? 'Upcoming Dates' : datesController.text.trim(),
                          pricePerPerson: price,
                          currency: 'USD',
                          totalSpots: spots,
                          bookedMembers: const [],
                          allMembers: chat.memberNames,
                          bookingRef: randomRef,
                          shareableUrl: 'https://aperture.travel/grp/${randomRef.replaceAll('#', '').toLowerCase()}',
                          createdBy: 'You',
                          createdAt: DateTime.now(),
                        );

                        repo.createGroupBookingLink(chat.id, info);
                        Navigator.pop(context);
                        _scrollToBottom();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.cinemaSlate,
                            content: Text('Group booking link posted to ${chat.title}!'),
                          ),
                        );
                      },
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

  void _showIndividualBookingCheckoutSheet(GroupChat chat, GroupBookingLinkInfo booking) {
    final nameController = TextEditingController(text: 'Alex Mercer');
    final passportController = TextEditingController(text: 'P89421054');
    final emailController = TextEditingController(text: 'alex.mercer@aperture.ai');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppTheme.cinemaSlate,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.solarAmber, width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mutedPhosphor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.solarAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_pin_rounded, color: AppTheme.solarAmber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Individual Spot Checkout',
                            style: TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Book & pay for your own spot in this group',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.mutedPhosphor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightObsidian,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.frameBorder),
                    ),
                    child: Text(
                      booking.bookingRef,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Property summary
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hotel_class_rounded, color: AppTheme.vapourIon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.hotelOrStayName,
                            style: const TextStyle(
                              color: AppTheme.ghostIce,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${booking.destination} • ${booking.dates}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.mutedPhosphor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Traveler Name
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Traveler Name',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                  prefixIcon: const Icon(Icons.badge_rounded, color: AppTheme.vapourIon, size: 16),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.frameBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
              ),
              const SizedBox(height: 8),

              // Passport
              TextField(
                controller: passportController,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Passport Number',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: AppTheme.vapourIon, size: 16),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.frameBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
              ),
              const SizedBox(height: 8),

              // Email
              TextField(
                controller: emailController,
                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Confirmation Email',
                  labelStyle: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.vapourIon, size: 16),
                  filled: true,
                  fillColor: AppTheme.midnightObsidian,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.frameBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
              ),
              const SizedBox(height: 12),

              // Cost summary
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Individual Share:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${booking.currency}${booking.pricePerPerson.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.solarAmber,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: Text(
                    'CONFIRM MY SPOT (${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)})',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: () {
                    final guestName = nameController.text.trim().isNotEmpty ? nameController.text.trim() : 'Alex Mercer';
                    final passport = passportController.text.trim().isNotEmpty ? passportController.text.trim() : 'P89421054';
                    final email = emailController.text.trim().isNotEmpty ? emailController.text.trim() : 'alex.mercer@aperture.ai';

                    // 1. Mark booked in squad
                    repo.bookIndividualSpot(chat.id, booking.id, 'You');

                    // 2. Add to user's personal travel bookings manager
                    final personalBooking = TravelBooking(
                      id: 'bk-grp-${DateTime.now().millisecondsSinceEpoch}',
                      destinationTitle: '${booking.destination} (Group Trip)',
                      hotelName: booking.hotelOrStayName,
                      roomType: 'Individual Squad Slot',
                      dates: booking.dates,
                      bookingRef: '${booking.bookingRef}-YOU',
                      totalPrice: '${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)}',
                      status: 'CONFIRMED',
                      statusColor: AppTheme.cyberEmerald,
                      guestName: guestName,
                      guestPassport: passport,
                      guestNationality: 'United States',
                      guestEmail: email,
                      guestPhone: '+1 (555) 382-9014',
                      specialRequests: 'Linked to Squad Master Reservation ${booking.bookingRef}',
                      createdAt: DateTime.now(),
                      guestCount: 1,
                      isGroupTrip: true,
                      groupMembers: booking.allMembers,
                      perPersonPrice: '${booking.currency}${booking.pricePerPerson.toStringAsFixed(0)} / person',
                    );
                    TravelBookingsManager.instance.addBooking(personalBooking);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.cinemaSlate,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.cyberEmerald, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Spot confirmed for ${booking.hotelOrStayName}! Ref: ${booking.bookingRef}',
                                style: const TextStyle(color: AppTheme.ghostIce, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // In-Chat Bill Split Card
  // -------------------------------------------------------------
  Widget _buildBillSplitAttachment(GroupChat chat, ChatMessage msg) {
    final bill = msg.billSplit!;
    final isSettled = bill.isSettled;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppTheme.cyberEmerald, size: 15),
                  const SizedBox(width: 6),
                  const Text(
                    'EXPENSE SPLIT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.cyberEmerald,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSettled ? AppTheme.cyberEmerald.withValues(alpha: 0.2) : AppTheme.solarAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isSettled ? 'SETTLED' : 'ACTIVE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isSettled ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bill.title,
            style: const TextStyle(
              color: AppTheme.ghostIce,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Paid by ${bill.paidBy} • Total \$${bill.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.mutedPhosphor,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 8),

          // Split summary chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Share (${bill.splitAmongCount} pax):',
                  style: const TextStyle(color: AppTheme.mutedPhosphor, fontSize: 11),
                ),
                Text(
                  '\$${bill.amountPerPerson.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.cyberEmerald,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick Action: Pay via QR
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyberEmerald,
                    foregroundColor: AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 14),
                  label: Text(
                    'PAY \$${bill.amountPerPerson.toStringAsFixed(2)} VIA QR',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    _showQrPaymentDialog(
                      chat,
                      defaultAmount: bill.amountPerPerson,
                      defaultPayee: bill.paidBy,
                      defaultNote: 'Share for ${bill.title}',
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => repo.toggleBillSettled(chat.id, msg.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: Icon(
                    isSettled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: isSettled ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(() => _selectedSection = 0),
            child: Row(
              children: const [
                Icon(Icons.campaign_rounded, color: AppTheme.solarAmber, size: 12),
                SizedBox(width: 4),
                Text(
                  'Tracked in Announcements & Debts ➔',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.solarAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // In-Chat QR Payment Card
  // -------------------------------------------------------------
  Widget _buildQrPaymentAttachment(GroupChat chat, ChatMessage msg) {
    final qr = msg.qrPayment!;
    final isPaid = qr.isPaid;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPaid ? AppTheme.cyberEmerald.withValues(alpha: 0.5) : AppTheme.solarAmber.withValues(alpha: 0.7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: AppTheme.solarAmber, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'QR PAYMENT REQUEST',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: AppTheme.solarAmber,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid ? AppTheme.cyberEmerald.withValues(alpha: 0.2) : AppTheme.solarAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'PENDING',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: isPaid ? AppTheme.cyberEmerald : AppTheme.solarAmber,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Mini QR Preview Graphic
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: _StylizedQrPainter(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${qr.amount.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.ghostIce,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Pay to ${qr.payeeName} • ${qr.referenceNote}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.mutedPhosphor,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaid ? AppTheme.cinemaSlate : AppTheme.solarAmber,
                    foregroundColor: isPaid ? AppTheme.cyberEmerald : AppTheme.midnightObsidian,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: Icon(isPaid ? Icons.check_circle_rounded : Icons.qr_code_2_rounded, size: 14),
                  label: Text(
                    isPaid ? 'PAYMENT CONFIRMED' : 'SCAN & PAY QR',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    _showQrPaymentDialog(
                      chat,
                      defaultAmount: qr.amount,
                      defaultPayee: qr.payeeName,
                      defaultNote: qr.referenceNote,
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => repo.toggleQrPaid(chat.id, msg.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.midnightObsidian,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.frameBorder),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: isPaid ? AppTheme.cyberEmerald : AppTheme.mutedPhosphor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(() => _selectedSection = 0),
            child: Row(
              children: const [
                Icon(Icons.campaign_rounded, color: AppTheme.solarAmber, size: 12),
                SizedBox(width: 4),
                Text(
                  'Tracked in Announcements & Debts ➔',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.solarAmber,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedVideoAttachment(ChatMessage msg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.midnightObsidian.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.solarAmber.withValues(alpha: 0.6)),
            ),
            child: const Center(
              child: Icon(Icons.play_arrow_rounded, color: AppTheme.solarAmber, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.movie_filter_rounded, color: AppTheme.solarAmber, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'FYP TRAVEL REEL',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.solarAmber,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  msg.sharedVideoTitle ?? 'Shared Video',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ghostIce,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  msg.sharedVideoCreator ?? '@creator',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(String user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const SizedBox(width: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cinemaSlate,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.frameBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$user is typing',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: AppTheme.mutedPhosphor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                const SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.vapourIon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // WhatsApp-Style Input Bar with + Button
  // -------------------------------------------------------------
  Widget _buildInputBar(GroupChat chat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
      decoration: const BoxDecoration(
        color: AppTheme.cinemaSlate,
        border: Border(top: BorderSide(color: AppTheme.frameBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // WhatsApp-style '+' attachment action
            GestureDetector(
              onTap: () => _showWhatsAppStyleAttachmentMenu(chat),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: AppTheme.vapourIon, size: 22),
              ),
            ),
            const SizedBox(width: 6),

            // Quick Split Bill Button on Input Bar
            GestureDetector(
              onTap: () => _showBillSplitDialog(chat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cyberEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cyberEmerald.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_rounded, color: AppTheme.cyberEmerald, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Split',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppTheme.cyberEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Text Input Box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.midnightObsidian,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.frameBorder),
                ),
                child: TextField(
                  controller: _textController,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(color: AppTheme.ghostIce, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Message squad or split bill...',
                    hintStyle: TextStyle(color: AppTheme.mutedPhosphor, fontSize: 12.5),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Send Button
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppTheme.vapourIon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: AppTheme.midnightObsidian, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// -------------------------------------------------------------
// Stylized QR Code Painter (High-Tech Matrix Graphic)
// -------------------------------------------------------------
class _StylizedQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF161C24);
    final paintAccent = Paint()..color = const Color(0xFFD48806);

    const int gridSize = 15;
    final double step = size.width / gridSize;

    // Corner Finder Patterns
    void drawCorner(double ox, double oy) {
      // Outer box (3x3)
      canvas.drawRect(Rect.fromLTWH(ox, oy, step * 4, step * 4), paintDark);
      // Inner hollow
      canvas.drawRect(Rect.fromLTWH(ox + step * 0.7, oy + step * 0.7, step * 2.6, step * 2.6), Paint()..color = Colors.white);
      // Center dot
      canvas.drawRect(Rect.fromLTWH(ox + step * 1.3, oy + step * 1.3, step * 1.4, step * 1.4), paintAccent);
    }

    drawCorner(0, 0); // Top-left
    drawCorner(size.width - step * 4, 0); // Top-right
    drawCorner(0, size.height - step * 4); // Bottom-left

    // Deterministic pseudo-random pattern for inner matrix
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Skip corner finder zones
        if ((r < 5 && c < 5) || (r < 5 && c >= gridSize - 5) || (r >= gridSize - 5 && c < 5)) {
          continue;
        }
        if ((r * 7 + c * 13 + (r % 3)) % 2 == 0) {
          final isAccent = (r + c) % 5 == 0;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * step + 0.5, r * step + 0.5, step - 1, step - 1),
              const Radius.circular(1),
            ),
            isAccent ? paintAccent : paintDark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
