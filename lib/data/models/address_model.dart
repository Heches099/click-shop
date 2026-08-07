import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
abstract class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    required String name,
    required String phone,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    @Default(false) bool isDefault,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  factory AddressModel.fromEntity(Address address) => AddressModel(
        id: address.id,
        name: address.name,
        phone: address.phone,
        street: address.street,
        city: address.city,
        state: address.state,
        zipCode: address.zipCode,
        country: address.country,
        isDefault: address.isDefault,
      );
}

extension AddressModelX on AddressModel {
  Address toEntity() => Address(
        id: id,
        name: name,
        phone: phone,
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        country: country,
        isDefault: isDefault,
      );
}
