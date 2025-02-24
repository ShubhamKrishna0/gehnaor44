class Login {
  String message;
  int status;
  String email;
  String token;
  String identity;
  int wholesalerId;

  Login({
    required this.message,
    required this.status,
    required this.email,
    required this.token,
    required this.identity,
    required this.wholesalerId,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      message: json['message'],
      status: json['status'],
      email: json['email'],
      token: json['token'],
      identity: json['identity'],
      wholesalerId: json['wholesalerId'],
    );
  }
}
