
import 'package:flutter_bloc/flutter_bloc.dart';

import 'order_event.dart';
import 'order_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final String apiUrl = "https://674869495801f5153590c2a3.mockapi.io/api/v1/order";
 
  OrderBloc() : super(OrderInitialState()) {
    on<FetchOrdersEvent>(_onFetchOrders);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderEvent>(_onUpdateOrder);
    on<DeleteOrderEvent>(_onDeleteOrder);
  }
 
  void _onFetchOrders(FetchOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoadingState());
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final orders = json.decode(response.body);
        emit(OrderLoadedState(orders: orders));
      } else {
        emit(OrderErrorState(message: "Failed to fetch orders"));
      }
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
 
  void _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'name': event.name,
          'avatar': event.avatar,
          'email': event.email,
          'total_amount': event.totalAmount,
          'status': event.status,
          'date': event.date,
        }),
        headers: {'Content-Type': 'application/json'},
      );
 
      if (response.statusCode == 201) {
        add(FetchOrdersEvent());
      } else {
        emit(OrderErrorState(message: "Failed to create order"));
      }
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
 
  void _onUpdateOrder(UpdateOrderEvent event, Emitter<OrderState> emit) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${event.id}'),
        body: json.encode({
          'name': event.name,
          'avatar': event.avatar,
          'email': event.email,
          'total_amount': event.totalAmount,
          'status': event.status,
          'date': event.date,
        }),
        headers: {'Content-Type': 'application/json'},
      );
 
      if (response.statusCode == 200) {
        add(FetchOrdersEvent());
      } else {
        emit(OrderErrorState(message: "Failed to update order"));
      }
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
 
  void _onDeleteOrder(DeleteOrderEvent event, Emitter<OrderState> emit) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/${event.id}'));
      if (response.statusCode == 200) {
        add(FetchOrdersEvent());
      } else {
        emit(OrderErrorState(message: "Failed to delete order"));
      }
    } catch (e) {
      emit(OrderErrorState(message: e.toString()));
    }
  }
}