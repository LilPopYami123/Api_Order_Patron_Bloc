import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class ScreenOrder extends StatefulWidget {
  const ScreenOrder({super.key});

  @override
  State<ScreenOrder> createState() => _ScreenOrderState();
}

class _ScreenOrderState extends State<ScreenOrder> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _status = false;

  // Futuristic color palette
  static const Color _primaryColor = Color(0xFF0E1E2E);
  static const Color _accentColor = Color(0xFF1E96FC);
  static const Color _backgroundDark = Color(0xFF121B28);
  static const Color _textPrimary = Color(0xFFF0F4F8);
  static const Color _textSecondary = Color(0xFFA0AEC0);

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDark,
      appBar: AppBar(
        title: Text(
          'ORDER MANAGEMENT',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: _primaryColor,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                color: _accentColor,
              ),
            );
          } else if (state is OrderLoadedState) {
            return _buildOrderList(state.orders);
          } else if (state is OrderErrorState) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.red[300], fontSize: 18),
              ),
            );
          }
          return Center(
            child: Text(
              'NO DATA',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearForm();
          _showEditDialog(
            context,
            'ADD ORDER',
            onSubmit: () {
              context.read<OrderBloc>().add(CreateOrderEvent(
                    name: _nameController.text,
                    avatar: _avatarController.text,
                    email: _emailController.text,
                    totalAmount: int.tryParse(_totalAmountController.text) ?? 0,
                    status: _status,
                    date: int.tryParse(_dateController.text) ?? 0,
                  ));
              Navigator.pop(context);
            },
          );
        },
        backgroundColor: _accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    order['avatar'] ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: _textSecondary.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: _textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['name'] ?? 'UNNAMED',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailText('EMAIL', order['email'] ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildDetailText(
                          'TOTAL', '\$${order['total_amount'] ?? 0}'),
                      const SizedBox(height: 4),
                      _buildDetailText(
                          'DATE',
                          DateTime.fromMillisecondsSinceEpoch(
                                  order['date'] * 1000)
                              .toIso8601String()
                              .split('T')[0]),
                      const SizedBox(height: 4),
                      _buildStatusText(order['status']),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildIconButton(
                            icon: Icons.edit,
                            color: _accentColor,
                            onPressed: () {
                              _populateForm(order);
                              _showEditDialog(
                                context,
                                'EDIT ORDER',
                                onSubmit: () {
                                  context
                                      .read<OrderBloc>()
                                      .add(UpdateOrderEvent(
                                        id: order['id'],
                                        name: _nameController.text,
                                        avatar: _avatarController.text,
                                        email: _emailController.text,
                                        totalAmount: int.tryParse(
                                                _totalAmountController.text) ??
                                            0,
                                        status: _status,
                                        date: int.tryParse(
                                                _dateController.text) ??
                                            0,
                                      ));
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                          _buildIconButton(
                            icon: Icons.delete,
                            color: Colors.red[300]!,
                            onPressed: () {
                              context
                                  .read<OrderBloc>()
                                  .add(DeleteOrderEvent(id: order['id']));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method for consistent detail text styling
  Widget _buildDetailText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 16,
              color: _textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Styled status text
  Widget _buildStatusText(bool status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status
            ? Colors.green[900]!.withOpacity(0.3)
            : Colors.red[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'STATUS: ${status ? "COMPLETED" : "PENDING"}',
        style: TextStyle(
          fontSize: 14,
          color: status ? Colors.green[300] : Colors.red[300],
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // Futuristic icon button
  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _avatarController.clear();
    _emailController.clear();
    _totalAmountController.clear();
    _dateController.clear();
    _status = false;
  }

  void _populateForm(Map<String, dynamic> order) {
    _nameController.text = order['name'] ?? '';
    _avatarController.text = order['avatar'] ?? '';
    _emailController.text = order['email'] ?? '';
    _totalAmountController.text = (order['total_amount'] ?? '').toString();
    _dateController.text = (order['date'] ?? '').toString();
    _status = order['status'] ?? false;
  }

  void _showEditDialog(BuildContext context, String title,
      {required VoidCallback onSubmit}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildCustomTextField('Name', _nameController),
                const SizedBox(height: 10),
                _buildCustomTextField('Avatar URL', _avatarController),
                const SizedBox(height: 10),
                _buildCustomTextField('Email', _emailController),
                const SizedBox(height: 10),
                _buildCustomTextField('Total Amount', _totalAmountController),
                const SizedBox(height: 10),
                _buildCustomTextField('Date (Epoch)', _dateController),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 16,
                        color: _textSecondary,
                      ),
                    ),
                    Switch(
                      value: _status,
                      onChanged: (value) {
                        setState(() {
                          _status = value;
                        });
                      },
                      activeColor: _accentColor,
                      inactiveTrackColor: _textSecondary.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: _textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'SUBMIT',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: _textPrimary),
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        labelStyle: TextStyle(
          color: _textSecondary,
          letterSpacing: 1.2,
        ),
        filled: true,
        fillColor: _backgroundDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
      ),
    );
  }
}
