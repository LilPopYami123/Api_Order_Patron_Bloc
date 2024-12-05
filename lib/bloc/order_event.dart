abstract class OrderEvent {}
 
class FetchOrdersEvent extends OrderEvent {}
 
class CreateOrderEvent extends OrderEvent {
  final String name;
  final String avatar;
  final String email;
  final int totalAmount;
  final bool status;
  final int date;
 
  CreateOrderEvent({
    required this.name,
    required this.avatar,
    required this.email,
    required this.totalAmount,
    required this.status,
    required this.date,
  });
}
 
class UpdateOrderEvent extends OrderEvent {
  final String id;
  final String name;
  final String avatar;
  final String email;
  final int totalAmount;
  final bool status;
  final int date;
 
  UpdateOrderEvent({
    required this.id,
    required this.name,
    required this.avatar,
    required this.email,
    required this.totalAmount,
    required this.status,
    required this.date,
  });
}
 
class DeleteOrderEvent extends OrderEvent {
  final String id;
 
  DeleteOrderEvent({required this.id});
}