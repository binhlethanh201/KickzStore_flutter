import 'package:flutter/material.dart';
import '../../../../data/services/admin_service.dart';
import '../../../widgets/uniqlo_widgets.dart';

class AdminVouchersScreen extends StatefulWidget {
  const AdminVouchersScreen({super.key});

  @override
  State<AdminVouchersScreen> createState() => _AdminVouchersScreenState();
}

class _AdminVouchersScreenState extends State<AdminVouchersScreen> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Tông nền trắng sạch sẽ
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "VOUCHERS MANAGEMENT",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () => _showVoucherForm(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _adminService.getAllVouchers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No vouchers available.", style: TextStyle(color: Colors.grey)));
          }

          final vouchers = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final v = vouchers[index];
              return _buildVoucherCard(v);
            },
          );
        },
      ),
    );
  }

  Widget _buildVoucherCard(dynamic v) {
    bool isPercent = v['discountType'] == 'percent';
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 25),
            color: Colors.black, // Tông đen mạnh mẽ
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPercent ? "${v['discountValue']}%" : "\$${v['discountValue']}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const Text("OFF", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v['code'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    v['description'] ?? "No description provided",
                    style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text("Min Order: \$${v['minOrderValue']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black),
                onPressed: () => _showVoucherForm(voucher: v),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                onPressed: () => _showDeleteConfirm(v['_id']),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- FORM THÊM/SỬA ---
  void _showVoucherForm({dynamic voucher}) {
    final bool isEdit = voucher != null;
    final codeCtrl = TextEditingController(text: isEdit ? voucher['code'] : '');
    final descCtrl = TextEditingController(text: isEdit ? voucher['description'] : '');
    final valCtrl = TextEditingController(text: isEdit ? voucher['discountValue'].toString() : '');
    final minCtrl = TextEditingController(text: isEdit ? voucher['minOrderValue'].toString() : '');
    final dateCtrl = TextEditingController(text: isEdit ? (voucher['endDate'] != null ? voucher['endDate'].toString().substring(0, 10) : '2026-12-31') : '2026-12-31');
    String type = isEdit ? (voucher['discountType'] == 'percent' ? "Percentage" : "Fixed") : "Percentage";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(isEdit ? "EDIT VOUCHER" : "NEW VOUCHER", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UniqloInput(label: "Code", controller: codeCtrl),
                const SizedBox(height: 15),
                UniqloInput(label: "Description", controller: descCtrl),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: type, 
                  decoration: const InputDecoration(
                    labelText: "Discount Type",
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                  items: ["Percentage", "Fixed"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 15),
                UniqloInput(label: "Discount Value", controller: valCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 15),
                UniqloInput(label: "Min Order Value", controller: minCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 15),
                UniqloInput(label: "Expires At (YYYY-MM-DD)", controller: dateCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () async {
                if (codeCtrl.text.isEmpty || valCtrl.text.isEmpty) return;

                final data = {
                  "code": codeCtrl.text.toUpperCase(),
                  "description": descCtrl.text,
                  "discountType": type,
                  "discountValue": double.parse(valCtrl.text),
                  "minOrderValue": double.parse(minCtrl.text.isEmpty ? "0" : minCtrl.text),
                  "expiresAt": dateCtrl.text,
                  "isActive": true
                };

                bool ok = isEdit 
                    ? await _adminService.updateVoucher(voucher['_id'], data) 
                    : await _adminService.createVoucher(data);

                if (!context.mounted) return;
                if (ok) {
                  setState(() {});
                  Navigator.pop(ctx);
                }
              },
              child: Text(isEdit ? "UPDATE" : "CREATE"),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text("DELETE VOUCHER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        content: const Text("Are you sure you want to delete this voucher?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              bool ok = await _adminService.deleteVoucher(id);
              if (!context.mounted) return;
              if (ok) {
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}