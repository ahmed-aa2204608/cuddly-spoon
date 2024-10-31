class Customer {
  String id;
  String companyName;
  Address address;
  ContactDetails contactDetails;

  Customer({
    required this.id,
    required this.companyName,
    required this.address,
    required this.contactDetails,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      companyName: json['companyName'],
      address: Address.fromJson(json['address']),
      contactDetails: ContactDetails.fromJson(json['contactDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'address': address.toJson(),
      'contactDetails': contactDetails.toJson(),
    };
  }
}

class Address {
  String street;
  String city;
  String country;

  Address({
    required this.street,
    required this.city,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'country': country,
    };
  }
}

class ContactDetails {
  String firstName;
  String lastName;
  String email;
  String mobile;

  ContactDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
    };
  }
}
