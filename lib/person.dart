class Person {
  int id;
  String nomeCompleto;
  String email;
  String telefone;
  String cep;
  int numero;

  Person(
      {this.id,
      this.nomeCompleto,
      this.email,
      this.telefone,
      this.cep,
      this.numero});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json["id"],
      nomeCompleto: json["nomeCompleto"],
      email: json["email"],
      telefone: json["telefone"],
      cep: json["cep"],
      numero: json["numero"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'numero': numero,
    };
  }
}
